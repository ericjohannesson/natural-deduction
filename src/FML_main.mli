exception Parse_error of string

exception Cannot_replace_var_with_term_containing_var_in_fml of FML_types.t_var * FML_types.t_term * FML_types.t_var * FML_types.t_fml


(** Parse *)

val fml_list_of_file : bool -> string -> FML_types.t_fml list

val fml_of_string : bool -> string -> FML_types.t_fml


(** Print *)

val string_of_fml : FML_types.t_fml -> string

val string_of_term : FML_types.t_term -> string

val string_of_pred : FML_types.t_pred -> string

val string_of_var : FML_types.t_var -> string

(** Manipulate *)


val closed_terms_of_fml : FML_types.t_fml -> FML_types.t_term list

val is_closed_term : FML_types.t_term -> bool

val is_instance_of_with : FML_types.t_fml -> FML_types.t_fml -> FML_types.t_var -> FML_types.t_term option

val subst_in_fml : FML_types.t_var -> FML_types.t_term -> FML_types.t_fml -> FML_types.t_fml

val subst_in_fml_err : FML_types.t_var -> FML_types.t_term -> FML_types.t_fml -> FML_types.t_fml

val subst_in_fml_opt : FML_types.t_var -> FML_types.t_term -> FML_types.t_fml -> FML_types.t_fml option

val fml_contains_pred : FML_types.t_fml -> FML_types.t_pred -> bool

val vars_of_terms : FML_types.t_term list -> FML_types.t_var list

val free_vars_of_fml : FML_types.t_fml -> FML_types.t_var list

