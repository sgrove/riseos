Bushi.do
===

This is the repo for Sean Grove's personal site, http://bushi.do/.

It also serves as a (currently very messy) example of a site built in OCaml, using the the Mirage libraries, and deployed as a unikernel.

TODO
====

 1. The liquid parser is a total hack right now, and needs 1.) to be improved to support the full liquid spec and 2.) Split off into its own library for others to use.
 1. The code needs to be extracted into a single, turn-key dev and deploy solution, with a `three steps to your first unikernel in production` guide:
    1. git clone the repo
    1. Edit to add your credentials
    1. Run the (simple) deploy script

Credit
======

* The code was originally a fork of, and is still *hugely* based off of, Drup's [No.](https://github.com/Drup/No.) repo.

COPYRIGHT
=========

All images and blog materials are copyright Sean Grove 2016. 
