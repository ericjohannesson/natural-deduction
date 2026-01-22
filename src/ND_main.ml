open ND_types
open FML_types

exception Error of string

(** Parse *)

let string_of_token (t:ND_parser.token):string =
        match t with
        |ND_parser.EOF -> "EOF"
        |ND_parser.FML s -> String.concat "" ["FML";" ";"\'";s;"\'"]
        |ND_parser.SEP -> "SEP"
        |ND_parser.NULLARY_RULE s -> String.concat "" ["NULLARY_RULE";" ";"\'";s;"\'"]
        |ND_parser.UNARY_RULE s -> String.concat "" ["UNARY_RULE";" ";"\'";s;"\'"]
        |ND_parser.BINARY_RULE s -> String.concat "" ["BINARY_RULE";" ";"\'";s;"\'"]
        |ND_parser.TRINARY_RULE s -> String.concat "" ["TRINARY_RULE";" ";"\'";s;"\'"]

let lexer (print_tokens : bool) (b : Lexing.lexbuf) : ND_parser.token =
        let t : ND_parser.token = ND_lexer.token b in
        match print_tokens with
        |true -> let _ : unit = IO.print_to_stderr (string_of_token t) in t
        |false -> t

let rec prf_raw_of_string (trace : bool) (print_tokens : bool) (raw : string) : t_prf_raw =
        try
                let s : string = ND_sequencer.sequence_of_string trace raw in
                let lexbuf = Lexing.from_string s in
                let parser = ND_parser.main (lexer print_tokens) in
                parser lexbuf
        with
        |ND_parser.Error _ -> (
                match print_tokens with
                |false -> 
                        let _ = IO.print_to_stderr "ND_parser failed; read the following tokens:" in
                        prf_raw_of_string trace true raw
                |true -> raise (Error "ND_parser failed.")
        )
        |ND_sequencer.Error n -> (
                match trace with
                |false -> 
                        let _ = IO.print_to_stderr "ND_sequencer failed; went through the following states:" in
                        prf_raw_of_string true print_tokens raw
                |true -> raise (Error ("ND_sequencer failed in state " ^ (string_of_int n)))
        )
        |ND_sequencer.ERROR e -> raise (Error ("ND_sequencer failed: " ^ e))


let prf_raw_of_file (trace : bool) (print_tokens : bool) (path : string): t_prf_raw =
        match Sys.file_exists path with
        |false -> raise (Error ("cannot read from " ^ path ^ ": No such file"))
        |true -> 
                prf_raw_of_string trace print_tokens (IO.string_of_file path)

let prf_raw_of_stdin (trace : bool) (print_tokens : bool) : t_prf_raw =
        prf_raw_of_string trace print_tokens (IO.string_of_stdin ())


(** Print *)


let string_of_fml_raw (fml_raw : t_fml_raw) : string =
        match fml_raw with
        |Fml_raw s -> s

let string_of_nullary_rule (rule : t_nullary_rule) : string =
        match rule with
        |Nullary_rule s -> s

let string_of_unary_rule (rule : t_unary_rule) : string =
        match rule with
        |Unary_rule s -> s

let string_of_binary_rule (rule : t_binary_rule) : string =
        match rule with
        |Binary_rule s -> s

let string_of_trinary_rule (rule : t_trinary_rule) : string =
        match rule with
        |Trinary_rule s -> s

let length_of_string (s: string) : int =
        List.length (UTF8_decoder.string_list_of_string s)


let rec width_of_prf_raw (prf_raw : t_prf_raw) : int =
        match prf_raw with
        |Atomic_prf_raw fml_raw -> width_of_fml_raw fml_raw
        |Nullary_prf_raw (nullary_rule, fml_raw) ->
                (width_of_nullary_rule nullary_rule) + (width_of_fml_raw fml_raw)
        |Unary_prf_raw (prf_raw1, unary_rule, fml_raw) ->
                (Int.max (width_of_prf_raw prf_raw1) (width_of_fml_raw fml_raw)) + (width_of_unary_rule unary_rule) 
        |Binary_prf_raw (prf_raw1, prf_raw2, binary_rule, fml_raw) ->
                (Int.max ((width_of_prf_raw prf_raw1) + 4 + (width_of_prf_raw prf_raw2)) (width_of_fml_raw fml_raw)) + (width_of_binary_rule binary_rule) 
        |Trinary_prf_raw (prf_raw1, prf_raw2, prf_raw3, trinary_rule, fml_raw) ->
                (Int.max ((width_of_prf_raw prf_raw1) + 4 + (width_of_prf_raw prf_raw2) + 4 + (width_of_prf_raw prf_raw3)) (width_of_fml_raw fml_raw)) + (width_of_trinary_rule trinary_rule) 

and width_of_fml_raw (fml_raw : t_fml_raw) : int =
        length_of_string (string_of_fml_raw fml_raw)

and width_of_nullary_rule (rule : t_nullary_rule) : int =
        length_of_string (string_of_nullary_rule rule)

and width_of_unary_rule (rule : t_unary_rule) : int =
        length_of_string (string_of_unary_rule rule)

and width_of_binary_rule (rule : t_binary_rule) : int =
        length_of_string (string_of_binary_rule rule)

and width_of_trinary_rule (rule : t_trinary_rule) : int =
        length_of_string (string_of_trinary_rule rule)



let segments (center : int) (width : int) : int * int * int =
        let left : int = Int.div (width - center) 2 in
        let right : int = width - center - left in
        (left, center, right)

let conclusion_of_prf_raw (prf_raw : t_prf_raw) : t_fml_raw =
        match prf_raw with
        |Atomic_prf_raw f -> f
        |Nullary_prf_raw (_, f) -> f
        |Unary_prf_raw (_,_,f) -> f
        |Binary_prf_raw (_,_,_,f) -> f
        |Trinary_prf_raw (_,_,_,_,f) -> f


let rec lines_of_prf_raw (width : int) (prf_raw : t_prf_raw) (acc : string list) : string list =
        match prf_raw with
        |Atomic_prf_raw fml_raw -> (
                match segments (width_of_fml_raw fml_raw) width with
                |left, center, right -> 
                        let fml_line : string = String.concat "" [
                                String.make left ' ';
                                string_of_fml_raw fml_raw;
                                String.make right ' ';
                        ]
                        in
                        (fml_line :: acc)
        )
        |Nullary_prf_raw (nullary_rule, fml_raw) -> (
                let rule_width = width_of_nullary_rule nullary_rule in
                match segments (width_of_fml_raw fml_raw) (width - rule_width) with
                |left, center, right ->
                        let fml_line : string = String.concat "" [
                                String.make left ' ';
                                string_of_fml_raw fml_raw;
                                String.make (right + rule_width) ' ';
                        ] 
                        in
                        let overline : string = String.concat "" [
                                String.make (width - rule_width) '-'; 
                                string_of_nullary_rule nullary_rule;
                        ]
                        in
                        overline ::(fml_line::acc)
        )
        |Unary_prf_raw (prf_raw1, unary_rule, fml_raw) -> (
                let rule_width : int = (width_of_unary_rule unary_rule) in
                match segments (width_of_fml_raw fml_raw) (width - rule_width) with
                |(left, center, right) ->
                        let fml_line : string = String.concat "" [
                                String.make left ' ';
                                string_of_fml_raw fml_raw;
                                String.make (right + rule_width) ' ';
                        ] 
                        in
                        let overline : string = String.concat "" [
                                String.make (width - rule_width) '-'; 
                                string_of_unary_rule unary_rule;
                        ]
                        in
                        let lines1 = lines_of_prf_raw (width - rule_width) prf_raw1 [] in
                        let lines = merge width lines1 (width - rule_width) [] rule_width in
                        List.concat [lines;[overline;fml_line];acc]
        )
        |Binary_prf_raw (prf_raw1, prf_raw2, binary_rule, fml_raw) -> (
                let rule_width : int = (width_of_binary_rule binary_rule) in
                match segments (width_of_fml_raw fml_raw) (width - rule_width) with
                |(left, center, right) ->
                        let fml_line : string = String.concat "" [
                                String.make left ' ';
                                string_of_fml_raw fml_raw;
                                String.make (right + rule_width) ' ';
                        ] 
                        in
                        let overline : string = String.concat "" [
                                String.make (width - rule_width) '-'; 
                                string_of_binary_rule binary_rule;
                        ]
                        in 
                        let width1 = width_of_prf_raw prf_raw1 in
                        let width2 = width_of_prf_raw prf_raw2 in
                        let lines1 = lines_of_prf_raw width1 prf_raw1 [] in
                        let lines2 = lines_of_prf_raw width2 prf_raw2 [] in
                        let lines12 = merge (width - rule_width) lines1 width1 lines2 width2 in
                        let lines = merge width lines12 (width - rule_width) [] rule_width in
                        List.concat [lines;[overline;fml_line];acc]
        )
        |Trinary_prf_raw (prf_raw1, prf_raw2, prf_raw3, trinary_rule, fml_raw) -> (
                let rule_width : int = (width_of_trinary_rule trinary_rule) in
                match segments (width_of_fml_raw fml_raw) (width - rule_width) with
                |(left, center, right) ->
                        let fml_line : string = String.concat "" [
                                String.make left ' ';
                                string_of_fml_raw fml_raw;
                                String.make (right + rule_width) ' ';
                        ] 
                        in
                        let overline : string = String.concat "" [
                                String.make (width - rule_width) '-'; 
                                string_of_trinary_rule trinary_rule;
                        ]
                        in 
                        let width1 = width_of_prf_raw prf_raw1 in
                        let width2 = width_of_prf_raw prf_raw2 in
                        let width3 = width_of_prf_raw prf_raw3 in
                        let lines1 = lines_of_prf_raw width1 prf_raw1 [] in
                        let lines2 = lines_of_prf_raw width2 prf_raw2 [] in
                        let lines3 = lines_of_prf_raw width3 prf_raw3 [] in
                        let lines12 = merge (width - rule_width - width3 - 4) lines1 width1 lines2 width2 in
                        let lines123 = merge (width - rule_width) lines12 (width - rule_width - width3 - 4) lines3 width3  in
                        let lines = merge width lines123 (width - rule_width) [] rule_width in
                        List.concat [lines;[overline;fml_line];acc]
        )

and merge (width : int) (lines1 : string list) (width1 : int) (lines2 : string list) (width2 : int) : string list =
        let sep : string = String.make (width - width1 - width2) ' ' in
        let rec aux (lst1 : string list) (lst2 : string list) (acc : string list) : string list =
                match lst1, lst2 with
                |[],[] -> acc
                |hd1::tl1, hd2::tl2 -> aux tl1 tl2 ((String.concat sep [hd1;hd2])::acc)
                |hd1::tl1, [] -> aux tl1 [] ((String.concat sep [hd1;String.make width2 ' '])::acc)
                |[], hd2::tl2 -> aux [] tl2 ((String.concat sep [String.make width1 ' ';hd2])::acc)
        in aux (List.rev lines1) (List.rev lines2) []


let string_of_prf_raw (prf_raw : t_prf_raw) : string =
        let width : int = width_of_prf_raw prf_raw in
        let lines : string list = lines_of_prf_raw width prf_raw [] in
        String.concat "\n" lines

