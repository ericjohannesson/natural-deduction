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
exception Error of string
exception Parse_error of string

(** Parse *)

val prf_raw_of_string : bool ->  bool -> string -> PRF_types.t_prf_raw
val prf_raw_of_file : bool -> bool -> string -> PRF_types.t_prf_raw
val prf_raw_of_stdin : bool -> bool -> PRF_types.t_prf_raw

val fml_of_string : string -> FML_types.t_fml
val prf_of_prf_raw : PRF_types.t_prf_raw -> PRF_types.t_prf
val fml_of_fml_raw : PRF_types.t_fml_raw -> FML_types.t_fml
val prf_of_file : string -> PRF_types.t_prf
val prf_of_string : string -> PRF_types.t_prf
val prf_of_stdin : unit -> PRF_types.t_prf


(** Print *)

val string_of_prf_raw : PRF_types.t_prf_raw -> string

val string_of_prf : PRF_types.t_prf -> string

(** Manipulate *)

val transform_prf : (FML_types.t_fml -> FML_types.t_fml) -> (PRF_types.t_prf) -> PRF_types.t_prf

val subst_in_prf : (PRF_types.t_prf -> PRF_types.t_prf) -> PRF_types.t_prf -> PRF_types.t_prf
