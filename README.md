[RiseOS](https://www.riseos.com)
===

This is the repo for Sean Grove's personal site, [https://www.riseos.com/](https://www.riseos.com/).

It also serves as a (currently very messy) example of a site built in OCaml, using the the Mirage libraries, and deployed as a unikernel.

Instructions
====

Make sure you have [opam](https://opam.ocaml.org/doc/Install.html#Usingyourdistribution39spackagesystem) installed, and that you're using at least OCaml `4.02.3` (simple as `opam switch 4.02.3`).

To auto-rebuild the javascript on osx, install [fswatch](https://github.com/emcrisostomo/fswatch) and run `fswatch -o client.ml | xargs -n1 -I{} ./rebuild_js.sh` in a terminal. It works pretty well, though there can be random delays in the rebuild for some reason.

Relevant Mirage Issues
========
These mirage issues affect this repo, the sooner they're closed the better (keeping track for myself so I can unpin packages):

 * [Functoria: need a way to disable Bootvar](https://github.com/mirage/mirage/issues/493)
 * [Missing `strtod`](https://github.com/mirage/mirage-platform/issues/118)
 * [No way to specify package versions/pins in config.ml](https://github.com/mirage/mirage/issues/499)

TODO
====

 1. The liquid parser is a total hack right now, and needs 1.) to be improved to support the full liquid spec and 2.) Split off into its own library for others to use.
 1. The code needs to be extracted into a single, turn-key dev and deploy solution, with a `three steps to your first unikernel in production` guide:
    1. git clone the repo
    1. Edit to add your credentials
    1. Run the (simple) deploy script
 1. Add instructions and examples section

Credit
======

* The code was originally a fork of, and is still *hugely* based off of, Drup's [No.](https://github.com/Drup/No.) repo.

COPYRIGHT
=========

All images and blog materials are copyright Sean Grove 2016. 
