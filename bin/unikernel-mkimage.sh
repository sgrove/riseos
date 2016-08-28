#!/bin/sh
#
# unikernel-mkimage: Builds an MBR-partitioned disk image with SYSLINUX and a
# unikernel on it. The image file is sparse, sized to 1GB (or modify $SIZE
# below).
#
# Requirements: A Linux system with sfdisk, mtools and syslinux installed.
# Path names for syslinux library files are based on those for Debian, YMMV.
#
# To boot the resulting image in QEMU, use:
#
# $ qemu-system-x86_64 -vga none -nographic -drive file=IMAGE ...
#
die ()
{
    echo unikernel-mkimage: error: "$@" 1>&2
    if [ -n "${TMPDIR}" -a -f "${TMPDIR}"/log ]; then
        echo For more information, see ${TMPDIR}/log
        PRESERVE_TMPDIR=1
    fi
    exit 1
}

nuketmpdir ()
{
    [ -n "${PRESERVE_TMPDIR}" ] && return
    [ -z "${TMPDIR}" ] && return
    [ ! -d "${TMPDIR}" ] && return
    rm -rf ${TMPDIR}
}

if [ $# -lt 2 ]; then
    echo "usage: unikernel-mkimage IMAGE UNIKERNEL [ ARGS ... ]" 1>&2
    exit 1
fi

IMAGE=$(readlink -f $1)
shift
SIZE=1G
UNIKERNEL=$(readlink -f $1)
shift
[ ! -f ${UNIKERNEL} ] && die "not found: ${UNIKERNEL}"
trap nuketmpdir 0 INT TERM
TMPDIR=$(mktemp -d)
if [ $? -ne 0 ]; then
    echo "error creating temporary directory" 1>&2
    exit 1
fi

LOG=${TMPDIR}/log
# Write SYSLINUX MBR to image and extend to desired size (sparse)
cp ~/syslinux/bios/mbr/mbr.bin ${TMPDIR}/image.mbr || die "could not copy mbr"
truncate -s ${SIZE} ${TMPDIR}/image.mbr
# Create DOS (FAT32) primary partition
echo ",,0xc,*" | sfdisk -D ${TMPDIR}/image.mbr >${LOG} 2>&1 || die "sfdisk failed"
# Start offset of partition (sectors)
O_SECTORS=$(sfdisk -d ${TMPDIR}/image.mbr | awk -- '/Id= c/{print $4}' | sed -e s/,//)
# Size of partition (sectors)
S_SECTORS=$(sfdisk -d ${TMPDIR}/image.mbr | awk -- '/Id= c/{print $6}' | sed -e s/,//)
# Start offset of partition (bytes)
O_BYTES=$(expr ${O_SECTORS} \* 512)
# Size of partition (1k blocks, which mkdosfs expects)
S_BLOCKS=$(expr ${S_SECTORS} / 2)
# Extract partition from image
dd if=${TMPDIR}/image.mbr of=${TMPDIR}/image.dos bs=512 skip=${O_SECTORS} conv=sparse 2>/dev/null || die "dd failed"
# Truncate image.mbr to contain only the MBR + padding before partition start
truncate -s ${O_BYTES} ${TMPDIR}/image.mbr

# Create FAT32 filesystem, install SYSLINUX
mkfs.msdos -F 32 ${TMPDIR}/image.dos ${S_BLOCKS} >${LOG} 2>&1 || die "mkfs failed"
syslinux --install ${TMPDIR}/image.dos
cat <<EOM >syslinux.cfg
SERIAL 0 115200
DEFAULT unikernel
LABEL unikernel
  KERNEL mboot.c32
  APPEND unikernel.bin $@
EOM
# Ugh, mtools complains about filesystem size not being a multiple of
# what it thinks the sectors-per-track are, ignore.
echo mtools_skip_check=1 > mtoolsrc
export MTOOLSRC=./mtoolsrc
# Populate filesystem
mcopy -i ${TMPDIR}/image.dos syslinux.cfg ::syslinux.cfg || die "1 copy failed"
mcopy -i ${TMPDIR}/image.dos ~/syslinux/bios/com32/lib/libcom32.c32 ::libcom32.c32 || die "2 copy failed"
mcopy -i ${TMPDIR}/image.dos ~/syslinux/bios/com32/mboot/mboot.c32 ::mboot.c32 || die "3 copy failed"
mcopy -i ${TMPDIR}/image.dos ${UNIKERNEL} ::unikernel.bin || die "4 copy failed"

# Construct final image (MBR + padding + filesystem)
cat ${TMPDIR}/image.mbr ${TMPDIR}/image.dos | dd of=${IMAGE} conv=sparse 2>/dev/null || die "dd failed"

nuketmpdir
