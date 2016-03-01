if [ -f _build/sanitize.sh ]; then
    echo "Sanitize script found, running"
    _build/sanitize.sh
fi
echo "Cleaning"
make clean
echo "Building client"
make client
echo "Configuring unikernel"
env FS=crunch mirage configure --xen --dhcp=true --no-argv
echo "Building unikernel"
make
