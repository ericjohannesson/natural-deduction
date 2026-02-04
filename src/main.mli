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

type t_logic = Classical | Intuitionistic | Minimal

type t_options = {
        verbose : bool;
        discharge : bool;
        undischarge: bool;
        logic : t_logic;
        print_proof : bool;
        print_report : bool;
}


(** Parse *)

val prf_raw_of_file : string -> PRF_types.t_prf_raw
val prf_raw_of_string : string -> PRF_types.t_prf_raw

val prf_of_file : string -> PRF_types.t_prf
val prf_of_string : string -> PRF_types.t_prf
val prf_of_stdin : unit -> PRF_types.t_prf

val fml_list_of_file : string -> FML_types.t_fml list
val fml_of_string : string -> FML_types.t_fml

(** Print *)

val string_of_fml : FML_types.t_fml -> string
val string_of_prf : PRF_types.t_prf -> string
val string_of_prf_raw : PRF_types.t_prf_raw -> string

(** Validate *)

val conclusion_of_prf : PRF_types.t_prf -> FML_types.t_fml
val premises_of_prf : FML_types.t_fml list -> PRF_types.t_prf -> FML_types.t_fml list
val validate_prf : t_options -> PRF_types.t_prf -> PRF_types.t_prf option
val validate_file : t_options -> string -> PRF_types.t_prf option
val validate_stdin : t_options -> PRF_types.t_prf option

(** Expand *)

val expand_file : string -> unit

val expand_and_validate_file : t_options -> string -> unit


