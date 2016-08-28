set -x
set -e
if [ ! -e syslinux-6.03/syslinux ]; then
    wget https://www.kernel.org/pub/linux/utils/boot/syslinux/6.xx/syslinux-6.03.tar.gz
    tar -xzvf syslinux-6.03.tar.gz
    cd syslinux-6.03
    make;
fi
