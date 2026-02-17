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
%}

%token <string> VAR
%token <string> PREFIX_PRED INFIX_PRED NEG_INFIX_PRED
%token <string> PREFIX_FUNC INFIX_FUNC POSTFIX_FUNC
%token <string> UNOP BINOP QUANT
%token LPAR RPAR LBR RBR COMMA
%token EOF

%left BINOP
%left INFIX_FUNC
%nonassoc UNOP QUANT
%nonassoc POSTFIX_FUNC

%start main
%type <FML_types.t_fml> main

%%
main:
        |fml EOF                        { $1 }
;

fml:
        |unop_fml                       { $1 }
        |quant_fml                      { $1 }
        |binop_fml                      { $1 }
        |atomic_fml                     { $1 }
        |par_fml                        { $1 }
;

par_fml:
        |lpar fml rpar                  { $2 }
        |lbr fml rbr                    { $2 }
;


atomic_fml:
        |nullary_pred                   { PredApp ($1,[]) }
        |prefix_pred par_terms          { PredApp ($1,$2) }
        |term infix_pred term           { PredApp ($2,[$1;$3]) }
        |term neg_infix_pred term       { UnopApp (Unop "¬", PredApp ($2,[$1;$3])) }
;

par_terms:
        |lpar terms rpar                { $2 }
        |lbr terms rbr                  { $2 }
;

unop_fml:
        |unop fml %prec UNOP            { UnopApp ($1,$2) }
;

quant_fml:
        |quant var fml %prec QUANT      { QuantApp ($1,$2,$3) }
;

binop_fml:
        |fml binop fml %prec BINOP      { BinopApp ($2,$1,$3) }
;

terms:
        |term                           { $1::[] }
        |term comma terms               { $1::$3 }
;

term:
        |var                                    { Atom $1 }
        |nullary_func                           { FuncApp ($1,[]) }
        |prefix_func par_terms                  { FuncApp ($1,$2) }
        |term infix_func term %prec INFIX_FUNC  { FuncApp ($2,[$1;$3]) }
        |term postfix_func                      { FuncApp ($2,[$1]) }
        |par_term                               { $1 }
;

par_term:
        |lpar term rpar                         { $2 }
        |lbr term rbr                           { $2 }
;

var:
        |VAR                            { Var $1 }
;

nullary_pred:
        |PREFIX_PRED                    { Pred $1 }
;

prefix_pred:
        |PREFIX_PRED                    { Pred $1 }
;

infix_pred:
        |INFIX_PRED                     { Pred $1 }
;

neg_infix_pred:
        |NEG_INFIX_PRED                 { Pred $1 }
;


nullary_func:
        |PREFIX_FUNC                    { Func $1 }
;

prefix_func:
        |PREFIX_FUNC                    { Func $1 }
;

infix_func:
        |INFIX_FUNC                     { Func $1 }
;

postfix_func:
        |POSTFIX_FUNC                   { Func $1 }
;

binop:
        |BINOP                          { Binop $1 }
;

unop:
        |UNOP                           { Unop $1 }
;

quant:
        |QUANT                          { Quant $1 }
;

lpar:
        |LPAR                           { }
;

rpar:
        |RPAR                           { }
;

lbr:
        |LBR                            { }
;

rbr:
        |RBR                            { }
;

comma:
        |COMMA                          { }
;

