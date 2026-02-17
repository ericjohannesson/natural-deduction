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

(** Lexer for parsing formula strings.
Generated from {{:../src/FML_lexer.mll}FML_lexer.mll} with ocamllex. *)

exception Cannot_unnegate of string

val canonical : string -> string
(**
Maps common notational variants of logical and mathematical terms to
their canonical counterparts, e.g. '&' ↦ '∧' and '\forall' ↦ '∀', if they have one. Otherwise returns the same string.
*)

val unnegate : string -> string
(**
Maps ["≠"] to ["="], for instance. Raises exception [Cannot_unnegate s] if [s] cannot be unnegated.
*)

val token : Stdlib.Lexing.lexbuf -> FML_parser.token

