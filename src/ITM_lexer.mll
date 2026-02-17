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
open ITM_parser

let line_of_lexbuf (lexbuf : Lexing.lexbuf) : int =
        (lexbuf.Lexing.lex_curr_p).Lexing.pos_lnum

let new_lines (s : string) (b : Lexing.lexbuf) : unit =
        let rec aux (string_list : string list) : unit =
                match string_list with
                |[] -> ()
                |hd::[] -> ()
                |hd::tl-> let _ : unit = Lexing.new_line b in aux tl
        in
        aux (String.split_on_char '\n' s)
}

let prf_line = [^ '=' '\n' ':' '#']+ [^ '\n' ':' '#']* "\n"?
let prf = prf_line+
let nls = "\n"+
let fml = [^ '=' '\n' ':' '#']+ [^ ':' '\n' '#']*
(*let prf = [^ '=' '\n' ':' '#']+ [^ ':' '#']* *)
let comment = "#" [^ '\n']* "\n"
let colon = ":"
let eq = "="

rule token = parse 
        |prf as s               { let _ : unit = new_lines s lexbuf in PRF s }
        |eq nls (prf as s) nls  { let _ : unit = new_lines s lexbuf in PRF s }
        |(fml as s) colon       { DEF s }
        |eq (fml as s)          { FML s }
        |comment as s           { let _ : unit = new_lines s lexbuf in token lexbuf }
        |nls as s               { let _ : unit = new_lines s lexbuf in token lexbuf }
        |eof                    { EOF }
