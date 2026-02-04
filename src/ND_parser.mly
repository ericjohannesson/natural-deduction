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
%{
open FML_types
open PRF_types
open ND_types
%}


%token                                  EOF
%token <ND_types.t_def_token>           DEF
%token <string>                         FML PRF

%type <ND_types.t_item list> main
%start main


%%
main:
        |items EOF                              { $1 : t_item list }
        |EOF                                    { [] : t_item list }
;

items:
        |item                                   { ($1::[]) : t_item list } 
        |item items                                     { ($1 :: $2) : t_item list }
;

item:
        |prf                                    { Prf $1 : t_item }
        |def_fml                                { Def_fml $1 : t_item }
        |def_prf                                { Def_prf $1 : t_item }
;

def_fml:
        |def fml                                { (PRF_main.fml_of_string $1.content, $2, $1.line) : t_fml * t_fml * int }
;

def_prf:
        |def prf                                { (PRF_main.prf_of_string $1.content, $2, $1.line) : t_prf * t_prf * int }
;

def:
        |DEF                                    { $1 : t_def_token }
;

fml:
        |FML                                    { PRF_main.fml_of_string $1 : t_fml }
;

prf:
        |PRF                                    { PRF_main.prf_of_string $1 : t_prf }
;
