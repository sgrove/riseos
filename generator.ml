(** Html generation. *)

module H = Html5.M
module S = Svg.M


let words lang =
  Data.distinguish Data.no lang

let head words =
  H.(head
      (title @@ pcdata @@ Sequence.head_exn words)
      [
        meta ~a:[ a_charset "utf-8" ] () ;
        link ~rel:[`Stylesheet] ~href:"style.css" ();
      ])

let body words =
  H.(body [
      svg ~a:[
        S.a_viewbox (0.,0.,400.,100.) ;
        S.a_id "main" ;
        S.a_preserveaspectratio "xMidYMid meet" ;
      ]
        S.[text
             ~a:[a_x_list [50.,Some `Percent] ;
                 a_y_list [50.,Some `Percent] ;
                 a_text_anchor `Middle ;
                 a_dominant_baseline `Central ;
                 a_fill (`Color ("white", None)) ;
                ]
             [pcdata @@ Sequence.head_exn words] ]
    ])


let html lang =
  let words = words lang in
  H.html (head words) @@ (body words)

let page =
  let f doc =
    let b = Buffer.create 17 in
    Html5.P.print ~output:(Buffer.add_string b) doc;
    Buffer.contents b
  in
  fun lang -> Lwt.return @@ f @@ html lang
