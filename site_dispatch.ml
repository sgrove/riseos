type author = {
  name: string;
  email: string;
}

type post = {
  title: string;
  file: string;
  author: author;
  permalink: string;
  page_title: string;
}

exception File_not_found

let html_mime =
  Magic_mime.lookup "index.html"

let rec sublist b e l =
  if e = 0 then [] else
  match l with
    [] -> failwith "sublist"
  | h :: t ->
    let tail = if e = 0 then [] else sublist (b - 1) (e - 1) t in
    if b > 0 then tail else h :: tail

let rec sub_omd(src_list : Omd.t) dest_list (count_remaining : int ref) =
  if !count_remaining <= 0 then
    dest_list
  else
    match src_list with
    | [] -> dest_list
    | next_element :: next_src ->
      match next_element with
      | Omd.Paragraph x -> let next_dest = (List.append dest_list [Omd.Paragraph (sub_omd x [] count_remaining)]) in
        sub_omd next_src next_dest count_remaining
      (* Don't count blank strings as tokens *)
      | Omd.Text x when x = "" -> let next_dest = List.append dest_list [Omd.Text x] in
        sub_omd next_src next_dest count_remaining
      | Omd.Text x ->
        let all_words = Str.split (Str.regexp " ") x in
        let allowed_words = if (List.length all_words) > 0 then
            (sublist 0 (max 0 (min (List.length all_words) !count_remaining)) all_words)
          else
            []
        in
        let words = String.concat " " allowed_words in
        let next_dest = List.append dest_list [Omd.Text (" " ^ words ^ " ")] in
        count_remaining := !count_remaining - (List.length allowed_words);
        sub_omd next_src next_dest count_remaining
      | _ -> decr count_remaining; sub_omd next_src (List.append dest_list [next_element]) count_remaining

let site_url =
  "https://www.riseos.com"

let site_title =
  "RiseOS"

let site_description =
  "Personal blog of Sean Grove, going over tech, travel, and various personal musings."

let sean_grove =
  {
    name = "Sean Grove";
    email = "sean@bushi.do";
  }

let posts =
  [{ title = "First post"
   ; file = "posts/2016_02_06_first_post.md"
   ; author = sean_grove
   ; permalink = "/posts/2016_02_06_first_post"
   ; page_title = "First post"}
  ;{ title = "Mirage questions"
   ; file = "posts/2016_02_20_mirage_questions.md"
   ; author = sean_grove
   ; permalink = "/posts/2016_02_20_mirage_questions"
   ; page_title = "Mirage Questions"}
  ;{ title = "RiseOS TODOs"
   ; file = "posts/2016_02_27_riseos_todos.md"
   ; author = sean_grove
   ; permalink = "/posts/2016_02_27_riseos_todos"
   ; page_title = "RiseOS TODOs"}
  ;{ title = "Let's Encrypt SSL"
   ; file = "posts/2016_02_29_letsencrypt_ssl.md"
   ; author = sean_grove
   ; permalink = "/posts/2016_02_29_lets_encrypt_ssl"
   ; page_title = "Let's Encrypt SSL"}
  ;{ title = "Install OCaml AWS and dbm on OSX"
   ; file = "posts/2016_03_03_install_ocaml_aws_and_dbm_on_osx.md"
   ; author = sean_grove
   ; permalink = "/posts/2016_03_03_install_ocaml_aws_and_dbm_on_osx"
   ; page_title = "Install OCaml AWS and dbm on OSX"}
  ;{ title = "OCaml on iOS, babysteps"
   ; file = "posts/2016_03_04_ocaml_on_ios_babysteps.md"
   ; author = sean_grove
   ; permalink = "/posts/2016_03_04_ocaml_on_ios_babysteps"
   ; page_title = "OCaml on iOS, babysteps"}
  ;{ title = "Mirage build via Docker"
   ; file = "posts/2016_03_31_mirage_build_via_docker.md"
   ; author = sean_grove
   ; permalink = "/posts/2016_03_31_mirage_build_via_docker"
   ; page_title = "Mirage build via Docker"}
  ;{ title = "Email reports on error in OCaml via Mailgun"
   ; file = "posts/2016_04_09_email_reports_on_error_in_ocaml_via_mailgun.md"
   ; author = sean_grove
   ; permalink = "/posts/2016_04_09_email_reports_on_error_in_ocaml_via_mailgun"
   ; page_title = "Email reports on error in OCaml via Mailgun"}
  ]

let recent_post_count =
  min 5 (List.length posts)

let recent_posts =
  let len = List.length posts in
  let rec helper counter list =
    match counter with
    | 0 -> list
    | _ -> try
        helper (counter - 1) ((List.nth posts (len - counter)) :: list)
      with
      | Failure _ -> list
      | Invalid_argument _ -> list
  in
  helper recent_post_count []

let post_to_recent_post_html post =
  let li = Soup.create_element "li" in
  let a = Soup.create_element "a" ~attributes:["href", post.permalink] ~inner_text:post.title in
  Soup.append_child li a;
  li

let head_post src limit =
  let md = Omd.of_string src in
  let sub = sub_omd md [] (ref limit) in
  let sub_md = Omd.to_markdown sub in
  Omd.to_html (Omd.of_string ((String.trim sub_md) ^ "..."))

(** Common signature for http and https. *)
module type HTTP = Cohttp_lwt.Server

module RiseDispatch (C: V1_LWT.CONSOLE) (FS: V1_LWT.KV_RO) (S: HTTP) = struct

  let log c fmt = Printf.ksprintf (C.log c) fmt

  let read_fs fs name =
    let open Lwt.Infix in
    FS.size fs name >>=
    fun x ->
    match x with
    | `Error (FS.Unknown_key _) ->
      Lwt.fail File_not_found
    | `Ok size ->
      FS.read fs name 0 (Int64.to_int size)
      >>= function
      | `Error (FS.Unknown_key _) -> Lwt.fail (Failure ("read " ^ name))
      | `Ok bufs -> Lwt.return (Cstruct.copyv bufs)

  (** This is the part that is not boilerplate. *)

  let gen_page _c body _render_context liquid_template title =
    let open Soup in
    (* TODO: Test.render converts ' -> #llr, fix Test.render *)
    (* (Test.render body render_context) *)
    let body_html = Omd.to_html ~nl2br:true (Omd.of_string (Bytes.to_string body)) in
    print_endline ("HTML: " ^ body_html);
    let template = liquid_template in
    let parsed = parse template in
    let post_body_el = parsed $ ".post-body" in
    let post_title_el = parsed $ ".post-title" in
    let page_title_el = parsed $ "title" in
    let recent_posts_el = parsed $ ".recent-posts" in
    (clear post_title_el);
    (clear post_body_el);
    (clear page_title_el);
    (clear recent_posts_el);
    append_child page_title_el (Soup.create_text (title ^ " - " ^ site_title));
    append_child post_title_el (Soup.create_text title);
    append_child post_body_el (Soup.parse ("<div>" ^ body_html ^ "</div>"));
    List.iter (fun post -> Soup.append_child recent_posts_el (post_to_recent_post_html post)) recent_posts;
    parsed |> to_string

  let gen_post c fs liquid_template post =
    let open Lwt in
    let raw_file = read_fs fs post.file in
    raw_file >>=
    fun body ->
    let render_context =
      (let open Liquid in
       [ ("post.title"), String post.title
       ; ("post.author"), String post.author.name
       ; ("post.body"), String body
       ]) in
    return (gen_page c (Bytes.of_string body) render_context liquid_template post.title)

  let gen_index c fs liquid_template (posts : post list) =
    let open Lwt in
    let lwt_bodies = List.map (fun post -> post, (read_fs fs post.file)) posts in
    let all_bodies = Lwt_list.fold_left_s (fun acc (post, next) ->
        next >|=
        (fun s ->
           let body = s in
           (* TODO: Test.render converts ' -> #llr, fix Test.render *)
           (* (Bytes.to_string (Test.render body render_context_1)) in *)
           let link = Soup.create_element "a" ~attributes:["href", post.permalink] in
           let title = Soup.create_element "strong" ~inner_text:post.title in
           Soup.append_child link title;
           let full = Soup.to_string link in
           (acc ^ full ^ "<br />" ^ (head_post body 50) ^ "<hr />"))) "" lwt_bodies in
    all_bodies >>=
    fun body ->
    let render_context = [] in
    return (gen_page c (Bytes.of_string body) render_context liquid_template "Home")

  let render_blog_index c fs =
    let open Lwt.Infix in
    (read_fs fs "index.html"
     >>= (fun template ->
         gen_index c fs template (List.rev posts)), html_mime)

  let gen_atom_feed () =
    let module Atom = Syndic_atom in
    let entries = List.map (fun post ->
        let link = Atom.link ~title:post.title (Uri.of_string (site_url ^ post.permalink)) in
        let author = Atom.author ~email:post.author.email post.author.name in
        Atom.entry
            ~id:(Uri.of_string "http://www.riseos.com/atom.xml")
            ~authors:(author, [])
            ~title:(Atom.Text "Entry Title")
            ~links:[link]
            ~updated:Syndic_date.epoch ()) (List.rev posts) in
    let rss_channel = Atom.feed
        ~id:(Uri.of_string site_url)
        ~title:(Atom.Text site_title)
        ~subtitle:(Atom.Text site_description)
        ~updated:Syndic_date.epoch
        entries in
    Syndic_xml.to_string ~ns_prefix:(fun _ -> Some "") (Atom.to_xml rss_channel)

  let render_error fs status =
    let open Lwt.Infix in
    read_fs fs "error.html" >>=
    fun body ->
    S.respond_string
      ~headers:(Cohttp.Header.of_list [("Content-Type", Magic_mime.lookup "error.html")])
      ~status
      ~body ()

  let render_not_found fs status =
    let open Lwt.Infix in
    read_fs fs "not_found.html" >>=
    fun body ->
    S.respond_string
      ~headers:(Cohttp.Header.of_list [("Content-Type", Magic_mime.lookup "not_found.html")])
      ~status
      ~body ()

  let route c fs request uri =
    let open Lwt.Infix in
    match (Cohttp.Request.meth request), Uri.path uri with
    | _, "" | _, "/" | _, "index.html" | _, "/blog" -> render_blog_index c fs
    | `GET, "/test" -> (Lwt.return "Testing", html_mime)
    | `GET, "/healthy" -> (Lwt.return "OK!", html_mime)
    | `GET, "/version" -> ((read_fs fs "VERSION"), "text/plain")
    | `GET, "/test_error" -> raise (Failure "Testing, error raised")
    | `GET, "/atom.xml" -> (Lwt.return (gen_atom_feed ()), "text/xml;charset=utf-8")
    | _method, url ->
      (* Try to find and read a matching post *)
      try
        let post = List.find (fun post ->
            post.permalink = url) posts in
        read_fs fs "index.html"
        >>= (fun template ->
            gen_post c fs template post), html_mime
      with
      | Not_found ->
        (* Read the static file *)
        (read_fs fs url), Magic_mime.lookup url

  (** Dispatching/redirecting boilerplate. *)

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
      (* TODO: Figure out how to capture arbitrary context (via
         middleware?) and send as context with error email *)
      ignore(Mailgun.send ~domain:"riseos.com" ~api_key:(Key_gen.mailgun_api_key ()) params))

  let dispatcher fs c request uri =
    let open Lwt.Infix in
    Lwt.catch
      (fun () ->
         let (lwt_body, content_type) = route c fs request uri in
         lwt_body >>= fun body ->
         S.respond_string ~status:`OK ~headers: (Cohttp.Header.of_list [("Content-Type", content_type)]) ~body ())
      (fun exn ->
         match exn with
         | File_not_found -> render_not_found fs `Not_found
         | _ -> let status = `Internal_server_error in
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
           | false -> render_error fs `Internal_server_error)

  let _redirect _c _request uri =
    let new_uri = Uri.with_scheme uri (Some "https") in
    let headers =
      Cohttp.Header.init_with "location" (Uri.to_string new_uri)
    in
    S.respond ~headers ~status:`Moved_permanently ~body:`Empty ()

  let serve c dispatch =
    let callback (_, cid) request _body =
      let uri = Cohttp.Request.uri request in
      let cid = Cohttp.Connection.to_string cid in
      log c "[%s] serving %s." cid (Uri.to_string uri);
      dispatch c request uri
    in
    let conn_closed (_,cid) =
      let cid = Cohttp.Connection.to_string cid in
      log c "[%s] closing." cid
    in
    S.make ~conn_closed ~callback ()
end


(** Server boilerplate *)
module Make
    (C : V1_LWT.CONSOLE) (Clock : V1.CLOCK)
    (DATA : V1_LWT.KV_RO) (KEYS: V1_LWT.KV_RO)
    (Http: HTTP) =
struct

  module X509 = Tls_mirage.X509 (KEYS) (Clock)

  module D  = RiseDispatch(C)(DATA)(Http)

  let tls_init kv =
    let open Lwt.Infix in
    X509.certificate kv `Default >>= fun cert ->
    let conf = Tls.Config.server ~certificates:(`Single cert) () in
    Lwt.return conf

  let start c () data keys http =
    (* Setup dev *)
    Printexc.record_backtrace (Key_gen.show_errors ());
    let open Lwt.Infix in
    tls_init keys >>= fun cfg ->
    let tcp = `TCP (Key_gen.https_port ()) in
    let tls = `TLS (cfg, tcp) in
    (* let wm = D.wm_main () in *)
    Lwt.join [
      http tls @@ D.serve c (D.dispatcher data) ;
      http (`TCP (Key_gen.http_port ())) @@ D.serve c (D.dispatcher data) ;
    ]

end

