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

(** For parsing, printing, and manipulating formulas. *)

(** {2 Parse } *)


exception Parse_error of string

val fml_of_string : ?print_tokens:bool -> string -> FML_types.t_fml
(**
[fml_of_string fml] evaluates to an object of type [FML_types.t_fml] if [fml] conforms to the grammar specified in {{:specs/grammar/fml.txt}fml.txt}, and raises exception [Parse_error fml] otherwise.
*)

val fml_list_of_file : string -> FML_types.t_fml list
(**
[fml_list_of_file path] applies [fml_of_string] to each line of the file located at [path].
*)




(** {2 Print } *)

val string_of_binop : FML_types.t_binop -> string

val string_of_unop : FML_types.t_unop -> string

val string_of_quant : FML_types.t_quant -> string

val string_of_pred : FML_types.t_pred -> string

val string_of_var : FML_types.t_var -> string

val string_of_term : FML_types.t_term -> string

val string_of_fml : FML_types.t_fml -> string



(** {2 Manipulate } *)


val closed_terms_of_fml : FML_types.t_fml -> FML_types.t_term list

val is_closed_term : FML_types.t_term -> bool

val fml_is_fml_with_var_replaced_by_term : FML_types.t_fml -> FML_types.t_fml -> FML_types.t_var -> FML_types.t_term option
(**
[fml_is_fml_with_var_replaced_by_term fml1 fml2 var] evaluates to [Some term], if [term] is the first element of [closed_terms_of_fml fml1] such that [fml1 = subst_in_fml var term fml2] evaluates to [true], and to [None] if no such element exists. 
*)

val subst_in_fml : FML_types.t_var -> FML_types.t_term -> FML_types.t_fml -> FML_types.t_fml
(**
[subst_in_fml var term fml] evaluates to the result of replacing every free occurrence of [var] in [fml] with [term],
regardless of whether [term] contains variables that become bound.
*)

val vars_of_terms : FML_types.t_term list -> FML_types.t_var list
(**
Recursively lists all variables occurring in a list of terms.
*)

val free_vars_of_fml : FML_types.t_fml -> FML_types.t_var list

