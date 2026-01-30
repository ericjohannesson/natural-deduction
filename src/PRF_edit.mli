type t_direction = Only | Left | Right | Center

exception Error of string


(** Decompose *)

val decompose_file : string list -> string -> string -> unit
val decompose_file_raw : string list -> string -> string -> unit


(** Compose *)

val compose_prf_rec : string -> PRF_types.t_prf
val compose_prf_raw_rec : string -> PRF_types.t_prf_raw

val compose_dir : string list -> string -> PRF_types.t_prf
val compose_dir_raw : string list -> string -> PRF_types.t_prf_raw


(** Show *)

val sub_prf_of_file : t_direction list -> string -> PRF_types.t_prf
val sub_prf_raw_of_file : t_direction list -> string -> PRF_types.t_prf_raw

val sub_prf_of_stdin : t_direction list -> PRF_types.t_prf
val sub_prf_raw_of_stdin : t_direction list -> PRF_types.t_prf_raw


(** Edit *)

val replace_in_file : t_direction list -> string  -> string -> unit
val replace_in_file_raw : t_direction list -> string -> string -> unit

val edit_file : t_direction list -> string -> unit
val edit_file_raw : t_direction list -> string -> unit


