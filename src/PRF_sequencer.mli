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

(**
For mapping two-dimensional natural deduction proof trees onto one-dimensional proof sequences of type {!type:PRF_sequencer.t_prf_seq}.
*)


(** {2 Utf8-segmentation } *)


val matrix_of_string : string -> string array array
(**
[matrix_of_string s] forms rows by splitting [s] on character ['\n'], forms columns by applying {!val:UTF8_segmenter.utf_8_grapheme_clusters} to each row, and converts the result to arrays.
*)

val matrix_of_file : string -> string array array
(**
Same as [matrix_of_string], but reads string from file located at the provided path.
*)


(** {2 Automaton } *)

type t_state = State of int
type t_symbol = Space | Dash | Letter of string | Out
type t_action = Left | Right | Up | Down | Stay
type t_token = HSEP | RSEP of int | VSEP | FML_LETTER of string | RULE_LETTER of string
type t_stack = Stack of (int list)

type t_automaton = {
        transition : (t_state -> t_symbol -> t_stack -> t_action * t_state * t_token option * t_stack);
        end_state : t_state;
}

exception Error of string

exception Automaton_error of t_state

val default_automaton : t_automaton


(** {2 Lexer } *)


val lexer_of_matrix : ?print_trace : bool -> ?automaton:t_automaton -> string array array -> t_token list
(**
[lexer_of_matrix m] evaluates to [lexer_of_matrix ~print_trace:false ~automaton:default_automaton m].
*)

val lexer_of_string : ?print_trace : bool -> string -> t_token list
(**
[lexer_of_string s] evaluates to [lexer_of_matrix (matrix_of_string s)].
*)

val lexer_of_file : ?print_trace : bool -> string -> t_token list
(**
[lexer_of_file path] evaluates to [lexer_of_matrix (matrix_of_file path)].
*)

(** {2 Parser } *)

type t_prf_seq = Prf_seq of string

val string_of_token : t_token -> string
(**
[string_of_token token] evaluates to
{[
        match token with
        |FML_LETTER s -> s
        |RULE_LETTER s -> s
        |HSEP -> ";"
        |RSEP n -> "#" ^ (string_of_int n)
        |VSEP -> ":"
]}
*)

val prf_seq_of_string : ?print_trace : bool -> string -> t_prf_seq
(**
[prf_seq_of_string prf_tree] evaluates to [Prf_seq (String.concat "" (List.map string_of_token (lexer_of_string s)))].

If [prf_tree] is a string conforming to the grammar roughly specified in {{:specs/grammar/prf_tree.txt}prf_tree.txt}, then [prf_seq_of_string prf_tree] evaluates to [Prf_seq prf_seq], where [prf_seq] is a string conforming to the grammar specified in {{:specs/grammar/prf_seq.txt}prf_seq.txt}, and otherwise to [prf_seq_of_string ~print_trace:true prf_tree].

[prf_seq_of_string ~print_trace:true prf_tree] evaluates to the same thing, but prints the trace of {!val:default_automaton} to stderr, and raises exception [Automaton_error state] if [prf_tree] does not conform to the grammar.
*)

val prf_seq_of_file : ?print_trace:bool -> string -> t_prf_seq
(**

Same as {!val:prf_seq_of_string}, but reads from the file located at the provided path.

*)

