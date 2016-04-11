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
