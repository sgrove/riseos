(* open Core.Std *)
open Lexer
open Lexing

(* let print_position outx lexbuf = *)
(*   let pos = lexbuf.lex_curr_p in *)
(*   fprintf outx "%s:%d:%d" pos.pos_fname *)
(*     pos.pos_lnum (pos.pos_cnum - pos.pos_bol + 1) *)

let cur_pos lexbuf =
  let pos = lexbuf.lex_curr_p in
  Printf.sprintf "%s:%d:%d" pos.pos_fname
                 pos.pos_lnum (pos.pos_cnum - pos.pos_bol + 1)

let parse_with_error lexbuf =
  try Parser.prog Lexer.read lexbuf with
  | SyntaxError msg ->
    Printf.printf "SYN_ERROR %s : %s\n" (cur_pos lexbuf) msg;
    None
  | Parser.Error ->
    Printf.printf "PARSE_ERROR %s: syntax error\n" (cur_pos lexbuf);
    exit (-1)

(* part 1 *)
(* let rec parse_and_print lexbuf out = *)
(*   match parse_with_error lexbuf with *)
(*   | Some value -> *)
(*     (\* printf "%a\n" Liquid.output_value value; *\) *)
(*      (Buffer.add_bytes out (Liquid.to_hc_string value)); *)
(*      parse_and_print lexbuf out *)
(*   | None -> out *)

let rec parse_with_context lexbuf context out =
  match parse_with_error lexbuf with
  | Some value ->
     (Buffer.add_bytes out (Bytes.of_string (Liquid.to_string context value)));
     Printf.printf "parsed: %s\n" (Liquid.to_string context value);
     parse_with_context lexbuf context out
  | None -> out

let render (str : string) context =
  Printf.printf "RENDER PLEASE\n";
  let lexbuf = Lexing.from_string str in
  lexbuf.lex_curr_p <- { lexbuf.lex_curr_p with pos_fname = "string" };
  Printf.printf "Parsing with context\n";
  let final = parse_with_context lexbuf context (Buffer.create 17) in
  Printf.printf "Finished parsing context\n";
  Buffer.to_bytes final

(* let loop filename () = *)
(*   let open Core.Std in *)
(*   let inx = In_channel.create filename in *)
(*   let lexbuf = Lexing.from_channel inx in *)
(*   lexbuf.lex_curr_p <- { lexbuf.lex_curr_p with pos_fname = filename }; *)
(*   let final = parse_and_print lexbuf (Buffer.create 17) in *)
(*   let html_output = Omd.to_html(Omd.of_string (Buffer.to_bytes final)) in *)
(*   In_channel.close inx; *)
(*   print_endline html_output *)

(* (\* part 2 *\) *)
(* let () = *)
(*   Command.basic ~summary:"Parse and display Liquid" *)
(*     Command.Spec.(empty +> anon ("filename" %: file)) *)
(*     loop *)
(*   |> Command.run *)
