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

(** Parser for mapping objects of type {!type:PRF_sequencer.t_prf_seq} to objects of type {!type:PRF_types.t_prf}.
Generated from {{:../src/PRF_parser.mly}PRF_parser.mly} with {{:https://gallium.inria.fr/~fpottier/menhir/}Menhir}. *)


type token = 
|       UNARY_RULE of string
|       TRINARY_RULE of string
|       SEP
|       NULLARY_RULE of string
|       FML of string
|       EOF
|       BINARY_RULE of string

exception Error of int

val main : (Lexing.lexbuf -> token) -> Lexing.lexbuf -> PRF_types.t_prf_raw
