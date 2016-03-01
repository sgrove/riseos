if [ -f _build/sanitize.sh ]; then
    echo "Sanitize script found, running"
    _build/sanitize.sh
fi
echo "Cleaning"
make clean
echo "First make"
make
echo "Building client"
make client
echo "Configuring unikernel"
env FS=crunch mirage configure --xen --dhcp=true --no-argv --http_port=80 --https_port=443
echo "Building unikernel via final make"
make
