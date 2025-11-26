open FOL_types
open ND_types
open Main


let nd0_in : string = "../examples/ND0.txt"

let nd0_out_raw : ND_types.t_prf_raw =
ND_types.Binary_prf_raw
 (ND_types.Atomic_prf_raw (ND_types.Fml_raw "good bye"),
  ND_types.Atomic_prf_raw (ND_types.Fml_raw "cruel"),
  ND_types.Binary_rule "", ND_types.Fml_raw "world")

let nd1_in :string = "../examples/ND1.txt"

let nd1_out_raw : ND_types.t_prf_raw =
ND_types.Binary_prf_raw
 (ND_types.Unary_prf_raw
   (ND_types.Binary_prf_raw
     (ND_types.Unary_prf_raw
       (ND_types.Atomic_prf_raw (ND_types.Fml_raw "U"),
        ND_types.Unary_rule "∧E", ND_types.Fml_raw "A"),
      ND_types.Trinary_prf_raw
       (ND_types.Atomic_prf_raw (ND_types.Fml_raw "X"),
        ND_types.Atomic_prf_raw (ND_types.Fml_raw "Y"),
        ND_types.Atomic_prf_raw (ND_types.Fml_raw "Z"),
        ND_types.Trinary_rule "∨E", ND_types.Fml_raw "B"),
      ND_types.Binary_rule "", ND_types.Fml_raw "C"),
    ND_types.Unary_rule "∃I", ND_types.Fml_raw "Hello"),
  ND_types.Binary_prf_raw
   (ND_types.Atomic_prf_raw (ND_types.Fml_raw "g"),
    ND_types.Atomic_prf_raw (ND_types.Fml_raw "(h→i)"),
    ND_types.Binary_rule "", ND_types.Fml_raw "world"),
  ND_types.Binary_rule "∧I", ND_types.Fml_raw "conclusion")


let nd2_in : string = "../examples/ND2.txt"

let nd2_out_raw : ND_types.t_prf_raw =
ND_types.Binary_prf_raw
 (ND_types.Unary_prf_raw
   (ND_types.Binary_prf_raw
     (ND_types.Unary_prf_raw
       (ND_types.Nullary_prf_raw
         (ND_types.Nullary_rule "", ND_types.Fml_raw "U"),
        ND_types.Unary_rule "∧E", ND_types.Fml_raw "A"),
      ND_types.Trinary_prf_raw
       (ND_types.Nullary_prf_raw
         (ND_types.Nullary_rule "", ND_types.Fml_raw "X"),
        ND_types.Atomic_prf_raw (ND_types.Fml_raw "Y"),
        ND_types.Atomic_prf_raw (ND_types.Fml_raw "Z"),
        ND_types.Trinary_rule "∨E", ND_types.Fml_raw "B"),
      ND_types.Binary_rule "", ND_types.Fml_raw "C"),
    ND_types.Unary_rule "∃I", ND_types.Fml_raw "He llo"),
  ND_types.Binary_prf_raw
   (ND_types.Atomic_prf_raw (ND_types.Fml_raw "g"),
    ND_types.Atomic_prf_raw (ND_types.Fml_raw "(h → i)"),
    ND_types.Binary_rule "", ND_types.Fml_raw "wor ld"),
  ND_types.Binary_rule "", ND_types.Fml_raw "conclusion")

let nd3_in : string = "../examples/ND3.txt"

let nd3_out_raw : ND_types.t_prf_raw =
ND_types.Binary_prf_raw
 (ND_types.Unary_prf_raw
   (ND_types.Atomic_prf_raw (ND_types.Fml_raw "∀x(x+0=x)"),
    ND_types.Unary_rule "", ND_types.Fml_raw "0'+0=0'"),
  ND_types.Unary_prf_raw
   (ND_types.Unary_prf_raw
     (ND_types.Atomic_prf_raw (ND_types.Fml_raw "∀x∀y(x+y'=(x+y)')"),
      ND_types.Unary_rule "", ND_types.Fml_raw "∀y(0'+y'=(0'+y)')"),
    ND_types.Unary_rule "", ND_types.Fml_raw "0'+0'=(0'+0)'"),
  ND_types.Binary_rule "", ND_types.Fml_raw "0'+0'=0''")



let nd3_out : ND_types.t_prf =
ND_types.Binary_prf
 (ND_types.Unary_prf
   (ND_types.Atomic_prf
     (FOL_types.QuantApp (FOL_types.Quant "∀", FOL_types.Var "x",
       FOL_types.PredApp (FOL_types.Pred "=",
        [FOL_types.FuncApp (FOL_types.Func "+",
          [FOL_types.Atom (FOL_types.Var "x");
           FOL_types.FuncApp (FOL_types.Func "0", [])]);
         FOL_types.Atom (FOL_types.Var "x")]))),
    ND_types.Unary_rule "",
    FOL_types.PredApp (FOL_types.Pred "=",
     [FOL_types.FuncApp (FOL_types.Func "+",
       [FOL_types.FuncApp (FOL_types.Func "'",
         [FOL_types.FuncApp (FOL_types.Func "0", [])]);
        FOL_types.FuncApp (FOL_types.Func "0", [])]);
      FOL_types.FuncApp (FOL_types.Func "'",
       [FOL_types.FuncApp (FOL_types.Func "0", [])])])),
  ND_types.Unary_prf
   (ND_types.Unary_prf
     (ND_types.Atomic_prf
       (FOL_types.QuantApp (FOL_types.Quant "∀", FOL_types.Var "x",
         FOL_types.QuantApp (FOL_types.Quant "∀", FOL_types.Var "y",
          FOL_types.PredApp (FOL_types.Pred "=",
           [FOL_types.FuncApp (FOL_types.Func "+",
             [FOL_types.Atom (FOL_types.Var "x");
              FOL_types.FuncApp (FOL_types.Func "'",
               [FOL_types.Atom (FOL_types.Var "y")])]);
            FOL_types.FuncApp (FOL_types.Func "'",
             [FOL_types.FuncApp (FOL_types.Func "+",
               [FOL_types.Atom (FOL_types.Var "x");
                FOL_types.Atom (FOL_types.Var "y")])])])))),
      ND_types.Unary_rule "",
      FOL_types.QuantApp (FOL_types.Quant "∀", FOL_types.Var "y",
       FOL_types.PredApp (FOL_types.Pred "=",
        [FOL_types.FuncApp (FOL_types.Func "+",
          [FOL_types.FuncApp (FOL_types.Func "'",
            [FOL_types.FuncApp (FOL_types.Func "0", [])]);
           FOL_types.FuncApp (FOL_types.Func "'",
            [FOL_types.Atom (FOL_types.Var "y")])]);
         FOL_types.FuncApp (FOL_types.Func "'",
          [FOL_types.FuncApp (FOL_types.Func "+",
            [FOL_types.FuncApp (FOL_types.Func "'",
              [FOL_types.FuncApp (FOL_types.Func "0", [])]);
             FOL_types.Atom (FOL_types.Var "y")])])]))),
    ND_types.Unary_rule "",
    FOL_types.PredApp (FOL_types.Pred "=",
     [FOL_types.FuncApp (FOL_types.Func "+",
       [FOL_types.FuncApp (FOL_types.Func "'",
         [FOL_types.FuncApp (FOL_types.Func "0", [])]);
        FOL_types.FuncApp (FOL_types.Func "'",
         [FOL_types.FuncApp (FOL_types.Func "0", [])])]);
      FOL_types.FuncApp (FOL_types.Func "'",
       [FOL_types.FuncApp (FOL_types.Func "+",
         [FOL_types.FuncApp (FOL_types.Func "'",
           [FOL_types.FuncApp (FOL_types.Func "0", [])]);
          FOL_types.FuncApp (FOL_types.Func "0", [])])])])),
  ND_types.Binary_rule "",
  FOL_types.PredApp (FOL_types.Pred "=",
   [FOL_types.FuncApp (FOL_types.Func "+",
     [FOL_types.FuncApp (FOL_types.Func "'",
       [FOL_types.FuncApp (FOL_types.Func "0", [])]);
      FOL_types.FuncApp (FOL_types.Func "'",
       [FOL_types.FuncApp (FOL_types.Func "0", [])])]);
    FOL_types.FuncApp (FOL_types.Func "'",
     [FOL_types.FuncApp (FOL_types.Func "'",
       [FOL_types.FuncApp (FOL_types.Func "0", [])])])]))


let nd4_in : string = "../examples/ND4.txt"

let nd4_out_raw : ND_types.t_prf_raw =
ND_types.Unary_prf_raw
 (ND_types.Nullary_prf_raw (ND_types.Nullary_rule "", ND_types.Fml_raw "P"),
  ND_types.Unary_rule "", ND_types.Fml_raw "(P → P)")

let nd4_out : ND_types.t_prf =
ND_types.Unary_prf
 (ND_types.Nullary_prf
   (ND_types.Nullary_rule "", FOL_types.PredApp (FOL_types.Pred "P", [])),
  ND_types.Unary_rule "",
  FOL_types.BinopApp (FOL_types.Binop "→",
   FOL_types.PredApp (FOL_types.Pred "P", []),
   FOL_types.PredApp (FOL_types.Pred "P", [])))

let nd5_in : string = "../examples/ND5.txt"

let nd5_out_raw : ND_types.t_prf_raw =
ND_types.Binary_prf_raw
 (ND_types.Nullary_prf_raw (ND_types.Nullary_rule "", ND_types.Fml_raw "P"),
  ND_types.Atomic_prf_raw (ND_types.Fml_raw "Q"), ND_types.Binary_rule "",
  ND_types.Fml_raw "(P ∧ Q)")


let nd5_out : ND_types.t_prf =
ND_types.Binary_prf
 (ND_types.Nullary_prf
   (ND_types.Nullary_rule "", FOL_types.PredApp (FOL_types.Pred "P", [])),
  ND_types.Atomic_prf (FOL_types.PredApp (FOL_types.Pred "Q", [])),
  ND_types.Binary_rule "",
  FOL_types.BinopApp (FOL_types.Binop "∧",
   FOL_types.PredApp (FOL_types.Pred "P", []),
   FOL_types.PredApp (FOL_types.Pred "Q", [])))

let nd6_in : string = "../examples/ND6.txt"

let nd6_out_raw : ND_types.t_prf_raw =
ND_types.Unary_prf_raw
 (ND_types.Nullary_prf_raw (ND_types.Nullary_rule "", ND_types.Fml_raw "a=a"),
  ND_types.Unary_rule "", ND_types.Fml_raw "∀x(x=x)")


let nd6_out : ND_types.t_prf =
ND_types.Unary_prf
   (ND_types.Nullary_prf
     (ND_types.Nullary_rule "",
      FOL_types.PredApp (FOL_types.Pred "=",
       [FOL_types.FuncApp (FOL_types.Func "a", []);
        FOL_types.FuncApp (FOL_types.Func "a", [])])),
    ND_types.Unary_rule "",
    FOL_types.QuantApp (FOL_types.Quant "∀", FOL_types.Var "x",
     FOL_types.PredApp (FOL_types.Pred "=",
      [FOL_types.Atom (FOL_types.Var "x");
       FOL_types.Atom (FOL_types.Var "x")])))

let nd7_in : string = "../examples/ND7.txt"

let nd7_out_raw : ND_types.t_prf_raw =
ND_types.Binary_prf_raw
 (ND_types.Unary_prf_raw
   (ND_types.Binary_prf_raw
     (ND_types.Unary_prf_raw
       (ND_types.Nullary_prf_raw
         (ND_types.Nullary_rule "1", ND_types.Fml_raw "P"),
        ND_types.Unary_rule "", ND_types.Fml_raw "(P \\lor \\neg P)"),
      ND_types.Nullary_prf_raw
       (ND_types.Nullary_rule "2",
        ND_types.Fml_raw "\\neg (P \\lor \\neg P)"),
      ND_types.Binary_rule "¬I,1", ND_types.Fml_raw "\\neg P"),
    ND_types.Unary_rule "", ND_types.Fml_raw "(P \\lor \\neg P)"),
  ND_types.Nullary_prf_raw
   (ND_types.Nullary_rule "2", ND_types.Fml_raw "\\neg (P \\lor \\neg P)"),
  ND_types.Binary_rule "¬E,2", ND_types.Fml_raw "(P \\lor \\neg P)")

let nd7_out : ND_types.t_prf =
ND_types.Binary_prf
 (ND_types.Unary_prf
   (ND_types.Binary_prf
     (ND_types.Unary_prf
       (ND_types.Nullary_prf
         (ND_types.Nullary_rule "1",
          FOL_types.PredApp (FOL_types.Pred "P", [])),
        ND_types.Unary_rule "",
        FOL_types.BinopApp (FOL_types.Binop "∨",
         FOL_types.PredApp (FOL_types.Pred "P", []),
         FOL_types.UnopApp (FOL_types.Unop "¬",
          FOL_types.PredApp (FOL_types.Pred "P", [])))),
      ND_types.Nullary_prf
       (ND_types.Nullary_rule "2",
        FOL_types.UnopApp (FOL_types.Unop "¬",
         FOL_types.BinopApp (FOL_types.Binop "∨",
          FOL_types.PredApp (FOL_types.Pred "P", []),
          FOL_types.UnopApp (FOL_types.Unop "¬",
           FOL_types.PredApp (FOL_types.Pred "P", []))))),
      ND_types.Binary_rule "¬I,1",
      FOL_types.UnopApp (FOL_types.Unop "¬",
       FOL_types.PredApp (FOL_types.Pred "P", []))),
    ND_types.Unary_rule "",
    FOL_types.BinopApp (FOL_types.Binop "∨",
     FOL_types.PredApp (FOL_types.Pred "P", []),
     FOL_types.UnopApp (FOL_types.Unop "¬",
      FOL_types.PredApp (FOL_types.Pred "P", [])))),
  ND_types.Nullary_prf
   (ND_types.Nullary_rule "2",
    FOL_types.UnopApp (FOL_types.Unop "¬",
     FOL_types.BinopApp (FOL_types.Binop "∨",
      FOL_types.PredApp (FOL_types.Pred "P", []),
      FOL_types.UnopApp (FOL_types.Unop "¬",
       FOL_types.PredApp (FOL_types.Pred "P", []))))),
  ND_types.Binary_rule "¬E,2",
  FOL_types.BinopApp (FOL_types.Binop "∨",
   FOL_types.PredApp (FOL_types.Pred "P", []),
   FOL_types.UnopApp (FOL_types.Unop "¬",
    FOL_types.PredApp (FOL_types.Pred "P", []))))

let nd8_in : string = "../examples/ND8.txt"

let nd8_out_raw : ND_types.t_prf_raw =
ND_types.Binary_prf_raw
 (ND_types.Unary_prf_raw
   (ND_types.Nullary_prf_raw
     (ND_types.Nullary_rule "1", ND_types.Fml_raw "P"),
    ND_types.Unary_rule "", ND_types.Fml_raw "(P \\lor \\neg P)"),
  ND_types.Nullary_prf_raw
   (ND_types.Nullary_rule "", ND_types.Fml_raw "\\neg (P \\lor \\neg P)"),
  ND_types.Binary_rule "¬I,1", ND_types.Fml_raw "\\neg P")

let nd8_out : ND_types.t_prf =
ND_types.Binary_prf
 (ND_types.Unary_prf
   (ND_types.Nullary_prf
     (ND_types.Nullary_rule "1", FOL_types.PredApp (FOL_types.Pred "P", [])),
    ND_types.Unary_rule "",
    FOL_types.BinopApp (FOL_types.Binop "∨",
     FOL_types.PredApp (FOL_types.Pred "P", []),
     FOL_types.UnopApp (FOL_types.Unop "¬",
      FOL_types.PredApp (FOL_types.Pred "P", [])))),
  ND_types.Nullary_prf
   (ND_types.Nullary_rule "",
    FOL_types.UnopApp (FOL_types.Unop "¬",
     FOL_types.BinopApp (FOL_types.Binop "∨",
      FOL_types.PredApp (FOL_types.Pred "P", []),
      FOL_types.UnopApp (FOL_types.Unop "¬",
       FOL_types.PredApp (FOL_types.Pred "P", []))))),
  ND_types.Binary_rule "¬I,1",
  FOL_types.UnopApp (FOL_types.Unop "¬",
   FOL_types.PredApp (FOL_types.Pred "P", [])))


let nd9_in : string = "../examples/ND9.txt"
let nd10_in : string = "../examples/ND10.txt"
let nd11_in : string = "../examples/ND11.txt"
let nd12_in : string = "../examples/ND12.txt"
let nd31_in : string = "../examples/ND31.txt"
let nd32_in : string = "../examples/ND32.txt"
let nd33_in : string = "../examples/ND33.txt"
let nd20_in : string = "../examples/ND20.txt"
let nd14_in : string = "../examples/ND14.txt"
let nd15_in : string = "../examples/ND15.txt"
let nd16_in : string = "../examples/ND16.txt"


let nd3_valid = Some
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


let nd31_valid =Some
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

let nd32_valid = Some
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

let nd33_valid = Some
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


let nd4_valid = Some
 (Unary_prf
   (Nullary_prf (Nullary_rule "0", PredApp (Pred "P", [])), Unary_rule "→I0",
    BinopApp (Binop "→", PredApp (Pred "P", []), PredApp (Pred "P", []))))

let nd5_valid = None

let nd6_valid = Some
 (Unary_prf
   (Nullary_prf
     (Nullary_rule "=I",
      PredApp (Pred "=", [FuncApp (Func "a", []); FuncApp (Func "a", [])])),
    Unary_rule "∀I",
    QuantApp (Quant "∀", Var "x",
     PredApp (Pred "=", [Atom (Var "x"); Atom (Var "x")]))))

let nd7_valid = Some
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

let nd8_valid = None

let nd9_valid = Some
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


let nd10_valid = None

let nd11_valid = Some
 (Unary_prf
   (Atomic_prf
     (BinopApp (Binop "∧",
       BinopApp (Binop "→", PredApp (Pred "P", []), PredApp (Pred "Q", [])),
       BinopApp (Binop "→", PredApp (Pred "R", []), PredApp (Pred "Q", [])))),
    Unary_rule "∧E",
    BinopApp (Binop "→", PredApp (Pred "P", []), PredApp (Pred "Q", []))))


let nd12_valid = None

let nd20_valid = Some
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

let nd14_valid = Some
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


let nd15_valid = Some
 (Unary_prf
   (Atomic_prf
     (BinopApp (Binop "↔", PredApp (Pred "A", []), PredApp (Pred "B", []))),
    Unary_rule "↔E",
    BinopApp (Binop "→", PredApp (Pred "A", []), PredApp (Pred "B", []))))

let nd16_valid = None

let nd17_in : string = "../examples/ND17.txt"
let nd18_in : string = "../examples/ND18.txt"
let nd21_in : string = "../examples/ND21.txt"


let fol0_in : string = "../examples/FOL0.txt"
let fol1_in : string = "../examples/FOL1.txt"
let fol2_in : string = "../examples/FOL2.txt"
let fol3_in : string = "../examples/FOL3.txt"

let nd_raw_test input output : unit =
        match Main.prf_raw_of_file input = output with
        |true -> ()
        |false -> IO.print_to_stderr ("nd_raw_test FAILED on " ^ input)

let nd_test input output : unit =
        match Main.prf_of_file input = output with
        |true -> ()
        |false -> IO.print_to_stderr ("nd_test FAILED on " ^ input)


let nd_fixpoint_test_raw input : unit =
try     let out1 : ND_types.t_prf_raw = Main.prf_raw_of_file input in
        let str : string = ND_main.nd_string_of_prf_raw out1 in
        let out2 : ND_types.t_prf_raw = Main.prf_raw_of_string str in
        match out1 = out2 with
        |true -> ()
        |false -> IO.print_to_stderr ("nd_fixpoint_test_raw FAILED on " ^ input)
with ND_main.Error e -> IO.print_to_stderr (String.concat " " ["nd_fixpoint_test_raw FAILED on";input;e])


let nd_fixpoint_test input : unit =
try     let out1 : ND_types.t_prf = Main.prf_of_file input in
        let str : string = Main.nd_string_of_prf out1 in
        let out2 : ND_types.t_prf = Main.prf_of_string str in
        match out1 = out2 with
        |true -> ()
        |false -> IO.print_to_stderr ("nd_fixpoint_test FAILED on " ^ input)
with ND_main.Error e -> IO.print_to_stderr (String.concat " " ["nd_fixpoint_test FAILED on";input;e])


let fol_fixpoint_test input : unit =
try     let out1 : FOL_types.t_fml list = Main.fml_list_of_file input in
        let strings : string list = List.map Main.string_of_fml out1 in
        let out2 : FOL_types.t_fml list = List.map Main.fml_of_string strings in
        match out1 = out2 with
        |true -> ()
        |false -> IO.print_to_stderr ("fol_fixpoint_test FAILED on " ^ input)
with FOL_main.Error e -> IO.print_to_stderr (String.concat " " ["fol_fixpoint_test_raw FAILED on";input;e])


let validity_test input output : unit =
        match Main.validate_file [] input = output with 
        |true -> ()
        |false -> IO.print_to_stderr ("validity_test FAILED on " ^ input)


let comp_test input : unit =
        let prf_in : t_prf = Main.prf_of_file input in
        let temp_dir = Filename.temp_dir "" "" in
        let _ : unit = Main.decompose_file ["-R"] temp_dir input in
        let prf_out : t_prf = Main.compose_prf_rec temp_dir in
        let _ : int = Sys.command (String.concat " " ["rm -r";temp_dir]) in
        match prf_in = prf_out with
        |true -> ()
        |false -> IO.print_to_stderr ("comp_test FAILED on " ^ input)


let _ : unit = nd_raw_test nd0_in nd0_out_raw
let _ : unit = nd_raw_test nd1_in nd1_out_raw
let _ : unit = nd_raw_test nd2_in nd2_out_raw
let _ : unit = nd_raw_test nd3_in nd3_out_raw
let _ : unit = nd_raw_test nd4_in nd4_out_raw
let _ : unit = nd_raw_test nd5_in nd5_out_raw
let _ : unit = nd_raw_test nd6_in nd6_out_raw

let _ : unit = fol_fixpoint_test fol0_in
let _ : unit = fol_fixpoint_test fol1_in
let _ : unit = fol_fixpoint_test fol2_in
let _ : unit = fol_fixpoint_test fol3_in

let _ : unit = nd_test nd3_in nd3_out
let _ : unit = nd_test nd4_in nd4_out
let _ : unit = nd_test nd5_in nd5_out
let _ : unit = nd_test nd6_in nd6_out
let _ : unit = nd_test nd7_in nd7_out
let _ : unit = nd_test nd8_in nd8_out


let _ : unit = nd_fixpoint_test_raw nd0_in
let _ : unit = nd_fixpoint_test_raw nd1_in
let _ : unit = nd_fixpoint_test_raw nd2_in
let _ : unit = nd_fixpoint_test_raw nd3_in
let _ : unit = nd_fixpoint_test_raw nd4_in
let _ : unit = nd_fixpoint_test_raw nd5_in
let _ : unit = nd_fixpoint_test_raw nd6_in
let _ : unit = nd_fixpoint_test_raw nd7_in
let _ : unit = nd_fixpoint_test_raw nd8_in
let _ : unit = nd_fixpoint_test_raw nd9_in
let _ : unit = nd_fixpoint_test_raw nd10_in
let _ : unit = nd_fixpoint_test_raw nd11_in
let _ : unit = nd_fixpoint_test_raw nd12_in
let _ : unit = nd_fixpoint_test_raw nd14_in
let _ : unit = nd_fixpoint_test_raw nd15_in


let _ : unit = nd_fixpoint_test nd3_in
let _ : unit = nd_fixpoint_test nd4_in
let _ : unit = nd_fixpoint_test nd5_in
let _ : unit = nd_fixpoint_test nd6_in
let _ : unit = nd_fixpoint_test nd7_in
let _ : unit = nd_fixpoint_test nd8_in
let _ : unit = nd_fixpoint_test nd9_in
let _ : unit = nd_fixpoint_test nd10_in
let _ : unit = nd_fixpoint_test nd11_in
let _ : unit = nd_fixpoint_test nd12_in
let _ : unit = nd_fixpoint_test nd20_in
let _ : unit = nd_fixpoint_test nd14_in
let _ : unit = nd_fixpoint_test nd15_in
let _ : unit = nd_fixpoint_test nd15_in
let _ : unit = nd_fixpoint_test nd16_in
let _ : unit = nd_fixpoint_test nd17_in
let _ : unit = nd_fixpoint_test nd18_in
let _ : unit = nd_fixpoint_test nd20_in
let _ : unit = nd_fixpoint_test nd21_in

let _ : unit = validity_test nd3_in nd3_valid
let _ : unit = validity_test nd4_in nd4_valid
let _ : unit = validity_test nd5_in nd5_valid
let _ : unit = validity_test nd6_in nd6_valid
let _ : unit = validity_test nd7_in nd7_valid
let _ : unit = validity_test nd8_in nd8_valid
let _ : unit = validity_test nd9_in nd9_valid
let _ : unit = validity_test nd10_in nd10_valid
let _ : unit = validity_test nd11_in nd11_valid
let _ : unit = validity_test nd12_in nd12_valid
let _ : unit = validity_test nd14_in nd14_valid
let _ : unit = validity_test nd15_in nd15_valid
let _ : unit = validity_test nd16_in nd16_valid
let _ : unit = validity_test nd31_in nd31_valid
let _ : unit = validity_test nd32_in nd32_valid
let _ : unit = validity_test nd33_in nd33_valid
let _ : unit = validity_test nd20_in nd20_valid


let _ : unit = comp_test nd3_in
let _ : unit = comp_test nd4_in
let _ : unit = comp_test nd5_in
let _ : unit = comp_test nd6_in
let _ : unit = comp_test nd7_in
let _ : unit = comp_test nd8_in
let _ : unit = comp_test nd9_in

