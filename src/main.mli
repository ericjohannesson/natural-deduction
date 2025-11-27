exception Error of string


(** Parsing *)

val prf_raw_of_file : string -> ND_types.t_prf_raw
val prf_raw_of_string : string -> ND_types.t_prf_raw
val fml_list_of_file : string -> FOL_types.t_fml list
val fml_of_string : string -> FOL_types.t_fml
val prf_of_prf_raw : ND_types.t_prf_raw -> ND_types.t_prf
val fml_of_fml_raw : ND_types.t_fml_raw -> FOL_types.t_fml
val prf_of_file : string -> ND_types.t_prf
val prf_of_string : string -> ND_types.t_prf

(** Printing *)

val string_of_fml : FOL_types.t_fml -> string
val fml_raw_of_fml : FOL_types.t_fml -> ND_types.t_fml_raw
val prf_raw_of_prf : ND_types.t_prf -> ND_types.t_prf_raw
val nd_string_of_prf : ND_types.t_prf -> string

(** Validation *)

val subst_in_term : FOL_types.t_var -> FOL_types.t_term -> FOL_types.t_term -> FOL_types.t_term
val subst_in_fml : FOL_types.t_var -> FOL_types.t_term -> FOL_types.t_fml -> FOL_types.t_fml
val conclusion_of_prf : ND_types.t_prf -> FOL_types.t_fml
val premises_of_prf : FOL_types.t_fml list -> ND_types.t_prf -> FOL_types.t_fml list
val validate_prf : string list -> ND_types.t_prf -> ND_types.t_prf option
val validate_file : string list -> string -> ND_types.t_prf option
val validate_stdin : string list -> ND_types.t_prf option


(** Decomposing *)

val decompose_file : string list -> string -> string -> unit
val decompose_file_raw : string list -> string -> string -> unit


(** Composing *)

val compose_prf_rec : string -> ND_types.t_prf
val compose_prf_raw_rec : string -> ND_types.t_prf_raw

val compose_dir : string list -> string -> ND_types.t_prf
val compose_dir_raw : string list -> string -> ND_types.t_prf_raw

(** Editing *)

val sub_prf_of_file : (string list) -> string -> ND_types.t_prf
(** 
[sub_prf_of_file directions path]
raises error if no sub-proof of proof contained in [path] matches [directions].
*)
val sub_prf_raw_of_file : (string list) -> string -> ND_types.t_prf_raw

val sub_prf_of_stdin : (string list) -> ND_types.t_prf
val sub_prf_raw_of_stdin : (string list) -> ND_types.t_prf_raw

val subst_in_file : string -> string list -> string -> unit
val subst_in_file_raw : string -> string list -> string -> unit

val edit_file : string list -> string -> unit
val edit_file_raw : string list -> string -> unit
