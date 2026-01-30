open PRF_types
open FML_types
open ND_types

exception Error of string

type t_options = {
	verbose : bool;
	discharge : bool;
	undischarge: bool;
	print_proof : bool;
	print_report : bool;
}


(** Parse *)

let prf_raw_of_file (path : string) : t_prf_raw =
        PRF_main.prf_raw_of_file false false path

let prf_raw_of_string (s : string) : t_prf_raw =
        PRF_main.prf_raw_of_string false false s

let prf_raw_of_stdin () : t_prf_raw =
        PRF_main.prf_raw_of_stdin false false

let prf_of_file (path:string) =
        PRF_main.prf_of_file path

let prf_of_string (s : string) =
        PRF_main.prf_of_string s

let prf_of_stdin () =
        PRF_main.prf_of_stdin ()


let fml_list_of_file (path : string) =
        FML_main.fml_list_of_file false path

let fml_of_string (s : string) =
        FML_main.fml_of_string false s


(** Print *)

let string_of_fml (fml : t_fml) : string =
        FML_main.string_of_fml fml

let string_of_prf_raw (prf : t_prf_raw) : string =
        PRF_main.string_of_prf_raw prf

let string_of_prf (prf : t_prf) : string =
        PRF_main.string_of_prf prf


(** Validate *)

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
        FML_main.is_closed_term term1 && FML_main.is_closed_term term2 &&
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

let premises_of_prf (excluded : t_fml list) (prf : t_prf): t_fml list =
        let rec aux (prf : t_prf): t_fml list =
                match prf with
                |Atomic_prf fml -> if List.mem fml excluded then [] else [fml]
                |Nullary_prf (_, fml) -> []
                |Unary_prf (prf1,_,_) ->
                        aux prf1 
                |Binary_prf (prf1, prf2, _, _) ->
                        List.concat [aux prf1; aux prf2] 
                |Trinary_prf (prf1, prf2, prf3, _, _) ->
                        List.concat [aux prf1; aux prf2; aux prf3]
        in
        enumerate (aux prf)


let occurs_in (term : t_term) (fml : t_fml) : bool =
        List.mem term (FML_main.closed_terms_of_fml fml)


let rec validate (options: t_options) (rule_count : int) (attempt : int) (dischargeable: t_fml -> int option) (acc : t_prf list) (prf : t_prf) : t_prf option =
        match prf with
        | Atomic_prf fml -> (
                        match dischargeable fml with
                        |None -> Some prf
                        |Some i ->
                                let _ : unit =
                                        if options.verbose then
                                        IO.print_to_stderr_green (
                                        String.concat "" [
                                        "\nGOOD NEWS: Undischarged assumption ";
                                        "\'"; string_of_fml fml; "\'";
                                        " may be discharged on the following branch:\n\n";
                                        String.concat "\n\nwhich is part of\n\n" (List.map string_of_prf (prf::acc));"\n";
                                        ]
                                        ) else ()
                                in
                                if options.discharge then
                                        let _ : unit = 
                                                if options.verbose then
                                                IO.print_to_stderr "Discharging it.\n" 
                                                else ()
                                        in
                                        Some (Nullary_prf (Nullary_rule (string_of_int i), fml))
				else Some prf
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
                                        if options.verbose then
                                        IO.print_to_stderr_yellow (
                                        String.concat "" [
                                        "\nBAD NEWS: Discharged assumption ";
                                        "\'"; string_of_fml fml; "\'";
                                        " may not be discharged on the following branch:\n\n";
                                        String.concat "\n\nwhich is part of\n\n" (List.map string_of_prf (prf::acc));"\n";
                                        ]
                                        ) else ()
                                in
                                if options.undischarge then
                                        let _ : unit = 
                                                if options.verbose then
                                                IO.print_to_stderr_green "Undischarging it.\n" 
                                                else () 
                                        in
                                        Some (Atomic_prf fml)
				else None
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
                                match FML_main.is_instance_of_with fml1 sub_fml var with
                                |Some (FuncApp (Func c,[])) -> (
                                        let const : t_term = (FuncApp (Func c,[])) in
                                        match List.exists (occurs_in const) (premises_of_prf [] prf1) with
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
                                match FML_main.is_instance_of_with fml1 sub_fml var with
                                |Some _ -> (
                                        match validate options rule_count 0 dischargeable (prf::acc) prf1 with
                                        |Some valid_prf1 -> Some (Unary_prf (valid_prf1, Unary_rule "∃I", fml))
                                        |None -> validate options rule_count (attempt+1) dischargeable acc prf
                                )
                                |None -> validate options rule_count (attempt+1) dischargeable acc prf
                        )
                        |QuantApp (Quant "∀", var, sub_fml1), _, 5 -> (
                                match FML_main.is_instance_of_with fml sub_fml1 var with
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
                                        if options.verbose then
                                        IO.print_to_stderr_yellow (
                                        String.concat "" [
                                        "\nBAD NEWS: The following branch does not satisfy the conditions of any unary rule:\n\n";
                                        String.concat "\n\nwhich is part of\n\n" (List.map string_of_prf (prf::acc));"\n";
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
                                                match FML_main.is_instance_of_with f sub_fml1 var with
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
                                                match FML_main.is_instance_of_with f sub_fml2 var with
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
                                        if options.verbose then
                                        IO.print_to_stderr_yellow (
                                        String.concat "" [
                                        "\nBAD NEWS: The following branch does not satisfy the conditions of any binary rule:\n\n";
                                        String.concat "\n\nwhich is part of\n\n" (List.map string_of_prf (prf::acc));"\n";
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
                |BinopApp (Binop "∨", left, right), fml3, fml2, _, 1 -> (
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
                |fml2, BinopApp (Binop "∨", left, right), fml3, _, 2 -> (
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
                |fml3, BinopApp (Binop "∨", left, right), fml2, _, 3 -> (
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
                |fml2, fml3, BinopApp (Binop "∨", left, right), _, 4 -> (
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
                |fml3, fml2, BinopApp (Binop "∨", left, right), _, 5 -> (
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
                |_, _, _, _, 6 ->
                        let _ : unit = 
                                if options.verbose then
                                IO.print_to_stderr_yellow (
                                String.concat "" [
                                "\nBAD NEWS: The following branch does not satisfy the conditions of any trinary rule:\n\n";
                                String.concat "\n\nwhich is part of\n\n" (List.map string_of_prf (prf::acc));"\n";
                                ]
                                ) else ()
                        in None
                |_, _, _, _, _ -> validate options rule_count (attempt+1) dischargeable acc prf


let validate_prf (options : t_options) (prf : t_prf) : t_prf option =
	let dischargeable (fml : t_fml) : int option = None in
        match validate options 0 0 dischargeable [] prf with
        |Some valid_prf ->
                let premises : t_fml list = premises_of_prf [] valid_prf in
                let conclusion : t_fml = conclusion_of_prf valid_prf in
                let premises_string : string = String.concat ", " (List.map string_of_fml premises) in
                let conclusion_string : string = string_of_fml conclusion in
                let proves_string : string = String.concat " ⊢ " [premises_string; conclusion_string] in
                let proof_string : string = string_of_prf valid_prf in
                let report_string : string = String.concat "" [
                        "\n"; "Proof is VALID."; "\n\n";
                        "PROVES: "; proves_string; ".\n";
                ] 
                in
                let _ : unit = if options.print_report then IO.print_to_stderr report_string else () in
                let _ : unit = if options.print_proof then IO.print_to_stdout proof_string else () in
                Some valid_prf
        |None ->
                let premises : t_fml list = premises_of_prf [] prf in
                let conclusion : t_fml = conclusion_of_prf prf in
                let premises_string : string = String.concat ", " (List.map string_of_fml premises) in
                let conclusion_string : string = string_of_fml conclusion in
                let proves_string : string = String.concat " ⊢ " [premises_string; conclusion_string] in
                let proof_string = string_of_prf prf in
                let report_string : string = String.concat "" [
                        "\n"; "Proof is NOT valid:";"\n\n";
                        proof_string;"\n\n";
                        "Does NOT prove: "; proves_string; ".\n";
                ]
                in
                let _ : unit = if options.print_report then IO.print_to_stderr report_string else () in
                None


let validate_file (options : t_options) (path : string) : t_prf option =
        let prf = PRF_main.prf_of_file path in
        validate_prf options prf

let validate_stdin (options : t_options) : t_prf option =
        let prf = PRF_main.prf_of_stdin () in
        validate_prf options prf


(** Expand *)

let expand_file (path : string) : unit =
	let exp_items : t_item list = ND_main.expand_file_alt path in
	IO.print_to_stdout (ND_main.string_of_items exp_items)

let expand_and_validate_file (options : t_options) (path : string) : unit =
	let exp_items : t_item list = ND_main.expand_file_alt path in
	let map (item : t_item) : string =
		match item with
		|Prf prf -> (
			match validate_prf options prf with
			|Some valid_prf -> 
		                let premises : t_fml list = premises_of_prf [] valid_prf in
		                let conclusion : t_fml = conclusion_of_prf valid_prf in
		                let premises_string : string = String.concat ", " (List.map string_of_fml premises) in
		                let conclusion_string : string = string_of_fml conclusion in
		                let proves_string : string = String.concat " ⊢ " [premises_string; conclusion_string] in
		                let report_string : string = String.concat "" [
		                        "\n"; "# Proof is VALID."; "\n";
		                        "# PROVES: "; proves_string; ".\n";
		                ] 
		                in
				String.concat "\n" [ND_main.string_of_item (Prf valid_prf);report_string]
			|None -> 
		                let premises : t_fml list = premises_of_prf [] prf in
		                let conclusion : t_fml = conclusion_of_prf prf in
		                let premises_string : string = String.concat ", " (List.map string_of_fml premises) in
		                let conclusion_string : string = string_of_fml conclusion in
		                let proves_string : string = String.concat " ⊢ " [premises_string; conclusion_string] in
		                let report_string : string = String.concat "" [
		                        "\n"; "# Proof is NOT valid.";"\n";
		                        "# Does NOT prove: "; proves_string; ".\n";
		                ]
		                in
				String.concat "\n" [ND_main.string_of_item (Prf prf);report_string]
		)	
		|Def_prf (p, prf, line) -> (
			match validate_prf options prf with
			|Some valid_prf -> 
		                let premises : t_fml list = premises_of_prf [] valid_prf in
		                let conclusion : t_fml = conclusion_of_prf valid_prf in
		                let premises_string : string = String.concat ", " (List.map string_of_fml premises) in
		                let conclusion_string : string = string_of_fml conclusion in
		                let proves_string : string = String.concat " ⊢ " [premises_string; conclusion_string] in
		                let report_string : string = String.concat "" [
		                        "\n"; "# ";string_of_prf p;" is VALID."; "\n";
		                        "# PROVES: "; proves_string; ".\n";
		                ] 
		                in
				String.concat "\n" [ND_main.string_of_item (Def_prf (p,valid_prf, line));report_string]
			|None -> 
		                let premises : t_fml list = premises_of_prf [] prf in
		                let conclusion : t_fml = conclusion_of_prf prf in
		                let premises_string : string = String.concat ", " (List.map string_of_fml premises) in
		                let conclusion_string : string = string_of_fml conclusion in
		                let proves_string : string = String.concat " ⊢ " [premises_string; conclusion_string] in
		                let report_string : string = String.concat "" [
		                        "\n"; "# ";string_of_prf p;" is NOT valid.";"\n";
		                        "# Does NOT prove: "; proves_string; ".\n";
		                ]
		                in
				String.concat "\n" [ND_main.string_of_item (Def_prf (p, prf, line));report_string]
		)
		|Def_fml _ -> ND_main.string_of_item item
	in IO.print_to_stdout (String.concat "\n\n" (List.map map exp_items))


