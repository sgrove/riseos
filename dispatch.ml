open V1
open V1_LWT

open Lwt.Infix

type post = {
  title: string;
  file: string;
  author: string;
  permalink: string;
}

let posts =
  [{title = "First post";
    file = "posts/2016_02_06_first_post.md";
    author = "Sean Grove";
    permalink = "2016_02_06_first_post";}
  ;{title = "Mirage questions";
    file = "posts/2016_02_20_mirage_questions.md";
    author = "Sean Grove";
    permalink = "2016_02_20_mirage_questions";}]

(** Common signature for http and https. *)
module type HTTP = Cohttp_lwt.Server

module Dispatch (C: CONSOLE) (FS: KV_RO) (S: HTTP) = struct

  let log c fmt = Printf.ksprintf (C.log c) fmt

  let read_fs fs name =
    print_endline ("read_fs 1: " ^ name);
    FS.size fs name >>=
      fun x ->
      match x with
      | `Error (FS.Unknown_key _) -> 
         (print_endline "read_fs 2";);
         Lwt.fail (Failure ("read " ^ name))
      | `Ok size ->
         (print_endline "read_fs 3";);
         FS.read fs name 0 (Int64.to_int size) >>= function
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

  let gen_post c fs liquid_template post =
    let open Lwt in
    let open Soup in
    log c "f1";
    let raw_file = read_fs fs post.file in
    log c "f1.5";
    raw_file >>=
      fun file ->
      log c "f2";
      let body_html = Omd.to_html(Omd.of_string file) in
      let render_context_1 =
        (let open Liquid in
         [ ("person.name", String "Tyler")
         ; ("post.title"), String post.title
         ; ("post.author"), String post.author]) in
      let post_body_rendered = (Bytes.to_string (Test.render body_html render_context_1)) in
      log c "f3";
      let first_post = List.nth posts 0 in
      let second_post = List.nth posts 0 in
      let render_context =
        (let open Liquid in
         [ ("person.name", String "Tyler")
         ; ("post.title"), String post.title
         ; ("post.author"), String post.author
         ; ("post.body"), String post_body_rendered
         ; ("recent_posts.first.title"), String (first_post.title)
         ]) in
      log c "f4";
      log c "f4.3";
      (* let interm = (Test.render liquid_template render_context) in  *)
      (* log c "f4.4"; *)
      (* let template = Bytes.to_string interm in *)
      let template = liquid_template in
      log c "f4.5";
      let parsed_body = parse post_body_rendered in
      let parsed = parse template in
      log c "f5";
      let post_body_el = parsed $ ".post-body" in
      (clear post_body_el);
      append_child post_body_el parsed_body;
      (* Soup.replace title_el new_title_el; *)
      parsed |> to_string |> return


  let get_content c fs request uri = match Uri.path uri with
    | "" | "/" | "index.html" ->
                  log c "Looking for index %s\n" "...";
                  (* TODO: Figure out why this crashes the unikernel
                  with: "Unsupported function strtod called in Mini-OS kernel". Pretty important to be able to work with query params at some point.

                  let lang =
                    CCOpt.get [] (Uri.get_query_param' uri "lang") @
                      accept_lang (Cohttp.Request.headers request) @
                        [Key_gen.lang ()]
                  in *)
                  log c "Reading fs %s\n" "...";
                  (read_fs fs "index.html", "text/html;charset=utf-8")
    | "test" ->
       (Lwt.return "Testing", "text/html;charset=utf-8")
    | s ->
       let permalink = (String.sub s 1 ((String.length s) - 1)) in
       log c "Looking for %s\n" permalink;
       try
         let post = List.find (fun post ->
                               log c "\t%s = %s ? %b" post.permalink s (post.permalink = permalink);
                               post.permalink = permalink) posts in
         (read_fs fs "index.html"
          >>= (fun template ->
               log c "\tRendering template!\n";
               gen_post c fs template post), "text/html;charset=utf-8")
       with
       | Not_found -> (read_fs fs s, Magic_mime.lookup s)

  (** Dispatching/redirecting boilerplate. *)

  let dispatcher fs c request uri =
    (* Lwt.catch *)
    (*   (fun () -> *)
    let (lwt_body, content_type) = get_content c fs request uri in
    lwt_body >>= fun body ->
    S.respond_string ~status:`OK ~headers: (Cohttp.Header.of_list [("Content-Type", content_type)]) ~body ()
  (* ) *)
      (* (fun _exn -> *)
      (*    S.respond_not_found ()) *)


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
    let tcp = `TCP 443 in
    let tls = `TLS (cfg, tcp) in
    Lwt.join [
      http tls @@ D.serve c (D.dispatcher data) ;
      http (`TCP 80) @@ D.serve c (D.dispatcher data)
    ]

end
