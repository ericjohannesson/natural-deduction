exception Parse_error of string
exception Invalid_definition of ND_types.t_item
exception Too_many_variables of (FML_types.t_var list)
exception Too_many_terms of (FML_types.t_term list)

(** Parse *)

val items_of_file : string -> ND_types.t_item list

(** Print *)

val string_of_item : ND_types.t_item -> string

val string_of_items : ND_types.t_item list -> string


(** Expand *)

val expand_items : ND_types.t_item list -> ND_types.t_item list

val expand_file : string -> ND_types.t_item list

val expand_items_alt : ND_types.t_item list -> ND_types.t_item list

val expand_file_alt : string -> ND_types.t_item list
