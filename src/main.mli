exception Error of string


(** Parse *)

val prf_raw_of_file : string -> ND_types.t_prf_raw
val prf_raw_of_string : string -> ND_types.t_prf_raw
val fml_list_of_file : string -> FML_types.t_fml list
val fml_of_string : string -> FML_types.t_fml
val prf_of_prf_raw : ND_types.t_prf_raw -> ND_types.t_prf
val fml_of_fml_raw : ND_types.t_fml_raw -> FML_types.t_fml
val prf_of_file : string -> ND_types.t_prf
val prf_of_string : string -> ND_types.t_prf


(** Print *)

val string_of_fml : FML_types.t_fml -> string
val fml_raw_of_fml : FML_types.t_fml -> ND_types.t_fml_raw
val prf_raw_of_prf : ND_types.t_prf -> ND_types.t_prf_raw
val string_of_prf : ND_types.t_prf -> string
val string_of_prf_raw : ND_types.t_prf_raw -> string


(** Expand *)

val transform_prf : (FML_types.t_fml -> FML_types.t_fml) -> (ND_types.t_prf) -> ND_types.t_prf

val transform_prf_opt : (FML_types.t_fml -> FML_types.t_fml option) -> (ND_types.t_prf) -> ND_types.t_prf option

val expand_prf_by_defs : (FML_types.t_fml * FML_types.t_fml) list -> (ND_types.t_prf) -> ND_types.t_prf option

val expand_prf_by_defs_opt : (FML_types.t_fml * FML_types.t_fml) list -> (ND_types.t_prf) -> ND_types.t_prf option

val expand_file_by_file : string list -> string -> string -> ND_types.t_prf option

val expand_file_by_file_opt : string list -> string -> string -> ND_types.t_prf option

val expand_stdin_by_file : string list -> string -> ND_types.t_prf option

val expand_stdin_by_file_opt : string list -> string -> ND_types.t_prf option

(** Validate *)

val conclusion_of_prf : ND_types.t_prf -> FML_types.t_fml
val premises_of_prf : FML_types.t_fml list -> ND_types.t_prf -> FML_types.t_fml list
val validate_prf : string list -> ND_types.t_prf -> ND_types.t_prf option
val validate_file : string list -> string -> ND_types.t_prf option
val validate_stdin : string list -> ND_types.t_prf option


(** Decompose *)

val decompose_file : string list -> string -> string -> unit
val decompose_file_raw : string list -> string -> string -> unit


(** Compose *)

val compose_prf_rec : string -> ND_types.t_prf
val compose_prf_raw_rec : string -> ND_types.t_prf_raw

val compose_dir : string list -> string -> ND_types.t_prf
val compose_dir_raw : string list -> string -> ND_types.t_prf_raw


(** Show *)

val sub_prf_of_file : (string list) -> string -> ND_types.t_prf
val sub_prf_raw_of_file : (string list) -> string -> ND_types.t_prf_raw

val sub_prf_of_stdin : (string list) -> ND_types.t_prf
val sub_prf_raw_of_stdin : (string list) -> ND_types.t_prf_raw


(** Edit *)

val subst_in_file : string -> string list -> string -> unit
val subst_in_file_raw : string -> string list -> string -> unit

val edit_file : string list -> string -> unit
val edit_file_raw : string list -> string -> unit


