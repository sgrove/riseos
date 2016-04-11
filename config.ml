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
            ~doc:"Show error and backtrace on site error (useful for dev/staging)." ["show_errors"]
  in
  Key.create "show_errors" Key.Arg.(opt bool true i)

let report_errors =
  let i = Key.Arg.info
            ~doc:"Report error and backtrace on site error (useful for prod)." ["report_errors"]
  in
  Key.create "report_errors" Key.Arg.(opt bool false i)

let error_report_emails =
  let i = Key.Arg.info
            ~doc:"Comma-separated list of emails to report to when error occurs (useful for prod)." ["error_report_emails"]
  in
  Key.create "error_report_emails" Key.Arg.(opt string "" i)

let mailgun_api_key =
  let i = Key.Arg.info
            ~doc:"Mailgun API key (from https://mailgun.com/app/account/settings)" ["mailgun_api_key"]
  in
  Key.create "mailgun_api_key" Key.Arg.(opt string "missing" i)


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
  let packages = [ "sequence" ; "containers" ; "tyxml" ; "omd" ; "lambdasoup" ; "menhir" ; "core" ; "magic-mime" ; "opium" ; "aws" ;  "base64" ] in
  register "riseos"
    ~libraries
    ~packages
    ~keys:[
      Key.abstract http_port ;
      Key.abstract https_port ;
      Key.abstract bootvar_use_headers ;
      Key.abstract mailgun_api_key ;
      Key.abstract report_errors ;
      Key.abstract show_errors ;
      Key.abstract error_report_emails ;
    ]
    [ server $ default_console $ default_clock $ data $ keys $ my_https ]
