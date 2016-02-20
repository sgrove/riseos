type value = [
  | `Assoc of (string * value) list
  | `Id of string
  | `Bool of bool
  | `Float of float
  | `Int of int
  | `List of value list
  | `Null
  | `String of string
]

type template_value =
  | String of string
  | Obj of (string * template_value)

let (context : (string * template_value) list) =
  [
    ("color", String "blue")
  ; ("person", Obj ("name", String "Tyler"))
  ; ("person.name", String "Tyler")
  ; ("name", String "Sean")]

let to_hc_string = function
  | `String s   -> s
  | `Id id      ->  (match (List.assoc id context) with
                     | String s -> s
                     | _ -> "This value not found")
  | `Bool true  -> "true"
  | `Bool false -> "false"
  | `Null       -> "null"
  | _ -> "???"

let to_string context item =
  match item with
  | `String s   -> s
  | `Id id      ->  (match (List.assoc id context) with
                     | String s -> s
                     | _ -> raise  Not_found)
  | `Bool true  -> "true"
  | `Bool false -> "false"
  | `Null       -> "null"
  | _ -> "???"


(* part 1 *)
let rec output_value outc = function
  | `Assoc obj  -> print_assoc outc obj
  | `List l     -> print_list outc l
  | `String s   -> Printf.printf "\"%s\"" s
  | `Int i      -> Printf.printf "%d" i
  | `Float x    -> Printf.printf "%f" x
  | `Id id      -> Printf.printf "Looking up key `%s`, %b\n" id (List.mem_assoc id context);
                   Printf.printf "%s -> %s" id (match (List.assoc id context) with
                                                | String s -> s
                                                | _ -> raise  Not_found)
  | `Bool true  -> output_string outc "true"
  | `Bool false -> output_string outc "false"
  | `Null       -> output_string outc "null"

and print_assoc outc obj =
  output_string outc "{ ";
  let sep = ref "" in
  List.iter (fun (key, value) ->
      ignore (Printf.printf "%s\"%s\": %a" !sep key output_value value);
      sep := ",\n  ") obj;
  output_string outc " }"

and print_list outc arr =
  output_string outc "[";
  List.iteri (fun i v ->
      if i > 0 then
        output_string outc ", ";
      output_value outc v) arr;
  output_string outc "]"
