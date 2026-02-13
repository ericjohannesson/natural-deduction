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

(** For handling input and output *)


(** Input *)

let string_of_file (path:string):string =
        let ic = open_in path in
        let s = In_channel.input_all ic in
        let _ = close_in ic in s

let string_of_stdin () : string =
        In_channel.input_all stdin


(** Output *)
let print_to_file (s : string) (path : string) : unit =
        let oc = open_out path in
        let _ = output_string oc (s ^ "\n") in
        let _ = flush oc in
        let _ = close_out oc in ()

let print_to_stdout (s : string) : unit =
        print_endline s

let print_to_stderr (s:string):unit = 
        Printf.eprintf "%s\n" s

let print_to_stderr_red (s:string):unit = 
        Printf.eprintf "\027[31m%s\027[m\n" s

let print_to_stderr_green (s:string):unit = 
        Printf.eprintf "\027[32m%s\027[m\n" s

let print_to_stderr_yellow (s:string):unit = 
        Printf.eprintf "\027[33m%s\027[m\n" s

