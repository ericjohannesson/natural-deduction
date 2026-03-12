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

(** Parser for mapping objects of type {!type:PRF_sequencer.t_prf_seq} to objects of type {!type:PRF_types.t_prf_raw}.
Generated from {{:specs/PRF_parser.mly.txt}PRF_parser.mly} with ocamlyacc. *)


type token =
        SEP
      | EOF
      | NULLARY_RULE of string
      | UNARY_RULE of string
      | BINARY_RULE of string
      | TRINARY_RULE of string
      | FML of string

val main :
      (Lexing.lexbuf -> token) ->
      Lexing.lexbuf -> Natural_deduction.PRF_types.t_prf_raw

