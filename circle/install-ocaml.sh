set -x
set -e

if [ ! -e /home/ubuntu/bin/opam ]; then
    sudo apt-get update
    sudo apt-get install aspcud
    # This will simply check your architecture, download and install the proper pre-compiled binary and run opam init.
    export PATH=$PATH:/home/ubuntu/bin/
    export BINDIR=/home/ubuntu/bin
    wget https://raw.github.com/ocaml/opam/master/shell/opam_installer.sh -O - | sh -s /usr/local/bin

    opam switch -A 4.02.3 riseos
    opam remote add mirage-dev https://github.com/mirage/mirage-dev.git
    opam pin add mirage https://github.com/mirage/mirage.git#9be9b6160842d8f25a4c763fb6b6a0d8a4362631
    opam pin add -y mirage-entropy-solo5 https://github.com/mirage/mirage-entropy.git
    # opam switch import -y /home/ubuntu/riseos/opam/riseos.opam.snapshot
fi
