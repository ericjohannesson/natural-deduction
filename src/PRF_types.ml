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
The abstract proof types (and their sub-types).
*)


type t_fml_raw = Fml_raw of string

type t_nullary_rule = Nullary_rule of string
type t_unary_rule = Unary_rule of string
type t_binary_rule = Binary_rule of string
type t_trinary_rule = Trinary_rule of string

type t_prf_raw = 
        | Atomic_prf_raw of t_fml_raw
        | Nullary_prf_raw of (t_nullary_rule * t_fml_raw)
        | Unary_prf_raw of (t_prf_raw * t_unary_rule * t_fml_raw)
        | Binary_prf_raw of (t_prf_raw * t_prf_raw * t_binary_rule * t_fml_raw)
        | Trinary_prf_raw of (t_prf_raw * t_prf_raw * t_prf_raw * t_trinary_rule * t_fml_raw)

type t_prf =
        | Atomic_prf of FML_types.t_fml
        | Nullary_prf of (t_nullary_rule * FML_types.t_fml)
        | Unary_prf of (t_prf * t_unary_rule * FML_types.t_fml)
        | Binary_prf of (t_prf * t_prf * t_binary_rule * FML_types.t_fml)
        | Trinary_prf of (t_prf * t_prf * t_prf * t_trinary_rule * FML_types.t_fml)

