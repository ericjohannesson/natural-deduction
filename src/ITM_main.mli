(* ************************************************************************* *)
(*                                                                           *)
(*    natural-deduction: a basic proof assistant for natural deduction in    *)
(*    first-order logic.                                                     *)
(*                                                                           *)
(*    Copyright (C) 2026  Eric Johannesson, eric@ericjohannesson.com         *)
(*                                                                           *)
(*    This program is free software: you can redistribute it and/or modify   *)
(*    it under the terms of the GNU General Public License as published by   *)
(*    the Free Software Foundation, either version 3 of the License, or      *)
(*    (at your option) any later version.                                    *)
(*                                                                           *)
(*    This program is distributed in the hope that it will be useful,        *)
(*    but WITHOUT ANY WARRANTY; without even the implied warranty of         *)
(*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          *)
(*    GNU General Public License for more details.                           *)
(*                                                                           *)
(*    You should have received a copy of the GNU General Public License      *)
(*    along with this program.  If not, see <https://www.gnu.org/licenses/>. *)
(*                                                                           *)
(* ************************************************************************* *)

(**
For expanding formulas and proofs containing defined expressions, replacing each defined expression with its defining expression.
*)

(** {2 Parse } *)

exception Parse_error of string

val items_of_file : string -> ITM_types.t_itm list
(**
If [path] is the path of a file whose content conforms to the grammar specified in {{:specs/grammar/items.txt}items.txt}, then [items_of_file path] evaluates to a list of type {!type:ITM_types.t_itm}, and otherwise raises an exception.
*)


(** {2 Print } *)

val string_of_item : ITM_types.t_itm -> string

val string_of_items : ITM_types.t_itm list -> string


(** {2 Expand } *)

exception Invalid_definition of ITM_types.t_itm

exception Cannot_replace_var_with_term_containing_var_in_fml of FML_types.t_var * FML_types.t_term * FML_types.t_var * FML_types.t_fml 

val subst_free_vars_in_fml_with_terms : (FML_types.t_var -> FML_types.t_term) -> FML_types.t_fml -> FML_types.t_fml
(**
[subst_free_vars_in_fml_with_terms subst fml] evaluates to the result of simultaneously replacing every free variable in [fml] with a term according to the function [subst: t_var -> t_term].

Raises exception [Cannot_replace_var_with_term_containing_var_in_fml (var1, term, var2, fml)] if [term] contains a variable [var2] that will be bound if [term] replaces [var1] in [fml].
*)

val expand_items : ITM_types.t_itm list -> ITM_types.t_itm list
(**
Recursively expands each item on a list according to the definitions preceding it (with the most immediate predecessors being applied first).

For instance, if the head of the list is a definition, the last operation is to expand every element in the tail according to that definition.

Raises [Invalid_definition item] if [item] represents an invalid definition, e.g. 

{v P(x) := ∃yQ(y,z) v}
*)

val expand_file : string -> ITM_types.t_itm list
(**
[expand_file path] evaluates to [expand_items (items_of_file path)].
*)


