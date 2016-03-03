 #!/bin/bash

#set -e
#set -x

fail() {
	echo $1
	[ -e ${EBS_DEVICE} ] && [ "$VOLUME_ID" != "" ] && [ $REGION != "" ] && {
		ec2-detach-volume --region $REGION $VOLUME_ID
		ec2-delete-volume --region $REGION $VOLUME_ID
	}
	exit 1
}

if [ ! -e "$1" ]; then
  echo Usage: $0 kernel.xen
  echo This script will create an EBS-backed AMI and launch a t1.micro instance for the Xen kernel you pass as the first argument.
  echo This script is meant to be run on an EC2 instance, and will fail if run elsewhere.
  echo Remember to set each of EC2_ACCESS, EC2_ACCESS_SECRET, EC2_CERT, EC2_USER
  exit 1
fi

[ "$NAME" = "" ] && NAME=mirage-`date -u +%s`

[ "$INSTANCE_ID" = "" ] && INSTANCE_ID="i-84030304"

# these work but are quite slow;
# the user would do well to set these values as environment variables
[ "$REGION" = "" ] && REGION=us-east-1 #TODO: autodiscover the instance's region
[ "$EBS_DEVICE" = "" ] && EBS_DEVICE="/dev/xvdh"
[ "$HOST_INSTANCE_ID" = "" ] && HOST_INSTANCE_ID=`ec2-describe-instances --aws-access-key ${EC2_ACCESS} --aws-secret-key ${EC2_ACCESS_SECRET} --region $REGION -F tag:role=host|grep ^INSTANCE|cut -f2`
[ "$ZONE" = "" ] && ZONE=`ec2-describe-instances --aws-access-key ${EC2_ACCESS} --aws-secret-key ${EC2_ACCESS_SECRET} -F instance-id=${INSTANCE_ID} --region $REGION |cut -f12|grep -v "^$"`

EXTANT_IMAGE=`ec2-describe-images --aws-access-key ${EC2_ACCESS} --aws-secret-key ${EC2_ACCESS_SECRET} -o self --filter name="$NAME" --filter architecture=x86_64 --region $REGION --hide-tags|grep "^IMAGE"|cut -f2`
if [ "$EXTANT_IMAGE" ]; then
	echo "An image already exists with the name $NAME".  ec2-bundle-create will fail.
	echo "To delete the extant image, try this:"
	fail "ec2-deregister --region $REGION $EXTANT_IMAGE"
fi

if [ -e $EBS_DEVICE ]; then
	fail "There is already a device present at $EBS_DEVICE.  Please change the device ID or detach the device."
fi

#make an EBS volume of small size
VOLUME_ID=`ec2-create-volume --aws-access-key ${EC2_ACCESS} --aws-secret-key ${EC2_ACCESS_SECRET} --size 1 --region ${REGION} -z ${ZONE}|cut -f2`
if [ "$VOLUME_ID" = "" ]; then
	fail "Failed to create an EBS volume."
fi
echo "Sleep for 10 seconds"; sleep 10
#attach it to ourselves
ec2-attach-volume --aws-access-key ${EC2_ACCESS} --aws-secret-key ${EC2_ACCESS_SECRET} $VOLUME_ID -i $HOST_INSTANCE_ID -d $EBS_DEVICE --region $REGION
[ $? -ne 0 ] && {
	fail "Couldn't attach the EBS volume to this instance."
}

[ ! -e ${EBS_DEVICE} ] && sleep 2
[ ! -e ${EBS_DEVICE} ] && sleep 2
[ ! -e ${EBS_DEVICE} ] && sleep 2

# KERNEL is ec2-describe-images -o amazon --region ${REGION} -F "manifest-location=*pv-grub-hd0*" -F "architecture=x86_64" | tail -1 | cut -f2
KERNEL_ID=`ec2-describe-images --aws-access-key ${EC2_ACCESS} --aws-secret-key ${EC2_ACCESS_SECRET} -o amazon --region ${REGION} -F "manifest-location=*pv-grub-hd0*" -F "architecture=x86_64" | tail -1 | cut -f2`
IMG=${NAME}.img
MNT=/mnt
SUDO=sudo

${SUDO} mkfs.ext2 $EBS_DEVICE

#${SUDO} mkdir -p /mnt/mirage
#rm -f ${IMG}
#dd if=/dev/zero of=${IMG} bs=1M count=20
#${SUDO} mke2fs -F -j ${IMG}
#${SUDO} mount -o loop ${IMG} ${MNT}
${SUDO} mount -t ext2 ${EBS_DEVICE} $MNT

${SUDO} mkdir -p ${MNT}/boot/grub
echo default 0 > menu.lst
echo timeout 1 >> menu.lst
echo title Mirage >> menu.lst
echo " root (hd0)" >> menu.lst
echo " kernel /boot/mirage-os.gz" >> menu.lst
${SUDO} mv menu.lst ${MNT}/boot/grub/menu.lst

${SUDO} sh -c "gzip -c $1 > ${MNT}/boot/mirage-os.gz"
${SUDO} umount -d ${MNT}

SNAPSHOT_ID=`ec2-create-snapshot --aws-access-key ${EC2_ACCESS} --aws-secret-key ${EC2_ACCESS_SECRET} --region $REGION $VOLUME_ID|cut -f2`
[ "$SNAPSHOT_ID" = "" ] && fail "Couldn't make a snapshot of the EBS volume."
read -n1 -r -p "Press space to continue when snapshot is ready..." key
AMI_ID=`ec2-register --aws-access-key ${EC2_ACCESS} --aws-secret-key ${EC2_ACCESS_SECRET} -n $NAME --snapshot $SNAPSHOT_ID --kernel $KERNEL_ID --region $REGION --architecture x86_64|cut -f2`

[ "$AMI_ID" = "" ] && {
	echo "Sleeping for 15 seconds, Retrying snapshot..."
	sleep 15
	AMI_ID=`ec2-register --aws-access-key ${EC2_ACCESS} --aws-secret-key ${EC2_ACCESS_SECRET} -n $NAME --snapshot $SNAPSHOT_ID --kernel $KERNEL_ID --region $REGION --architecture x86_64|cut -f2`
}


[ "$AMI_ID" = "" ] && fail "Couldn't make an AMI from the snapshot $SNAPSHOT_ID and the kernel ID $KERNEL_ID ."

#now make an instance running that.
#TODO: should be able to specify security group here.
INSTANCE_ID=`ec2-run-instances --aws-access-key ${EC2_ACCESS} --aws-secret-key ${EC2_ACCESS_SECRET} $AMI_ID  -t t1.micro --region ${REGION}|grep ^INSTANCE|cut -f2`

[ "$INSTANCE_ID" = "" ] && fail "Couldn't start an instance with AMI ID $AMI_ID ."

echo "Successfully made an instance; it should be online soon."
echo "To keep an eye on it:"
echo "ec2-get-console-output --region $REGION $INSTANCE_ID"

# TODO: Fix below. Doesn't work properly because these resources will still be in use.
ec2-detach-volume --aws-access-key ${EC2_ACCESS} --aws-secret-key ${EC2_ACCESS_SECRET} --region $REGION $VOLUME_ID
ec2-delete-snapshot --aws-access-key ${EC2_ACCESS} --aws-secret-key ${EC2_ACCESS_SECRET} --region $REGION $SNAPSHOT_ID
ec2-delete-volume --aws-access-key ${EC2_ACCESS} --aws-secret-key ${EC2_ACCESS_SECRET} --region $REGION $VOLUME_ID
