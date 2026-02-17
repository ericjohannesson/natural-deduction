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

type t_prf_seq = Prf_seq of string

(** Utf8-segmentation *)

let matrix_of_string (s : string) : string array array =
        let rows : string list = String.split_on_char '\n' s in
        let utf8_rows : string list list = List.map UTF8_segmenter.utf_8_grapheme_clusters rows in
        let utf8_arrays : string array list = List.map Array.of_list utf8_rows in
        Array.init (List.length utf8_arrays) (List.nth utf8_arrays)

let matrix_of_file (path : string) : string array array =
        matrix_of_string (IO.string_of_file path)

(** Automaton *)

type t_state = State of int
type t_symbol = Space | Dash | Letter of string | Out
type t_action = Left | Right | Up | Down | Stay
type t_token = HSEP | RSEP of int | VSEP | FML_LETTER of string | RULE_LETTER of string
type t_stack = Stack of (int list)

type t_automaton = {
        transition : (t_state -> t_symbol -> t_stack -> t_action * t_state * t_token option * t_stack);
        end_state : t_state
}

exception Automaton_error of t_state
exception Error of string

let stack_hd (stack : t_stack) : int =
        match stack with
        |Stack [] -> raise (Error "empty stack")
        |Stack (hd::tl) -> hd

let stack_tl (stack : t_stack) : t_stack =
        match stack with
        |Stack [] -> raise (Error "empty stack")
        |Stack (hd::tl) -> Stack tl

let inc_stack_hd (stack : t_stack) : t_stack =
        match stack with
        |Stack (hd::tl) -> Stack ((hd+1)::tl)
        |Stack [] -> raise (Error "empty stack")

let push_to_stack (n : int) (stack : t_stack) : t_stack =
        match stack with
        |Stack int_list -> Stack (n::int_list)

let default_transition (state : t_state) (symbol : t_symbol) (stack: t_stack) : t_action * t_state * (t_token option) * t_stack =
        match state with
        |State 0 -> (
                match symbol with
                |Space -> Right, State 0, None, stack
                |Letter _ -> Up, State 10, None, stack
                |Dash -> Up, State 10, None, stack
                |Out -> Left, State 1, None, stack              (* end of row has been reached *)
        )
        |State 1 -> (
                match symbol with
                |Space -> Down, State 2, None, stack            (* find begining of row to the left *)
                |Letter _ -> raise (Automaton_error state)
                |Dash -> raise (Automaton_error state)
                |Out -> raise (Automaton_error state)
        )
        |State 2 -> (                                           (* find begining of row to the left *)
                match symbol with
                |Space -> Left, State 2, None, stack
                |Letter _ -> Left, State 2, None, stack
                |Dash -> Left, State 2, None, stack
                |Out -> Right, State 0, None, stack             (* begining of row has been found *)
        )
        |State 3 -> (                                           (* find begining of row to the right *)
                match symbol with
                |Space -> Right, State 0, None, stack                   (* beginning of row has been found *)
                |Letter _ -> Stay, State 0, None, stack                 (* beginning of row has been found *)
                |Dash -> Stay, State 0, None, stack
                |Out -> Right, State 3, None, stack                     (* continue *)
        )
        |State 10 -> (                                          (* roof? *)
                match symbol with
                |Space -> Down, State 30, None, stack                   (* no roof! *)
                |Letter _ -> raise (Automaton_error state)
                |Dash -> Stay, State 20, None, push_to_stack 0 stack                 (* find beginning of roof to the left *)
                |Out -> Down, State 30, None, stack                     (* no roof! *)
        )
        |State 20 -> (                                          (* find beginning of roof to the left *)
                match symbol with
                |Space -> Right, State 21, None, stack                  (* beginning of roof has been found; any premises on it? *)
                |Letter _ -> raise (Automaton_error state)
                |Dash -> Left, State 20, None, stack                    (* continue *)
                |Out -> Right, State 21, None, stack                    
        )
        |State 21 -> (                                          (* any premises on this roof? *)
                match symbol with
                |Space -> Left, State 50, Some (RSEP (stack_hd stack)), (stack_tl stack)          (* no premises *)
                |Letter _ -> Stay, State 61, Some (RSEP (stack_hd stack)), (stack_tl stack)       (* rule begins *)
                |Dash -> Up, State 22, None, stack                                              (* any premises? *)
                |Out -> Left, State 50, Some (RSEP (stack_hd stack)), (stack_tl stack)            (* no premises *)
        )
        |State 22 -> (                                  (* any premises? *)
                match symbol with
                |Space -> Right, State 23, None, stack
                |Letter _ -> Stay, State 0, None, inc_stack_hd stack
                |Dash -> raise (Automaton_error state)
                |Out -> Down, State 42, Some (RSEP (stack_hd stack)), (stack_tl stack)            (* find end of floor to the right *)
        )
        |State 23 -> (
                match symbol with
                |Space -> Down, State 21, None, stack
                |Letter _ -> Stay, State 0, None, inc_stack_hd stack
                |Dash -> raise (Automaton_error state)
                |Out -> Down, State 42, Some (RSEP (stack_hd stack)), (stack_tl stack)            (* find end of floor to the right *)
        )
        |State 30 -> (                                          (* read formula *)
                match symbol with
                |Space -> Right, State 301, None, stack                 (* formula continues? *)
                |Letter s -> Right, State 30, Some (FML_LETTER s), stack
                |Dash -> Right, State 30, Some (FML_LETTER "-"), stack
                |Out -> Left, State 40, None, stack                     (* no more premises *)
        )
        |State 301 -> (                                         (* formula continues? *)
                match symbol with
                |Space -> Down, State 31, None, stack                   (* more premises? *)
                |Letter _ -> Stay, State 30, Some (FML_LETTER " "), stack
                |Dash -> Stay, State 30, Some (FML_LETTER " "), stack   
                |Out -> Left, State 34, None, stack             
        )
        |State 31 -> (                                          (* more premises ? *)
                match symbol with
                |Space -> Left, State 50, Some (RSEP (stack_hd stack)), (stack_tl stack)                  (* find end of floor to the left *)
                |Letter _ -> Stay, State 62, Some (RSEP (stack_hd stack)), (stack_tl stack)               (* find beginning of rule to the left *)
                |Dash -> Right, State 32, None, stack                                                   (* more premises? *)
                |Out -> Left, State 35, None, stack                                                     (* is there a floor? *)
        )
        |State 32 -> (                                          (* more premises ?*)
                match symbol with
                |Space -> Left, State 60, Some (RSEP (stack_hd stack)), (stack_tl stack)                  (* end of floor has been found *)
                |Letter _ -> Stay, State 61, Some (RSEP (stack_hd stack)), (stack_tl stack)               (* rule begins *)
                |Dash -> Up, State 33, None, stack                                                      (* more premises? *)
                |Out -> Left, State 60, Some (RSEP (stack_hd stack)), (stack_tl stack)                    (* end of floor has been found *)
        )
        |State 33 -> (                                          (* more premises? *)
                match symbol with
                |Space -> Down, State 31, None, stack
                |Letter _ -> Stay, State 0, Some HSEP, inc_stack_hd stack    (* more premises! *)
                |Dash -> raise (Automaton_error state)
                |Out -> Left, State 34, None, stack                                            (* no more premises, go left to last letter*)
        )
        |State 34 -> (
                match symbol with
                |Space -> Left, State 34, None, stack                   (* continute *)
                |Letter _ -> Stay, State 40, None, stack
                |Dash -> Stay, State 40, None, stack
                |Out -> raise (Automaton_error state)
        )
        |State 35 -> (
                match symbol with
                |Space -> Left, State 36, None, stack
                |Letter _ -> Stay, State 62, Some (RSEP (stack_hd stack)), (stack_tl stack)      (* rule ends *)
                |Dash -> Stay, State 60, Some (RSEP (stack_hd stack)), (stack_tl stack)          (* floor has no rule *)
                |Out -> Left, State 36, None, stack                                            (* no floor! *)
        )
        |State 36 -> (
                match symbol with
                |Space -> Left, State 50, None, stack
                |Letter _ -> Stay, State 62, Some (RSEP (stack_hd stack)), (stack_tl stack)      (* rule ends *)
                |Dash -> Stay, State 60, Some (RSEP (stack_hd stack)), (stack_tl stack)          (* floor has no rule *)
                |Out -> Stay, State 100, None, stack                                           (* no floor! *)
        )
        |State 40 -> (                                          (* on the last letter *)
                match symbol with
                |Space -> raise (Automaton_error state)
                |Letter _ -> Down, State 41, None, stack        (* is there a floor? *)
                |Dash -> Down, State 41, None, stack
                |Out -> raise (Automaton_error state)
        )
        |State 41 -> (                                          (* is there a floor? *)
                match symbol with
                |Space -> Stay, State 100, None, stack
                |Letter _ -> raise (Automaton_error state)
                |Dash -> Right, State 42, Some (RSEP (stack_hd stack)), (stack_tl stack)          (* find end of floor to the right *)
                |Out -> Stay, State 100, None, stack
        )
        |State 42 -> (
                match symbol with
                |Space -> Left, State 60, None, stack
                |Letter s -> Stay, State 61, None, stack
                |Dash -> Right, State 42, None, stack           (* continue *)
                |Out -> Left, State 60, None, stack
        )
        |State 50 -> (                                          (* find end of of floor to the left*)
                match symbol with
                |Space -> Left, State 50, None, stack           (* contiunue *)
                |Letter _ -> Stay, State 62, None, stack        (* rule ends *)
                |Dash -> Stay, State 60, None, stack            (* floor has no rule *)
                |Out -> Stay, State 100, None, stack            (* no floor! *)
        )
        |State 60 -> (                                          (* end of floor-dashes have been found *)
                match symbol with
                |Space -> raise (Automaton_error state)
                |Letter _ -> raise (Automaton_error state)
                |Dash -> Right, State 61, None, stack           (* is there a rule? *)
                |Out -> raise (Automaton_error state)
        )
        |State 61 -> (                                          (* read rule *)
                match symbol with
                |Space -> Down, State 70, Some VSEP, stack
                |Letter s -> Right, State 61, Some (RULE_LETTER s), stack
                |Dash -> raise (Automaton_error state)
                |Out -> Down, State 70, Some VSEP, stack
        )
        |State 62 -> (                                          (* rule ends *)
                match symbol with
                |Space -> raise (Automaton_error state)
                |Letter _ -> Left, State 62, None, stack
                |Dash -> Right, State 61, None, stack
                |Out -> raise (Automaton_error state)
        )
        |State 70 -> (                                          (* find end of row to the left *)
                match symbol with
                |Space -> Stay, State 80, None, stack           (* end of row has been found, reading empty *)
                |Letter _ -> Stay, State 90, None, stack        (* end of row has been found, reading the last letter of a word *)
                |Dash -> raise (Automaton_error state)
                |Out -> Left, State 70, None, stack             (* continue *)
        )
        |State 80 -> (                                          (* find word to the left *)
                match symbol with
                |Space -> Left, State 80, None, stack
                |Letter _ -> Stay, State 90, None, stack
                |Dash -> raise (Automaton_error state)
                |Out -> raise (Automaton_error state)
        )
        |State 90 -> (                                          (* find beginning of formula to the left *)
                match symbol with
                |Space -> Left, State 91, None, stack           (* more formula? *)
                |Letter _ -> Left, State 90, None, stack
                |Dash -> Left, State 90, None, stack
                |Out -> Right, State 30, None, stack
        )
        |State 91 -> (                                          (* more formula? *)
                match symbol with
                |Space -> Right, State 92, None, stack          (* find beginning of formula to the right *)
                |Letter _ -> Left, State 90, None, stack
                |Dash -> Left, State 90, None, stack
                |Out -> Right, State 92, None, stack            (* find beginning of formula to the right *)
        )
        |State 92 -> (                                          (* find beginning of formula to the right *)
                match symbol with
                |Space -> Right, State 92, None, stack          (* continue *)
                |Letter _ -> Stay, State 30, None, stack
                |Dash -> Stay, State 30, None, stack
                |Out -> Right, State 92, None, stack            (* continue *)
        )
        |State n -> raise (Automaton_error state)

let default_automaton : t_automaton = {
        transition = default_transition;
        end_state = State 100;
}

let symbol_of_matrix (row : int) (col : int) (matrix : string array array) : t_symbol =
        try 
        match matrix.(row).(col) with
        |" " -> Space
        |"-" -> Dash
        |s -> Letter s
        with _ -> Out

let string_of_state (state : t_state) : string =
        match state with
        |State n -> "State " ^ (string_of_int n)

let string_of_token_opt (token_opt : t_token option) : string =
        match token_opt with
        |Some HSEP -> "HSEP"
        |Some (RSEP n) -> "RSEP" ^ (string_of_int n)
        |Some VSEP -> "VSEP"
        |Some (FML_LETTER s) -> String.concat "" ["FML_LETTER ";"\'";s;"\'"]
        |Some (RULE_LETTER r) -> String.concat "" ["RULE_LETTER ";"\'";r;"\'"]
        |None -> "None"

let string_of_token (token : t_token) : string =
        match token with
        |FML_LETTER s -> s
        |RULE_LETTER s -> s
        |HSEP -> ";"
        |RSEP n -> "#" ^ (string_of_int n)
        |VSEP -> ":"

let string_of_symbol (symbol : t_symbol) : string =
        match symbol with
        |Space -> "Space"
        |Dash -> "Dash"
        |Letter s -> String.concat "" ["Letter ";"\'";s;"\'"]
        |Out -> "Out"

let string_of_stack (stack : t_stack) : string =
        match stack with
        |Stack int_list -> String.concat ";" (List.map string_of_int int_list)

let trace (state : t_state) (row : int) (col : int) (symbol : t_symbol) (token_opt : t_token option) (stack: t_stack): unit =
        IO.print_to_stderr (String.concat " " [
                string_of_state state;
                "row"; string_of_int row;
                "col"; string_of_int col;
                string_of_symbol symbol;
                "->"; string_of_token_opt token_opt;
                string_of_stack stack;
        ])

let last_non_empty_row_of_matrix (matrix : string array array) : int option =
        let rec aux (i : int) : int option =
                try
                        match matrix.(i) with
                        |[||] -> aux (i-1)
                        |_ -> Some i
                with _ -> None
        in aux ((Array.length matrix) - 1)

(** Lexer *)

let rec lexer_of_matrix ?(print_trace = false) ?(automaton = default_automaton) (matrix : string array array) : t_token list =
        let rec aux (acc : t_token list) (state : t_state) (row : int) (col : int) (stack : t_stack) =
                if state = automaton.end_state then acc else
                let symbol = symbol_of_matrix row col matrix in
                match automaton.transition state symbol stack with
                |action, next_state, token_opt, next_stack -> 
                        let _ : unit = if print_trace then trace state row col symbol token_opt next_stack else () in 
                        let next_row, next_col =
                                match action with
                                |Up -> row-1, col
                                |Down -> row+1, col
                                |Left -> row, col-1
                                |Right -> row, col+1
                                |Stay -> row, col 
                        in
                        match token_opt with
                        |None -> aux acc next_state next_row next_col next_stack
                        |Some token -> aux (token::acc) next_state next_row next_col next_stack
        in
        match last_non_empty_row_of_matrix matrix with
        |None -> raise (Error "empty matrix")
        |Some i -> List.rev (aux [] (State 0) i 0 (Stack []))

let lexer_of_string ?(print_trace = false) (s : string) : t_token list =
        let matrix : string array array = matrix_of_string s in
        try lexer_of_matrix ~print_trace:print_trace matrix with
        |Error "empty matrix" -> raise (Error "empty string")

let lexer_of_file ?(print_trace = false) (path : string) : t_token list =
        try lexer_of_string ~print_trace:print_trace (IO.string_of_file path) with
        |Error "empty string" -> raise (Error "empty file")

let prf_seq_of_string ?(print_trace = false) (s : string) : t_prf_seq =
        Prf_seq (String.concat "" (List.map string_of_token (lexer_of_string ~print_trace:print_trace s)))

let prf_seq_of_file ?(print_trace = false) (path : string) : t_prf_seq =
        Prf_seq (String.concat "" (List.map string_of_token (lexer_of_file ~print_trace:print_trace path)))

