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

exception Parse_error of string

(** Parse *)

let string_of_token (t:FML_parser.token) : string =
        match t with
        |FML_parser.EOF -> "EOF"
        |FML_parser.LPAR -> "LPAR"
        |FML_parser.RPAR -> "RPAR"
        |FML_parser.LBR -> "LBR"
        |FML_parser.RBR -> "RBR"
        |FML_parser.COMMA -> "COMMA"
        |FML_parser.VAR s -> String.concat "" ["VAR";" ";"\'";s;"\'"]
        |FML_parser.PREFIX_FUNC s -> String.concat "" ["PREFIX_FUNC";" ";"\'";s;"\'"]
        |FML_parser.INFIX_FUNC s -> String.concat "" ["INFIX_FUNC";" ";"\'";s;"\'"]
        |FML_parser.POSTFIX_FUNC s -> String.concat "" ["POSTFIX_FUNC";" ";"\'";s;"\'"]
        |FML_parser.PREFIX_PRED s -> String.concat "" ["PREFIX_PRED";" ";"\'";s;"\'"]
        |FML_parser.INFIX_PRED s -> String.concat "" ["INFIX_PRED";" ";"\'";s;"\'"]
        |FML_parser.NEG_INFIX_PRED s -> String.concat "" ["NEG_INFIX_PRED";" ";"\'";s;"\'"]
        |FML_parser.UNOP s -> String.concat "" ["UNOP";" ";"\'";s;"\'"]
        |FML_parser.BINOP1 s -> String.concat "" ["BINOP1";" ";"\'";s;"\'"]
        |FML_parser.BINOP2 s -> String.concat "" ["BINOP2";" ";"\'";s;"\'"]
        |FML_parser.QUANT s -> String.concat "" ["QUANT";" ";"\'";s;"\'"]


let lexer (print_tokens : bool) (b : Lexing.lexbuf) : FML_parser.token =
        let t : FML_parser.token = FML_lexer.token b in
        match print_tokens with
        |true -> let _ : unit = IO.print_to_stderr (string_of_token t) in t
        |false -> t


let rec fml_of_string ?(print_tokens = false) (s:string): t_fml =
        let b : Lexing.lexbuf = Lexing.from_string s in
        try
                FML_parser.main (lexer print_tokens) b
        with
        |FML_parser.Error n ->
                match print_tokens with
                |false -> 
                        let _ : unit = IO.print_to_stderr_red (
                                String.concat "\n" [
                                        "FML_parser failed in the following state of the automaton:";
                                        "==========================================================";
                                        FML_parser_automaton.state n;
                                        "==========================================================";
                                        "Read the the following tokens from \'" ^ s ^ "\':";
                                ]
                        ) 
                        in fml_of_string ~print_tokens:true s
                |true -> 
                        let _ : unit = IO.print_to_stderr_red (
                                String.concat "" [
                                        "Last token does not match any Transitions or Reductions of State ";
                                        Int.to_string n;"."
                                ]
                        )
                        in raise (Parse_error s)


let fml_list_of_file (path : string) : t_fml list =
        let ic = open_in path in
        let rec aux (acc : FML_types.t_fml list) : t_fml list =
                try
                        let s : string = input_line ic in
                        let fml : t_fml = fml_of_string s in
                        aux (fml::acc)
                with
                |End_of_file -> acc
                |Parse_error e -> let _ : unit = IO.print_to_stderr e in acc
        in List.rev (aux [])

(** Print *)

let rec string_of_fml_rec (embedded: bool) (fml : t_fml) : string =
        match fml with
        | PredApp (p, term_list) -> (
                match is_infix_pred p, term_list with
                |true, [a;b] -> String.concat "" [string_of_term a;" ";string_of_pred p;" ";string_of_term b]
                |false,[] -> string_of_pred p
                |_, _ -> String.concat "" [string_of_pred p;string_of_term_list term_list]
        )
        | BinopApp (binop, fml1, fml2) -> (
                match embedded with
                |true -> String.concat "" ["("; string_of_fml_rec true fml1; " "; string_of_binop binop;" "; string_of_fml_rec true fml2;")"]
                |false -> String.concat "" [string_of_fml_rec true fml1; " "; string_of_binop binop; " "; string_of_fml_rec true fml2]
        )
        | UnopApp (unop, fml) -> String.concat "" [string_of_unop unop; string_of_fml_rec true fml]
        | QuantApp (quant, var,fml) -> String.concat "" [string_of_quant quant; string_of_var var; " "; string_of_fml_rec true fml]

and string_of_binop (binop : t_binop) : string =
        match binop with 
        |Binop s -> s

and string_of_unop (unop : t_unop) : string =
        match unop with 
        |Unop s -> s

and string_of_quant (quant : t_quant) : string =
        match quant with 
        |Quant s -> s

and string_of_pred (p : t_pred) : string =
        match p with
        |Pred s -> s

and string_of_var (var : t_var) : string =
        match var with
        |Var v -> v

and string_of_term_list (term_list : t_term list) : string =
        String.concat "" ["(";String.concat "," (List.map string_of_term term_list);")"]

and string_of_term_rec (embedded : bool) (term : t_term) : string =
        match term with
        | Atom var -> string_of_var var
        | FuncApp (Func f, term_list) ->
                match is_infix_func f, term_list with
                |true, [a;b] -> (
                        match embedded with
                        |true -> String.concat "" ["(";string_of_term_rec true a;" ";f;" ";string_of_term_rec true b;")"]
                        |false -> String.concat "" [string_of_term_rec true a;" ";f;" ";string_of_term_rec true b]
                )
                |false, [] -> f
                |false, [a] -> (
                        match is_postfix_func f with
                        |true -> String.concat "" [string_of_term_rec true a;f]
                        |false -> String.concat "" [f;"(";string_of_term a;")"]
                )
                |_, _ -> String.concat "" [f;string_of_term_list term_list]

and is_infix_pred (p : t_pred) : bool =
        match string_of_pred p with
        |"=" | "<" | ">" |"≤" | "\\leq" | "≥" | "\\geq" 
        | "∈" | "\\in" | "⊂" | "\\subset" | "⊆" | "\\subseteq" -> true
        |_ -> false

and is_infix_func (f : string) : bool =
        match f with
        |"+"|"×"|"*"|"-"|"^"|"·" -> true
        |_ -> false

and is_postfix_func (f : string) : bool =
        match f with
        |"\'" | "²" | "³" -> true
        |_ -> false

and string_of_fml (fml : t_fml) : string =
        string_of_fml_rec false fml

and string_of_term (term : t_term) : string =
        string_of_term_rec false term

(** Manipulate *)

let rec is_closed_term (term : t_term) : bool =
        match term with
        |Atom _ -> false
        |FuncApp (_, term_list) -> List.for_all is_closed_term term_list


let rec closed_terms_of_fml (fml : t_fml) : t_term list =
        match fml with
        | PredApp (_, term_list) -> closed_terms_of_term_list term_list
        | BinopApp (_, fml1, fml2) -> List.concat [closed_terms_of_fml fml1;closed_terms_of_fml fml2]
        | UnopApp (_, fml1) -> closed_terms_of_fml fml1
        | QuantApp (_, _, fml1) -> closed_terms_of_fml fml1

and closed_terms_of_term_list (term_list : t_term list) : t_term list =
        List.flatten (List.map closed_terms_of_term term_list)

and closed_terms_of_term (term : t_term) : t_term list =
        match term with
        |Atom _ -> []
        |FuncApp (_,[]) -> [term]
        |FuncApp (_, term_list) ->
                match is_closed_term term with
                |true -> term::(closed_terms_of_term_list term_list)
                |false -> closed_terms_of_term_list term_list


let rec subst_in_term (var : t_var) (replacement : t_term) (term : t_term): t_term =
        match term with
        | Atom var1 -> (
                match var = var1 with
                |true -> replacement
                |false -> term
        )
        | FuncApp (func, term_list) -> FuncApp (func, List.map (subst_in_term var replacement) term_list)


let rec subst_in_fml (var : t_var) (term : t_term) (fml : t_fml) : t_fml =
        match fml with
        | PredApp (pred, term_list) -> PredApp (pred, List.map (subst_in_term var term) term_list)
        | BinopApp (binop, fml1, fml2) -> BinopApp (binop, subst_in_fml var term fml1, subst_in_fml var term fml2)
        | UnopApp (unop, fml1) -> UnopApp (unop, subst_in_fml var term fml1)
        | QuantApp (quant, var1, fml1) -> 
                match var = var1 with
                |true -> QuantApp (quant, var1, fml1)
                |false -> QuantApp (quant, var1, subst_in_fml var term fml1)


let rec vars_of_terms (term_list : t_term list) : t_var list =
        let rec aux (lst : t_term list) (acc : t_var list) : t_var list =
                match lst with
                |[] -> acc
                |hd::tl ->
                        match hd with
                        |Atom (var : t_var) -> aux tl (var::acc)
                        |FuncApp (_, terms) -> aux tl (List.concat [acc;vars_of_terms terms])
        in List.rev (aux term_list [])


let fml_is_fml_with_var_replaced_by_term (inst : t_fml) (fml : t_fml) (var : t_var) : t_term option =
        let rec aux (term_list : t_term list) : t_term option =
                match term_list with
                |[] -> None
                |hd::tl -> 
                        match inst = subst_in_fml var hd fml with
                        |true -> Some hd
                        |false -> aux tl
        in
        aux (closed_terms_of_fml inst)


let subtract (lst1 : 'a list) (lst2 : 'a list) : 'a list =
        let rec aux (lst : 'a list) (acc : 'a list) : 'a list =
                match lst with
                |[] -> acc
                |hd::tl ->
                        if List.mem hd lst2 then aux tl acc else
                        aux tl (hd::acc)
        in aux lst1 []


let free_vars_of_fml (fml : t_fml) : t_var list =
        let rec aux (bound_vars : t_var list) (f : t_fml) : t_var list =
                match f with
                |PredApp (_, (term_list : t_term list)) ->
                        subtract (vars_of_terms term_list) bound_vars
                |UnopApp (_, fml1) ->
                        aux bound_vars fml1
                |BinopApp (_, fml1, fml2) ->
                        List.concat [aux bound_vars fml1;aux bound_vars fml2]
                |QuantApp (_, (var : t_var), fml1) ->
                        aux (var::bound_vars) fml1
        in aux [] fml


