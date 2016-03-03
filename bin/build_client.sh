#!/usr/bin/env bash
echo "Rebuilding bytecode"
ocamlfind ocamlc -g -package js_of_ocaml -package js_of_ocaml.syntax -package js_of_ocaml.ppx -linkpkg -o client.byte client.ml
echo "Outputting js"
js_of_ocaml --source-map --pretty --no-inline --debug-info -o static/js/client.js client.byte
echo "Done"
