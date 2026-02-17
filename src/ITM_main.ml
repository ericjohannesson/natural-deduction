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
open PRF_types
open ITM_types

exception Parse_error of string
exception Invalid_definition of t_itm
exception Cannot_replace_var_with_term_containing_var_in_fml of t_var * t_term * t_var * t_fml 


(** Parse *)


let items_of_file (path : string) : t_itm list =
        match Sys.file_exists path with
        |false -> raise (Parse_error ("Cannot read from " ^ path ^ ": No such file"))
        |true -> 
        let ic : in_channel = open_in path in
        let lexbuf : Lexing.lexbuf = Lexing.from_channel ic in
        try ITM_parser.main ITM_lexer.token lexbuf with
        |PRF_main.Parse_error e -> 
                raise (Parse_error (String.concat "" [
                        "Parsing failed on line ";string_of_int (ITM_lexer.line_of_lexbuf lexbuf);" of "; path;"; ";
                        "Cannot parse the following proof:\n";e;
                ]))
        |FML_main.Parse_error e ->
                raise (Parse_error (String.concat "" [
                        "Parsing failed on line ";string_of_int (ITM_lexer.line_of_lexbuf lexbuf);" of ";path;"; ";
                        "Cannot parse the following formula: \'";e;"\'";
                ]))

        |_ -> raise (Parse_error (String.concat " " ["Parsing failed on line";string_of_int (ITM_lexer.line_of_lexbuf lexbuf);"of"; path]))

(** Print *)

let string_of_item (item : t_itm) : string =
        match item with
        |Prf prf -> PRF_main.string_of_prf prf
        |Def_fml (left, right) -> String.concat "" [FML_main.string_of_fml left;" := ";FML_main.string_of_fml right]
        |Def_prf (left, right) -> String.concat "" [PRF_main.string_of_prf left;" :=\n\n";PRF_main.string_of_prf right]

let string_of_items (items : t_itm list) : string =
        String.concat "\n\n" (List.map string_of_item items)


(** Validate *)


let rec has_duplicates (lst : 'a list) : bool =
        match lst with
        |[] -> false
        |hd::tl ->
                if List.mem hd tl then true else
                has_duplicates tl

let rec is_subset_of (lst1 : 'a list) (lst2: 'a list) : bool =
        match lst1 with
        |[] -> true
        |hd::tl ->
                if List.mem hd lst2 then is_subset_of tl lst2 else false


let valid_def_fml (item : t_itm) : (t_pred * (t_var list) * t_fml) option =
        match item with
        |Prf _ -> None
        |Def_fml (fml1, fml2) -> (
                match fml1 with
                |PredApp ((p : t_pred), (term_list : t_term list)) ->
                        let var_list : t_var list = FML_main.vars_of_terms term_list in
                        if List.length var_list < List.length term_list then None else
                        if has_duplicates var_list then None else
                        let free_vars : t_var list = FML_main.free_vars_of_fml fml2 in
                        if (is_subset_of var_list free_vars) && (is_subset_of free_vars var_list) then
                                Some (p,var_list,fml2)
                        else None
                |_ -> None
        )
        |Def_prf _ -> None

let valid_def_prf (item : t_itm) : (t_prf * t_prf) option =
        match item with
        |Prf _ -> None
        |Def_fml _ -> None
        |Def_prf (prf1, prf2) ->
                match prf1 with
                |Atomic_prf _ -> Some (prf1, prf2)
                |_ -> None



let is_valid_item (item : t_itm) : bool =
        match item with
        |Prf _ -> true
        |Def_fml _ -> (
                match valid_def_fml item with
                |Some _ -> true
                |None -> false
        )
        |Def_prf _ -> (
                match valid_def_prf item with
                |Some _ -> true
                |None -> false
        )

(** Expand *)


let rec subst_free_vars_in_fml_with_terms (subst : t_var -> t_term) (fml : t_fml) : t_fml =
        match fml with
        |PredApp (p, terms) ->
                let map (term : t_term) : t_term =
                        match term with
                        |Atom var -> subst var
                        |_ -> term
                in PredApp (p, List.map map terms)
        |UnopApp (unop, fml1) ->
                UnopApp (unop, subst_free_vars_in_fml_with_terms subst fml1)
        |BinopApp (binop, fml1, fml2) ->
                BinopApp (binop, subst_free_vars_in_fml_with_terms subst fml1, subst_free_vars_in_fml_with_terms subst fml2)
        |QuantApp (quant, var1, fml1) ->
                let new_subst (var : t_var) : t_term =
                        if var = var1 then Atom var else 
                        match List.mem var1 (FML_main.vars_of_terms [subst var]) with
                        |true -> raise (Cannot_replace_var_with_term_containing_var_in_fml (var, subst var, var1, fml))
                        |false -> subst var 
                in
                QuantApp (quant, var1, subst_free_vars_in_fml_with_terms new_subst fml1)


let subst_func_of_vars_terms (vars: t_var list) (terms : t_term list) : (t_var -> t_term) =
        let rec aux vars terms (acc : t_var -> t_term) : (t_var -> t_term) =
                match vars, terms with
                |[],[] -> acc
                |vars_hd::vars_tl, terms_hd::terms_tl ->
                        let new_acc (var : t_var) : t_term =
                                if var = vars_hd then terms_hd else acc var
                        in aux vars_tl terms_tl new_acc
                |_,_ -> raise (Invalid_argument "term lists of unequal length")
        in
        let acc (var : t_var) : t_term = Atom var in
        aux vars terms acc


let rec replace_pred_in_fml_with_fml (p : t_pred) (vars : t_var list) (right : t_fml) (fml : t_fml): t_fml =
        match fml with
        |PredApp ((q : t_pred), (terms : t_term list)) ->
                if p=q && (List.length terms = List.length vars) then 
                subst_free_vars_in_fml_with_terms (subst_func_of_vars_terms vars terms) right else fml
        |UnopApp (unop, fml1) ->
                UnopApp (unop, replace_pred_in_fml_with_fml p vars right fml1)
        |BinopApp (binop, fml1, fml2) ->
                BinopApp (binop, replace_pred_in_fml_with_fml p vars right fml1, replace_pred_in_fml_with_fml p vars right fml2)
        |QuantApp (quant, (var : t_var), fml1) ->
                QuantApp (quant, var, replace_pred_in_fml_with_fml p vars right fml1)


let apply_item_to_item (item1 : t_itm) (item2 : t_itm) : t_itm =
        match item1 with
        |Prf _ -> item2
        |Def_fml _ -> ( 
                match valid_def_fml item1 with
                |Some (p1,vars,right1) -> (
                        let map (fml : t_fml) : t_fml = 
                                replace_pred_in_fml_with_fml p1 vars right1 fml
                        in
                        match item2 with
                        |Prf prf -> Prf (PRF_main.transform_prf map prf)
                        |Def_fml (left2, right2) -> Def_fml (left2, map right2)
                        |Def_prf (left2, right2) -> Def_prf (left2, PRF_main.transform_prf map right2)
                )       
                |None -> raise (Invalid_definition item1)
        )
        |Def_prf _ -> (
                match valid_def_prf item1 with
                |Some (prf1, right1) -> (
                        let map (prf : t_prf) : t_prf =
                                if prf = prf1 then right1 else prf
                        in
                        match item2 with
                        |Prf prf -> Prf (PRF_main.subst_in_prf map prf)
                        |Def_prf (left2, right2) ->
                                Def_prf (left2, PRF_main.subst_in_prf map right2)
                        |_ -> item2
                )
                |None -> raise (Invalid_definition item1)
        )


let rec expand_items_rec (rev_items : t_itm list) (acc : t_itm list): t_itm list =
        match rev_items with
        |[] -> acc
        |hd::tl ->
                if is_valid_item hd then
                        let map (item1 : t_itm) (item2 : t_itm) : t_itm =
                                try apply_item_to_item item1 item2 with
                                |Cannot_replace_var_with_term_containing_var_in_fml (var, term, var1, fml) -> 
                                        let _ : unit = IO.print_to_stderr_yellow (String.concat "" [
                                                "WARNING: Cannot replace \'";
                                                FML_main.string_of_var var;"\' with \'";
                                                FML_main.string_of_term term;"\' (which contains \'";
                                                FML_main.string_of_var var1;"\') in \'";
                                                FML_main.string_of_fml fml;"\'"
                                        ]) in item2
                        in
                        let new_acc = List.map (map hd) acc in
                        expand_items_rec tl (hd::new_acc)
                else
                let _ : unit = 
                        match hd with
                        |Prf _ -> ()
                        |Def_fml (fml1,_) ->
                                IO.print_to_stderr_yellow (String.concat "" [
                                        "WARNING: Invalid definition: \'";
                                        FML_main.string_of_fml fml1;" := ...\'";
                                ])
                        |Def_prf (prf1,_) ->
                                IO.print_to_stderr_yellow (String.concat "" [
                                        "WARNING: Invalid definition: \'";
                                        PRF_main.string_of_prf prf1;" := ...\'";
                                ])
                in
                expand_items_rec tl (hd::acc)


let expand_items (items : t_itm list) : t_itm list =
        expand_items_rec (List.rev items) []

let expand_file (path : string) : t_itm list =
        let items : t_itm list = items_of_file path in
        expand_items items


