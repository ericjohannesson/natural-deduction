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

(** For validating natural deduction proofs in first-order \{ classical | intuitionistic | minimal \} logic.
For a specification of the proof system, see {{:../specifications/logic/natural_deduction_rules.txt}Natural deduction in classical first-order logic}. *)

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
(**
[premises_of_prf excluded prf] evaluates to a non-repeating list of all undsicharged assumptions of [prf], except for those in [excluded].
*)

val validate_prf : ?options:t_options -> PRF_types.t_prf -> PRF_types.t_prf option
(**
[validate_prf prf] evaluates to [Some prf] if [prf] represents a valid proof in classical first-order logic, and to [None] otherwise. Prints proof to [stdout] if proof is valid, and a report to [stderr]. Otherwise prints both proof and report to [stderr].

If [options.logic] evaluates to [Intuitionistic], then [validate_prf options prf] evaluates to [Some prf] if [prf] represents a valid proof in intuitionistic logic, and to [None] otherwise. Mutatis mutandis for [Minimal].

If [options.discharge] evaluates to [true], then a version of the proof is considered where all dischargeable assumptions are discharged.

If [options.undischarge] evaluates to [true], then a version of the proof is considered where all non-discharegeable assumptions are undischarged.

If [options.quiet] evaluates to [true], then no proof is printed to [stdout] or [stderr], and no report is printed to [stderr].
*)

val validate_file : ?options:t_options -> string -> PRF_types.t_prf option

val validate_stdin : ?options:t_options -> unit -> PRF_types.t_prf option

val expand_and_validate_file : ?options:t_options -> string -> unit
(**
[expand_and_validate_file options path] expands proofs in file located at [path] according to definitions in file and checks validity of each expanded proof according to [options]. Prints a report to [stdout].
*)

