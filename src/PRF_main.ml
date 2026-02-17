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

exception Error of string
exception Parse_error of string

(** Parse *)

let string_of_token (t : PRF_parser.token):string =
        match t with
        |PRF_parser.EOF -> "EOF"
        |PRF_parser.FML s -> String.concat "" ["FML";" ";"\'";s;"\'"]
        |PRF_parser.SEP -> "SEP"
        |PRF_parser.NULLARY_RULE s -> String.concat "" ["NULLARY_RULE";" ";"\'";s;"\'"]
        |PRF_parser.UNARY_RULE s -> String.concat "" ["UNARY_RULE";" ";"\'";s;"\'"]
        |PRF_parser.BINARY_RULE s -> String.concat "" ["BINARY_RULE";" ";"\'";s;"\'"]
        |PRF_parser.TRINARY_RULE s -> String.concat "" ["TRINARY_RULE";" ";"\'";s;"\'"]

let lexer (print_tokens : bool) (b : Lexing.lexbuf) : PRF_parser.token =
        let t : PRF_parser.token = PRF_lexer.token b in
        match print_tokens with
        |true -> let _ : unit = IO.print_to_stderr (string_of_token t) in t
        |false -> t

let rec prf_raw_of_prf_seq ?(print_tokens = false) (prf_seq : PRF_sequencer.t_prf_seq) : t_prf_raw =
        match prf_seq with
        |Prf_seq s ->
                let lexbuf = Lexing.from_string s in
                try PRF_parser.main (lexer print_tokens) lexbuf with
                |PRF_parser.Error _ ->
                        match print_tokens with
                        |false -> 
                                let _ = IO.print_to_stderr_red "PRF_parser failed; read the following tokens:" in
                                prf_raw_of_prf_seq ~print_tokens:true prf_seq
                        |true -> raise (Parse_error s)


let rec prf_raw_of_string ?(print_trace = false) ?(print_tokens = false) (s : string) : t_prf_raw =
        try
                let prf_seq : PRF_sequencer.t_prf_seq = PRF_sequencer.prf_seq_of_string ~print_trace:print_trace s in
                prf_raw_of_prf_seq ~print_tokens:print_tokens prf_seq
        with
        |PRF_sequencer.Error "empty string" -> raise (Error "Empty file")
        |PRF_sequencer.Automaton_error (PRF_sequencer.State n) ->
                match print_trace with
                |false -> 
                        let _ = IO.print_to_stderr_red "PRF_sequencer failed; went through the following states:" in
                        prf_raw_of_string ~print_trace:true ~print_tokens:print_tokens s
                |true -> 
                        let _ : unit = IO.print_to_stderr_red ("PRF_sequencer failed in state " ^ (string_of_int n)) in
                        raise (Parse_error s)

let prf_raw_of_file ?(print_trace = false) ?(print_tokens = false) (path : string): t_prf_raw =
        match Sys.file_exists path with
        |false -> raise (Error ("Cannot read from " ^ path ^ ": No such file"))
        |true -> 
                try prf_raw_of_string ~print_trace:print_trace ~print_tokens:print_tokens (IO.string_of_file path) with
                |Parse_error s -> raise (Error ("Cannot parse file " ^ path))

let prf_raw_of_stdin ?(print_trace = false) ?(print_tokens = false) () : t_prf_raw =
        prf_raw_of_string ~print_trace:print_trace ~print_tokens:print_tokens (IO.string_of_stdin ())


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
        |Fml_raw (s : string) -> FML_main.fml_of_string s

let prf_of_file ?(print_trace = false) ?(print_tokens = false) (path:string) =
        try prf_of_prf_raw (prf_raw_of_file ~print_trace:print_trace ~print_tokens:print_tokens path) with
        |FML_main.Parse_error _ -> raise (Error ("Cannot parse formulas in file " ^ path))

let prf_of_string ?(print_trace = false) ?(print_tokens = false) (s : string) =
        try prf_of_prf_raw (prf_raw_of_string ~print_trace:print_trace ~print_tokens:print_tokens s) with
        |FML_main.Parse_error _ -> raise (Error ("Cannot parse formulas in string \'" ^ s ^ "\'"))

let prf_of_stdin ?(print_trace = false) ?(print_tokens = false) () =
        prf_of_prf_raw (prf_raw_of_stdin ~print_trace:print_trace ~print_tokens:print_tokens ())


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
        List.length (UTF8_segmenter.utf_8_grapheme_clusters s)


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

let string_of_fml (fml : t_fml) : string =
        FML_main.string_of_fml fml

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

let string_of_prf_raw (prf : t_prf_raw) : string =
        string_of_prf_raw prf


let string_of_prf (prf : t_prf) : string =
        string_of_prf_raw (prf_raw_of_prf prf)


(** Manipulate *)

let rec transform_prf (f : t_fml -> t_fml) (prf : t_prf) : t_prf =
        match prf with
        |Atomic_prf fml -> Atomic_prf (f fml)
        |Nullary_prf (rule, fml) -> Nullary_prf (rule, f fml)
        |Unary_prf (prf1, rule, fml) -> Unary_prf (transform_prf f prf1, rule, f fml)
        |Binary_prf (prf1, prf2, rule, fml) -> Binary_prf (transform_prf f prf1, transform_prf f prf2, rule, f fml)
        |Trinary_prf (prf1, prf2, prf3, rule, fml) -> Trinary_prf (transform_prf f prf1, transform_prf f prf2, transform_prf f prf3, rule, f fml)


let rec subst_in_prf (f : t_prf -> t_prf) (prf : t_prf) : t_prf =
        match prf with
        |Atomic_prf _ -> f prf
        |Nullary_prf _ -> prf
        |Unary_prf (prf1, rule, fml) -> Unary_prf (subst_in_prf f prf1, rule, fml)
        |Binary_prf (prf1, prf2, rule, fml) -> Binary_prf (subst_in_prf f prf1, subst_in_prf f prf2, rule, fml)
        |Trinary_prf (prf1, prf2, prf3, rule, fml) -> Trinary_prf (subst_in_prf f prf1, subst_in_prf f prf2, subst_in_prf f prf3, rule, fml)


