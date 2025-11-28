exception Error of string

(** Parse *)

val prf_raw_of_string : bool ->  bool -> string -> ND_types.t_prf_raw
val prf_raw_of_file : bool -> bool -> string -> ND_types.t_prf_raw
val prf_raw_of_stdin : bool -> bool -> ND_types.t_prf_raw

(** Print *)

val nd_string_of_prf_raw : ND_types.t_prf_raw -> string
