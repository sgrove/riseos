open V1
open V1_LWT

module type HTTP = Cohttp_lwt.Server

module Make
    (C : CONSOLE) (Clock : PCLOCK)
    (DATA : KV_RO) (KEYS: KV_RO)
    (Http: HTTP) : sig
  val start :
    C.t -> Pclock.t ->
    DATA.t -> KEYS.t ->
    ([> `TCP of int | `TLS of Tls.Config.server * [> `TCP of int ] ] ->
     Http.t -> unit Lwt.t) ->
    unit Lwt.t

end
