module Mime = Magic_mime
module H = Html5.M

type post = {
  title: string;
  file: string;
  author: string;
  permalink: string;
  page_title: string;
}

let ty_head title_str =
  H.(head
       (title (pcdata title_str))
       [
         meta ~a:[ a_charset "utf-8" ] () ;
         meta ~a:[ a_name "author"; a_content "Sean Grove"] () ;
         meta ~a:[ a_http_equiv "Content-Type"; a_content "text/html; charset=utf-8"] () ;
         meta ~a:[ a_name "viewport"; a_content "width=device=width";] () ;
         meta ~a:[ a_name "HandheldFriendly"; a_content "true";] () ;
         meta ~a:[ a_name "MobileOptimized"; a_content "320";] () ;
         meta ~a:[ a_name "viewport"; a_content "width=device-width, initial-scale=1";] () ;
         link ~rel:[`Stylesheet] ~href:"stylesheets/normalize.css" ();
         link ~rel:[`Stylesheet] ~href:"stylesheets/foundation.css"();
         link ~rel:[`Stylesheet] ~href:"https://fonts.googleapis.com/css?family=Lato:300,700,300italic,700italic" ();
         link ~rel:[`Icon] ~href:"/images/favicon.ico" ();
         link ~rel:[`Other "apple-touch-icon"] ~href:"/images/apple-icon-57x57.png" ~a:[ a_sizes (`Sizes [(57, 57)])] ();
         link ~rel:[`Other "apple-touch-icon"] ~href:"/images/apple-icon-57x57.png" ~a:[ a_sizes (`Sizes [(57, 57)])] ();
         link ~rel:[`Other "apple-touch-icon"] ~href:"/images/apple-icon-57x57.png" ~a:[ a_sizes (`Sizes [(57, 57)])] ();
         link ~rel:[`Other "apple-touch-icon"] ~href:"/images/apple-icon-60x60.png" ~a:[ a_sizes (`Sizes [(60, 60)])] ();
         link ~rel:[`Other "apple-touch-icon"] ~href:"/images/apple-icon-72x72.png" ~a:[ a_sizes (`Sizes [(72, 72)])] ();
         link ~rel:[`Other "apple-touch-icon"] ~href:"/images/apple-icon-76x76.png" ~a:[ a_sizes (`Sizes [(76, 76)])] ();
         link ~rel:[`Other "apple-touch-icon"] ~href:"/images/apple-icon-114x114.png" ~a:[ a_sizes (`Sizes [(114, 114)])] ();
         link ~rel:[`Other "apple-touch-icon"] ~href:"/images/apple-icon-120x120.png" ~a:[ a_sizes (`Sizes [(120, 120)])] ();
         link ~rel:[`Other "apple-touch-icon"] ~href:"/images/apple-icon-144x144.png" ~a:[ a_sizes (`Sizes [(144, 144)])] ();
         link ~rel:[`Other "apple-touch-icon"] ~href:"/images/apple-icon-152x152.png" ~a:[ a_sizes (`Sizes [(152, 152)])] ();
         link ~rel:[`Other "apple-touch-icon"] ~href:"/images/apple-icon-180x180.png" ~a:[ a_sizes (`Sizes [(180, 180)])] ();
         link ~rel:[`Icon] ~href:"/images/android-icon-192x192.png" ~a:[a_sizes (`Sizes [(192, 192)])] ();
         link ~rel: [`Icon] ~a:[a_sizes (`Sizes [(192, 192)])] ~href:"/images/android-icon-192x192.png" ();
         link ~rel: [`Icon] ~a:[a_sizes (`Sizes [(32, 32)])]   ~href:"/images/favicon-32x32.png" ();
         link ~rel: [`Icon] ~a:[a_sizes (`Sizes [(96, 96)])]   ~href:"/images/favicon-96x96.png" ();
         link ~rel: [`Icon] ~a:[a_sizes (`Sizes [(16, 16)])]   ~href:"/images/favicon-16x16.png" ();
         script ~a:[a_src "https://cdnjs.cloudflare.com/ajax/libs/react/0.14.7/react-with-addons.js"] (pcdata "") ;
         script ~a:[a_src "https://cdnjs.cloudflare.com/ajax/libs/react/0.14.7/react-dom.js"] (pcdata "") ;
         script ~a:[a_src "/js/client.js"] (pcdata "") ;
       ])


let ty_body_src =
  H.(
    body ~a:[ a_class ["collapse-sidebar"; "sidebar-footer"]] [
      div ~a:[ a_class ["contain-to-grid"; "sticky"]] [
        div ~a:[ a_class ["row"]] [
          div ~a:[ a_class ["large-12"; "columns"]] [
            nav ~a:[ a_class ["top-bar"]] [
              ul ~a:[ a_class ["title-area"]] [
                li ~a:[ a_class ["name"] ] [
                  h1 ~a:[] [
                    a ~a:[a_href "/"; a_style "padding-left:0px;"] [ 
                      img ~src:"/images/sofuji_black_30.png" ~alt:"RiseOS" ~a:[a_style "transform:translateY(10px);margin-right:5px;"] ();
                      (pcdata "RiseOS")]
                  ]
                ]
              ]
            ]
          ]
        ]
      ]
    ]
  )

let html =
  H.html (ty_head "RiseOS") @@ ty_body_src

let ty_page =
  let b = Buffer.create 17 in
  Html5.P.print ~output:(Buffer.add_string b) html;
  Buffer.contents b

let rec sublist b e l =
  if e = 0 then [] else
  match l with
    [] -> failwith "sublist"
  | h :: t ->
    let tail = if e = 0 then [] else sublist (b - 1) (e - 1) t in
    if b > 0 then tail else h :: tail

let rec sub_omd(src_list : Omd.t) dest_list (count_remaining : int ref) =
  let open Omd in
  Printf.printf "sub_omd cr: %d\n" !count_remaining;
  match !count_remaining with
  | 0 -> dest_list
  | n when n < 0 -> dest_list
  | _ ->
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

let site_title =
  "RiseOS"

let posts =
  [{ title = "First post"
   ; file = "posts/2016_02_06_first_post.md"
   ; author = "Sean Grove"
   ; permalink = "/posts/2016_02_06_first_post"
   ; page_title = "First post"}
  ;{ title = "Mirage questions"
   ; file = "posts/2016_02_20_mirage_questions.md"
   ; author = "Sean Grove"
   ; permalink = "/posts/2016_02_20_mirage_questions"
   ; page_title = "Mirage Questions"}
  ;{ title = "RiseOS TODOs"
   ; file = "posts/2016_02_27_riseos_todos.md"
   ; author = "Sean Grove"
   ; permalink = "/posts/2016_02_27_riseos_todos"
   ; page_title = "RiseOS TODOs"}
  ;{ title = "Let's Encrypt SSL"
   ; file = "posts/2016_02_29_letsencrypt_ssl.md"
   ; author = "Sean Grove"
   ; permalink = "/posts/2016_02_29_lets_encrypt_ssl"
   ; page_title = "Let's Encrypt SSL"}
  ;{ title = "Install OCaml AWS and dbm on OSX"
   ; file = "posts/2016_03_03_install_ocaml_aws_and_dbm_on_osx.md"
   ; author = "Sean Grove"
   ; permalink = "/posts/2016_03_03_install_ocaml_aws_and_dbm_on_osx"
   ; page_title = "Install OCaml AWS and dbm on OSX"}
  ;{ title = "OCaml on iOS, babysteps"
   ; file = "posts/2016_03_04_ocaml_on_ios_babysteps.md"
   ; author = "Sean Grove"
   ; permalink = "/posts/2016_03_04_ocaml_on_ios_babysteps"
   ; page_title = "OCaml on iOS, babysteps"}
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

let empty_string s =
  not (List.mem s ["\\n"; " "])

let head_post src limit =
  let md = Omd.of_string src in
  let sub = sub_omd md [] (ref limit) in
  let sub_md = Omd.to_markdown sub in
  Omd.to_html (Omd.of_string ((String.trim sub_md) ^ "..."))

(** Common signature for http and https. *)
module type HTTP = Cohttp_lwt.Server

module Dispatch (C: V1_LWT.CONSOLE) (FS: V1_LWT.KV_RO) (S: HTTP) = struct

  let log c fmt = Printf.ksprintf (C.log c) fmt

  let read_fs fs name =
    let open Lwt.Infix in
    FS.size fs name >>=
    fun x ->
    match x with
    | `Error (FS.Unknown_key _) ->
      Lwt.fail (Failure ("read " ^ name))
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
    append_child post_body_el (Soup.create_text body_html);
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
       ; ("post.author"), String post.author
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
         gen_index c fs template (List.rev posts)), "text/html;charset=utf-8")

  let get_content c fs _request uri =
    let open Lwt.Infix in
    match Uri.path uri with
    | "" | "/" | "index.html" | "/blog" -> render_blog_index c fs
    | "/test" -> (Lwt.return "Testing", "text/html;charset=utf-8")
    | "/tyxml" -> (Lwt.return ty_page, "text/html;charset=utf-8")
    | url ->
      try
        let post = List.find (fun post ->
            post.permalink = url) posts in
        read_fs fs "index.html"
        >>= (fun template ->
            gen_post c fs template post), "text/html;charset=utf-8"
      with
      | Not_found -> (read_fs fs url, Mime.lookup url)

  (** Dispatching/redirecting boilerplate. *)

  let dispatcher fs c request uri =
    let open Lwt.Infix in
    Lwt.catch
      (fun () ->
         let (lwt_body, content_type) = get_content c fs request uri in
         lwt_body >>= fun body ->
         S.respond_string ~status:`OK ~headers: (Cohttp.Header.of_list [("Content-Type", content_type)]) ~body ())
      (fun _exn ->
         S.respond_not_found ())

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

  module D  = Dispatch(C)(DATA)(Http)

  let tls_init kv =
    let open Lwt.Infix in
    X509.certificate kv `Default >>= fun cert ->
    let conf = Tls.Config.server ~certificates:(`Single cert) () in
    Lwt.return conf

  let start c () data keys http =
    let open Lwt.Infix in
    tls_init keys >>= fun cfg ->
    let tcp = `TCP (Key_gen.https_port ()) in
    let tls = `TLS (cfg, tcp) in
    Lwt.join [
      http tls @@ D.serve c (D.dispatcher data) ;
      http (`TCP (Key_gen.http_port ())) @@ D.serve c (D.dispatcher data)
    ]

end
