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
exception Invalid_definition of ND_types.t_item
exception Cannot_replace_var_with_term_containing_var_in_fml of FML_types.t_var * FML_types.t_term * FML_types.t_var * FML_types.t_fml 

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



