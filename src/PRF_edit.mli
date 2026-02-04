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
type t_direction = Only | Left | Right | Center

exception Error of string


(** Decompose *)

val decompose_file : bool -> string -> string -> unit
val decompose_file_raw : bool -> string -> string -> unit


(** Compose *)

val compose_prf_rec : string -> PRF_types.t_prf
val compose_prf_raw_rec : string -> PRF_types.t_prf_raw

val compose_dir : bool -> string -> PRF_types.t_prf
val compose_dir_raw : bool -> string -> PRF_types.t_prf_raw


(** Show *)

val sub_prf_of_file : t_direction list -> string -> PRF_types.t_prf
val sub_prf_raw_of_file : t_direction list -> string -> PRF_types.t_prf_raw

val sub_prf_of_stdin : t_direction list -> PRF_types.t_prf
val sub_prf_raw_of_stdin : t_direction list -> PRF_types.t_prf_raw


(** Edit *)

val replace_in_file : t_direction list -> string  -> string -> unit
val replace_in_file_raw : t_direction list -> string -> string -> unit

val edit_file : t_direction list -> string -> unit
val edit_file_raw : t_direction list -> string -> unit


