The OCaml web-situation is barren. Really barren.

I'm not sure if it's because the powers-that-be in the OCaml world are simply uninterested in the domain, or if it's looked down upon as "not-real development" by established/current OCaml devs, but it's a pretty dire situation. There's some movement in the right direction between [Opium](https://github.com/rgrinberg/opium) and [Ocaml WebMachine](https://github.com/inhabitedtype/ocaml-webmachine), but both are 1.) extremely raw and 2.) pretty much completely incompatible. There's no middleware standard (Rack, Connect, or the one I'm most familiar with, Ring), so it's not easy to layer in orthogonal-but-important pieces like session-management, authentication, authorization, logging, and - relevant for today's post - error reporting.

I've worked over the past few years on ever-increasingly useful error reporting, in part because it was *so terrible* before, especially compared to error reports from the server-side. A few years ago, you probably wouldn't even know if your users had an error. If you worked hard, you'd get a rollbar notification that "main.js:0:0: undefined is not a function". How do you repro this case? What did the user do? What path through a (for a human) virtually unbounded state-space lead to this error? Well friend, get ready to play computer in your head, because you're on your own. I wanted to make it better, and so I worked on it in various ways, include improved source-map support in the language I was using at the time (ClojureScript), user session replay in development, predictive testing, automated repro cases, etc., until it was so nice that getting server-side errors was a terrible drag because it didn't have any of the pleasantries that I had come to be used to on the frontend.

Fast forward to this week in OCaml, when I was poking around my site, and hit a "Not found" error. The url was correct, I had just previously a top-level error handler in my Mirage code return "Not found" on any error, because I was very new to OCaml in general and that seemed to work to the extend I needed that day. But today I wanted to know what was going on - why did this happen? Googling a bit for "reporting OCaml errors in production" brought back that familiar frustration of working in an environment where devs just care (let's assume they're capable). Not much for the web, to say the least.

So I figured I would cobble together a quick solution. I didn't want to pull in an SMTP library (finding that 1. the [namespacing in OCaml is *fucking crazy*](https://github.com/inhabitedtype/ocaml-dispatch/issues/16) and 2. some OPAM packages don't work with Mirage only when compiling for a non-Unix backend after developing a full feature has led me to be very cautious about any dependency) - but no worries, the ever-excellent [Mailgun](https://mailgun.com) offers a great service to send emails via HTTP POSTs. Sadly, Cohttp [can't handle multipart (e.g. form) posts](https://github.com/mirage/ocaml-cohttp/issues/181) (another sign of the weakness of OCaml's infrastructure compared to the excellent [clj-http](https://github.com/dakrone/clj-http)), so I had to do that on my own. I ended up copying the curl examples from Mailgun's, but directing the url to an http requestbin, so I could see exactly what the post looked like. Then, it was just matter of building up the examples in a utop with Cohttp bit by bit until I was able to match the *exact* data sent over by the curl example. From there, the last bit was to generate a random boundary to make sure there would never be a collision between form values. It's been awhile since I had to work at that level (I *definitely* prefer to just focus on my app and not constantly be sucked down into implementing this kind of thing), but luckily it still proved possible, if unpleasant. Here's the full module in all its glory currently:

```ocaml
(* Renamed from http://www.codecodex.com/wiki/Generate_a_random_password_or_random_string#OCaml *)
let gen_boundary length =
    let gen() = match Random.int(26+26+10) with
        n when n < 26 -> int_of_char 'a' + n
      | n when n < 26 + 26 -> int_of_char 'A' + n - 26
      | n -> int_of_char '0' + n - 26 - 26 in
    let gen _ = String.make 1 (char_of_int(gen())) in
    String.concat "" (Array.to_list (Array.init length gen))

let send ~domain ~api_key params =
  let authorization = "Basic " ^ (B64.encode ("api:" ^ api_key)) in
  let _boundary = gen_boundary 24 in 
  let header_boundary = "------------------------" ^ _boundary in
  let boundary = "--------------------------" ^ _boundary in
  let content_type = "multipart/form-data; boundary=" ^ header_boundary in
  let form_value = List.fold_left (fun run (key, value) ->
      run ^ (Printf.sprintf "%s\r\nContent-Disposition: form-data; name=\"%s\"\r\n\r\n%s\r\n" boundary key value)) "" params in
  let headers = Cohttp.Header.of_list [
      ("Content-Type", content_type);
      ("Authorization", authorization)
    ] in
  let uri = (Printf.sprintf "https://api.mailgun.net/v3/%s/messages" domain) in
  let body = Cohttp_lwt_body.of_string (Printf.sprintf "%s\r\n%s--" form_value boundary) in
  Cohttp_mirage.Client.post ~headers ~body (Uri.of_string uri)
```

Perhaps I should expand it a bit so that it could become an OPAM package?
    
From there, I changed the error-handler for the site dispatcher to catch the error and send me the top level message. A bit more work, and I had a stack trace. It still wasn't *quite* right though, because to debug an error like this, you often need to know the context. With some help from [@das_cube](https://twitter.com/das_cube), I was able to serialize the request, with info like the headers, URI, etc. and send it along with the error report. The final step was to use [@Drup](https://github.com/Drup)'s [bootvar work](https://github.com/mirage/mirage-bootvar-xen) (or is it Functoria? I'm not sure what the line is here) to make all of the keys configurable, so that I only send emails in production, and to a comma-separated list of email supplied either at compile- or boot-time:


```ocaml
let report_error exn request =
  let error = Printexc.to_string exn in
  let trace = Printexc.get_backtrace () in
  let body = String.concat "\n" [error; trace] in
  let req_text = Format.asprintf "%a@." Cohttp.Request.pp_hum request in
  ignore(
    let emails = Str.split (Str.regexp ",") (Key_gen.error_report_emails ())
                 |> List.map (fun email -> ("to", email)) in
    let params = List.append emails [
        ("from", "RiseOS (OCaml) <errors@riseos.com>");
        ("subject", (Printf.sprintf "[%s] Exception: %s" site_title error));
        ("text", (Printf.sprintf "%s\n\nRequest:\n\n%s" body req_text))
      ]
    in
    (* TODO: Figure out how to capture context (via
       middleware?) and send as context with error email *)
    ignore(Mailgun.send ~domain:"riseos.com" ~api_key:(Key_gen.mailgun_api_key ()) params))

let dispatcher fs c request uri =
  let open Lwt.Infix in
  Lwt.catch
    (fun () ->
       let (lwt_body, content_type) = get_content c fs request uri in
       lwt_body >>= fun body ->
       S.respond_string ~status:`OK ~headers: (Cohttp.Header.of_list [("Content-Type", content_type)]) ~body ())
    (fun exn ->
       let status = `Internal_server_error in
       let error = Printexc.to_string exn in
       let trace = Printexc.get_backtrace () in
       let body = String.concat "\n" [error; trace] in
       ignore(match (Key_gen.report_errors ()) with
           | true -> report_error exn request
           | false -> ());
       match (Key_gen.show_errors ()) with
       | true -> S.respond_error ~status ~body ()
       (* If we're not showing a stacktrace, then show a nice html
          page *)
       | false -> read_fs fs "error.html" >>=
         fun body ->
         S.respond_string
           ~headers:(Cohttp.Header.of_list [("Content-Type", Magic_mime.lookup "error.html")])
           ~status
           ~body ())
```
It's still not anywhere near what you get for free in Rails, Clojure, etc. - and *definitely* not close to session-replay, predictive testing, etc. - but it's a huge step up from before!

An example error email, in all its glory:


![](/images/posts/riseos_error_email.png)

