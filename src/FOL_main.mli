exception Error of string

(** Parse *)

val fml_list_of_file : bool -> string -> FOL_types.t_fml list
val fml_of_string : bool -> string -> FOL_types.t_fml


(** Print *)

val string_of_fml : FOL_types.t_fml -> string
