exception Error of string
exception Parse_error of string

(** Parse *)

val prf_raw_of_string : bool ->  bool -> string -> PRF_types.t_prf_raw
val prf_raw_of_file : bool -> bool -> string -> PRF_types.t_prf_raw
val prf_raw_of_stdin : bool -> bool -> PRF_types.t_prf_raw

val fml_of_string : string -> FML_types.t_fml
val prf_of_prf_raw : PRF_types.t_prf_raw -> PRF_types.t_prf
val fml_of_fml_raw : PRF_types.t_fml_raw -> FML_types.t_fml
val prf_of_file : string -> PRF_types.t_prf
val prf_of_string : string -> PRF_types.t_prf
val prf_of_stdin : unit -> PRF_types.t_prf


(** Print *)

val string_of_prf_raw : PRF_types.t_prf_raw -> string

val string_of_prf : PRF_types.t_prf -> string

(** Manipulate *)

val transform_prf : (FML_types.t_fml -> FML_types.t_fml) -> (PRF_types.t_prf) -> PRF_types.t_prf

val transform_prf_opt : (FML_types.t_fml -> FML_types.t_fml option) -> (PRF_types.t_prf) -> PRF_types.t_prf option


val prf_contains_pred : PRF_types.t_prf -> FML_types.t_pred -> bool

val subst_in_prf : (PRF_types.t_prf -> PRF_types.t_prf) -> PRF_types.t_prf -> PRF_types.t_prf
