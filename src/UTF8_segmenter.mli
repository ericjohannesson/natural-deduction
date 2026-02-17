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

(** For splitting strings into utf-8 grapheme clusters. Uses {{:https://erratique.ch/software/uuseg}Uuseg}. *)

val utf_8_segments : Uuseg.boundary -> string -> string list
(**
Splits a string by {{:https://erratique.ch/software/uuseg/doc/Uuseg/index.html#type-boundary}[Uuseg.boundary]}.
*)

val utf_8_grapheme_clusters : string -> string list
(**
evaluates to [utf_8_segments `Grapheme_cluster].
*)
