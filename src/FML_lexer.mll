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
open FML_parser

exception Cannot_unnegate of string

let canonical (s : string) : string =
        match s with
        |"\\forall" | "\\A" | "∀" -> "∀"
        |"\\exists" | "\\E" | "∃" -> "∃"
        |"\\neg" | "~" | "¬" -> "¬"
        |"\\land" | "\\wedge" | "&" | "∧" -> "∧"
        |"\\lor" | "\\vee" | "∨" -> "∨"
        |"\\to" | "\\rightarrow" | "->" | "→" -> "→"
        |"\\leftrightarrow" | "<->" | "↔" -> "↔"
        |"\\in" | "∈" -> "∈"
        |"\\subset" | "⊂" -> "⊂"
        |"\\subseteq" | "⊆" -> "⊆"
        |"\\times" | "×" -> "×"
        |"\\cdot" | "·" -> "·"
        |"\\cap" | "∩" -> "∩"
        |"\\cup" | "∪" -> "∪"
        |_ -> s

let unnegate (s : string) : string =
        match s with
        |"≠" | "\\neq" -> "="
        |"∉" | "\\not\\in" | "\\not \\in" |"\\notin" -> "∈"
        |_ -> raise (Cannot_unnegate s)
}


let forall = "∀" | "\\forall" | "\\A"
let exists = "∃" | "\\exists" | "\\E"
let impl = "→" | "\\to" | "\\rightarrow" | "->"
let conj = "∧" | "\\land" | "\\wedge" | "&"
let disj = "∨" | "\\lor" | "\\vee"
let eqv = "↔" | "\\leftrightarrow" | "<->"
let neg = "¬" | "\\neg" | "~"
let eq = "="
let neq = "≠" | "\\neq"

let plus = "+"
let times = "\\times" | "×" 
let star =  "*" 
let cdot = "\\cdot" | "·"
let minus = "-"
let le = "<"
let ge = ">"
let leq = "≤" | "\\leq"
let geq = "≥" | "\\geq"
let prime = "\'"
let pwr2 = "²"
let pwr3 = "³"
let hat = "^"

let el = "∈" | "\\in"
let nel = "∉" | "\\not\\in" | "\\not \\in" | "\\notin"
let subset = "⊂" | "\\subset"
let subseteq = "⊆" | "\\subseteq"
let cap = "\\cap" | "∩"
let cup = "\\cup" | "∪"

let prefix_func = ['a' - 't'] (['_' '.'] | ['a' - 'z'] | ['0' - '9'])* | ['0' - '9']+
let var = ['u' - 'z'] (['_' '.'] | ['a' - 'z'] | ['0' - '9'])*
let prefix_pred = ['A' - 'Z'] (['_' '.'] | ['A' - 'Z'] | ['a' - 'z'] | ['0' - '9'])*
let comma = ","
let lpar = "("
let rpar = ")"
let lbr = "["
let rbr = "]"
let quant = forall | exists
let unop = neg
let binop = conj | disj | impl | eqv
let infix_func = plus | times | star | cdot | minus | cap | cup | hat
let infix_pred = le | ge | leq | geq | eq | el | subset | subseteq
let neg_infix_pred = neq | nel
let postfix_func = prime | pwr2 | pwr3

rule token = parse
        | comma                 { COMMA }
        | lpar                  { LPAR }
        | rpar                  { RPAR }
        | lbr                   { LBR }
        | rbr                   { RBR }
        | var as e              { VAR e }
        | prefix_func as e      { PREFIX_FUNC e }
        | infix_func as e       { INFIX_FUNC (canonical e) }
        | postfix_func as e     { POSTFIX_FUNC e }
        | prefix_pred as e      { PREFIX_PRED e }
        | infix_pred as e       { INFIX_PRED (canonical e) }
        | neg_infix_pred as e   { NEG_INFIX_PRED (unnegate e) }
        | quant as e            { QUANT (canonical e) }
        | unop as e             { UNOP (canonical e) }
        | binop as e            { BINOP (canonical e) }
        | eof                   { EOF }
        | _                     { token lexbuf }
