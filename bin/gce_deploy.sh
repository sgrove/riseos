set -e

# bin/gce_deploy.sh mir-riseos-34 mir-riseos mirage-solo5-test

NAME=$1
CANONICAL=$2
GCS_FOLDER=$3

# mirage configure -t virtio --dhcp=true --net=direct --network=tap0
# make clean
# make
# bin/unikernel-mkimage.sh tmp/disk.raw mir-riseos.virtio
# cd tmp/
# tar -czvf ${NAME}.tar.gz disk.raw
# cd ..

# Upload the file to Google Compute Storage as the original filename

gsutil cp ./${NAME}.tar.gz  gs://${GCS_FOLDER}
# Copy/Alias it as *-latest
gsutil cp gs://${GCS_FOLDER}/${NAME}.tar.gz  gs://${GCS_FOLDER}/${CANONICAL}-latest.tar.gz

# Delete the image if it exists
y | gcloud compute images delete ${CANONICAL}-latest

# Create an image from the new latest file
gcloud compute images create ${CANONICAL}-latest --source-uri  gs://${GCS_FOLDER}/${CANONICAL}-latest.tar.gz

# Updating the ${CANONICAL}-latest *image* in place will mutate the
# *instance-template* that points to it.  To then update all of our
# instances with zero downtime, we now just have to ask gcloud to do a
# rolling update to a group using said *instance-template*.
gcloud alpha compute rolling-updates start --group ${CANONICAL}-group --template ${CANONICAL}-1 --zone us-west1-a


# bin/gce_deploy.sh mir-riseos-34 mir
