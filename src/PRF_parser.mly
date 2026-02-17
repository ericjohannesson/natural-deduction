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
open PRF_types
%}

%token                  SEP EOF
%token <string>         NULLARY_RULE UNARY_RULE BINARY_RULE TRINARY_RULE FML

%type <t_prf_raw> main prf
%type <t_fml_raw> fml
%type <t_nullary_rule> nullary_rule
%type <t_unary_rule> unary_rule
%type <t_binary_rule> binary_rule
%type <t_trinary_rule> trinary_rule

%start main


%%
main:
        |prf EOF                                { $1 : t_prf_raw }
;

prf:
        |fml                                    { Atomic_prf_raw $1 : t_prf_raw }
        |nullary_rule fml                       { Nullary_prf_raw ($1, $2) : t_prf_raw }
        |prf unary_rule fml                     { Unary_prf_raw ($1, $2, $3) : t_prf_raw }
        |prf SEP prf binary_rule fml            { Binary_prf_raw ($1, $3, $4, $5) : t_prf_raw }
        |prf SEP prf SEP prf trinary_rule fml   { Trinary_prf_raw ($1, $3, $5, $6, $7) : t_prf_raw }
;

fml:
        |FML                                    { Fml_raw $1 : t_fml_raw }
;

nullary_rule:
        |NULLARY_RULE                           { Nullary_rule $1 : t_nullary_rule }
;

unary_rule:
        |UNARY_RULE                             { Unary_rule $1 : t_unary_rule }
;

binary_rule:
        |BINARY_RULE                            { Binary_rule $1 : t_binary_rule }
;

trinary_rule:
        |TRINARY_RULE                           { Trinary_rule $1 : t_trinary_rule }
;
