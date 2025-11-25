open ND_types
open FOL_types

exception Error of string

(** Parsing *)

let prf_raw_of_file (path : string) : t_prf_raw =
	ND_main.prf_raw_of_file false false path

let prf_raw_of_string (s : string) : t_prf_raw =
	ND_main.prf_raw_of_string false false s

let prf_raw_of_stdin () : t_prf_raw =
	ND_main.prf_raw_of_stdin false false


let fml_list_of_file (path : string) =
	FOL_main.fml_list_of_file false path

let fml_of_string (s : string) =
	FOL_main.fml_of_string false s

let rec prf_of_prf_raw (prf_raw : t_prf_raw) : t_prf =
	match prf_raw with
	| Atomic_prf_raw fml_raw ->
		Atomic_prf (fml_of_fml_raw fml_raw) 
	| Nullary_prf_raw (nullary_rule, fml_raw) ->
		Nullary_prf (nullary_rule, fml_of_fml_raw fml_raw)
	| Unary_prf_raw (prf_raw1, unary_rule, fml_raw) ->
		Unary_prf (prf_of_prf_raw prf_raw1, unary_rule, fml_of_fml_raw fml_raw)
	| Binary_prf_raw (prf_raw1, prf_raw2, binary_rule, fml_raw) ->
		Binary_prf (prf_of_prf_raw prf_raw1, prf_of_prf_raw prf_raw2, binary_rule, fml_of_fml_raw fml_raw)
	| Trinary_prf_raw (prf_raw1, prf_raw2, prf_raw3, trinary_rule, fml_raw) ->
		Trinary_prf (prf_of_prf_raw prf_raw1, prf_of_prf_raw prf_raw2, prf_of_prf_raw prf_raw3, trinary_rule, fml_of_fml_raw fml_raw)

and fml_of_fml_raw (fml_raw : t_fml_raw) : t_fml =
	match fml_raw with
	Fml_raw (s : string) -> fml_of_string s

let prf_of_file (path:string) =
	prf_of_prf_raw (prf_raw_of_file path)

let prf_of_string (s : string) =
	prf_of_prf_raw (prf_raw_of_string s)

let prf_of_stdin () =
	prf_of_prf_raw (prf_raw_of_stdin ())


(** Printing *)

let string_of_fml (fml : t_fml) : string =
	FOL_main.string_of_fml fml

let fml_raw_of_fml (fml : t_fml) : t_fml_raw =
	Fml_raw (string_of_fml fml)

let rec prf_raw_of_prf (prf : t_prf) : t_prf_raw =
	match prf with
	| Atomic_prf fml ->
		Atomic_prf_raw (fml_raw_of_fml fml) 
	| Nullary_prf (nullary_rule, fml) ->
		Nullary_prf_raw (nullary_rule, fml_raw_of_fml fml)
	| Unary_prf (prf, unary_rule, fml) ->
		Unary_prf_raw (prf_raw_of_prf prf, unary_rule, fml_raw_of_fml fml)
	| Binary_prf (prf1, prf2, binary_rule, fml) ->
		Binary_prf_raw (prf_raw_of_prf prf1, prf_raw_of_prf prf2, binary_rule, fml_raw_of_fml fml)
	| Trinary_prf (prf1, prf2, prf3, trinary_rule, fml) ->
		Trinary_prf_raw (prf_raw_of_prf prf1, prf_raw_of_prf prf2, prf_raw_of_prf prf3, trinary_rule, fml_raw_of_fml fml)

let nd_string_of_prf (prf : t_prf) : string =
	ND_main.nd_string_of_prf_raw (prf_raw_of_prf prf)

(** Validation *)

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

and is_closed_term (term : t_term) : bool =
	match term with
	|Atom _ -> false
	|FuncApp (_, term_list) -> List.for_all is_closed_term term_list

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

let is_instance_of_with (inst : t_fml) (fml : t_fml) (var : t_var) : t_term option =
	let rec aux (term_list : t_term list) : t_term option =
		match term_list with
		|[] -> None
		|hd::tl -> 
			match inst = subst_in_fml var hd fml with
			|true -> Some hd
			|false -> aux tl
	in
	aux (closed_terms_of_fml inst)

let rec subst_equiv_terms (term1 : t_term) (term2 : t_term) (eq_term1 : t_term) (eq_term2 : t_term) : bool =
	(eq_term1 = term1 && eq_term2 = term2) || 
	(eq_term1 = term2 && eq_term2 = term1) ||
	(eq_term1 = eq_term2) ||
	match eq_term1, eq_term2 with
	| FuncApp (func1, term_list1), FuncApp (func2, term_list2) ->
		(func1 = func2 && (subst_equiv_term_lists term1 term2 term_list1 term_list2))
	| Atom var1, Atom var2 -> var1 = var2
	| _ ,_  -> false

and subst_equiv_term_lists (term1 : t_term) (term2 : t_term) (term_list1 : t_term list) (term_list2 : t_term list) : bool =
	try List.for_all2 (subst_equiv_terms term1 term2) term_list1 term_list2
	with _ -> false


let rec subst_equiv (term1 : t_term) (term2 : t_term) (fml1 : t_fml) (fml2 : t_fml) : bool =
	match fml1, fml2 with
	| PredApp (pred1, term_list1), PredApp (pred2, term_list2) ->
		pred1 = pred2 && (subst_equiv_term_lists term1 term2 term_list1 term_list2)
	| BinopApp (binop1, fml11, fml12), BinopApp (binop2, fml21, fml22) ->
		binop1 = binop2 && (subst_equiv term1 term2 fml11 fml21) && (subst_equiv term1 term2 fml12 fml22)
	| UnopApp (unop1, fml11), UnopApp (unop2, fml21) ->
		unop1 = unop2 && (subst_equiv term1 term2 fml11 fml21)
	| QuantApp (quant1, var1, fml11), QuantApp (quant2, var2, fml21) -> 
		quant1 = quant2 && var1 = var2 && (subst_equiv term1 term2 fml11 fml21)
	|_ ,_ -> false


let conclusion_of_prf (prf : t_prf) : t_fml =
	match prf with
	|Atomic_prf fml -> fml
	|Nullary_prf (_, fml) -> fml
	|Unary_prf (_,_,fml) -> fml
	|Binary_prf (_,_,_,fml) -> fml
	|Trinary_prf (_,_,_,_,fml) -> fml

let rec premises_of_prf (excluded : t_fml list) (prf : t_prf): t_fml list =
	match prf with
	|Atomic_prf fml -> if List.mem fml excluded then [] else [fml]
	|Nullary_prf (_, fml) -> []
	|Unary_prf (prf1,_,_) -> premises_of_prf excluded prf1 
	|Binary_prf (prf1, prf2, _, _) -> List.concat [premises_of_prf excluded prf1; premises_of_prf excluded prf2] 
	|Trinary_prf (prf1, prf2, prf3, _, _) -> List.concat [premises_of_prf excluded prf1; premises_of_prf excluded prf2; premises_of_prf excluded prf3] 


let occurs_in (term : t_term) (fml : t_fml) : bool =
	List.mem term (closed_terms_of_fml fml)

let discharge (options : string list) : bool =
	 List.mem "--discharge" options || List.mem "-d" options

let undischarge (options : string list) : bool =
	 List.mem "--undischarge" options || List.mem "-u" options


let verbose (options : string list) : bool =
	 List.mem "--verbose" options || List.mem "-v" options


let rec validate (options: string list) (rule_count : int) (attempt : int) (dischargeable: t_fml -> int option) (acc : t_prf list) (prf : t_prf) : t_prf option =
	match prf with
	| Atomic_prf fml -> (
			match dischargeable fml with
			|None -> Some prf
			|Some i ->
				let _ : unit =
					if verbose options then
					IO.print_to_stderr (
					String.concat "" [
					"\nGOOD NEWS: Undischarged assumption ";
					"\'"; string_of_fml fml; "\'";
					" may be discharged on the following branch:\n\n";
					String.concat "\n\nwhich is part of\n\n" (List.map nd_string_of_prf (prf::acc));"\n";
					]
					) else ()
				in
				match discharge options with
				|false -> Some prf
				|true -> 
					let _ : unit = 
						if verbose options then
						IO.print_to_stderr "Discharging it.\n" 
						else ()
					in
					Some (Nullary_prf (Nullary_rule (string_of_int i), fml))
	)
	| Nullary_prf (_, fml) -> (
		match fml, attempt with
		|PredApp (Pred "=",[term1;term2]), 0 -> (
			match term1 = term2 with
			|true -> Some (Nullary_prf (Nullary_rule "=I", fml))
			|false -> validate options rule_count (attempt+1) dischargeable acc prf
		)
		|_, _ ->
			match dischargeable fml with
			|Some i -> Some (Nullary_prf (Nullary_rule (string_of_int i), fml))
			|None ->
				let _ : unit = 
					if verbose options then
					IO.print_to_stderr (
					String.concat "" [
					"\nBAD NEWS: Discharged assumption ";
					"\'"; string_of_fml fml; "\'";
					" may not be discharged on the following branch:\n\n";
					String.concat "\n\nwhich is part of\n\n" (List.map nd_string_of_prf (prf::acc));"\n";
					]
					) else ()
				in
				match undischarge options with
				|false -> None
				|true -> 
					let _ : unit = 
						if verbose options then
						IO.print_to_stderr "Undischarging it.\n" 
						else () 
					in
					Some (Atomic_prf fml)

	)
	| Unary_prf (prf1, _, fml) -> (
		match conclusion_of_prf prf1, fml, attempt with
			|BinopApp (Binop "∧", conj1, conj2), _, 0 -> (
				match fml = conj1 || fml = conj2 with
				|true -> (
					match validate options rule_count 0 dischargeable (prf::acc) prf1 with
					|Some valid_prf1 -> Some (Unary_prf (valid_prf1, Unary_rule "∧E", fml))
					|None -> validate options rule_count (attempt+1) dischargeable acc prf
				)
				|false -> validate options rule_count (attempt+1) dischargeable acc prf
			)
			|fml1, BinopApp (Binop "∨", disj1, disj2), 1 -> (
				match fml1 = disj1 || fml1 = disj2 with
				|true -> (
					match validate options rule_count 0 dischargeable (prf::acc) prf1 with
					|Some valid_prf1 -> Some (Unary_prf (valid_prf1, Unary_rule "∨I", fml))
					|None -> validate options rule_count (attempt+1) dischargeable acc prf
				)
				|false -> validate options rule_count (attempt+1) dischargeable acc prf
			)
			|fml1, BinopApp (Binop "→", ant, cons), 2 -> (
				match fml1 = cons with
				|true -> (
					let dischargeable_new (f : t_fml) : int option =
						if f = ant then Some rule_count else dischargeable f
					in
					match validate options (rule_count+1) 0 dischargeable_new (prf::acc) prf1 with
					|Some valid_prf1 -> 
						Some (Unary_prf (
							valid_prf1, 
							Unary_rule ("→I" ^ (string_of_int rule_count)),
							fml
						))
					|None -> validate options rule_count (attempt+1) dischargeable acc prf
				)
				|false -> validate options rule_count (attempt+1) dischargeable acc prf
			)
			|fml1, QuantApp (Quant "∀", var, sub_fml), 3 -> (
				match is_instance_of_with fml1 sub_fml var with
				|Some (FuncApp (Func c,[])) -> (
					match List.exists (occurs_in (FuncApp (Func c,[]))) (premises_of_prf [] prf1) with
					|false -> (
						match validate options rule_count 0 dischargeable (prf::acc) prf1 with
						|Some valid_prf1 -> Some (Unary_prf (valid_prf1, Unary_rule "∀I", fml))
						|None -> validate options rule_count (attempt+1) dischargeable acc prf
					)
					|true -> validate options rule_count (attempt+1) dischargeable acc prf
				)
				|_ -> validate options rule_count (attempt+1) dischargeable acc prf
			)
			|fml1, QuantApp (Quant "∃", var, sub_fml), 4 -> (
				match is_instance_of_with fml1 sub_fml var with
				|Some _ -> (
					match validate options rule_count 0 dischargeable (prf::acc) prf1 with
					|Some valid_prf1 -> Some (Unary_prf (valid_prf1, Unary_rule "∃I", fml))
					|None -> validate options rule_count (attempt+1) dischargeable acc prf
				)
				|None -> validate options rule_count (attempt+1) dischargeable acc prf
			)
			|QuantApp (Quant "∀", var, sub_fml1), _, 5 -> (
				match is_instance_of_with fml sub_fml1 var with
				|Some _ -> (
					match validate options rule_count 0 dischargeable (prf::acc) prf1 with
					|Some valid_prf1 -> Some (Unary_prf (valid_prf1, Unary_rule "∀E", fml))
					|None -> validate options rule_count (attempt+1) dischargeable acc prf
				)
				|None -> validate options rule_count (attempt+1) dischargeable acc prf
			)
			|BinopApp (Binop "↔", eqv1, eqv2), _, 6 -> (
				match fml = BinopApp (Binop "→", eqv1, eqv2) || fml = BinopApp (Binop "→", eqv2, eqv1) with
				|true -> (
					match validate options rule_count 0 dischargeable (prf::acc) prf1 with
					|Some valid_prf1 -> Some (Unary_prf (valid_prf1, Unary_rule "↔E", fml))
					|None -> validate options rule_count (attempt+1) dischargeable acc prf
				)
				|false -> validate options rule_count (attempt+1) dischargeable acc prf
			)
			|_, _, 7 -> 
				let _ : unit = 
					if verbose options then
					IO.print_to_stderr (
					String.concat "" [
					"\nBAD NEWS: The following branch does not satisfy the conditions of any unary rule:\n\n";
					String.concat "\n\nwhich is part of\n\n" (List.map nd_string_of_prf (prf::acc));"\n";
					]
					) else ()
				in None

			|_, _, _ -> validate options rule_count (attempt+1) dischargeable acc prf
	)
	| Binary_prf (prf1, prf2, _, fml) -> (
		match conclusion_of_prf prf1, conclusion_of_prf prf2, fml, attempt with
			|fml1, fml2, BinopApp (Binop "∧", conj1, conj2), 0 -> (
				match (conj1 = fml1 && conj2 = fml2) || (conj1 = fml2 && conj2 = fml1) with
				|true -> (
					match
					validate options rule_count 0 dischargeable (prf::acc) prf1,
					validate options rule_count 0 dischargeable (prf::acc) prf2
					with
					|Some valid_prf1, Some valid_prf2 -> 
						Some (Binary_prf (valid_prf1, valid_prf2, Binary_rule "∧I", fml))
					|_, _ -> validate options rule_count (attempt+1) dischargeable acc prf
				)
				|false -> validate options rule_count (attempt+1) dischargeable acc prf
			)
			|BinopApp (Binop "→", ant1, cons1), fml2, _, 1 -> ( 
				match ant1 = fml2 && cons1 = fml with
				|true -> (
					match
					validate options rule_count 0 dischargeable (prf::acc) prf1,
					validate options rule_count 0 dischargeable (prf::acc) prf2
					with
					|Some valid_prf1, Some valid_prf2 -> 
						Some (Binary_prf (valid_prf1, valid_prf2, Binary_rule "→E", fml))
					|_, _ -> validate options rule_count (attempt+1) dischargeable acc prf
				)
				|false -> validate options rule_count (attempt+1) dischargeable acc prf
			)
			|fml1, BinopApp (Binop "→", ant2, cons2), _, 2 -> ( 
				match ant2 = fml1 && cons2 = fml with
				|true -> (
					match
					validate options rule_count 0 dischargeable (prf::acc) prf1,
					validate options rule_count 0 dischargeable (prf::acc) prf2
					with
					|Some valid_prf1, Some valid_prf2 -> 
						Some (Binary_prf (valid_prf1, valid_prf2, Binary_rule "→E", fml))
					|_, _ -> validate options rule_count (attempt+1) dischargeable acc prf
				)
				|false -> validate options rule_count (attempt+1) dischargeable acc prf
			)
			|fml1, fml2, UnopApp (Unop "¬", ass), 3 -> (
				match fml1 = UnopApp (Unop "¬",fml2) || fml2 = UnopApp (Unop "¬",fml1) with
				|true -> (
					let dischargeable_new (f : t_fml) : int option =
						if f = ass then Some rule_count else dischargeable f
					in
					match
					validate options (rule_count+1) 0 dischargeable_new (prf::acc) prf1,
					validate options (rule_count+1) 0 dischargeable_new (prf::acc) prf2
					with
					|Some valid_prf1, Some valid_prf2 -> 
						Some (Binary_prf (
							valid_prf1, valid_prf2, 
							Binary_rule ("¬I" ^ (string_of_int rule_count)), 
							fml
						))
					|_, _ -> validate options rule_count (attempt+1) dischargeable acc prf
				)
				|false -> validate options rule_count (attempt+1) dischargeable acc prf
			)
			|fml1, fml2, _, 4 -> (
				match fml1 = UnopApp (Unop "¬",fml2) || fml2 = UnopApp (Unop "¬",fml1) with
				|true -> (
					let dischargeable_new (f : t_fml) : int option =
						if f = UnopApp (Unop "¬",fml) then Some rule_count else dischargeable f
					in
					match
					validate options (rule_count+1) 0 dischargeable_new (prf::acc) prf1,
					validate options (rule_count+1) 0 dischargeable_new (prf::acc) prf2
					with
					|Some valid_prf1, Some valid_prf2 -> 
						Some (Binary_prf (
							valid_prf1, valid_prf2, 
							Binary_rule ("¬E" ^ (string_of_int rule_count)), 
							fml
						))
					|_, _ -> validate options rule_count (attempt+1) dischargeable acc prf
				)
				|false -> validate options rule_count (attempt+1) dischargeable acc prf
			)
			|QuantApp (Quant "∃", var, sub_fml1), fml2, _, 5 -> (
				match fml = fml2 with
				|true -> (
					let dischargeable_new (f : t_fml) : int option =
						match is_instance_of_with f sub_fml1 var with
						|Some (FuncApp (Func c,[])) ->
							let const = FuncApp (Func c,[]) in
							if not (List.exists (occurs_in const) (fml2::(premises_of_prf [f] prf2)))
							then Some rule_count else dischargeable f
						|_ -> dischargeable f
					in
					match
					validate options (rule_count+1) 0 dischargeable (prf::acc) prf1,
					validate options (rule_count+1) 0 dischargeable_new (prf::acc) prf2
					with
					|Some valid_prf1, Some valid_prf2 -> 
						Some (Binary_prf (
							valid_prf1, valid_prf2,
							Binary_rule ("∃E" ^ (string_of_int rule_count)),
							fml
						))
					|_, _ -> validate options rule_count (attempt+1) dischargeable acc prf
				)
				|false -> validate options rule_count (attempt+1) dischargeable acc prf
			)
			|fml1, QuantApp (Quant "∃", var, sub_fml2), _, 6 -> (
				match fml = fml1 with
				|true -> (
					let dischargeable_new (f : t_fml) : int option =
						match is_instance_of_with f sub_fml2 var with
						|Some (FuncApp (Func c,[])) ->
							let const = FuncApp (Func c,[]) in
							if not (List.exists (occurs_in const) (fml1::(premises_of_prf [f] prf1)))
							then Some rule_count else dischargeable f
						|_ -> dischargeable f
					in
					match
					validate options (rule_count+1) 0 dischargeable_new (prf::acc) prf1,
					validate options (rule_count+1) 0 dischargeable (prf::acc) prf2
					with
					|Some valid_prf1, Some valid_prf2 -> 
						Some (Binary_prf (
							valid_prf1, valid_prf2, 
							Binary_rule ("∃E" ^ (string_of_int rule_count)),
							fml
						))
					|_, _ -> validate options rule_count (attempt+1) dischargeable acc prf
				)
				|false -> validate options rule_count (attempt+1) dischargeable acc prf
			)
			|PredApp (Pred "=", [term1;term2]), fml2, _, 7 -> (
				match subst_equiv term1 term2 fml2 fml with
				|true -> (
					match
					validate options rule_count 0 dischargeable (prf::acc) prf1,
					validate options rule_count 0 dischargeable (prf::acc) prf2
					with
					|Some valid_prf1, Some valid_prf2 -> 
						Some (Binary_prf (valid_prf1, valid_prf2, Binary_rule "=E", fml))
					|_, _ -> validate options rule_count (attempt+1) dischargeable acc prf
				)
				|false -> validate options rule_count (attempt+1) dischargeable acc prf
			)
			|fml1, PredApp (Pred "=", [term1;term2]), _, 8 -> (
				match subst_equiv term1 term2 fml1 fml with
				|true -> (
					match
					validate options rule_count 0 dischargeable (prf::acc) prf1,
					validate options rule_count 0 dischargeable (prf::acc) prf2
					with
					|Some valid_prf1, Some valid_prf2 -> 
						Some (Binary_prf (valid_prf1, valid_prf2, Binary_rule "=E", fml))
					|_, _ -> validate options rule_count (attempt+1) dischargeable acc prf
				)
				|false -> validate options rule_count (attempt+1) dischargeable acc prf
			)
			|BinopApp (Binop "→", ant1, cons1), BinopApp (Binop "→", ant2, cons2), BinopApp (Binop "↔", eqv1, eqv2), 9 -> (
				match ((ant1 = eqv1 && cons1 = eqv2) && (ant2 = eqv2 && cons2 = eqv1)) ||
					((ant2 = eqv1 && cons2 = eqv2) && (ant1 = eqv2 && cons1 = eqv1)) 
				with
				|true -> (
					match
					validate options rule_count 0 dischargeable (prf::acc) prf1,
					validate options rule_count 0 dischargeable (prf::acc) prf2
					with
					|Some valid_prf1, Some valid_prf2 -> 
						Some (Binary_prf (valid_prf1, valid_prf2, Binary_rule "↔I", fml))
					|_, _ -> validate options rule_count (attempt+1) dischargeable acc prf
				)
				|false -> validate options rule_count (attempt+1) dischargeable acc prf
			)
			|_, _, _, 10 ->
				let _ : unit = 
					if verbose options then
					IO.print_to_stderr (
					String.concat "" [
					"\nBAD NEWS: The following branch does not satisfy the conditions of any binary rule:\n\n";
					String.concat "\n\nwhich is part of\n\n" (List.map nd_string_of_prf (prf::acc));"\n";
					]
					) else ()
				in None
			|_, _, _, _ -> validate options rule_count (attempt+1) dischargeable acc prf
	)
	| Trinary_prf (prf1, prf2, prf3, _, fml) -> 
		match conclusion_of_prf prf1, conclusion_of_prf prf2, conclusion_of_prf prf3, fml, attempt with
		|BinopApp (Binop "∨", left, right), fml2, fml3, _, 0 -> (
			match fml = fml2 && fml = fml3 with
			|true -> (
				let dischargeable_left (f : t_fml) : int option =
					 if f = left then Some rule_count else dischargeable f
				in
				let dischargeable_right (f : t_fml) : int option =
					 if f = right then Some rule_count else dischargeable f
				in
				match 
				validate options (rule_count+1) 0 dischargeable (prf::acc) prf1, 
				validate options (rule_count+1) 0 dischargeable_left (prf::acc) prf2, 
				validate options (rule_count+1) 0 dischargeable_right (prf::acc) prf3
				with
				|Some valid_prf1, Some valid_prf2, Some valid_prf3 ->
					Some (Trinary_prf (
						valid_prf1, valid_prf2, valid_prf3, 
						Trinary_rule ("∨E" ^ (string_of_int rule_count)),
						fml
					))
				|_,_,_ -> validate options rule_count (attempt+1) dischargeable acc prf
			)
			|false -> validate options rule_count (attempt+1) dischargeable acc prf
		)
		|fml1, fml2, BinopApp (Binop "∨", left, right), _, 1 -> (
			match fml = fml1 && fml = fml2 with
			|true -> (
				let dischargeable_left (f : t_fml) : int option =
					 if f = left then Some rule_count else dischargeable f
				in
				let dischargeable_right (f : t_fml) : int option =
					 if f = right then Some rule_count else dischargeable f
				in
				match 
				validate options (rule_count+1) 0 dischargeable_left (prf::acc) prf1, 
				validate options (rule_count+1) 0 dischargeable_right (prf::acc) prf2, 
				validate options (rule_count+1) 0 dischargeable (prf::acc) prf3
				with
				|Some valid_prf1, Some valid_prf2, Some valid_prf3 ->
					Some (Trinary_prf (
						valid_prf1, valid_prf2, valid_prf3,
						Trinary_rule ("∨E" ^ (string_of_int rule_count)),
						fml
					))
				|_,_,_ -> validate options rule_count (attempt+1) dischargeable acc prf
			)
			|false -> validate options rule_count (attempt+1) dischargeable acc prf
		)
		|_, _, _, _, 2 ->
			let _ : unit = 
				if List.mem "verbose" options then
				IO.print_to_stderr (
				String.concat "" [
				"\nBAD NEWS: The following branch does not satisfy the conditions of any trinary rule:\n\n";
				String.concat "\n\nwhich is part of\n\n" (List.map nd_string_of_prf (prf::acc));"\n";
				]
				) else ()
			in None
		|_, _, _, _, _ -> validate options rule_count (attempt+1) dischargeable acc prf

let enumerate (lst : 'a list) : 'a list =
	let rec aux (lst: 'a list) (acc : 'a list) : 'a list =
		match lst with
		|[] -> acc
		|hd::tl -> 
			match List.mem hd acc with
			|true -> aux tl acc
			|false -> aux tl (hd::acc)
	in
	List.rev (aux lst [])


let dischargeable (fml : t_fml) : int option = None

let validate_prf (options : string list) (prf : t_prf) : t_prf option =
	match validate options 0 0 dischargeable [] prf with
	|Some valid_prf ->
		let premises : t_fml list = enumerate (premises_of_prf [] valid_prf) in
		let conclusion : t_fml = conclusion_of_prf valid_prf in
		let premises_string : string = String.concat ", " (List.map string_of_fml premises) in
		let conclusion_string : string = string_of_fml conclusion in
		let proves_string : string = String.concat " ⊢ " [premises_string; conclusion_string] in
		let proof_string : string = nd_string_of_prf valid_prf in
		let report : string = String.concat "" [
			"\n"; "Proof is VALID:"; "\n\n";
			proof_string;"\n\n";
			"PROVES: "; proves_string; ".\n";
		] 
		in
		let _ : unit = IO.print_to_stderr report in
		let _ : unit = IO.print_to_stdout proof_string in
		Some valid_prf
	|None ->
		let premises : t_fml list = enumerate (premises_of_prf [] prf) in
		let conclusion : t_fml = conclusion_of_prf prf in
		let premises_string : string = String.concat ", " (List.map string_of_fml premises) in
		let conclusion_string : string = string_of_fml conclusion in
		let proves_string : string = String.concat " ⊢ " [premises_string; conclusion_string] in
		let proof_string = nd_string_of_prf prf in
		let report : string = String.concat "" [
			"\n"; "Proof is NOT valid:";"\n\n";
			proof_string;"\n\n";
			"Does NOT prove: "; proves_string; ".\n";
		]
		in
		let _ : unit = IO.print_to_stderr report in
		None


let validate_file (options : string list) (path : string) : t_prf option =
	let prf = prf_of_file path in
	validate_prf options prf

let validate_stdin (options : string list) : t_prf option =
	let prf = prf_of_stdin () in
	validate_prf options prf

(** Decomposing *)


let decompose_prf (path : string) (prf : t_prf) : unit =
	let make_dir = String.concat " " ["mkdir -p";path] in
	let _ : int = Sys.command make_dir in
	match prf with
	|Atomic_prf _ 
	|Nullary_prf _ -> IO.print_to_file (nd_string_of_prf prf) (String.concat "" [path;"/";"proof.txt"])
	|Unary_prf (prf1, _, fml) ->
		let _ : unit = IO.print_to_file (nd_string_of_prf prf) (String.concat "" [path;"/proof.txt"]) in
		let path1 = String.concat "" [path;"/sub-only"] in
		let make_dir1 = String.concat " " ["mkdir -p";path1] in
		let _ : int = Sys.command make_dir1 in
		let _ : unit = IO.print_to_file (nd_string_of_prf prf1) (String.concat "" [path1;"/proof.txt"]) in
		()
	|Binary_prf (prf1, prf2, _, fml) ->
		let _ : unit = IO.print_to_file (nd_string_of_prf prf) (String.concat "" [path;"/proof.txt"]) in
		let path1 = String.concat "" [path;"/sub-left"] in
		let make_dir1 = String.concat " " ["mkdir -p";path1] in
		let _ : int = Sys.command make_dir1 in
		let _ : unit = IO.print_to_file (nd_string_of_prf prf1) (String.concat "" [path1;"/proof.txt"]) in
		let path2 = String.concat "" [path;"/sub-right"] in
		let make_dir2 = String.concat " " ["mkdir -p";path2] in
		let _ : int = Sys.command make_dir2 in
		let _ : unit = IO.print_to_file (nd_string_of_prf prf2) (String.concat "" [path2;"/proof.txt"]) in
		()
	|Trinary_prf (prf1, prf2, prf3, _, fml) ->
		let _ : unit = IO.print_to_file (nd_string_of_prf prf) (String.concat "" [path;"/proof.txt"]) in
		let path1 = String.concat "" [path;"sub-left"] in
		let make_dir1 = String.concat " " ["mkdir -p";path1] in
		let _ : int = Sys.command make_dir1 in
		let _ : unit = IO.print_to_file (nd_string_of_prf prf1) (String.concat "" [path1;"/proof.txt"]) in
		let path2 = String.concat "" [path;"sub-center"] in
		let make_dir2 = String.concat " " ["mkdir -p";path2] in
		let _ : int = Sys.command make_dir2 in
		let _ : unit = IO.print_to_file (nd_string_of_prf prf2) (String.concat "" [path2;"/proof.txt"]) in
		let path3 = String.concat "" [path;"/sub-right"] in
		let make_dir3 = String.concat " " ["mkdir -p";path3] in
		let _ : int = Sys.command make_dir3 in
		let _ : unit = IO.print_to_file (nd_string_of_prf prf3) (String.concat "" [path3;"/proof.txt"]) in
		()


let rec decompose_prf_rec (path : string) (prf : t_prf) : unit =
	let make_dir = String.concat " " ["mkdir -p";path] in
	let _ : int = Sys.command make_dir in
	match prf with
	|Atomic_prf _ 
	|Nullary_prf _ -> IO.print_to_file (nd_string_of_prf prf) (String.concat "" [path;"/proof.txt"])
	|Unary_prf (prf1, _, fml) ->
		let _ : unit = IO.print_to_file (nd_string_of_prf prf) (String.concat "" [path;"/proof.txt"]) in
		let path1 = String.concat "" [path;"/sub-only"] in
		let _ : unit = decompose_prf_rec path1 prf1 in ()
	|Binary_prf (prf1, prf2, _, fml) ->
		let _ : unit = IO.print_to_file (nd_string_of_prf prf) (String.concat "" [path;"/proof.txt"]) in
		let path1 = String.concat "" [path;"/sub-left"] in
		let _ : unit = decompose_prf_rec path1 prf1 in
		let path2 = String.concat "" [path;"/sub-right"] in
		let _ : unit = decompose_prf_rec path2 prf2 in ()
	|Trinary_prf (prf1, prf2, prf3, _, fml) ->
		let _ : unit = IO.print_to_file (nd_string_of_prf prf) (String.concat "" [path;"/proof.txt"]) in
		let path1 = String.concat "" [path;"/sub-left"] in
		let _ : unit = decompose_prf_rec path1 prf1 in
		let path2 = String.concat "" [path;"/sub-center"] in
		let _ : unit = decompose_prf_rec path2 prf2 in
		let path3 = String.concat "" [path;"/sub-right"] in
		let _ : unit = decompose_prf_rec path3 prf3 in ()

let recursively (options : string list) : bool =
	List.mem "--recursively" options || List.mem "-R" options

let dir_path_of_file_path (path : string) : string =
	match List.rev (String.split_on_char '/' path) with
	|hd::(x::tl) -> String.concat "/" (List.rev (x::tl))
	|_ -> "."

let file_name_of_path (path : string) : string =
	match List.rev (String.split_on_char '/' path) with
	|hd::tl -> hd
	|[] -> ""

let decompose_file (options : string list) (prf_path : string) : unit =
	let prf : t_prf = prf_of_file prf_path in
	let path : string =
		match options with
		|[] -> dir_path_of_file_path prf_path
		|hd::tl -> hd
	in
	if recursively options then decompose_prf_rec path prf else
	decompose_prf path prf


(** Composing *)


let rec compose_prf (path : string) : t_prf =
	let prf : t_prf = prf_of_file (path ^ "/proof.txt") in
	match prf with
	|Atomic_prf _ 
	|Nullary_prf _ -> prf
	|Unary_prf (_, rule, fml) ->
		let path1 = String.concat "" [path;"/sub-only/proof.txt"] in
		let prf1 : t_prf = prf_of_file path1 in
		Unary_prf (prf1, rule, fml)
	|Binary_prf (_, _, rule, fml) ->
		let path1 = String.concat "" [path;"/sub-left/proof.txt"] in
		let path2 = String.concat "" [path;"/sub-right/proof.txt"] in
		let prf1 : t_prf = prf_of_file path1 in
		let prf2 : t_prf = prf_of_file path2 in
		Binary_prf (prf1, prf2, rule, fml)
	|Trinary_prf (_, _, _, rule, fml) ->
		let path1 = String.concat "" [path;"/sub-left/proof.txt"] in
		let path2 = String.concat "" [path;"/sub-center/proof.txt"] in
		let path3 = String.concat "" [path;"/sub-right/proof.txt"] in
		let prf1 : t_prf = prf_of_file path1 in
		let prf2 : t_prf = prf_of_file path2 in
		let prf3 : t_prf = prf_of_file path3 in
		Trinary_prf (prf1, prf2, prf3, rule, fml)


let rec compose_prf_rec (path : string) : t_prf =
	let prf : t_prf = prf_of_file (path ^ "/proof.txt") in
	match prf with
	|Atomic_prf _ 
	|Nullary_prf _ -> prf
	|Unary_prf (prf1, rule, fml) ->
		let path1 = String.concat "" [path;"/sub-only"] in
		let new_prf1 : t_prf = 
			if Sys.is_directory path1 then compose_prf_rec path1 
			else prf1
		in
		Unary_prf (new_prf1, rule, fml)
	|Binary_prf (prf1, prf2, rule, fml) ->
		let path1 = String.concat "" [path;"/sub-left"] in
		let path2 = String.concat "" [path;"/sub-right"] in
		let new_prf1 : t_prf = 
			if Sys.is_directory path1 then compose_prf_rec path1 
			else prf1
		in
		let new_prf2 : t_prf = 
			if Sys.is_directory path2 then compose_prf_rec path2 
			else prf2
		in
		Binary_prf (new_prf1, new_prf2, rule, fml)
	|Trinary_prf (prf1, prf2, prf3, rule, fml) ->
		let path1 = String.concat "" [path;"/sub-left"] in
		let path2 = String.concat "" [path;"/sub-center"] in
		let path3 = String.concat "" [path;"/sub-right"] in
		let new_prf1 : t_prf = 
			if Sys.is_directory path1 then compose_prf_rec path1 
			else prf1
		in
		let new_prf2 : t_prf = 
			if Sys.is_directory path2 then compose_prf_rec path2 
			else prf2
		in
		let new_prf3 : t_prf = 
			if Sys.is_directory path3 then compose_prf_rec path3 
			else prf3
		in
		Trinary_prf (new_prf1, new_prf2, new_prf3, rule, fml)

let compose_dir (options : string list) (path : string) : unit =
	let func : string -> t_prf =
		match recursively options with
		|true -> compose_prf_rec
		|false -> compose_prf
	in
	let prf : t_prf = func path in
	let prf_string = nd_string_of_prf prf in
	let _ : unit =IO.print_to_stdout prf_string in
	IO.print_to_file prf_string (String.concat "" [path;"/proof.txt"])

(** Editing *)


let sub_prf_only_of_prf (prf : t_prf) : t_prf =
	match prf with
	|Unary_prf (sub_prf, _, _) -> sub_prf
	|_ -> raise (Error "no such sub-proof")

let sub_prf_left_of_prf (prf : t_prf) : t_prf =
	match prf with
	|Binary_prf (sub_prf, _, _, _)
	|Trinary_prf (sub_prf, _, _, _, _) -> sub_prf
	|_ -> raise (Error "no such sub-proof")

let sub_prf_right_of_prf (prf : t_prf) : t_prf =
	match prf with
	|Binary_prf (_, sub_prf, _, _)
	|Trinary_prf (_, _, sub_prf, _, _) -> sub_prf
	|_ -> raise (Error "no such sub-proof")

let sub_prf_center_of_prf (prf : t_prf) : t_prf =
	match prf with
	|Trinary_prf (_, sub_prf, _, _, _) -> sub_prf
	|_ -> raise (Error "no such sub-proof")

let rec sub (options : string list) (prf : t_prf) : t_prf =
	match options with
	|[] -> prf
	|hd::tl -> 
		let sub_prf : t_prf =
			match hd with
			|"--sub-only" | "-o" -> sub_prf_only_of_prf prf
			|"--sub-left" | "-l" -> sub_prf_left_of_prf prf
			|"--sub-right" | "-r" -> sub_prf_right_of_prf prf
			|"--sub-center" | "-c" -> sub_prf_center_of_prf prf
			|s -> raise (Error ("invalid argument: \"" ^ s ^ "\""))
		in sub tl sub_prf


let sub_prf_of_file (options : string list) (path : string) : t_prf =
	let prf = sub options (prf_of_file path) in
	let _ : unit = IO.print_to_stdout (nd_string_of_prf prf) in
	prf

let sub_prf_of_stdin (options : string list) : t_prf =
	let prf = sub options (prf_of_stdin ()) in
	let _ : unit = IO.print_to_stdout (nd_string_of_prf prf) in
	prf



let rec subst_in_prf (replacement : t_prf) (options : string list) (prf : t_prf) : t_prf =
	match options with
	|[] -> replacement
	|hd :: tl -> 
		match prf with
		|Atomic_prf _ | Nullary_prf _ -> raise (Error ("invalid argument: \"" ^ hd ^ "\""))
		|Unary_prf (prf1, rule, fml) -> (
			match hd with
			|"--sub" | "-s" -> Unary_prf (subst_in_prf replacement tl prf1, rule, fml)
			| _ -> raise (Error ("invalid argument: \"" ^ hd ^ "\""))
		)
		|Binary_prf (prf1, prf2, rule, fml) -> (
			match hd with
			|"--left" | "-l" -> Binary_prf (subst_in_prf replacement tl prf1, prf2, rule, fml)
			|"--right" | "-r" -> Binary_prf (prf1, subst_in_prf replacement tl prf2, rule, fml)
			| _ -> raise (Error ("invalid argument: \"" ^ hd ^ "\""))
		)
		|Trinary_prf (prf1, prf2, prf3, rule, fml) -> (
			match hd with
			|"--left" | "-l" -> Trinary_prf (subst_in_prf replacement tl prf1, prf2, prf3, rule, fml)
			|"--right" | "-r" -> Trinary_prf (prf1, prf2, subst_in_prf replacement tl prf3, rule, fml)
			|"--center" | "-c" -> Trinary_prf (prf1, subst_in_prf replacement tl prf2, prf3, rule, fml)
			| _ -> raise (Error ("invalid argument: \"" ^ hd ^ "\""))
		)


let subst_in_file (replacement_path : string) (options : string list) (prf_path : string) : unit =
	let replacement = prf_of_file replacement_path in
	let prf = prf_of_file prf_path in
	let new_prf = subst_in_prf replacement options prf in
	let prf_string : string = nd_string_of_prf new_prf in
	let _ : unit = IO.print_to_stdout (prf_string) in
	IO.print_to_file prf_string prf_path


let edit_file (options : string list) (path : string): unit =
	let prf = prf_of_file path in
	let sub_prf = sub options prf in
	let temp_path = Filename.temp_file "" (String.concat "" ((file_name_of_path path)::options)) in
	let _ : unit = IO.print_to_file (nd_string_of_prf sub_prf) temp_path in
	let exit_code : int = Sys.command (String.concat " " ["nano";temp_path]) in
	let _ : unit = IO.print_to_stderr (string_of_int exit_code) in
	match exit_code with
	|0 ->
		let _ : unit = subst_in_file temp_path options path in
		let _ : int = Sys.command (String.concat " " ["rm";temp_path]) in
		()
	
	|_ ->
		let _ : int = Sys.command (String.concat " " ["rm";temp_path]) in
		()

