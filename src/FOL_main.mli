exception Error of string

(** Parse *)

val fml_list_of_file : bool -> string -> FOL_types.t_fml list
val fml_of_string : bool -> string -> FOL_types.t_fml


(** Print *)

val string_of_fml : FOL_types.t_fml -> string

(** Manipulate *)


val closed_terms_of_fml : FOL_types.t_fml -> FOL_types.t_term list


val is_closed_term : FOL_types.t_term -> bool


val is_instance_of_with : FOL_types.t_fml -> FOL_types.t_fml -> FOL_types.t_var -> FOL_types.t_term option

val subst_in_term : FOL_types.t_var -> FOL_types.t_term -> FOL_types.t_term -> FOL_types.t_term

val subst_in_fml : FOL_types.t_var -> FOL_types.t_term -> FOL_types.t_fml -> FOL_types.t_fml

