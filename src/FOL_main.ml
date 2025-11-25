exception Error of string
open FOL_types


(** Parsing *)

let string_of_token (t:FOL_parser.token) : string =
        match t with
        |FOL_parser.EOF -> "EOF"
        |FOL_parser.LPAR -> "LPAR"
        |FOL_parser.RPAR -> "RPAR"
        |FOL_parser.COMMA -> "COMMA"
        |FOL_parser.VAR s -> String.concat "" ["VAR";" ";"\"";s;"\""]
        |FOL_parser.PREFIX_FUNC s -> String.concat "" ["PREFIX_FUNC";" ";"\"";s;"\""]
        |FOL_parser.INFIX_FUNC s -> String.concat "" ["INFIX_FUNC";" ";"\'";s;"\'"]
        |FOL_parser.POSTFIX_FUNC s -> String.concat "" ["POSTFIX_FUNC";" ";"\"";s;"\""]
        |FOL_parser.PREFIX_PRED s -> String.concat "" ["PREFIX_PRED";" ";"\"";s;"\""]
        |FOL_parser.INFIX_PRED s -> String.concat "" ["INFIX_PRED";" ";"\"";s;"\""]
        |FOL_parser.NEG_INFIX_PRED s -> String.concat "" ["NEG_INFIX_PRED";" ";"\"";s;"\""]
        |FOL_parser.UNOP s -> String.concat "" ["UNOP";" ";"\"";s;"\""]
        |FOL_parser.BINOP s -> String.concat "" ["BINOP";" ";"\"";s;"\""]
        |FOL_parser.QUANT s -> String.concat "" ["QUANT";" ";"\"";s;"\""]


let lexer (print_tokens : bool) (b : Lexing.lexbuf) : FOL_parser.token =
        let t : FOL_parser.token = FOL_lexer.token b in
        match print_tokens with
        |true -> let _ : unit = IO.print_to_stderr (string_of_token t) in t
        |false -> t


let rec fml_of_string (print_tokens : bool) (s:string): t_fml =
        let b : Lexing.lexbuf = Lexing.from_string s in
        try
                FOL_parser.main (lexer print_tokens) b
        with
        |FOL_parser.Error n ->
                match print_tokens with
                |false -> 
                        let _ : unit = IO.print_to_stderr (
                                String.concat "\n" [
                                        "Parsing failed in the following state of the automaton:";
                                        "=======================================================";
                                        FOL_parser_automaton.state n;
                                        "=======================================================";
                                        "Read the the following tokens from \"" ^ s ^ "\":";
                                ]
                        ) 
                        in fml_of_string true s
                |true -> raise (Error ("Last token does not match any transition- or reduction-rule of State " ^ (Int.to_string n) ^ "."))


let fml_list_of_file (print_tokens : bool) (path : string) : t_fml list =
        let ic = open_in path in
        let rec aux (acc : FOL_types.t_fml list) : t_fml list =
                try
                        let s : string = input_line ic in
                        let fml : t_fml = fml_of_string print_tokens s in
                        aux (fml::acc)
                with
                |End_of_file -> acc
                |Error e -> let _ : unit = IO.print_to_stderr e in acc
        in List.rev (aux [])

(** Printing *)

let rec string_of_fml (fml : t_fml) : string =
        match fml with
        | PredApp (Pred p, term_list) -> (
                match is_infix_pred p, term_list with
                |true, [a;b] -> String.concat "" [string_of_term a;" ";p;" ";string_of_term b]
                |false,[] -> p
                |_, _ -> String.concat "" [p;string_of_term_list term_list]
        )
        | BinopApp (Binop o, fml1, fml2) -> String.concat "" ["(";string_of_fml fml1;" ";o;" ";string_of_fml fml2;")"]
        | UnopApp (Unop o, fml) -> String.concat "" [o;string_of_fml fml]
        | QuantApp (Quant q, Var v,fml) -> String.concat "" [q;v;" ";string_of_fml fml] 

and string_of_term_list (term_list : t_term list) : string =
        String.concat "" ["(";String.concat "," (List.map string_of_term term_list);")"]

and string_of_term (term : t_term) : string =
        match term with
        | Atom (Var v) -> v
        | FuncApp (Func f, term_list) ->
                match is_infix_func f, term_list with
                |true, [a;b] -> String.concat "" ["(";string_of_term a;" ";f;" ";string_of_term b;")"]
                |false, [] -> f
                |false, [a] -> (
                        match is_postfix_func f with
                        |true -> String.concat "" [string_of_term a;f]
                        |false -> String.concat "" [f;"(";string_of_term a;")"]
                )
                |_, _ -> String.concat "" [f;string_of_term_list term_list]


and is_infix_pred (p : string) : bool =
        match p with
        |"=" | "<" | ">" |"≤" | "\\leq" | "≥" | "\\geq" 
        | "∈" | "\\in" | "⊂" | "\\subset" | "⊆" | "\\subseteq" -> true
        |_ -> false

and is_infix_func (f : string) : bool =
        match f with
        |"+"|"×"|"*"|"-"|"|" -> true
        |_ -> false

and is_postfix_func (f : string) : bool =
        match f with
        |"\'" -> true
        |_ -> false


