mirage configure -t virtio --dhcp=true --show_errors=false --report_errors=true --mailgun_api_key="${MAILGUN_API_KEY}" --error_report_emails="${ERROR_REPORT_EMAIL}"
make clean
make
bin/unikernel-mkimage.sh tmp/disk.raw mir-riseos.virtio
cd tmp/
tar -czvf mir-riseos-${RISEOS_BUILD_NUM}.tar.gz disk.raw
cd ..
