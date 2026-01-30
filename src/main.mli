exception Error of string

type t_options = {
	verbose : bool;
	discharge : bool;
	undischarge: bool;
	print_proof : bool;
	print_report : bool;
}


(** Parse *)

val prf_raw_of_file : string -> PRF_types.t_prf_raw
val prf_raw_of_string : string -> PRF_types.t_prf_raw

val prf_of_file : string -> PRF_types.t_prf
val prf_of_string : string -> PRF_types.t_prf
val prf_of_stdin : unit -> PRF_types.t_prf

val fml_list_of_file : string -> FML_types.t_fml list
val fml_of_string : string -> FML_types.t_fml

(** Print *)

val string_of_fml : FML_types.t_fml -> string
val string_of_prf : PRF_types.t_prf -> string
val string_of_prf_raw : PRF_types.t_prf_raw -> string

(** Validate *)

val conclusion_of_prf : PRF_types.t_prf -> FML_types.t_fml
val premises_of_prf : FML_types.t_fml list -> PRF_types.t_prf -> FML_types.t_fml list
val validate_prf : t_options -> PRF_types.t_prf -> PRF_types.t_prf option
val validate_file : t_options -> string -> PRF_types.t_prf option
val validate_stdin : t_options -> PRF_types.t_prf option

(** Expand *)

val expand_file : string -> unit

val expand_and_validate_file : t_options -> string -> unit


