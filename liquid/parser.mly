%token <int> INT
%token <float> FLOAT
%token <string> ID
%token <string> PROP
%token <string> STRING
%token <string> TEXT
%token LEFT_DBRACE
%token RIGHT_DBRACE
%token LEFT_PBRACE
%token RIGHT_PBRACE
%token PIPE
%token DOT
%token EOF

(* part 1 *)
%start <Liquid.value option> prog
%%
(* part 2 *)
prog:
  | EOF       { None }
  | v = value { Some v }
  ;

(* part 3 *)
value:
  | LEFT_DBRACE; id = ID; RIGHT_DBRACE { `Id id }
  | LEFT_PBRACE; id = ID; RIGHT_PBRACE { `Id id }
  | t = TEXT
    { `String t }
  | s = STRING
    { `String s }
  | i = INT
    { `Int i }
  | x = FLOAT
    { `Float x }
  ;
