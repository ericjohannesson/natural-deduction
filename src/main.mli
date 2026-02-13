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

(** For validating natural deduction proofs in first-order \{ classical | intuitionistic | minimal \} logic. *)

exception Error of string

type t_logic = Classical | Intuitionistic | Minimal

type t_options = {
        verbose : bool;
        discharge : bool;
        undischarge: bool;
        logic : t_logic;
        quiet : bool;
}

val default_options : t_options
(**
{[= {
        verbose = false;
        discharge = false;
        undischarge = false;
        logic = Classical;
        quiet = false;
}
]}
*)


val conclusion_of_prf : PRF_types.t_prf -> FML_types.t_fml

val premises_of_prf : FML_types.t_fml list -> PRF_types.t_prf -> FML_types.t_fml list

val validate_prf : ?options:t_options -> PRF_types.t_prf -> PRF_types.t_prf option
(**
With default options, [validate_prf prf] evaluates to [Some prf] if [prf] represents a valid proof, and to [None] otherwise.
*)

val validate_file : ?options:t_options -> string -> PRF_types.t_prf option

val validate_stdin : ?options:t_options -> unit -> PRF_types.t_prf option

val expand_file : string -> unit

val expand_and_validate_file : ?options:t_options -> string -> unit


