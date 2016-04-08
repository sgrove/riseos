open Mirage

(** Custom bootvars *)

(** Default ports *)
let http_port =
  let i = Key.Arg.info
            ~doc:"Http port." ["http_port"]
  in
  Key.create "http_port" Key.Arg.(opt int 80 i)

let https_port =
  let i = Key.Arg.info
            ~doc:"Https port." ["https_port"]
  in
  Key.create "https_port" Key.Arg.(opt int 443 i)

let show_errors =
  let i = Key.Arg.info
            ~doc:"Show error and backtrace on site error." ["show_errors"]
  in
  Key.create "show_errors" Key.Arg.(opt bool true i)

(** Consider headers *)
let bootvar_use_headers =
  let i = Key.Arg.info
      ~doc:"Use headers to determine the language of the website visitor."
      ["use-header"]
  in
  Key.create "use_headers" Key.Arg.(opt bool true i)

(* Network configuration *)

let stack = generic_stackv4 default_console tap0

(* storage configuration *)

let data = direct_kv_ro "./static"
let keys = direct_kv_ro "./secrets"

(* Dependencies *)

let server =
  foreign "Site_dispatch.Make"
    (console @-> clock @-> kv_ro @-> kv_ro @-> http @-> job)

let my_https =
  http_server @@ conduit_direct ~tls:true stack

let () =
  let libraries = [ "sequence" ; "containers" ; "tyxml" ; "omd" ; "lambdasoup" ; "magic-mime" ; "opium" ; "aws" ; "webmachine" ; "ptime" ; "syndic" ] in
  let packages = [ "sequence" ; "containers" ; "tyxml" ; "omd" ; "lambdasoup" ; "menhir" ; "core" ; "magic-mime" ; "opium" ; "aws" ;  ] in
  register "riseos"
    ~libraries
    ~packages
    ~keys:[
      Key.abstract http_port ;
      Key.abstract https_port ;
      Key.abstract bootvar_use_headers ;
      Key.abstract show_errors ;
    ]
    [ server $ default_console $ default_clock $ data $ keys $ my_https ]
