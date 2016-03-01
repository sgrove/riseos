module Mime = Magic_mime
open V1
open V1_LWT

open Lwt.Infix

type post = {
  title: string;
  file: string;
  author: string;
  permalink: string;
  page_title: string;
}

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
  ]

let recent_post_count =
  5

let recent_posts =
  let len = List.length posts in
  let rec helper counter list =
    match counter with
    | 0 -> list
    | n -> try
           helper (counter - 1) ((List.nth posts (len - counter)) :: list)
           with
           | Failure _ -> list
           | Invalid_argument _ -> list
  in
  helper recent_post_count (List.rev posts)

let post_to_recent_post_html post =
  let li = Soup.create_element "li" in
  let a = Soup.create_element "a" ~attributes:["href", post.permalink] ~inner_text:post.title in
  Soup.append_child li a;
  li

let rec sublist b e l =
  match l with
    [] -> failwith "sublist"
  | h :: t ->
     let tail = if e = 0 then [] else sublist (b - 1) (e - 1) t in
     if b > 0 then tail else h :: tail

let empty_string s =
  not (List.mem s ["\\n"; " "])

let head_post string =
  let words = List.filter empty_string (Str.split (Str.regexp " ") string) in
  let head_words = sublist 0 (min (List.length words) 50) words in
  let ellipsis = if 50 < (List.length words) then "..." else "" in
  (String.concat " " head_words) ^ ellipsis

(** Common signature for http and https. *)
module type HTTP = Cohttp_lwt.Server

module Dispatch (C: CONSOLE) (FS: KV_RO) (S: HTTP) = struct

  let log c fmt = Printf.ksprintf (C.log c) fmt

  let read_fs fs name =
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

  let accept_lang headers =
    if not @@ Key_gen.use_headers () then []
    else
      let open Cohttp in
      headers
      |> Header.get_acceptable_languages
      |> Accept.qsort
      |> CCList.filter_map (function
        | _, Accept.Language (tag :: _) -> Some tag
        | _ -> None
      )

  let gen_page c body render_context liquid_template title =
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
    let open Soup in
    let lwt_bodies = List.map (fun post -> post, (read_fs fs post.file)) posts in
    let all_bodies = Lwt_list.fold_left_s (fun acc (post, next) ->
                                           next >|=
                                             (fun s ->
                                              let body = Omd.to_html (Omd.of_string s) in
                                              (* TODO: Test.render converts ' -> #llr, fix Test.render *)
                                              (* (Bytes.to_string (Test.render body render_context_1)) in *)
                                              let link = Soup.create_element "a" ~attributes:["href", post.permalink] in
                                              let title = Soup.create_element "strong" ~inner_text:post.title in
                                              Soup.append_child link title;
                                              let full = Soup.to_string link in
                                              (acc ^ full ^ "<br />" ^ (head_post body) ^ "<hr />"))) "" lwt_bodies in
    all_bodies >>=
      fun body ->
      let render_context = [] in
      return (gen_page c (Bytes.of_string body) render_context liquid_template "Home")

  let get_content c fs request uri = match Uri.path uri with
    | "" | "/"
    | "index.html" ->
       (read_fs fs "index.html"
        >>= (fun template ->
             gen_index c fs template (List.rev posts)), "text/html;charset=utf-8")
    | "/test" ->
       (Lwt.return "Testing", "text/html;charset=utf-8")
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
    Lwt.catch
      (fun () ->
       let (lwt_body, content_type) = get_content c fs request uri in
       lwt_body >>= fun body ->
       S.respond_string ~status:`OK ~headers: (Cohttp.Header.of_list [("Content-Type", content_type)]) ~body ())
      (fun _exn ->
       S.respond_not_found ())


  let redirect _c _request uri =
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
    (C : CONSOLE) (Clock : CLOCK)
    (DATA : KV_RO) (KEYS: KV_RO)
    (Http: HTTP) =
struct

  module X509 = Tls_mirage.X509 (KEYS) (Clock)

  module D  = Dispatch(C)(DATA)(Http)

  let tls_init kv =
    X509.certificate kv `Default >>= fun cert ->
    let conf = Tls.Config.server ~certificates:(`Single cert) () in
    Lwt.return conf

  let start c () data keys http =
    tls_init keys >>= fun cfg ->
    let tcp = `TCP (Key_gen.https_port ()) in
    let tls = `TLS (cfg, tcp) in
    Lwt.join [
      http tls @@ D.serve c (D.dispatcher data) ;
      http (`TCP (Key_gen.http_port ())) @@ D.serve c (D.dispatcher data)
    ]

end
