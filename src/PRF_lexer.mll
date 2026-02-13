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

{
open PRF_parser
}

let rule_name = [^ '#' ';' ':']*
let fml = [^ '#' ';' ':']+
let hsep = ';'
let vsep = ':'
let rsep0 = "#0"
let rsep1 = "#1"
let rsep2 = "#2"
let rsep3 = "#3"



rule token = parse
        |hsep                                   { SEP }
        |fml as s                               { FML s }
        |rsep0 (rule_name as s)                 { NULLARY_RULE s }
        |rsep1 (rule_name as s)                 { UNARY_RULE s }
        |rsep2 (rule_name as s)                 { BINARY_RULE s }
        |rsep3 (rule_name as s)                 { TRINARY_RULE s }
        |vsep                                   { token lexbuf }
        |eof                                    { EOF }
        |_                                      { token lexbuf }


