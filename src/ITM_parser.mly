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
open ITM_types

let prf_of_string (s : string) =
        PRF_main.prf_of_string s

let fml_of_string (s : string) =
        FML_main.fml_of_string s

%}


%token                                  EOF
%token <string>                         FML PRF DEF

%type <ITM_types.t_itm list> main
%start main


%%
main:
        |items EOF                              { $1 : t_itm list }
        |EOF                                    { [] : t_itm list }
;

items:
        |item                                   { ($1::[]) : t_itm list } 
        |item items                             { ($1 :: $2) : t_itm list }
;

item:
        |prf                                    { Prf $1 : t_itm }
        |def_fml                                { Def_fml $1 : t_itm }
        |def_prf                                { Def_prf $1 : t_itm }
;

def_fml:
        |def fml                                { (fml_of_string $1, $2) : t_fml * t_fml }
;

def_prf:
        |def prf                                { (prf_of_string $1, $2) : t_prf * t_prf }
;

def:
        |DEF                                    { $1 : string }
;

fml:
        |FML                                    { fml_of_string $1 : t_fml }
;

prf:
        |PRF                                    { prf_of_string $1 : t_prf }
;
