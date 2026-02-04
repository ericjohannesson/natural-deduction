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

exception ERROR of string

let rule_token (d: char) (name: string) : PRF_parser.token =
        match d with
        |'0' -> NULLARY_RULE name
        |'1' -> UNARY_RULE name
        |'2' -> BINARY_RULE name
        |'3' -> TRINARY_RULE name
        |_ -> raise (ERROR "arity of rule greater than 3")

}

let digit = ['0' '1' '2' '3']
let rule_name = [^ '#' ';' ':']*
let fml = [^ '#' ';' ':']+
let hsep = ';'
let vsep = ':'
let rsep = '#'



rule token = parse
        |hsep                                   { SEP }
        |fml as s                               { FML s }
        |rsep (digit as d) (rule_name as s)     { rule_token d s }
        |vsep                                   { token lexbuf }
        |eof                                    { EOF }
        |_                                      { token lexbuf }


