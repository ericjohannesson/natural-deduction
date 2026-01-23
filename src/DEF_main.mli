exception Error of string

(** Parse *)

val defs_of_file : string -> (FML_types.t_fml * FML_types.t_fml) list

(** Print *)

val string_of_defs : (FML_types.t_fml * FML_types.t_fml) list -> string

(** Validate *)

val defs_are_valid : (FML_types.t_fml * FML_types.t_fml) list -> bool

(** Expand *)

val expand_fml_by_defs : (FML_types.t_fml * FML_types.t_fml) list -> FML_types.t_fml -> FML_types.t_fml

val expand_fml_by_defs_opt : (FML_types.t_fml * FML_types.t_fml) list -> FML_types.t_fml -> FML_types.t_fml option

