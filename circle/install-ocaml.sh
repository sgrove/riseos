set -x
set -e

if [ ! -e opam ]; then
    # This will simply check your architecture, download and install the proper pre-compiled binary and run opam init.
    wget https://raw.github.com/ocaml/opam/master/shell/opam_installer.sh -O - | sh -s /usr/local/bin

    opam switch -A 4.02.3 riseos
    opam switch import opam/riseos.opam.snapshot
fi
