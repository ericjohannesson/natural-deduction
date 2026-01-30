open FML_types
open PRF_types

let input_dir : string = "../tests/examples/"

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


let prf_raw_test input output : unit =
        match Main.prf_raw_of_file input = output with
        |true -> ()
        |false -> IO.print_to_stderr ("prf_raw_test FAILED on " ^ input)

let prf_test input output : unit =
        match Main.prf_of_file input = output with
        |true -> ()
        |false -> IO.print_to_stderr ("prf_test FAILED on " ^ input)


let prf_fixpoint_test_raw input : unit =
try     let out1 : PRF_types.t_prf_raw = Main.prf_raw_of_file input in
        let str : string = Main.string_of_prf_raw out1 in
        let out2 : PRF_types.t_prf_raw = Main.prf_raw_of_string str in
        match out1 = out2 with
        |true -> ()
        |false -> IO.print_to_stderr ("prf_fixpoint_test_raw FAILED on " ^ input)
with PRF_main.Error e -> IO.print_to_stderr (String.concat " " ["prf_fixpoint_test_raw FAILED on";input;e])


let prf_fixpoint_test input : unit =
try     let out1 : PRF_types.t_prf = Main.prf_of_file input in
        let str : string = Main.string_of_prf out1 in
        let out2 : PRF_types.t_prf = Main.prf_of_string str in
        match out1 = out2 with
        |true -> ()
        |false -> IO.print_to_stderr ("prf_fixpoint_test FAILED on " ^ input)
with PRF_main.Error e -> IO.print_to_stderr (String.concat " " ["prf_fixpoint_test FAILED on";input;e])


let fml_fixpoint_test input : unit =
try     let out1 : FML_types.t_fml list = Main.fml_list_of_file input in
        let strings : string list = List.map Main.string_of_fml out1 in
        let out2 : FML_types.t_fml list = List.map Main.fml_of_string strings in
        match out1 = out2 with
        |true -> ()
        |false -> IO.print_to_stderr ("fml_fixpoint_test FAILED on " ^ input)
with FML_main.Parse_error e -> IO.print_to_stderr (String.concat " " ["fml_fixpoint_test FAILED on";input;e])


let validity_test input output : unit =
	let options : Main.t_options = {
		verbose = false;
		discharge = false;
		undischarge = false;
		print_proof = false;
		print_report = false;
	}
	in
        match Main.validate_file options input = output with 
        |true -> ()
        |false -> IO.print_to_stderr ("validity_test FAILED on " ^ input)


let comp_test input : unit =
        let prf_in : t_prf = Main.prf_of_file input in
        let temp_dir = Filename.temp_dir "" "" in
        let _ : unit = PRF_edit.decompose_file ["-R"] temp_dir input in
        let prf_out : t_prf = PRF_edit.compose_prf_rec temp_dir in
        let _ : int = Sys.command (String.concat " " ["rm -r";temp_dir]) in
        match prf_in = prf_out with
        |true -> ()
        |false -> IO.print_to_stderr ("comp_test FAILED on " ^ input)


let comp_test_raw input : unit =
        let prf_in : t_prf_raw = Main.prf_raw_of_file input in
        let temp_dir = Filename.temp_dir "" "" in
        let _ : unit = PRF_edit.decompose_file_raw ["-R"] temp_dir input in
        let prf_out : t_prf_raw = PRF_edit.compose_prf_raw_rec temp_dir in
        let _ : int = Sys.command (String.concat " " ["rm -r";temp_dir]) in
        match prf_in = prf_out with
        |true -> ()
        |false -> IO.print_to_stderr ("comp_test_raw FAILED on " ^ input)


let _ : unit = prf_raw_test prf0_in prf0_out_raw
let _ : unit = prf_raw_test prf1_in prf1_out_raw
let _ : unit = prf_raw_test prf2_in prf2_out_raw
let _ : unit = prf_raw_test prf3_in prf3_out_raw
let _ : unit = prf_raw_test prf4_in prf4_out_raw
let _ : unit = prf_raw_test prf5_in prf5_out_raw
let _ : unit = prf_raw_test prf6_in prf6_out_raw

let _ : unit = fml_fixpoint_test fml0_in
let _ : unit = fml_fixpoint_test fml1_in
let _ : unit = fml_fixpoint_test fml2_in
let _ : unit = fml_fixpoint_test fml3_in

let _ : unit = prf_test prf3_in prf3_out
let _ : unit = prf_test prf4_in prf4_out
let _ : unit = prf_test prf5_in prf5_out
let _ : unit = prf_test prf6_in prf6_out
let _ : unit = prf_test prf7_in prf7_out
let _ : unit = prf_test prf8_in prf8_out


let _ : unit = prf_fixpoint_test_raw prf0_in
let _ : unit = prf_fixpoint_test_raw prf1_in
let _ : unit = prf_fixpoint_test_raw prf2_in
let _ : unit = prf_fixpoint_test_raw prf3_in
let _ : unit = prf_fixpoint_test_raw prf4_in
let _ : unit = prf_fixpoint_test_raw prf5_in
let _ : unit = prf_fixpoint_test_raw prf6_in
let _ : unit = prf_fixpoint_test_raw prf7_in
let _ : unit = prf_fixpoint_test_raw prf8_in
let _ : unit = prf_fixpoint_test_raw prf9_in
let _ : unit = prf_fixpoint_test_raw prf10_in
let _ : unit = prf_fixpoint_test_raw prf11_in
let _ : unit = prf_fixpoint_test_raw prf12_in
let _ : unit = prf_fixpoint_test_raw prf14_in
let _ : unit = prf_fixpoint_test_raw prf15_in


let _ : unit = prf_fixpoint_test prf3_in
let _ : unit = prf_fixpoint_test prf4_in
let _ : unit = prf_fixpoint_test prf5_in
let _ : unit = prf_fixpoint_test prf6_in
let _ : unit = prf_fixpoint_test prf7_in
let _ : unit = prf_fixpoint_test prf8_in
let _ : unit = prf_fixpoint_test prf9_in
let _ : unit = prf_fixpoint_test prf10_in
let _ : unit = prf_fixpoint_test prf11_in
let _ : unit = prf_fixpoint_test prf12_in
let _ : unit = prf_fixpoint_test prf20_in
let _ : unit = prf_fixpoint_test prf14_in
let _ : unit = prf_fixpoint_test prf15_in
let _ : unit = prf_fixpoint_test prf15_in
let _ : unit = prf_fixpoint_test prf16_in
let _ : unit = prf_fixpoint_test prf17_in
let _ : unit = prf_fixpoint_test prf18_in
let _ : unit = prf_fixpoint_test prf20_in
let _ : unit = prf_fixpoint_test prf21_in

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

let _ : unit = comp_test_raw prf0_in
let _ : unit = comp_test_raw prf1_in
let _ : unit = comp_test_raw prf3_in
let _ : unit = comp_test_raw prf4_in
let _ : unit = comp_test_raw prf5_in
let _ : unit = comp_test_raw prf6_in
let _ : unit = comp_test_raw prf7_in
let _ : unit = comp_test_raw prf8_in
let _ : unit = comp_test_raw prf9_in

let _ : unit = comp_test prf3_in
let _ : unit = comp_test prf4_in
let _ : unit = comp_test prf5_in
let _ : unit = comp_test prf6_in
let _ : unit = comp_test prf7_in
let _ : unit = comp_test prf8_in
let _ : unit = comp_test prf9_in


