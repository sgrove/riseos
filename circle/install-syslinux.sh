set -x
set -e
if [ ! -e /home/ubuntu/bin/syslinux ]; then
    sudo apt-get update
    sudo apt-get install nasm
    cd ~/
    wget https://www.kernel.org/pub/linux/utils/boot/syslinux/6.xx/syslinux-6.03.tar.gz
    tar -xzvf syslinux-6.03.tar.gz
    cd syslinux-6.03
    make
    sudo make install
    mkdir /home/ubuntu/syslinux
    cp /usr/bin/syslinux /home/ubuntu/bin/
fi
