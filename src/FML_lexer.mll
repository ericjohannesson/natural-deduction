{
        open FML_parser
        exception Eof

let canonical (s : string) : string =
        match s with
        |"\\forall" | "\\A" | "∀" -> "∀"
        |"\\exists" | "\\E" | "∃" -> "∃"
        |"\\neg" | "~" | "¬" -> "¬"
        |"\\land" | "\\wedge" | "&" | "∧" -> "∧"
        |"\\lor" | "\\vee" | "∨" -> "∨"
        |"\\to" | "\\rightarrow" | "->" | "→" -> "→"
        |"\\leftrightarrow" | "<->" | "↔" -> "↔"
        |_ -> s

let unnegated (s : string) : string =
        match s with
        |"≠" | "\\neq" -> "="
        | "∉" | "\\not\\in" | "\\not \\in" |"\\notin" -> "∈"
        |_ -> s
}


let forall = "∀" | "\\forall" | "\\A"
let exists = "∃" | "\\exists" | "\\E"
let impl = "→" | "\\to" | "\\rightarrow" | "->"
let conj = "∧" | "\\land" | "\\wedge" | "&"
let disj = "∨" | "\\lor" | "\\vee"
let eqv = "↔" | "\\leftrightarrow" | "<->"
let neg = "¬" | "\\neg" | "~"
let plus = '+'
let times = "×" | "*" | "\\times" | "\\cdot"
let minus = '-'
let div = '|'
let le = '<'
let ge = '>'
let leq = "≤" | "\\leq"
let geq = "≥" | "\\geq"
let prime = '\''
let neq = "≠" | "\\neq"
let el = "∈" | "\\in"
let nel = "∉" | "\\not\\in" |"\\not \\in" | "\\notin"
let subset = "⊂" | "\\subset"
let subseteq = "⊆" | "\\subseteq"
let eq = '='

let prefix_func = ['a' - 't'] (['_'] | ['A' - 'Z'] | ['a' - 'z'] | ['0' - '9'])* | ['0' - '9']+
let var = ['u' - 'z'] (['_'] | ['A' - 'Z'] | ['a' - 'z'] | ['0' - '9'])*
let prefix_pred = ['A' - 'Z'] (['_'] | ['A' - 'Z'] | ['a' - 'z'] | ['0' - '9'])*
let comma = ','
let lpar = '('
let rpar = ')'
let quant = forall | exists
let unop = neg
let binop = conj | disj | impl | eqv
let infix_func = plus | times | minus | div
let infix_pred = le | ge | leq | geq | eq | el | subset | subseteq
let neg_infix_pred = neq | nel
let postfix_func = prime

rule token = parse
        | comma                 { COMMA }
        | lpar                  { LPAR }
        | rpar                  { RPAR }
        | var as e              { VAR e }
        | prefix_func as e      { PREFIX_FUNC e }
        | infix_func as e       { INFIX_FUNC e }
        | postfix_func as e     { POSTFIX_FUNC (String.make 1 e) }
        | prefix_pred as e      { PREFIX_PRED e }
        | infix_pred as e       { INFIX_PRED e }
        | neg_infix_pred as e   { NEG_INFIX_PRED (unnegated e) }
        | quant as e            { QUANT (canonical e) }
        | unop as e             { UNOP (canonical e) }
        | binop as e            { BINOP (canonical e) }
        | eof                   { EOF }
        | _                     { token lexbuf }
