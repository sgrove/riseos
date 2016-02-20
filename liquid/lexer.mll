{
open Lexing
open Parser

exception SyntaxError of string

let next_line lexbuf =
  let pos = lexbuf.lex_curr_p in
  lexbuf.lex_curr_p <-
    { pos with pos_bol = lexbuf.lex_curr_pos;
               pos_lnum = pos.pos_lnum + 1
    }
}

(* part 1 *)
let int = '-'? ['0'-'9'] ['0'-'9']*

(* part 2 *)
let digit = ['0'-'9']
let frac = '.' digit*
let exp = ['e' 'E'] ['-' '+']? digit+
(* let float = digit* frac? exp? *)

(* part 3 *)
let white = [' ' '\t']+
let newline = '\r' | '\n' | "\r\n"
let source_text =  ['a'-'z' 'A'-'Z' '_' '!' '@' '#' '$' '%' '^' '&' '*' '(' ')' '<' '>' '?' ':' '|' ',' '.' '/' '[' ']' ';' '\'' '\\' '-' '"' ' ' '+' '=' '~']+              (* Anything outside of {{ }} and {* *} *)
let id = ['a'-'z' 'A'-'Z' '_'] ['a'-'z' 'A'-'Z' '0'-'9' '_']*          (* simply {{ some_identifier }} *)
let prop = id '.' ['a'-'z' 'A'-'Z' '_'] ['a'-'z' 'A'-'Z' '0'-'9' '_']* (* {{ some_identifier.property_1.property_2 *)
let left_dbrace = '{' '{' 
let right_dbrace = '}' '}'
let left_pbrace = '{' '%'
let right_pbrace = '%' '}'


(* part 4: General top-level rules *)
rule read =
  parse
  | white        { read lexbuf }
  | newline      { next_line lexbuf; read lexbuf }
  | id           { ID (Lexing.lexeme lexbuf) }
  | prop         { ID (Lexing.lexeme lexbuf) }
  | int          { INT (int_of_string (Lexing.lexeme lexbuf)) }
  (* | float        { FLOAT (float_of_string (Lexing.lexeme lexbuf)) } *)
  | '"'          { read_string (Buffer.create 17) lexbuf }
  | left_dbrace  { LEFT_DBRACE }
  | right_dbrace { RIGHT_DBRACE }
  | left_pbrace  { LEFT_PBRACE }
  | right_pbrace { RIGHT_PBRACE }
  | '|'          { PIPE }
  (* | '.'          { DOT } *)
  | source_text  { TEXT (Lexing.lexeme lexbuf) }
  | eof          { EOF }
  | _            { raise (SyntaxError ("Unexpected char: " ^ Lexing.lexeme lexbuf)) }

(* part 5: Read everything outside of {{ }} and {% %} and return it as a string *)
and read_text buf =
  parse
  | left_dbrace { STRING (Buffer.contents buf) }
  | '\\' '/'  { Buffer.add_char buf '/'; read_string buf lexbuf }
  | '\\' '\\' { Buffer.add_char buf '\\'; read_string buf lexbuf }
  | '\\' 'b'  { Buffer.add_char buf '\b'; read_string buf lexbuf }
  | '\\' 'f'  { Buffer.add_char buf '\012'; read_string buf lexbuf }
  | '\\' 'n'  { Buffer.add_char buf '\n'; read_string buf lexbuf }
  | '\\' 'r'  { Buffer.add_char buf '\r'; read_string buf lexbuf }
  | '\\' 't'  { Buffer.add_char buf '\t'; read_string buf lexbuf }
  | [^ '"' '\\']+
    { Buffer.add_string buf (Lexing.lexeme lexbuf);
      read_string buf lexbuf
    }
  | _ { raise (SyntaxError ("Illegal string character: " ^ Lexing.lexeme lexbuf)) }
  | eof { STRING (Buffer.contents buf) }

  
(* part 6: Read a string inside of {{ }} and {% %} *)
and read_string buf =
  parse
  | '"'       { STRING (Buffer.contents buf) }
  | '\\' '/'  { Buffer.add_char buf '/'; read_string buf lexbuf }
  | '\\' '\\' { Buffer.add_char buf '\\'; read_string buf lexbuf }
  | '\\' 'b'  { Buffer.add_char buf '\b'; read_string buf lexbuf }
  | '\\' 'f'  { Buffer.add_char buf '\012'; read_string buf lexbuf }
  | '\\' 'n'  { Buffer.add_char buf '\n'; read_string buf lexbuf }
  | '\\' 'r'  { Buffer.add_char buf '\r'; read_string buf lexbuf }
  | '\\' 't'  { Buffer.add_char buf '\t'; read_string buf lexbuf }
  | [^ '"' '\\']+
    { Buffer.add_string buf (Lexing.lexeme lexbuf);
      read_string buf lexbuf
    }
  | _ { raise (SyntaxError ("Illegal string character: " ^ Lexing.lexeme lexbuf)) }
  | eof { raise (SyntaxError ("String is not terminated")) }
