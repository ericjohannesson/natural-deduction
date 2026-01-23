open FML_types

exception Error of string

(** Parse *)

let defs_raw_of_file (path : string) : (string * string) list =
	let ic : in_channel = open_in path in
	let lexbuf : Lexing.lexbuf = Lexing.from_channel ic in
	DEF_parser.main DEF_lexer.token lexbuf

let defs_of_defs_raw (defs_raw : (string * string) list) : (t_fml * t_fml) list =
	let map ((s,t) : string * string) : t_fml * t_fml =
		(FML_main.fml_of_string false s, FML_main.fml_of_string false t)
	in List.map map defs_raw

let defs_of_file (path : string) : (t_fml * t_fml) list =
	defs_of_defs_raw (defs_raw_of_file path)

(** Print *)

let string_of_def (def : t_fml * t_fml) : string =
	match def with
	|(left, right) -> String.concat " " [FML_main.string_of_fml left;":=";FML_main.string_of_fml right]

let string_of_defs (defs : (t_fml * t_fml) list) : string =
	String.concat "\n" (List.map string_of_def defs)

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



let def_is_valid ((fml1,fml2) : t_fml * t_fml) : bool =
	match fml1 with
	|PredApp ((p : t_pred), (term_list : t_term list)) ->
		if FML_main.fml_contains_pred fml2 p then false else
		if has_duplicates term_list then false else
		let var_list : t_var list = FML_main.vars_of_terms term_list in
		if List.length var_list < List.length term_list then false else
		let free_vars : t_var list = FML_main.free_vars_of_fml fml2 in
		(is_subset_of var_list free_vars) &&
		(is_subset_of free_vars var_list)
	|_ -> false

let rec defs_contain_pred (defs : (t_fml * t_fml) list) (p : t_pred) : bool =
	match defs with
	|[] -> false
	|(fml1, fml2)::tl ->
		if FML_main.fml_contains_pred fml1 p then true else
		if FML_main.fml_contains_pred fml2 p then true else
		defs_contain_pred tl p

let rec rev_defs_are_valid (rev_defs : (t_fml * t_fml) list) : bool =
	match rev_defs with
	|[] -> true
	|hd::tl ->
		def_is_valid hd &&
		match hd with
		|(fml, _) ->
			match fml with
			|PredApp ((p : t_pred), _) -> 
				if defs_contain_pred tl p then false else
				rev_defs_are_valid tl
			|_ -> false

let defs_are_valid (defs : (t_fml * t_fml) list) : bool =
	rev_defs_are_valid (List.rev defs)


(** Expand *)

let rec replace_vars_in_fml_with_terms (vars : t_var list) (fml : t_fml) (terms : t_term list) : t_fml =
	match vars, terms with
	|[],[] -> fml
	|var::vars_tl, term::terms_tl ->
		replace_vars_in_fml_with_terms vars_tl (FML_main.subst_in_fml var term fml) terms_tl
	|_ -> raise (Error "unexpected error")

let rec replace_vars_in_fml_with_terms_opt (vars : t_var list) (fml : t_fml) (terms : t_term list) : t_fml option =
	match vars, terms with
	|[],[] -> Some fml
	|var::vars_tl, term::terms_tl -> (
		match (FML_main.subst_in_fml_opt var term fml) with
		|None -> None
		|Some f -> replace_vars_in_fml_with_terms_opt vars_tl f terms_tl
	)
	|_ -> raise (Error "unexpected error")

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

let rec replace_pred_in_fml_with_fml_opt (p : t_pred) (vars : t_var list) (right : t_fml) (fml : t_fml): t_fml option =
	match fml with
	|PredApp ((q : t_pred), (terms : t_term list)) ->
		if p=q && (List.length terms = List.length vars) then 
		replace_vars_in_fml_with_terms_opt vars right terms else Some fml
	|UnopApp (unop, fml1) -> (
		match replace_pred_in_fml_with_fml_opt p vars right fml1 with
		|Some f1 -> Some (UnopApp (unop, f1))
		|None -> None
	)
	|BinopApp (binop, fml1, fml2) -> (
		match replace_pred_in_fml_with_fml_opt p vars right fml1, replace_pred_in_fml_with_fml_opt p vars right fml2 with
		|Some f1, Some f2 -> Some (BinopApp (binop, f1, f2))
		|_, _ -> None
	)
	|QuantApp (quant, (var : t_var), fml1) -> (
		match replace_pred_in_fml_with_fml_opt p vars right fml1 with
		|Some f1 -> Some (QuantApp (quant, var, f1))
		|None -> None
	)

let rec expand_fml_by_rev_defs (rev_defs : (t_fml * t_fml) list) (fml : t_fml) : t_fml =
	match rev_defs with
	|[] -> fml
	|def::tl ->
		match def with
		|(PredApp (p,terms), right) ->
			let vars = FML_main.vars_of_terms terms in
			expand_fml_by_rev_defs tl (replace_pred_in_fml_with_fml p vars right fml)
		|_ -> raise (Error (String.concat " " ["invalid definition:";string_of_def def]))


let rec expand_fml_by_rev_defs_opt (rev_defs : (t_fml * t_fml) list) (fml : t_fml) : t_fml option =
	match rev_defs with
	|[] -> Some fml
	|def::tl ->
		match def with
		|(PredApp (p,terms), right) -> (
			let vars = FML_main.vars_of_terms terms in
			match replace_pred_in_fml_with_fml_opt p vars right fml with
			|Some f -> expand_fml_by_rev_defs_opt tl f
			|None -> None
		)
		|_ -> raise (Error (String.concat " " ["invalid definition:";string_of_def def]))

let expand_fml_by_defs (defs : (t_fml * t_fml) list) (fml : t_fml) : t_fml =
	expand_fml_by_rev_defs (List.rev defs) fml

let expand_fml_by_defs_opt (defs : (t_fml * t_fml) list) (fml : t_fml) : t_fml option =
	expand_fml_by_rev_defs_opt (List.rev defs) fml

