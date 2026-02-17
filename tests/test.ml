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

open FML_types
open FML_main

open PRF_types
open PRF_main

open Main

let options : t_options = {
        verbose = false;
        discharge = false;
        undischarge = false;
        logic = Classical;
        quiet = true;
}


let input_dir : string = "examples/"

let prf0_in : string = input_dir ^ "prf0"

let prf0_out_raw : PRF_types.t_prf_raw =
PRF_types.Binary_prf_raw
 (PRF_types.Atomic_prf_raw (PRF_types.Fml_raw "good bye"),
  PRF_types.Atomic_prf_raw (PRF_types.Fml_raw "cruel"),
  PRF_types.Binary_rule "", PRF_types.Fml_raw "world")

let prf1_in :string = input_dir ^ "prf1"

let prf1_out_raw : PRF_types.t_prf_raw =
PRF_types.Binary_prf_raw
 (PRF_types.Unary_prf_raw
   (PRF_types.Binary_prf_raw
     (PRF_types.Unary_prf_raw
       (PRF_types.Atomic_prf_raw (PRF_types.Fml_raw "U"),
        PRF_types.Unary_rule "∧E", PRF_types.Fml_raw "A"),
      PRF_types.Trinary_prf_raw
       (PRF_types.Atomic_prf_raw (PRF_types.Fml_raw "X"),
        PRF_types.Atomic_prf_raw (PRF_types.Fml_raw "Y"),
        PRF_types.Atomic_prf_raw (PRF_types.Fml_raw "Z"),
        PRF_types.Trinary_rule "∨E", PRF_types.Fml_raw "B"),
      PRF_types.Binary_rule "", PRF_types.Fml_raw "C"),
    PRF_types.Unary_rule "∃I", PRF_types.Fml_raw "Hello"),
  PRF_types.Binary_prf_raw
   (PRF_types.Atomic_prf_raw (PRF_types.Fml_raw "g"),
    PRF_types.Atomic_prf_raw (PRF_types.Fml_raw "(h→i)"),
    PRF_types.Binary_rule "", PRF_types.Fml_raw "world"),
  PRF_types.Binary_rule "∧I", PRF_types.Fml_raw "conclusion")


let prf2_in : string = input_dir ^ "prf2"

let prf2_out_raw : PRF_types.t_prf_raw =
PRF_types.Binary_prf_raw
 (PRF_types.Unary_prf_raw
   (PRF_types.Binary_prf_raw
     (PRF_types.Unary_prf_raw
       (PRF_types.Nullary_prf_raw
         (PRF_types.Nullary_rule "", PRF_types.Fml_raw "U"),
        PRF_types.Unary_rule "∧E", PRF_types.Fml_raw "A"),
      PRF_types.Trinary_prf_raw
       (PRF_types.Nullary_prf_raw
         (PRF_types.Nullary_rule "", PRF_types.Fml_raw "X"),
        PRF_types.Atomic_prf_raw (PRF_types.Fml_raw "Y"),
        PRF_types.Atomic_prf_raw (PRF_types.Fml_raw "Z"),
        PRF_types.Trinary_rule "∨E", PRF_types.Fml_raw "B"),
      PRF_types.Binary_rule "", PRF_types.Fml_raw "C"),
    PRF_types.Unary_rule "∃I", PRF_types.Fml_raw "He llo"),
  PRF_types.Binary_prf_raw
   (PRF_types.Atomic_prf_raw (PRF_types.Fml_raw "g"),
    PRF_types.Atomic_prf_raw (PRF_types.Fml_raw "(h → i)"),
    PRF_types.Binary_rule "", PRF_types.Fml_raw "wor ld"),
  PRF_types.Binary_rule "", PRF_types.Fml_raw "conclusion")

let prf3_in : string = input_dir ^ "prf3"

let prf3_out_raw : PRF_types.t_prf_raw =
PRF_types.Binary_prf_raw
 (PRF_types.Unary_prf_raw
   (PRF_types.Atomic_prf_raw (PRF_types.Fml_raw "∀x(x+0=x)"),
    PRF_types.Unary_rule "", PRF_types.Fml_raw "0'+0=0'"),
  PRF_types.Unary_prf_raw
   (PRF_types.Unary_prf_raw
     (PRF_types.Atomic_prf_raw (PRF_types.Fml_raw "∀x∀y(x+y'=(x+y)')"),
      PRF_types.Unary_rule "", PRF_types.Fml_raw "∀y(0'+y'=(0'+y)')"),
    PRF_types.Unary_rule "", PRF_types.Fml_raw "0'+0'=(0'+0)'"),
  PRF_types.Binary_rule "", PRF_types.Fml_raw "0'+0'=0''")



let prf3_out : PRF_types.t_prf =
PRF_types.Binary_prf
 (PRF_types.Unary_prf
   (PRF_types.Atomic_prf
     (FML_types.QuantApp (FML_types.Quant "∀", FML_types.Var "x",
       FML_types.PredApp (FML_types.Pred "=",
        [FML_types.FuncApp (FML_types.Func "+",
          [FML_types.Atom (FML_types.Var "x");
           FML_types.FuncApp (FML_types.Func "0", [])]);
         FML_types.Atom (FML_types.Var "x")]))),
    PRF_types.Unary_rule "",
    FML_types.PredApp (FML_types.Pred "=",
     [FML_types.FuncApp (FML_types.Func "+",
       [FML_types.FuncApp (FML_types.Func "'",
         [FML_types.FuncApp (FML_types.Func "0", [])]);
        FML_types.FuncApp (FML_types.Func "0", [])]);
      FML_types.FuncApp (FML_types.Func "'",
       [FML_types.FuncApp (FML_types.Func "0", [])])])),
  PRF_types.Unary_prf
   (PRF_types.Unary_prf
     (PRF_types.Atomic_prf
       (FML_types.QuantApp (FML_types.Quant "∀", FML_types.Var "x",
         FML_types.QuantApp (FML_types.Quant "∀", FML_types.Var "y",
          FML_types.PredApp (FML_types.Pred "=",
           [FML_types.FuncApp (FML_types.Func "+",
             [FML_types.Atom (FML_types.Var "x");
              FML_types.FuncApp (FML_types.Func "'",
               [FML_types.Atom (FML_types.Var "y")])]);
            FML_types.FuncApp (FML_types.Func "'",
             [FML_types.FuncApp (FML_types.Func "+",
               [FML_types.Atom (FML_types.Var "x");
                FML_types.Atom (FML_types.Var "y")])])])))),
      PRF_types.Unary_rule "",
      FML_types.QuantApp (FML_types.Quant "∀", FML_types.Var "y",
       FML_types.PredApp (FML_types.Pred "=",
        [FML_types.FuncApp (FML_types.Func "+",
          [FML_types.FuncApp (FML_types.Func "'",
            [FML_types.FuncApp (FML_types.Func "0", [])]);
           FML_types.FuncApp (FML_types.Func "'",
            [FML_types.Atom (FML_types.Var "y")])]);
         FML_types.FuncApp (FML_types.Func "'",
          [FML_types.FuncApp (FML_types.Func "+",
            [FML_types.FuncApp (FML_types.Func "'",
              [FML_types.FuncApp (FML_types.Func "0", [])]);
             FML_types.Atom (FML_types.Var "y")])])]))),
    PRF_types.Unary_rule "",
    FML_types.PredApp (FML_types.Pred "=",
     [FML_types.FuncApp (FML_types.Func "+",
       [FML_types.FuncApp (FML_types.Func "'",
         [FML_types.FuncApp (FML_types.Func "0", [])]);
        FML_types.FuncApp (FML_types.Func "'",
         [FML_types.FuncApp (FML_types.Func "0", [])])]);
      FML_types.FuncApp (FML_types.Func "'",
       [FML_types.FuncApp (FML_types.Func "+",
         [FML_types.FuncApp (FML_types.Func "'",
           [FML_types.FuncApp (FML_types.Func "0", [])]);
          FML_types.FuncApp (FML_types.Func "0", [])])])])),
  PRF_types.Binary_rule "",
  FML_types.PredApp (FML_types.Pred "=",
   [FML_types.FuncApp (FML_types.Func "+",
     [FML_types.FuncApp (FML_types.Func "'",
       [FML_types.FuncApp (FML_types.Func "0", [])]);
      FML_types.FuncApp (FML_types.Func "'",
       [FML_types.FuncApp (FML_types.Func "0", [])])]);
    FML_types.FuncApp (FML_types.Func "'",
     [FML_types.FuncApp (FML_types.Func "'",
       [FML_types.FuncApp (FML_types.Func "0", [])])])]))


let prf4_in : string = input_dir ^ "prf4"

let prf4_out_raw : PRF_types.t_prf_raw =
PRF_types.Unary_prf_raw
 (PRF_types.Nullary_prf_raw (PRF_types.Nullary_rule "", PRF_types.Fml_raw "P"),
  PRF_types.Unary_rule "", PRF_types.Fml_raw "(P → P)")

let prf4_out : PRF_types.t_prf =
PRF_types.Unary_prf
 (PRF_types.Nullary_prf
   (PRF_types.Nullary_rule "", FML_types.PredApp (FML_types.Pred "P", [])),
  PRF_types.Unary_rule "",
  FML_types.BinopApp (FML_types.Binop "→",
   FML_types.PredApp (FML_types.Pred "P", []),
   FML_types.PredApp (FML_types.Pred "P", [])))

let prf5_in : string = input_dir ^ "prf5"

let prf5_out_raw : PRF_types.t_prf_raw =
PRF_types.Binary_prf_raw
 (PRF_types.Nullary_prf_raw (PRF_types.Nullary_rule "", PRF_types.Fml_raw "P"),
  PRF_types.Atomic_prf_raw (PRF_types.Fml_raw "Q"), PRF_types.Binary_rule "",
  PRF_types.Fml_raw "(P ∧ Q)")


let prf5_out : PRF_types.t_prf =
PRF_types.Binary_prf
 (PRF_types.Nullary_prf
   (PRF_types.Nullary_rule "", FML_types.PredApp (FML_types.Pred "P", [])),
  PRF_types.Atomic_prf (FML_types.PredApp (FML_types.Pred "Q", [])),
  PRF_types.Binary_rule "",
  FML_types.BinopApp (FML_types.Binop "∧",
   FML_types.PredApp (FML_types.Pred "P", []),
   FML_types.PredApp (FML_types.Pred "Q", [])))

let prf6_in : string = input_dir ^ "prf6"

let prf6_out_raw : PRF_types.t_prf_raw =
PRF_types.Unary_prf_raw
 (PRF_types.Nullary_prf_raw (PRF_types.Nullary_rule "", PRF_types.Fml_raw "a=a"),
  PRF_types.Unary_rule "", PRF_types.Fml_raw "∀x(x=x)")


let prf6_out : PRF_types.t_prf =
PRF_types.Unary_prf
   (PRF_types.Nullary_prf
     (PRF_types.Nullary_rule "",
      FML_types.PredApp (FML_types.Pred "=",
       [FML_types.FuncApp (FML_types.Func "a", []);
        FML_types.FuncApp (FML_types.Func "a", [])])),
    PRF_types.Unary_rule "",
    FML_types.QuantApp (FML_types.Quant "∀", FML_types.Var "x",
     FML_types.PredApp (FML_types.Pred "=",
      [FML_types.Atom (FML_types.Var "x");
       FML_types.Atom (FML_types.Var "x")])))

let prf7_in : string = input_dir ^ "prf7"

let prf7_out_raw : PRF_types.t_prf_raw =
PRF_types.Binary_prf_raw
 (PRF_types.Unary_prf_raw
   (PRF_types.Binary_prf_raw
     (PRF_types.Unary_prf_raw
       (PRF_types.Nullary_prf_raw
         (PRF_types.Nullary_rule "1", PRF_types.Fml_raw "P"),
        PRF_types.Unary_rule "", PRF_types.Fml_raw "(P \\lor \\neg P)"),
      PRF_types.Nullary_prf_raw
       (PRF_types.Nullary_rule "2",
        PRF_types.Fml_raw "\\neg (P \\lor \\neg P)"),
      PRF_types.Binary_rule "¬I,1", PRF_types.Fml_raw "\\neg P"),
    PRF_types.Unary_rule "", PRF_types.Fml_raw "(P \\lor \\neg P)"),
  PRF_types.Nullary_prf_raw
   (PRF_types.Nullary_rule "2", PRF_types.Fml_raw "\\neg (P \\lor \\neg P)"),
  PRF_types.Binary_rule "¬E,2", PRF_types.Fml_raw "(P \\lor \\neg P)")

let prf7_out : PRF_types.t_prf =
PRF_types.Binary_prf
 (PRF_types.Unary_prf
   (PRF_types.Binary_prf
     (PRF_types.Unary_prf
       (PRF_types.Nullary_prf
         (PRF_types.Nullary_rule "1",
          FML_types.PredApp (FML_types.Pred "P", [])),
        PRF_types.Unary_rule "",
        FML_types.BinopApp (FML_types.Binop "∨",
         FML_types.PredApp (FML_types.Pred "P", []),
         FML_types.UnopApp (FML_types.Unop "¬",
          FML_types.PredApp (FML_types.Pred "P", [])))),
      PRF_types.Nullary_prf
       (PRF_types.Nullary_rule "2",
        FML_types.UnopApp (FML_types.Unop "¬",
         FML_types.BinopApp (FML_types.Binop "∨",
          FML_types.PredApp (FML_types.Pred "P", []),
          FML_types.UnopApp (FML_types.Unop "¬",
           FML_types.PredApp (FML_types.Pred "P", []))))),
      PRF_types.Binary_rule "¬I,1",
      FML_types.UnopApp (FML_types.Unop "¬",
       FML_types.PredApp (FML_types.Pred "P", []))),
    PRF_types.Unary_rule "",
    FML_types.BinopApp (FML_types.Binop "∨",
     FML_types.PredApp (FML_types.Pred "P", []),
     FML_types.UnopApp (FML_types.Unop "¬",
      FML_types.PredApp (FML_types.Pred "P", [])))),
  PRF_types.Nullary_prf
   (PRF_types.Nullary_rule "2",
    FML_types.UnopApp (FML_types.Unop "¬",
     FML_types.BinopApp (FML_types.Binop "∨",
      FML_types.PredApp (FML_types.Pred "P", []),
      FML_types.UnopApp (FML_types.Unop "¬",
       FML_types.PredApp (FML_types.Pred "P", []))))),
  PRF_types.Binary_rule "¬E,2",
  FML_types.BinopApp (FML_types.Binop "∨",
   FML_types.PredApp (FML_types.Pred "P", []),
   FML_types.UnopApp (FML_types.Unop "¬",
    FML_types.PredApp (FML_types.Pred "P", []))))

let prf8_in : string = input_dir ^ "prf8"

let prf8_out_raw : PRF_types.t_prf_raw =
PRF_types.Binary_prf_raw
 (PRF_types.Unary_prf_raw
   (PRF_types.Nullary_prf_raw
     (PRF_types.Nullary_rule "1", PRF_types.Fml_raw "P"),
    PRF_types.Unary_rule "", PRF_types.Fml_raw "(P \\lor \\neg P)"),
  PRF_types.Nullary_prf_raw
   (PRF_types.Nullary_rule "", PRF_types.Fml_raw "\\neg (P \\lor \\neg P)"),
  PRF_types.Binary_rule "¬I,1", PRF_types.Fml_raw "\\neg P")

let prf8_out : PRF_types.t_prf =
PRF_types.Binary_prf
 (PRF_types.Unary_prf
   (PRF_types.Nullary_prf
     (PRF_types.Nullary_rule "1", FML_types.PredApp (FML_types.Pred "P", [])),
    PRF_types.Unary_rule "",
    FML_types.BinopApp (FML_types.Binop "∨",
     FML_types.PredApp (FML_types.Pred "P", []),
     FML_types.UnopApp (FML_types.Unop "¬",
      FML_types.PredApp (FML_types.Pred "P", [])))),
  PRF_types.Nullary_prf
   (PRF_types.Nullary_rule "",
    FML_types.UnopApp (FML_types.Unop "¬",
     FML_types.BinopApp (FML_types.Binop "∨",
      FML_types.PredApp (FML_types.Pred "P", []),
      FML_types.UnopApp (FML_types.Unop "¬",
       FML_types.PredApp (FML_types.Pred "P", []))))),
  PRF_types.Binary_rule "¬I,1",
  FML_types.UnopApp (FML_types.Unop "¬",
   FML_types.PredApp (FML_types.Pred "P", [])))


let prf9_in : string = input_dir ^ "prf9"
let prf10_in : string = input_dir ^ "prf10"
let prf11_in : string = input_dir ^ "prf11"
let prf12_in : string = input_dir ^ "prf12"
let prf31_in : string = input_dir ^ "prf31"
let prf32_in : string = input_dir ^ "prf32"
let prf33_in : string = input_dir ^ "prf33"
let prf20_in : string = input_dir ^ "prf20"
let prf14_in : string = input_dir ^ "prf14"
let prf15_in : string = input_dir ^ "prf15"
let prf16_in : string = input_dir ^ "prf16"


let prf3_valid = Some
 (Binary_prf
   (Unary_prf
     (Atomic_prf
       (QuantApp (Quant "∀", Var "x",
         PredApp (Pred "=",
          [FuncApp (Func "+", [Atom (Var "x"); FuncApp (Func "0", [])]);
           Atom (Var "x")]))),
      Unary_rule "∀E",
      PredApp (Pred "=",
       [FuncApp (Func "+",
         [FuncApp (Func "'", [FuncApp (Func "0", [])]); FuncApp (Func "0", [])]);
        FuncApp (Func "'", [FuncApp (Func "0", [])])])),
    Unary_prf
     (Unary_prf
       (Atomic_prf
         (QuantApp (Quant "∀", Var "x",
           QuantApp (Quant "∀", Var "y",
            PredApp (Pred "=",
             [FuncApp (Func "+",
               [Atom (Var "x"); FuncApp (Func "'", [Atom (Var "y")])]);
              FuncApp (Func "'",
               [FuncApp (Func "+", [Atom (Var "x"); Atom (Var "y")])])])))),
        Unary_rule "∀E",
        QuantApp (Quant "∀", Var "y",
         PredApp (Pred "=",
          [FuncApp (Func "+",
            [FuncApp (Func "'", [FuncApp (Func "0", [])]);
             FuncApp (Func "'", [Atom (Var "y")])]);
           FuncApp (Func "'",
            [FuncApp (Func "+",
              [FuncApp (Func "'", [FuncApp (Func "0", [])]); Atom (Var "y")])])]))),
      Unary_rule "∀E",
      PredApp (Pred "=",
       [FuncApp (Func "+",
         [FuncApp (Func "'", [FuncApp (Func "0", [])]);
          FuncApp (Func "'", [FuncApp (Func "0", [])])]);
        FuncApp (Func "'",
         [FuncApp (Func "+",
           [FuncApp (Func "'", [FuncApp (Func "0", [])]);
            FuncApp (Func "0", [])])])])),
    Binary_rule "=E",
    PredApp (Pred "=",
     [FuncApp (Func "+",
       [FuncApp (Func "'", [FuncApp (Func "0", [])]);
        FuncApp (Func "'", [FuncApp (Func "0", [])])]);
      FuncApp (Func "'", [FuncApp (Func "'", [FuncApp (Func "0", [])])])])))


let prf31_valid =Some
 (Binary_prf
   (Atomic_prf
     (PredApp (Pred "=",
       [FuncApp (Func "+",
         [FuncApp (Func "'", [FuncApp (Func "0", [])]); FuncApp (Func "0", [])]);
        FuncApp (Func "'", [FuncApp (Func "0", [])])])),
    Atomic_prf
     (PredApp (Pred "=",
       [FuncApp (Func "+",
         [FuncApp (Func "'", [FuncApp (Func "0", [])]);
          FuncApp (Func "'", [FuncApp (Func "0", [])])]);
        FuncApp (Func "'",
         [FuncApp (Func "+",
           [FuncApp (Func "'", [FuncApp (Func "0", [])]);
            FuncApp (Func "0", [])])])])),
    Binary_rule "=E",
    PredApp (Pred "=",
     [FuncApp (Func "+",
       [FuncApp (Func "'", [FuncApp (Func "0", [])]);
        FuncApp (Func "'", [FuncApp (Func "0", [])])]);
      FuncApp (Func "'", [FuncApp (Func "'", [FuncApp (Func "0", [])])])])))

let prf32_valid = Some
 (Unary_prf
   (Unary_prf
     (Atomic_prf
       (QuantApp (Quant "∀", Var "x",
         QuantApp (Quant "∀", Var "y",
          PredApp (Pred "=",
           [FuncApp (Func "+",
             [Atom (Var "x"); FuncApp (Func "'", [Atom (Var "y")])]);
            FuncApp (Func "'",
             [FuncApp (Func "+", [Atom (Var "x"); Atom (Var "y")])])])))),
      Unary_rule "∀E",
      QuantApp (Quant "∀", Var "y",
       PredApp (Pred "=",
        [FuncApp (Func "+",
          [FuncApp (Func "'", [FuncApp (Func "0", [])]);
           FuncApp (Func "'", [Atom (Var "y")])]);
         FuncApp (Func "'",
          [FuncApp (Func "+",
            [FuncApp (Func "'", [FuncApp (Func "0", [])]); Atom (Var "y")])])]))),
    Unary_rule "∀E",
    PredApp (Pred "=",
     [FuncApp (Func "+",
       [FuncApp (Func "'", [FuncApp (Func "0", [])]);
        FuncApp (Func "'", [FuncApp (Func "0", [])])]);
      FuncApp (Func "'",
       [FuncApp (Func "+",
         [FuncApp (Func "'", [FuncApp (Func "0", [])]); FuncApp (Func "0", [])])])])))

let prf33_valid = Some
 (Unary_prf
   (Atomic_prf
     (QuantApp (Quant "∀", Var "x",
       QuantApp (Quant "∀", Var "y",
        PredApp (Pred "=",
         [FuncApp (Func "+",
           [Atom (Var "x"); FuncApp (Func "'", [Atom (Var "y")])]);
          FuncApp (Func "'",
           [FuncApp (Func "+", [Atom (Var "x"); Atom (Var "y")])])])))),
    Unary_rule "∀E",
    QuantApp (Quant "∀", Var "y",
     PredApp (Pred "=",
      [FuncApp (Func "+",
        [FuncApp (Func "'", [FuncApp (Func "0", [])]);
         FuncApp (Func "'", [Atom (Var "y")])]);
       FuncApp (Func "'",
        [FuncApp (Func "+",
          [FuncApp (Func "'", [FuncApp (Func "0", [])]); Atom (Var "y")])])]))))


let prf4_valid = Some
 (Unary_prf
   (Nullary_prf (Nullary_rule "0", PredApp (Pred "P", [])), Unary_rule "→I0",
    BinopApp (Binop "→", PredApp (Pred "P", []), PredApp (Pred "P", []))))

let prf5_valid = None

let prf6_valid = Some
 (Unary_prf
   (Nullary_prf
     (Nullary_rule "=I",
      PredApp (Pred "=", [FuncApp (Func "a", []); FuncApp (Func "a", [])])),
    Unary_rule "∀I",
    QuantApp (Quant "∀", Var "x",
     PredApp (Pred "=", [Atom (Var "x"); Atom (Var "x")]))))

let prf7_valid = Some
 (Binary_prf
   (Unary_prf
     (Binary_prf
       (Unary_prf
         (Nullary_prf (Nullary_rule "1", PredApp (Pred "P", [])),
          Unary_rule "∨I",
          BinopApp (Binop "∨", PredApp (Pred "P", []),
           UnopApp (Unop "¬", PredApp (Pred "P", [])))),
        Nullary_prf
         (Nullary_rule "0",
          UnopApp (Unop "¬",
           BinopApp (Binop "∨", PredApp (Pred "P", []),
            UnopApp (Unop "¬", PredApp (Pred "P", []))))),
        Binary_rule "¬I1", UnopApp (Unop "¬", PredApp (Pred "P", []))),
      Unary_rule "∨I",
      BinopApp (Binop "∨", PredApp (Pred "P", []),
       UnopApp (Unop "¬", PredApp (Pred "P", [])))),
    Nullary_prf
     (Nullary_rule "0",
      UnopApp (Unop "¬",
       BinopApp (Binop "∨", PredApp (Pred "P", []),
        UnopApp (Unop "¬", PredApp (Pred "P", []))))),
    Binary_rule "¬E0",
    BinopApp (Binop "∨", PredApp (Pred "P", []),
     UnopApp (Unop "¬", PredApp (Pred "P", [])))))

let prf8_valid = None

let prf9_valid = Some
 (Trinary_prf
   (Atomic_prf
     (BinopApp (Binop "∨", PredApp (Pred "P", []), PredApp (Pred "R", []))),
    Binary_prf
     (Unary_prf
       (Atomic_prf
         (BinopApp (Binop "∧",
           BinopApp (Binop "→", PredApp (Pred "P", []), PredApp (Pred "Q", [])),
           BinopApp (Binop "→", PredApp (Pred "R", []), PredApp (Pred "Q", [])))),
        Unary_rule "∧E",
        BinopApp (Binop "→", PredApp (Pred "P", []), PredApp (Pred "Q", []))),
      Nullary_prf (Nullary_rule "0", PredApp (Pred "P", [])), Binary_rule "→E",
      PredApp (Pred "Q", [])),
    Binary_prf
     (Unary_prf
       (Atomic_prf
         (BinopApp (Binop "∧",
           BinopApp (Binop "→", PredApp (Pred "P", []), PredApp (Pred "Q", [])),
           BinopApp (Binop "→", PredApp (Pred "R", []), PredApp (Pred "Q", [])))),
        Unary_rule "∧E",
        BinopApp (Binop "→", PredApp (Pred "R", []), PredApp (Pred "Q", []))),
      Nullary_prf (Nullary_rule "0", PredApp (Pred "R", [])), Binary_rule "→E",
      PredApp (Pred "Q", [])),
    Trinary_rule "∨E0", PredApp (Pred "Q", [])))


let prf10_valid = None

let prf11_valid = Some
 (Unary_prf
   (Atomic_prf
     (BinopApp (Binop "∧",
       BinopApp (Binop "→", PredApp (Pred "P", []), PredApp (Pred "Q", [])),
       BinopApp (Binop "→", PredApp (Pred "R", []), PredApp (Pred "Q", [])))),
    Unary_rule "∧E",
    BinopApp (Binop "→", PredApp (Pred "P", []), PredApp (Pred "Q", []))))


let prf12_valid = None

let prf20_valid = Some
 (Binary_prf
   (Unary_prf
     (Binary_prf
       (Unary_prf
         (Atomic_prf
           (QuantApp (Quant "∀", Var "x",
             BinopApp (Binop "→", PredApp (Pred "P", [Atom (Var "x")]),
              PredApp (Pred "Q", [Atom (Var "x")])))),
          Unary_rule "∀E",
          BinopApp (Binop "→", PredApp (Pred "P", [FuncApp (Func "c", [])]),
           PredApp (Pred "Q", [FuncApp (Func "c", [])]))),
        Nullary_prf
         (Nullary_rule "0", PredApp (Pred "P", [FuncApp (Func "c", [])])),
        Binary_rule "→E", PredApp (Pred "Q", [FuncApp (Func "c", [])])),
      Unary_rule "∃I",
      QuantApp (Quant "∃", Var "x", PredApp (Pred "Q", [Atom (Var "x")]))),
    Atomic_prf
     (QuantApp (Quant "∃", Var "x", PredApp (Pred "P", [Atom (Var "x")]))),
    Binary_rule "∃E0",
    QuantApp (Quant "∃", Var "x", PredApp (Pred "Q", [Atom (Var "x")]))))

let prf14_valid = Some
 (Binary_prf
   (Unary_prf
     (Nullary_prf
       (Nullary_rule "0",
        BinopApp (Binop "↔", PredApp (Pred "A", []), PredApp (Pred "B", []))),
      Unary_rule "↔E",
      BinopApp (Binop "→", PredApp (Pred "A", []), PredApp (Pred "B", []))),
    Atomic_prf
     (UnopApp (Unop "¬",
       BinopApp (Binop "→", PredApp (Pred "A", []), PredApp (Pred "B", [])))),
    Binary_rule "¬I0",
    UnopApp (Unop "¬",
     BinopApp (Binop "↔", PredApp (Pred "A", []), PredApp (Pred "B", [])))))


let prf15_valid = Some
 (Unary_prf
   (Atomic_prf
     (BinopApp (Binop "↔", PredApp (Pred "A", []), PredApp (Pred "B", []))),
    Unary_rule "↔E",
    BinopApp (Binop "→", PredApp (Pred "A", []), PredApp (Pred "B", []))))

let prf16_valid = None

let prf17_in : string = input_dir ^ "prf17"
let prf18_in : string = input_dir ^ "prf18"
let prf21_in : string = input_dir ^ "prf21"


let fml0_in : string = input_dir ^ "fml0"
let fml1_in : string = input_dir ^ "fml1"
let fml2_in : string = input_dir ^ "fml2"
let fml3_in : string = input_dir ^ "fml3"
let fml4_in : string = input_dir ^ "fml4"
let fml5_in : string = input_dir ^ "fml5"

let fml0_out : t_fml list = 
[PredApp (Pred "=", [FuncApp (Func "a", []); FuncApp (Func "b", [])]);
 PredApp (Pred "A", []); UnopApp (Unop "¬", PredApp (Pred "A", []));
 BinopApp (Binop "∧", PredApp (Pred "A", []), PredApp (Pred "B", []));
 BinopApp (Binop "∧",
  PredApp (Pred "P",
   [FuncApp (Func "a", []); FuncApp (Func "b", []); FuncApp (Func "c", [])]),
  PredApp (Pred "Q", [Atom (Var "x"); Atom (Var "y"); Atom (Var "z")]));
 QuantApp (Quant "∀", Var "x",
  BinopApp (Binop "→", PredApp (Pred "Px", []), PredApp (Pred "Qx", [])));
 QuantApp (Quant "∀", Var "x",
  BinopApp (Binop "→", PredApp (Pred "P", [Atom (Var "x")]),
   PredApp (Pred "Q", [Atom (Var "x")])));
 QuantApp (Quant "∀", Var "x",
  BinopApp (Binop "→",
   PredApp (Pred "P", [FuncApp (Func "f", [Atom (Var "x")]); Atom (Var "y")]),
   PredApp (Pred "Q", [Atom (Var "x"); Atom (Var "z")])));
 QuantApp (Quant "∀", Var "x",
  BinopApp (Binop "→",
   PredApp (Pred "P",
    [FuncApp (Func "+", [Atom (Var "x"); Atom (Var "z")]); Atom (Var "y")]),
   PredApp (Pred "Q", [Atom (Var "x"); Atom (Var "z")])));
 QuantApp (Quant "∀", Var "x",
  BinopApp (Binop "→",
   PredApp (Pred "P",
    [FuncApp (Func "+", [Atom (Var "x"); Atom (Var "z")]); Atom (Var "y")]),
   PredApp (Pred "<", [Atom (Var "x"); Atom (Var "z")])))]

let fml1_out : t_fml list =
[PredApp (Pred "=",
  [FuncApp (Func "'", [FuncApp (Func "a", [])]); FuncApp (Func "b", [])]);
 PredApp (Pred "A", []); UnopApp (Unop "¬", PredApp (Pred "A", []));
 BinopApp (Binop "∧", PredApp (Pred "A", []), PredApp (Pred "B", []));
 BinopApp (Binop "∧",
  PredApp (Pred "P",
   [FuncApp (Func "'", [FuncApp (Func "a", [])]); FuncApp (Func "b", []);
    FuncApp (Func "c", [])]),
  PredApp (Pred "Q",
   [Atom (Var "x"); FuncApp (Func "'", [Atom (Var "y")]); Atom (Var "z")]));
 QuantApp (Quant "∀", Var "x",
  BinopApp (Binop "→", PredApp (Pred "Px", []), PredApp (Pred "Qx", [])));
 QuantApp (Quant "∀", Var "x",
  BinopApp (Binop "→", PredApp (Pred "P", [Atom (Var "x")]),
   PredApp (Pred "Q", [Atom (Var "x")])));
 QuantApp (Quant "∀", Var "x",
  BinopApp (Binop "→",
   PredApp (Pred "P", [FuncApp (Func "f", [Atom (Var "x")]); Atom (Var "y")]),
   PredApp (Pred "Q", [Atom (Var "x"); Atom (Var "z")])));
 QuantApp (Quant "∀", Var "x",
  BinopApp (Binop "→",
   PredApp (Pred "P",
    [FuncApp (Func "'", [FuncApp (Func "+", [Atom (Var "x"); Atom (Var "z")])]);
     Atom (Var "y")]),
   PredApp (Pred "Q", [Atom (Var "x"); Atom (Var "z")])));
 QuantApp (Quant "∀", Var "x",
  BinopApp (Binop "→",
   PredApp (Pred "P",
    [FuncApp (Func "+", [Atom (Var "x"); Atom (Var "z")]); Atom (Var "y")]),
   PredApp (Pred "<", [Atom (Var "x"); Atom (Var "z")])))]

let fml2_out : t_fml list =
[QuantApp (Quant "∀", Var "x",
  QuantApp (Quant "∀", Var "y",
   PredApp (Pred "=",
    [FuncApp (Func "+", [Atom (Var "x"); FuncApp (Func "'", [Atom (Var "y")])]);
     FuncApp (Func "'", [FuncApp (Func "+", [Atom (Var "x"); Atom (Var "y")])])])));
 QuantApp (Quant "∀", Var "x",
  PredApp (Pred "=",
   [FuncApp (Func "+", [Atom (Var "x"); FuncApp (Func "0", [])]);
    Atom (Var "x")]));
 QuantApp (Quant "∀", Var "y",
  PredApp (Pred "=",
   [FuncApp (Func "+",
     [FuncApp (Func "'", [FuncApp (Func "0", [])]);
      FuncApp (Func "'", [Atom (Var "y")])]);
    FuncApp (Func "'",
     [FuncApp (Func "+",
       [FuncApp (Func "'", [FuncApp (Func "0", [])]); Atom (Var "y")])])]));
 PredApp (Pred "=",
  [FuncApp (Func "+",
    [FuncApp (Func "'", [FuncApp (Func "0", [])]); FuncApp (Func "0", [])]);
   FuncApp (Func "'", [FuncApp (Func "0", [])])]);
 PredApp (Pred "=",
  [FuncApp (Func "+",
    [FuncApp (Func "'", [FuncApp (Func "0", [])]);
     FuncApp (Func "'", [FuncApp (Func "0", [])])]);
   FuncApp (Func "'",
    [FuncApp (Func "+",
      [FuncApp (Func "'", [FuncApp (Func "0", [])]); FuncApp (Func "0", [])])])]);
 PredApp (Pred "=",
  [FuncApp (Func "+",
    [FuncApp (Func "'", [FuncApp (Func "0", [])]);
     FuncApp (Func "'", [FuncApp (Func "0", [])])]);
   FuncApp (Func "'", [FuncApp (Func "'", [FuncApp (Func "0", [])])])])]

let fml3_out : t_fml list =
[QuantApp (Quant "∀", Var "x",
  QuantApp (Quant "∃", Var "y",
   QuantApp (Quant "∀", Var "z",
    BinopApp (Binop "↔", PredApp (Pred "∈", [Atom (Var "z"); Atom (Var "y")]),
     BinopApp (Binop "∧", PredApp (Pred "∈", [Atom (Var "z"); Atom (Var "x")]),
      PredApp (Pred "P", [Atom (Var "z")]))))));
 BinopApp (Binop "→", PredApp (Pred "A", []), PredApp (Pred "B", []));
 BinopApp (Binop "↔", PredApp (Pred "P_1", []), PredApp (Pred "Q_2", []));
 QuantApp (Quant "∀", Var "x",
  QuantApp (Quant "∀", Var "y",
   BinopApp (Binop "↔", PredApp (Pred "⊆", [Atom (Var "x"); Atom (Var "y")]),
    QuantApp (Quant "∀", Var "z",
     BinopApp (Binop "→", PredApp (Pred "∈", [Atom (Var "z"); Atom (Var "x")]),
      PredApp (Pred "∈", [Atom (Var "z"); Atom (Var "y")]))))))]


let fml4_out : t_fml list =
[BinopApp (Binop "→", UnopApp (Unop "¬", PredApp (Pred "P", [])),
  PredApp (Pred "Q", []));
 BinopApp (Binop "→",
  QuantApp (Quant "∀", Var "x", PredApp (Pred "P", [Atom (Var "x")])),
  PredApp (Pred "Q", []));
 BinopApp (Binop "→", PredApp (Pred "Q", []),
  UnopApp (Unop "¬", PredApp (Pred "P", [])));
 BinopApp (Binop "→", PredApp (Pred "Q", []),
  QuantApp (Quant "∀", Var "x", PredApp (Pred "P", [Atom (Var "x")])))]

let fml5_out : t_fml list =
  [QuantApp (Quant "∀", Var "x",
    PredApp (Pred "=",
     [FuncApp (Func "²", [Atom (Var "x")]);
      FuncApp (Func "×", [Atom (Var "x"); Atom (Var "x")])]));
   QuantApp (Quant "∀", Var "x",
    PredApp (Pred "=",
     [FuncApp (Func "³", [Atom (Var "x")]);
      FuncApp (Func "×",
       [FuncApp (Func "×", [Atom (Var "x"); Atom (Var "x")]); Atom (Var "x")])]));
   QuantApp (Quant "∀", Var "x",
    PredApp (Pred "=",
     [FuncApp (Func "^", [Atom (Var "x"); FuncApp (Func "0", [])]);
      FuncApp (Func "1", [])]));
   QuantApp (Quant "∀", Var "x",
    QuantApp (Quant "∀", Var "y",
     PredApp (Pred "=",
      [FuncApp (Func "^",
        [Atom (Var "x");
         FuncApp (Func "+", [Atom (Var "y"); FuncApp (Func "1", [])])]);
       FuncApp (Func "×",
        [FuncApp (Func "^", [Atom (Var "x"); Atom (Var "y")]); Atom (Var "x")])])));
   QuantApp (Quant "∀", Var "x",
    QuantApp (Quant "∀", Var "y",
     PredApp (Pred "=",
      [FuncApp (Func "^",
        [Atom (Var "x"); FuncApp (Func "'", [Atom (Var "y")])]);
       FuncApp (Func "×",
        [FuncApp (Func "^", [Atom (Var "x"); Atom (Var "y")]); Atom (Var "x")])])))]


let prf_raw_test input output : unit =
        match prf_raw_of_file input = output with
        |true -> ()
        |false -> IO.print_to_stderr_yellow ("prf_raw_test FAILED on " ^ input)

let prf_test input output : unit =
        match prf_of_file input = output with
        |true -> ()
        |false -> IO.print_to_stderr_yellow ("prf_test FAILED on " ^ input)


let prf_bidirection_test_raw input : unit =
try     let out1 : t_prf_raw = prf_raw_of_file input in
        let str : string = string_of_prf_raw out1 in
        let out2 : t_prf_raw = prf_raw_of_string str in
        match out1 = out2 with
        |true -> ()
        |false -> IO.print_to_stderr ("prf_bidirection_test_raw FAILED on " ^ input)
with PRF_main.Error e -> IO.print_to_stderr_yellow (String.concat " " ["prf_bidirection_test_raw FAILED on";input;e])


let prf_bidirection_test input : unit =
try     let out1 : t_prf = prf_of_file input in
        let str : string = string_of_prf out1 in
        let out2 : t_prf = prf_of_string str in
        match out1 = out2 with
        |true -> ()
        |false -> IO.print_to_stderr ("prf_bidirection_test FAILED on " ^ input)
with PRF_main.Error e -> IO.print_to_stderr_yellow (String.concat " " ["prf_bidirection_test FAILED on";input;e])


let fml_bidirection_test input : unit =
try     let out1 : t_fml list = fml_list_of_file input in
        let strings : string list = List.map string_of_fml out1 in
        let out2 : t_fml list = List.map fml_of_string strings in
        match out1 = out2 with
        |true -> ()
        |false -> IO.print_to_stderr ("fml_bidirection_test FAILED on " ^ input)
with FML_main.Parse_error e -> IO.print_to_stderr_yellow (String.concat " " ["fml_bidirection_test FAILED on";input;e])

let fml_test input output: unit =
        match fml_list_of_file input = output with
        |true -> ()
        |false -> IO.print_to_stderr ("fml_test FAILED on " ^ input)

let validity_test input output : unit =
        match validate_file ~options:options input = output with 
        |true -> ()
        |false -> IO.print_to_stderr_yellow ("validity_test FAILED on " ^ input)


let itm_bidirection_test (input : string) : unit =
	let items1 : ITM_types.t_itm list = ITM_main.items_of_file input in
	let items1_string : string = ITM_main.string_of_items items1 in
	let temp_path : string = Filename.temp_file "" "" in
	let _ : unit = IO.print_to_file items1_string temp_path in
	let items2 : ITM_types.t_itm list = ITM_main.items_of_file temp_path in
	match items1 = items2 with
	|true -> ()
	|false -> IO.print_to_stderr_yellow (String.concat "" ["itm_bidirection_test FAILED on ";input;"; see ";temp_path])

let itm_bidirection_tests (int_list : int list) : unit list =
	let input_of_int (i : int) : string =
		String.concat "" [input_dir;"itm";string_of_int i]
	in
	let inputs : string list =
		List.map input_of_int int_list
	in
	List.map itm_bidirection_test inputs 

let _ : unit list = itm_bidirection_tests [0;1;2;3;4;5;6;7;8;9;10;11;12]

let _ : unit = prf_raw_test prf0_in prf0_out_raw
let _ : unit = prf_raw_test prf1_in prf1_out_raw
let _ : unit = prf_raw_test prf2_in prf2_out_raw
let _ : unit = prf_raw_test prf3_in prf3_out_raw
let _ : unit = prf_raw_test prf4_in prf4_out_raw
let _ : unit = prf_raw_test prf5_in prf5_out_raw
let _ : unit = prf_raw_test prf6_in prf6_out_raw

let _ : unit = prf_test prf3_in prf3_out
let _ : unit = prf_test prf4_in prf4_out
let _ : unit = prf_test prf5_in prf5_out
let _ : unit = prf_test prf6_in prf6_out
let _ : unit = prf_test prf7_in prf7_out
let _ : unit = prf_test prf8_in prf8_out

let _ : unit = prf_bidirection_test_raw prf0_in
let _ : unit = prf_bidirection_test_raw prf1_in
let _ : unit = prf_bidirection_test_raw prf2_in
let _ : unit = prf_bidirection_test_raw prf3_in
let _ : unit = prf_bidirection_test_raw prf4_in
let _ : unit = prf_bidirection_test_raw prf5_in
let _ : unit = prf_bidirection_test_raw prf6_in
let _ : unit = prf_bidirection_test_raw prf7_in
let _ : unit = prf_bidirection_test_raw prf8_in
let _ : unit = prf_bidirection_test_raw prf9_in
let _ : unit = prf_bidirection_test_raw prf10_in
let _ : unit = prf_bidirection_test_raw prf11_in
let _ : unit = prf_bidirection_test_raw prf12_in
let _ : unit = prf_bidirection_test_raw prf14_in
let _ : unit = prf_bidirection_test_raw prf15_in


let _ : unit = prf_bidirection_test prf3_in
let _ : unit = prf_bidirection_test prf4_in
let _ : unit = prf_bidirection_test prf5_in
let _ : unit = prf_bidirection_test prf6_in
let _ : unit = prf_bidirection_test prf7_in
let _ : unit = prf_bidirection_test prf8_in
let _ : unit = prf_bidirection_test prf9_in
let _ : unit = prf_bidirection_test prf10_in
let _ : unit = prf_bidirection_test prf11_in
let _ : unit = prf_bidirection_test prf12_in
let _ : unit = prf_bidirection_test prf20_in
let _ : unit = prf_bidirection_test prf14_in
let _ : unit = prf_bidirection_test prf15_in
let _ : unit = prf_bidirection_test prf15_in
let _ : unit = prf_bidirection_test prf16_in
let _ : unit = prf_bidirection_test prf17_in
let _ : unit = prf_bidirection_test prf18_in
let _ : unit = prf_bidirection_test prf20_in
let _ : unit = prf_bidirection_test prf21_in

let _ : unit = validity_test prf3_in prf3_valid
let _ : unit = validity_test prf4_in prf4_valid
let _ : unit = validity_test prf5_in prf5_valid
let _ : unit = validity_test prf6_in prf6_valid
let _ : unit = validity_test prf7_in prf7_valid
let _ : unit = validity_test prf8_in prf8_valid
let _ : unit = validity_test prf9_in prf9_valid
let _ : unit = validity_test prf10_in prf10_valid
let _ : unit = validity_test prf11_in prf11_valid
let _ : unit = validity_test prf12_in prf12_valid
let _ : unit = validity_test prf14_in prf14_valid
let _ : unit = validity_test prf15_in prf15_valid
let _ : unit = validity_test prf16_in prf16_valid
let _ : unit = validity_test prf31_in prf31_valid
let _ : unit = validity_test prf32_in prf32_valid
let _ : unit = validity_test prf33_in prf33_valid
let _ : unit = validity_test prf20_in prf20_valid


let _ : unit = fml_test fml0_in fml0_out
let _ : unit = fml_test fml1_in fml1_out
let _ : unit = fml_test fml2_in fml2_out
let _ : unit = fml_test fml3_in fml3_out
let _ : unit = fml_test fml4_in fml4_out
let _ : unit = fml_test fml5_in fml5_out

let _ : unit = fml_bidirection_test fml0_in
let _ : unit = fml_bidirection_test fml1_in
let _ : unit = fml_bidirection_test fml2_in
let _ : unit = fml_bidirection_test fml3_in
let _ : unit = fml_bidirection_test fml4_in
let _ : unit = fml_bidirection_test fml5_in

