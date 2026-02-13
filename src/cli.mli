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

(** Comand-line interface for modules {!module:Main} and {!module:PRF_edit}. *)

val options_of_string_list : Main.t_options -> string list -> Main.t_options

val direction_list_of_string_list : string list -> PRF_edit.t_direction list


val execute_arg_list : string list -> unit
(**

Implements the follwing command-line interface:

{v

USAGE:

  nd <command>

  COMMANDS:

    \[ <options> \] <path-to-file>

        Expands proofs in file according to definitions in file and checks
        validity of each proof according to options.

        Prints a report to stdout.

    validate \[ <options> \] \{ <path-to-file> | - \}

        Prints an annotated and formatted version of proof contained in file
        to stdout, and a report to stderr, if proof is valid.

        Otherwise prints the proof and a report to stderr.

    show \[ <directions> \] \{ <path-to-file> | - \}

        Prints a formatted version of proof contained in file to stdout, or
        sub-proof thereof specified by directions.

        Prints message to stderr if no sub-proof matches directions.

    show-raw \[ <directions> \] \{ <path-to-file> | - \}

        Same as show, except that formulas are not parsed.

    edit \[ <directions> \] <path-to-file>

        Opens a formatted version of proof contained in file in nano, or
        sub-proof thereof specified by directions. Writes any changes to file,
        and prints the result to stdout.

    edit-raw \[ <directions> \] <path-to-file>

        Same as edit, except that formulas are not parsed.

    replace \[ <directions> \] <path-to-file> \{ <path-to-file> | - \}

        Prints to stdout result of replacing proof contained in first file
        (or sub-proof thereof specified by directions) with proof contained
        in second file.

    replace-raw \[ <directions> \] <path-to-file> \{ <path-to-file> | - \}

        Same as replace, except that formulas are not parsed.

    decompose \[ -R \] <path-to-directory> <path-to-file>

        Parses proof contained in file and creates a directory for each
        immediate sub-proof containing a file called 'proof.txt'. Also prints
        main proof to a file called 'proof.txt', and puts everything in
        directory.

        Does it recursively for each sub-proof if '-R' is provided.

    decompose-raw \[ -R \] <path-to-directory> <path-to-file>

        Same as decompose, except that formulas are not parsed.

    compose \[ -R \] <path-to-directory>

        Assumes that a proof has been decomposed in directory, and composes a
        proof from its immediate sub-proofs. Prints the result to stdout and
        to the file called 'proof.txt' located in directory.

        Does it recursively for each sub-proof if '-R' is provided.

    compose-raw \[ -R \] <path-to-directory>

        Same as compose, except that formulas are not parsed.

    help \[ basic | validate | show | edit | replace | decompose | compose |
           options | directions \]

        Prints manual to stdout, or part thereof specified by keyword.

    Reads from stdin if '-' is provided instead of a path (and if it may be so
    provided).

  OPTIONS:

    --discharge, -d

        Checks a version of the proof where all dischargeable assumptions are
        discharged.

    --undischarge, -u

        Checks a version of the proof where all non-dischargeable assumptions
        are undischarged.

    --intuitionistic, -i

        Uses EFQ (ex falso quodlibet) instead of negation elimination.

    --minimal, -m

        Uses neither EFQ nor negation elimination.

    --verbose, -v

        Prints information to stderr about discharged assumptions that may not
        be discharged, undischarged assumptions that may be discharged, and
        sub-proofs not satisfying the conditions of any inferential rule.

    --quiet, -q

       Supresses printing of proof and report to stderr when 'validate' is invoked.

  DIRECTIONS:

    --sub-only, -o

        Matches the (only) sub-proof of a unary proof.

    --sub-left, -l

        Matches the left sub-proof of a binary or trinary proof.

    --sub-right, -r

        Matches the right sub-proof of a binary or trinary proof.

    --sub-center, -c

        Matches the center sub-proof of a trinary proof.

    A space-separated list of directions is interpreted from left to right,
    in such a way that 

        nd show <directions> <direction> <path-to-file>

    is equivalent to

        nd show <directions> <path-to-file> | nd show <direction> -
v}

*)
