module Html = Dom_html

let my_add a b =
  a + b

let () =
  print_endline "Hello world";
  print_endline "Just works?";
  print_endline "Pretty fast at this stage..."

let () =
  let x = 10 in
  let y = 20 in
  Printf.printf "Sum of %d + %d = %d\n" x y (my_add x y)

let to_obj l = Js.Unsafe.obj @@ Array.of_list l
let jss s = Js.string s
let inj o = Js.Unsafe.inject o

let console =
  Js.Unsafe.variable "console"

let log msg = 
  Js.Unsafe.meth_call console "log" [| inj @@ msg |]

(* TODO: Handle decodeURIComponent, etc. - see https://ocsigen.org/js_of_ocaml/api/Js#2_StandardJavascriptfunctions *)
let page_params =
  let url = (Js.to_string Html.window##.location##.href) in
  let query_string = (String.concat "?" (List.tl (Regexp.split (Regexp.regexp "\\?") url))) in
  let kv_pairs = (Regexp.split (Regexp.regexp "&") query_string) in
  List.fold_left (fun run next ->
                  match (Regexp.split (Regexp.regexp "=") next) with
                  | key::value -> List.append run [(key, (String.concat "" value))]
                  | _ -> run)
                 [] kv_pairs

let get_query_param params ?default:(default="") key =
  (try
      List.assoc key page_params
    with
    | Not_found -> default)

module type REACT = sig
    type component

    type value_t = unit

    val component : (value_t -> component) -> (value_t -> component)
    val element_of_tag : string -> (string * Js.Unsafe.any) list -> string -> component
    val root : component -> Dom_html.element Js.t -> unit
    val render : component -> Dom_html.element Js.t -> unit
  end

module React:REACT = struct
  let react = (Js.Unsafe.variable "React")
  let react_impl = (Js.Unsafe.variable "ReactDOM")

  type component = Js.Unsafe.any
  type value_t = unit

  let component renderer =
    let rfun this _ =
      let props = Js.Unsafe.get this "props" in
      let value = Js.Unsafe.get props "value" in

      renderer value
    in
    let opts = to_obj [("render", inj @@ Js.wrap_meth_callback rfun)] in
    let comp = Js.Unsafe.meth_call react "createClass" [| opts |] in
    let r value =
      let opts = to_obj [("value", inj value)] in
      Js.Unsafe.meth_call react "createElement" [| comp; opts |]
    in
    r

  let element_of_tag tag opts children =
    Js.Unsafe.meth_call react "createElement"
                        [| inj @@ jss "div";
                           inj @@ to_obj opts;
                           inj @@ jss children |]

  let root comp node =
    let el = Js.Unsafe.meth_call react "createElement" [| inj @@ comp |] in
    print_endline "Rooting component:";
    ignore(log el);
    Js.Unsafe.meth_call react_impl "render" [| inj el; inj node |]

  let render comp node =
    Js.Unsafe.meth_call react_impl "render" [| inj comp; inj node |]
end

let box = 
  React.component
    (fun v ->
     React.element_of_tag "div" [("className", inj @@ jss "commentBox")] "This is a new commentBox")

let () =
  Js.Unsafe.set Html.window "myboxfn" box

type person = 
    {
      name : string
    ; age : int
    }

let colors =
  [|"blue" ; "green" ; "red" ; "purple" ; "pink" |]

let rand_color () =
  let n = Random.int (Array.length colors) in
  Array.get colors n

let start _:(bool Js.t) =
  Printf.printf "Start\n";
  let react = Js.Unsafe.variable "React" in
  let div = Dom_html.getElementById "main-area" in
  match get_query_param page_params "react" with
  | "true" ->
     Printf.printf "Rendering component:\n";
     let spec = object%js (self)
                  val displayName = jss "testClass"
                  method componentDidMount =
                    let props = Js.Unsafe.get self "state" in
                    let author = Js.Unsafe.get props "author" in
                    print_endline ("Component mounted with author: " ^ author.name)
                  method componentWillMount =
                    let props = Js.Unsafe.get self "props" in
                    let author = Js.Unsafe.get props "author" in
                    Js.Unsafe.meth_call self "setState" [| (to_obj ["author", inj author]) |]
                  method componentDidUpdate =
                    let props = Js.Unsafe.get self "state" in
                    let author = Js.Unsafe.get props "author" in
                    print_endline ("Component updated with author: " ^ author.name ^ ": " ^ (string_of_int author.age))
                  method render =
                    let props = Js.Unsafe.get self "state" in
                    let author = Js.Unsafe.get props "author" in
                    let button = Js.Unsafe.meth_call react "createElement" [| inj @@ jss "div" ; inj @@ to_obj [("onClick", inj @@ (fun event -> 
                                                                                                                                    print_endline ("Clicked me at " ^ (string_of_int author.age));
                                                                                                                                    Js.Unsafe.meth_call self "setState" [| (to_obj ["author", inj {author with age = author.age + 1}]) |]));
                                                                                                                ("style", inj @@ to_obj [("backgroundColor", inj @@ jss (rand_color ()))])] ; inj @@ jss (string_of_int author.age) |] in
                    Js.Unsafe.meth_call react "createElement" [| inj @@ jss "h3"; inj @@ []; inj @@ jss ("You, " ^ author.name ^ ", are " ^ string_of_int(author.age) ^ " years of age") ; button|]
                end
     in
     let sean = {age = 31; name = "Sean"} in
     let cc = {age = 24; name = "Chengcheng"} in
     let sean_2 = {age = 32; name = "Sean Grove"} in
     let dw = {age = 29; name = "Daniel"} in
     Js.Unsafe.set Html.window "my_spec" spec;
     let rclass = Js.Unsafe.meth_call react "createClass" [|inj @@ spec|] in
     let make_greeter person = Js.Unsafe.meth_call react "createElement" [| inj @@ rclass; inj @@ to_obj ["author", inj person] |] in
     let s_inst = make_greeter sean in
     let cc_inst = make_greeter cc in
     let s_inst_2 = make_greeter sean_2 in
     let dw_inst = make_greeter dw in
     let container = Js.Unsafe.meth_call react "createElement" [| inj @@ jss "div" ; inj @@ to_obj [] ; inj s_inst ; inj cc_inst ; |] in
     React.render container div;
     let container = Js.Unsafe.meth_call react "createElement" [| inj @@ jss "div" ; inj @@ to_obj [] ; inj cc_inst ; inj s_inst_2 ; dw_inst |] in
     Js.Unsafe.set Html.window "myinst" s_inst;
     React.render container div;
     Printf.printf "Finished initial rendering\n";
     Js._false
  | _ -> print_endline "Not rendering react components. To turn it on, add query param react=true";
         Js._false



let () =
  let my_obj = object%js (self)
                 val x = 3
                 val name = "Sean Grove"
               end
  in
  print_endline "Ok, starting up";
  Js.Unsafe.set Html.window "my_obj" my_obj;
  Printf.printf "value: %s\n" my_obj##.name;
  Js.Unsafe.set Html.window "onload" (Dom.handler start)
