_build/sanitize.sh
make clean
env FS=crunh mirage configure --xen --dhcp=true --no-argv
make
./rebuild_js.sh
