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

(**
The abstract formula type (and its sub-types).
*)

type t_fml = 
        | PredApp of t_pred * (t_term list)
        | BinopApp of t_binop * t_fml * t_fml
        | UnopApp of t_unop * t_fml
        | QuantApp of t_quant * t_var * t_fml

and t_binop = Binop of string

and t_unop = Unop of string

and t_quant = Quant of string

and t_term = 
        | Atom of t_var
        | FuncApp of t_func * (t_term list)

and t_pred = Pred of string

and t_func = Func of string

and t_var = Var of string

