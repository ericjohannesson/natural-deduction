(*****************************************************************************)
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
(*****************************************************************************)
exception Parse_error of string


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

val vars_of_terms : FML_types.t_term list -> FML_types.t_var list

val free_vars_of_fml : FML_types.t_fml -> FML_types.t_var list

