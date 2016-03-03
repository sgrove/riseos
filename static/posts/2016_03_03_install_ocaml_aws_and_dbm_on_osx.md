I'm toying with the idea of rewriting the [deploy script](https://github.com/sgrove/riseos/blob/master/bin/ec2_deploy.sh) I cribbed from [@yomimono](https://github.com/yomimono) for this blog from bash to OCaml (there are some features I'd like to make more robust to the full deploy is automated and resources are cleaned up), and came across the OCaml [AWS library](https://github.com/inhabitedtype/ocaml-aws). Unfortunately, installing it was a bit frustrating on OSX, I kept hitting:

`NDBM not found, the "camldbm" library cannot be built.`

After a bit of googling around, it was fairly simple: Simple install the `Command Line Tools`, and you should have the right header-files/etc. so that `opam install aws` or `opam install dbm` should work. Hope that helps someone who runs into a similar problem!

Happy hacking!

