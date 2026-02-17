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

let name () : string =
"NAME:

  nd - A basic proof assistant for natural deduction in first-order logic."

let synopsis () : string=
"SYNOPSIS:
  nd [ <options> ] <path-to-file>
  nd help"

let help_nd () : string =
"USAGE:

  nd [ <options> ] <path-to-file>

        Expands proofs in file according to definitions in file and checks
        validity of each expanded proof according to options.

        Prints a report to stdout."

let help_options () : string =
"  OPTIONS:

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
        sub-proofs not satisfying the conditions of any inferential rule."

let copyright () : string =
"Copyright (C) 2026  Eric Johannesson, eric@ericjohannesson.com"

let manual () : string =
        String.concat "\n\n" [
		name ();
                help_nd ();
                help_options ();
                copyright ();
        ]


let options_of_string (options : Main.t_options) (s : string) : Main.t_options =
        match s with
        |"--verbose" | "-v" -> {
                verbose = true;
                discharge = options.discharge;
                undischarge = options.undischarge;
                logic = options.logic;
                quiet = options.quiet;
        }
        |"--discharge" | "-d" -> {
                verbose = options.verbose;
                discharge = true;
                undischarge = options.undischarge;
                logic = options.logic;
                quiet = options.quiet;
        }
        |"--undischarge" | "-u" -> {
                verbose = options.verbose;
                discharge = options.discharge;
                undischarge = true;
                logic = options.logic;
                quiet = options.quiet;
        }
        |"--intuitionistic" | "-i" -> {
                verbose = options.verbose;
                discharge = options.discharge;
                undischarge = options.undischarge;
                logic = Main.Intuitionistic;
                quiet = options.quiet;
        }
        |"--minimal" | "-m" -> {
                verbose = options.verbose;
                discharge = options.discharge;
                undischarge = options.undischarge;
                logic = Main.Minimal;
                quiet = options.quiet;
        }
        |_ -> raise (Invalid_argument s)


let rec options_of_string_list (options : Main.t_options) (string_list : string list) : Main.t_options =
        match string_list with
        |[] -> options
        |hd::tl -> options_of_string_list (options_of_string options hd) tl


let execute_arg_list (arg_list : string list) : unit = 
        try
        match arg_list with
        |_::tl -> (
                match tl with
                |"help"::[] -> IO.print_to_stdout (manual ())
                |"help"::tl -> raise (Invalid_argument (String.concat " " tl))
                |option_list_path -> (
                        let default_options : Main.t_options = {
                                verbose = false;
                                discharge = false;
                                undischarge = false;
                                logic = Main.Classical;
                                quiet = true;
                        }
                        in
                        match List.rev option_list_path with
                        |path::option_list -> (
                                let options : Main.t_options = 
                                        options_of_string_list default_options option_list
                                in
                                Main.expand_and_validate_file ~options:options path
                        )
                        |_ -> raise (Invalid_argument (String.concat " " option_list_path))
                )
        )
        |_ -> raise (Invalid_argument (String.concat " " arg_list))
        with
        |ITM_main.Parse_error e
        |PRF_main.Parse_error e
        |PRF_main.Error e
        |FML_main.Parse_error e -> IO.print_to_stderr_red e
        |Invalid_argument e -> IO.print_to_stderr (String.concat "" ["invalid argument(s): ";e;"\n";synopsis ()])


