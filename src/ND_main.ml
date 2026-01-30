open FML_types
open PRF_types
open ND_types

exception Parse_error of string
exception Invalid_definition of t_item
exception Too_many_variables of (t_var list)
exception Too_many_terms of (t_term list)


(** Parse *)


let items_of_file (path : string) : t_item list =
        match Sys.file_exists path with
        |false -> raise (Parse_error ("Cannot read from " ^ path ^ ": No such file"))
        |true -> 
	let ic : in_channel = open_in path in
	let lexbuf : Lexing.lexbuf = Lexing.from_channel ic in
	try ND_parser.main ND_lexer.token lexbuf with
	|PRF_main.Parse_error e -> 
		raise (Parse_error (String.concat "" [
			"Parsing failed on line ";string_of_int (ND_lexer.line_of_lexbuf lexbuf);" of "; path;"; ";
			"Cannot parse the following proof:\n";e;
		]))
	|FML_main.Parse_error e ->
 		raise (Parse_error (String.concat "" [
			"Parsing failed on line ";string_of_int (ND_lexer.line_of_lexbuf lexbuf);" of ";path;"; ";
			"Cannot parse the following formula: \'";e;"\'";
		]))

	|_ -> raise (Parse_error (String.concat " " ["Parsing failed on line";string_of_int (ND_lexer.line_of_lexbuf lexbuf);"of"; path]))

(** Print *)

let string_of_item (item : t_item) : string =
	match item with
	|Prf prf -> PRF_main.string_of_prf prf
	|Def_fml (left, right, line) -> String.concat "" [FML_main.string_of_fml left;" := ";FML_main.string_of_fml right]
	|Def_prf (left, right, line) -> String.concat "" [PRF_main.string_of_prf left;" :=\n\n";PRF_main.string_of_prf right]

let string_of_items (items : t_item list) : string =
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


let valid_def_fml (item : t_item) : (t_pred * (t_var list) * t_fml) option =
	match item with
	|Prf _ -> None
	|Def_fml (fml1, fml2, line) -> (
		match fml1 with
		|PredApp ((p : t_pred), (term_list : t_term list)) ->
(*			if FML_main.fml_contains_pred fml2 p then None else *)
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

let valid_def_prf (item : t_item) : (t_prf * t_prf) option =
	match item with
	|Prf _ -> None
	|Def_fml _ -> None
	|Def_prf (prf1, prf2, line) ->
		match prf1 with
		|Atomic_prf _ -> Some (prf1, prf2)
		|_ -> None



let is_valid_item (item : t_item) : bool =
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

let rec replace_vars_in_fml_with_terms (vars : t_var list) (fml : t_fml) (terms : t_term list) : t_fml =
	match vars, terms with
	|[],[] -> fml
	|var::vars_tl, term::terms_tl ->
		replace_vars_in_fml_with_terms vars_tl (FML_main.subst_in_fml var term fml) terms_tl
	|var::vars_tl, [] -> raise (Too_many_variables vars)
	|[], term::terms -> raise (Too_many_terms terms)


let rec replace_vars_in_fml_with_terms_err (vars : t_var list) (fml : t_fml) (terms : t_term list) : t_fml =
	match vars, terms with
	|[],[] -> fml
	|var::vars_tl, term::terms_tl ->
		replace_vars_in_fml_with_terms_err vars_tl (FML_main.subst_in_fml_err var term fml) terms_tl
	|var::vars_tl, [] -> raise (Too_many_variables vars)
	|[], term::terms -> raise (Too_many_terms terms)

let rec replace_pred_in_fml_with_fml (p : t_pred) (vars : t_var list) (right : t_fml) (fml : t_fml): t_fml =
	match fml with
	|PredApp ((q : t_pred), (terms : t_term list)) ->
		if p=q && (List.length terms = List.length vars) then 
		replace_vars_in_fml_with_terms vars right terms else fml
	|UnopApp (unop, fml1) ->
		UnopApp (unop, replace_pred_in_fml_with_fml p vars right fml1)
	|BinopApp (binop, fml1, fml2) ->
		BinopApp (binop, replace_pred_in_fml_with_fml p vars right fml1, replace_pred_in_fml_with_fml p vars right fml2)
	|QuantApp (quant, (var : t_var), fml1) ->
		QuantApp (quant, var, replace_pred_in_fml_with_fml p vars right fml1)

let rec replace_pred_in_fml_with_fml_err (p : t_pred) (vars : t_var list) (right : t_fml) (fml : t_fml): t_fml =
	match fml with
	|PredApp ((q : t_pred), (terms : t_term list)) ->
		if p=q && (List.length terms = List.length vars) then 
		replace_vars_in_fml_with_terms_err vars right terms else fml
	|UnopApp (unop, fml1) ->
		UnopApp (unop, replace_pred_in_fml_with_fml_err p vars right fml1)
	|BinopApp (binop, fml1, fml2) ->
		BinopApp (binop, replace_pred_in_fml_with_fml_err p vars right fml1, replace_pred_in_fml_with_fml_err p vars right fml2)
	|QuantApp (quant, (var : t_var), fml1) ->
		QuantApp (quant, var, replace_pred_in_fml_with_fml_err p vars right fml1)


let apply_item_to_item (item1 : t_item) (item2 : t_item) : t_item =
	match item1 with
	|Prf _ -> item2
	|Def_fml _ -> ( 
		match valid_def_fml item1 with
		|Some (p1,vars,right1) -> (
			let map (fml : t_fml) : t_fml = 
				replace_pred_in_fml_with_fml_err p1 vars right1 fml
			in
			match item2 with
			|Prf prf -> Prf (PRF_main.transform_prf map prf)
			|Def_fml (left2, right2, line) -> Def_fml (left2, map right2, line)
			|Def_prf (left2, right2, line) -> Def_prf (left2, PRF_main.transform_prf map right2, line)
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
			|Def_prf (left2, right2, line) ->
				Def_prf (left2, PRF_main.subst_in_prf map right2, line)
			|_ -> item2
		)
		|None -> raise (Invalid_definition item1)
	)

let rec expand_items_rec (items : t_item list) (acc : t_item list): t_item list =
	match items with
	|[] -> List.rev acc
	|hd::tl ->
		if is_valid_item hd then
			let map (item1 : t_item) (item2 : t_item) : t_item =
				try apply_item_to_item item1 item2 with
				|FML_main.Cannot_replace_var_with_term_containing_var_in_fml (var, term, var1, fml) -> 
					let _ : unit = IO.print_to_stderr_yellow (String.concat "" [
						"WARNING: Cannot replace \'";
						FML_main.string_of_var var;"\' with \'";
						FML_main.string_of_term term;"\' containing \'";
						FML_main.string_of_var var1;"\' in \'";
						FML_main.string_of_fml fml;"\'"
					]) in item2
			in
			let new_tl = List.map (map hd) tl in
			expand_items_rec new_tl (hd::acc)
		else
		let _ : unit = 
			match hd with
			|Prf _ -> ()
			|Def_fml (fml1,_,line) ->
				IO.print_to_stderr_yellow (String.concat "" [
					"WARNING: Invalid definition on line ";string_of_int line;": \'";
					FML_main.string_of_fml fml1;" := ...\'";
				])
			|Def_prf (prf1,_,line) ->
				IO.print_to_stderr_yellow (String.concat "" [
					"WARNING: Invalid definition on line ";string_of_int line;": \'";
					PRF_main.string_of_prf prf1;" := ...\'";
				])
		in
		expand_items_rec tl (hd::acc)


let rec expand_items_rec_alt (rev_items : t_item list) (acc : t_item list): t_item list =
	match rev_items with
	|[] -> acc
	|hd::tl ->
		if is_valid_item hd then
			let map (item1 : t_item) (item2 : t_item) : t_item =
				try apply_item_to_item item1 item2 with
				|FML_main.Cannot_replace_var_with_term_containing_var_in_fml (var, term, var1, fml) -> 
					let _ : unit = IO.print_to_stderr_yellow (String.concat "" [
						"WARNING: Cannot replace \'";
						FML_main.string_of_var var;"\' with \'";
						FML_main.string_of_term term;"\' (which contains \'";
						FML_main.string_of_var var1;"\') in \'";
						FML_main.string_of_fml fml;"\'"
					]) in item2
			in
			let new_acc = List.map (map hd) acc in
			expand_items_rec_alt tl (hd::new_acc)
		else
		let _ : unit = 
			match hd with
			|Prf _ -> ()
			|Def_fml (fml1,_,line) ->
				IO.print_to_stderr_yellow (String.concat "" [
					"WARNING: Invalid definition on line ";string_of_int line;": \'";
					FML_main.string_of_fml fml1;" := ...\'";
				])
			|Def_prf (prf1,_,line) ->
				IO.print_to_stderr_yellow (String.concat "" [
					"WARNING: Invalid definition on line ";string_of_int line;": \'";
					PRF_main.string_of_prf prf1;" := ...\'";
				])
		in
		expand_items_rec_alt tl (hd::acc)

let expand_items (items : t_item list) : t_item list =
	expand_items_rec items []

let expand_items_alt (items : t_item list) : t_item list =
	expand_items_rec_alt (List.rev items) []

let expand_file (path : string) : t_item list =
	let items : t_item list = items_of_file path in
	expand_items items

let expand_file_alt (path : string) : t_item list =
	let items : t_item list = items_of_file path in
	expand_items_alt items

