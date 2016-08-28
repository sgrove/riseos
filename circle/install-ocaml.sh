set -x
# set -e

if [ ! -e /home/ubuntu/bin/opam ]; then
    sudo apt-get update
    sudo apt-get install aspcud
    # This will simply check your architecture, download and install the proper pre-compiled binary and run opam init.
    export PATH=$PATH:/home/ubuntu/bin/
    export BINDIR=/home/ubuntu/bin/
    env BINDIR=/home/ubuntu/bin wget https://raw.github.com/ocaml/opam/master/shell/opam_installer.sh -O - | sh -s /usr/local/bin

    opam switch --alias-of 4.03.0 riseos
    opam switch riseos
    eval `opam config env`
    opam repo add mirage-dev git://github.com/mirage/mirage-dev
    opam install depext
    opam depext -i -y mirage
    opam update -y
    opam upgrade -y
    echo "Install camlp4"
    opam install -y camlp4
    opam install -y tls
    opam install -y mirage
    opam install -y mirage sequence containers tyxml cohttp cstruct tls mirage-http lwt omd lambdasoup js_of_ocaml eliom menhir yojson ppx_deriving_yojson magic-mime syndic ptime
    # opam pin add -y mirage https://github.com/mirage/mirage.git#9be9b6160842d8f25a4c763fb6b6a0d8a4362631
    opam pin remove -y mirage
    opam pin add -y mirage-entropy-solo5 https://github.com/mirage/mirage-entropy.git
    # opam switch import -y /home/ubuntu/riseos/opam/riseos.opam.snapshot
fi


