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

(** For parsing, printing, and manipulating proofs. *)

exception Error of string

exception Parse_error of string

(** {2 Parse } *)

val prf_raw_of_prf_seq : ?print_tokens:bool -> PRF_sequencer.t_prf_seq -> PRF_types.t_prf_raw
(**
[prf_raw_of_prf_seq (Prf_seq s)] evaluates (essentially) to {!val:PRF_parser.main} {!val:PRF_lexer.token} [(Lexing.from_string s)].
*)

val prf_raw_of_string : ?print_trace:bool -> ?print_tokens:bool -> string -> PRF_types.t_prf_raw
(**
[prf_raw_of_string s] evaluates (essentially) to [prf_raw_of_prf_seq (PRF_sequencer.prf_seq_of_string s)].
*)

val prf_raw_of_file : ?print_trace:bool -> ?print_tokens:bool -> string -> PRF_types.t_prf_raw
(**
Same as [prf_raw_of_string], but reads from the file located at the given path.
*)

val prf_raw_of_stdin : ?print_trace:bool -> ?print_tokens:bool -> unit -> PRF_types.t_prf_raw
(**
Same as [prf_raw_of_string], but reads from [stdin].
*)

val fml_of_fml_raw : PRF_types.t_fml_raw -> FML_types.t_fml
(**
[fml_of_fml_raw fml_raw] evaluates to
{[
match fml_raw with
|Fml_raw (s : string) -> FML_main.fml_of_string s
]}
*)

val prf_of_prf_raw : PRF_types.t_prf_raw -> PRF_types.t_prf
(**
[prf_of_prf_raw prf_raw] evaluates to the result of applying [fml_of_fml_raw] to each formula in [prf_raw].
*)

val prf_of_file : ?print_trace:bool -> ?print_tokens:bool -> string -> PRF_types.t_prf
(**
[prf_of_file path] evaluates to [prf_of_prf_raw (prf_raw_of_file path)].
*)

val prf_of_string : ?print_trace:bool -> ?print_tokens:bool -> string -> PRF_types.t_prf
(**
[prf_of_string s] evaluates to [prf_of_prf_raw (prf_raw_of_string s)].
*)

val prf_of_stdin : ?print_trace:bool -> ?print_tokens:bool -> unit -> PRF_types.t_prf
(**
[prf_of_stdin ()] evaluates to [prf_of_prf_raw (prf_raw_of_stdin ())].
*)


(** {2 Print } *)

val string_of_prf_raw : PRF_types.t_prf_raw -> string

val string_of_prf : PRF_types.t_prf -> string

(** {2 Manipulate } *)

val transform_prf : (FML_types.t_fml -> FML_types.t_fml) -> (PRF_types.t_prf) -> PRF_types.t_prf
(**
[transform_prf subst prf] evaluates to the result of applying the function [subst : t_fml -> t_fml] to each formula in [prf].
*)

val subst_in_prf : (PRF_types.t_prf -> PRF_types.t_prf) -> PRF_types.t_prf -> PRF_types.t_prf
(**
[subst_in_prf subst prf] evaluates to the result of simultaneously replacing every atomic proof (undischarged assumption) in [prf] with another proof according to the function [subst : t_prf -> t_prf].
*)
