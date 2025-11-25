exception Error of int
exception ERROR of string

type t_state = State of int
type t_symbol = Space | Dash | Letter of string | Out
type t_action = Left | Right | Up | Down | Stay
type t_return = HSEP | RSEP of int | VSEP | FML_LETTER of string | RULE_LETTER of string

let transition (state : t_state) (symbol : t_symbol) (arity: int list) : (t_action * t_state * (t_return option) * (int list)) =
        match state with
        |State 0 -> (
                match symbol with
                |Space -> Right, State 0, None, arity
                |Letter _ -> Up, State 10, None, arity
                |Dash -> Up, State 10, None, arity
                |Out -> Left, State 1, None, arity              (* end of row has been reached *)
        )
        |State 1 -> (
                match symbol with
                |Space -> Down, State 2, None, arity                    (* find begining of row to the left *)
                |Letter _ -> raise (Error 1)
                |Dash -> raise (Error 1)
                |Out -> raise (Error 1)
        )
        |State 2 -> (                                           (* find begining of row to the left *)
                match symbol with
                |Space -> Left, State 2, None, arity
                |Letter _ -> Left, State 2, None, arity
                |Dash -> Left, State 2, None, arity
                |Out -> Right, State 0, None, arity                     (* begining of row has been found *)
        )
        |State 3 -> (                                           (* find begining of row to the right *)
                match symbol with
                |Space -> Right, State 0, None, arity                   (* beginning of row has been found *)
                |Letter _ -> Stay, State 0, None, arity         (* beginning of row has been found *)
                |Dash -> Stay, State 0, None, arity
                |Out -> Right, State 3, None, arity                     (* continue *)
        )
        |State 10 -> (                                          (* roof? *)
                match symbol with
                |Space -> Down, State 30, None, arity                   (* no roof! *)
                |Letter _ -> raise (Error 10)
                |Dash -> Stay, State 20, None, 0::arity                 (* find beginning of roof to the left *)
                |Out -> Down, State 30, None, arity                     (* no roof! *)
        )
        |State 20 -> (                                          (* find beginning of roof to the left *)
                match symbol with
                |Space -> Right, State 21, None, arity                  (* beginning of roof has been found; any premises on it? *)
                |Letter _ -> raise (Error 20)
                |Dash -> Left, State 20, None, arity                    (* continue *)
                |Out -> Right, State 21, None, arity                    
        )
        |State 21 -> (                                          (* any premises on this roof? *)
                match symbol with
                |Space -> Left, State 50, Some (RSEP (List.hd arity)), (List.tl arity)          (* no premises *)
                |Letter _ -> Stay, State 61, Some (RSEP (List.hd arity)), (List.tl arity)               (* rule begins *)
                |Dash -> Up, State 22, None, arity              (* any premises? *)
                |Out -> Left, State 50, Some (RSEP (List.hd arity)), (List.tl arity)            (* no premises *)
        )
        |State 22 -> (                                  (* any premises? *)
                match symbol with
                |Space -> Right, State 23, None, arity
                |Letter _ -> Stay, State 0, None, ((List.hd arity)+1)::(List.tl arity)
                |Dash -> raise (Error 22)
                |Out -> Down, State 42, Some (RSEP (List.hd arity)), (List.tl arity)            (* find end of floor to the right *)
        )
        |State 23 -> (
                match symbol with
                |Space -> Down, State 21, None, arity
                |Letter _ -> Stay, State 0, None, ((List.hd arity)+1)::(List.tl arity)
                |Dash -> raise (Error 23)
                |Out -> Down, State 42, Some (RSEP (List.hd arity)), (List.tl arity)            (* find end of floor to the right *)
        )
        |State 30 -> (                                          (* read formula *)
                match symbol with
                |Space -> Right, State 301, None, arity                 (* formula continues? *)
                |Letter s -> Right, State 30, Some (FML_LETTER s), arity
                |Dash -> Right, State 30, Some (FML_LETTER "-"), arity
                |Out -> Left, State 40, None, arity                     (* no more premises *)
        )
        |State 301 -> (                                         (* formula continues? *)
                match symbol with
                |Space -> Down, State 31, None, arity                   (* more premises? *)
                |Letter _ -> Stay, State 30, Some (FML_LETTER " "), arity
                |Dash -> Stay, State 30, Some (FML_LETTER " "), arity   
                |Out -> Left, State 34, None, arity             
        )
        |State 31 -> (                                          (* more premises ? *)
                match symbol with
                |Space -> Left, State 50, Some (RSEP (List.hd arity)), (List.tl arity)                  (* find end of floor to the left *)
                |Letter _ -> Stay, State 62, Some (RSEP (List.hd arity)), (List.tl arity)               (* find beginning of rule to the left *)
                |Dash -> Right, State 32, None, arity                   (* more premises? *)
                |Out -> Left, State 35, None, arity                     (* is there a floor? *)
        )
        |State 32 -> (                                          (* more premises ?*)
                match symbol with
                |Space -> Left, State 60, Some (RSEP (List.hd arity)), (List.tl arity)                  (* end of floor has been found *)
                |Letter _ -> Stay, State 61, Some (RSEP (List.hd arity)), (List.tl arity)               (* rule begins *)
                |Dash -> Up, State 33, None, arity                      (* more premises? *)
                |Out -> Left, State 60, Some (RSEP (List.hd arity)), (List.tl arity)                    (* end of floor has been found *)
        )
        |State 33 -> (                                          (* more premises? *)
                match symbol with
                |Space -> Down, State 31, None, arity
                |Letter _ -> Stay, State 0, Some HSEP, ((List.hd arity)+1)::(List.tl arity)             (* more premises! *)
                |Dash -> raise (Error 33)
                |Out -> Left, State 34, None, arity                     (* no more premises, go left to last letter*)
        )
        |State 34 -> (
                match symbol with
                |Space -> Left, State 34, None, arity                   (* continute *)
                |Letter _ -> Stay, State 40, None, arity
                |Dash -> Stay, State 40, None, arity
                |Out -> raise (Error 34)
        )
        |State 35 -> (
                match symbol with
                |Space -> Left, State 36, None, arity
                |Letter _ -> Stay, State 62, Some (RSEP (List.hd arity)), (List.tl arity)               (* rule ends *)
                |Dash -> Stay, State 60, Some (RSEP (List.hd arity)), (List.tl arity)                   (* floor has no rule *)
                |Out -> Left, State 36, None, arity                     (* no floor! *)
        )
        |State 36 -> (
                match symbol with
                |Space -> Left, State 50, None, arity
                |Letter _ -> Stay, State 62, Some (RSEP (List.hd arity)), (List.tl arity)               (* rule ends *)
                |Dash -> Stay, State 60, Some (RSEP (List.hd arity)), (List.tl arity)                   (* floor has no rule *)
                |Out -> Stay, State 100, None, arity                    (* no floor! *)
        )
        |State 40 -> (                                          (* on the last letter *)
                match symbol with
                |Space -> raise (Error 40)
                |Letter _ -> Down, State 41, None, arity                (* is there a floor? *)
                |Dash -> Down, State 41, None, arity
                |Out -> raise (Error 40)
        )
        |State 41 -> (                                          (* is there a floor? *)
                match symbol with
                |Space -> Stay, State 100, None, arity
                |Letter _ -> raise (Error 41)
                |Dash -> Right, State 42, Some (RSEP (List.hd arity)), (List.tl arity)          (* find end of floor to the right *)
                |Out -> Stay, State 100, None, arity
        )
        |State 42 -> (
                match symbol with
                |Space -> Left, State 60, None, arity
                |Letter s -> Stay, State 61, None, arity
                |Dash -> Right, State 42, None, arity                   (* continue *)
                |Out -> Left, State 60, None, arity
        )
        |State 50 -> (                                          (* find end of of floor to the left*)
                match symbol with
                |Space -> Left, State 50, None, arity                   (* contiunue *)
                |Letter _ -> Stay, State 62, None, arity                (* rule ends *)
                |Dash -> Stay, State 60, None, arity                    (* floor has no rule *)
                |Out -> Stay, State 100, None, arity                    (* no floor! *)
        )
        |State 60 -> (                                          (* end of floor-dashes have been found *)
                match symbol with
                |Space -> raise (Error 60)
                |Letter _ -> raise (Error 60)
                |Dash -> Right, State 61, None, arity                   (* is there a rule? *)
                |Out -> raise (Error 60)
        )
        |State 61 -> (                                          (* read rule *)
                match symbol with
                |Space -> Down, State 70, Some VSEP, arity
                |Letter s -> Right, State 61, Some (RULE_LETTER s), arity
                |Dash -> raise (Error 61)
                |Out -> Down, State 70, Some VSEP, arity
        )
        |State 62 -> (                                          (* rule ends *)
                match symbol with
                |Space -> raise (Error 62)
                |Letter _ -> Left, State 62, None, arity
                |Dash -> Right, State 61, None, arity
                |Out -> raise (Error 62)
        )
        |State 70 -> (                                          (* find end of row to the left *)
                match symbol with
                |Space -> Stay, State 80, None, arity                   (* end of row has been found, reading empty *)
                |Letter _ -> Stay, State 90, None, arity                (* end of row has been found, reading the last letter of a word *)
                |Dash -> raise (Error 70)
                |Out -> Left, State 70, None, arity                     (* continue *)
        )
        |State 80 -> (                                          (* find word to the left *)
                match symbol with
                |Space -> Left, State 80, None, arity
                |Letter _ -> Stay, State 90, None, arity
                |Dash -> raise (Error 80)
                |Out -> raise (Error 80)
        )
        |State 90 -> (                                          (* find beginning of formula to the left *)
                match symbol with
                |Space -> Left, State 91, None, arity           (* more formula? *)
                |Letter _ -> Left, State 90, None, arity
                |Dash -> Left, State 90, None, arity
                |Out -> Right, State 30, None, arity
        )
        |State 91 -> (                                          (* more formula? *)
                match symbol with
                |Space -> Right, State 92, None, arity          (* find beginning of formula to the right *)
                |Letter _ -> Left, State 90, None, arity
                |Dash -> Left, State 90, None, arity
                |Out -> Right, State 92, None, arity            (* find beginning of formula to the right *)
        )
        |State 92 -> (                                          (* find beginning of formula to the right *)
                match symbol with
                |Space -> Right, State 92, None, arity          (* continue *)
                |Letter _ -> Stay, State 30, None, arity
                |Dash -> Stay, State 30, None, arity
                |Out -> Right, State 92, None, arity            (* continue *)
        )
        |State 100 -> (
                match symbol with
                |Space -> Stay, State 100, None, arity
                |Letter _ -> Stay, State 100, None, arity
                |Dash -> Stay, State 100, None, arity
                |Out -> Stay, State 100, None, arity
        )
        |State n -> raise (ERROR (String.concat " " ["State"; string_of_int n; "does not exist."]))



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

let string_of_return_opt (return_opt : t_return option) : string =
        match return_opt with
        |Some HSEP -> "HSEP"
        |Some (RSEP arity) -> "RSEP" ^ (string_of_int arity)
        |Some VSEP -> "VSEP"
        |Some (FML_LETTER s) -> String.concat "" ["FML_LETTER ";"\"";s;"\""]
        |Some (RULE_LETTER r) -> String.concat "" ["RULE_LETTER ";"\"";r;"\""]
        |None -> "None"

let string_of_return (return : t_return) : string =
        match return with
        |FML_LETTER s -> s
        |RULE_LETTER s -> s
        |HSEP -> ";"
        |RSEP arity -> "#" ^ (string_of_int arity)
        |VSEP -> ":"

let string_of_symbol (symbol : t_symbol) : string =
        match symbol with
        |Space -> "Space"
        |Dash -> "Dash"
        |Letter s -> String.concat "" ["Letter ";"\"";s;"\""]
        |Out -> "Out"

let string_of_arity (arity : int list) : string =
        String.concat ";" (List.map string_of_int arity)

let print_trace (trace : bool) (state : t_state) (row : int) (col : int) (symbol : t_symbol) (return_opt : t_return option) (arity: int list): unit =
        match trace with 
        |true -> IO.print_to_stderr (String.concat " " [string_of_state state;"row";string_of_int row;"col";string_of_int col;string_of_symbol symbol;"->";string_of_return_opt return_opt;string_of_arity arity])
        |false -> ()

let matrix_of_string (s : string) : string array array =
        let rows : string list = String.split_on_char '\n' s in
        let utf8_rows : string list list = List.map UTF8_decoder.string_list_of_string rows in
        let utf8_arrays : string array list = List.map Array.of_list utf8_rows in
        Array.init (List.length utf8_arrays) (List.nth utf8_arrays)

let matrix_of_file (path : string) : string array array =
        matrix_of_string (IO.string_of_file path)

let last_non_empty_row_of_matrix (matrix : string array array) : int option =
        let rec aux (i : int) : int option =
                try
                        match matrix.(i) with
                        |[||] -> aux (i-1)
                        |_ -> Some i
                with _ -> None
        in aux ((Array.length matrix) - 1)

let rec lexer_of_matrix (trace : bool) (matrix : string array array) : string list =
        let rec aux (acc : string list) (state : t_state) (row : int) (col : int) (arity : int list) =
                if state = State 100 then acc else
                let symbol = symbol_of_matrix row col matrix in
                match transition state symbol arity with
                |action, next_state, return_opt, next_arity -> 
                        let _ : unit = print_trace trace state row col symbol return_opt next_arity in 
                        let next_row, next_col =
                                match action with
                                |Up -> row-1, col
                                |Down -> row+1, col
                                |Left -> row, col-1
                                |Right -> row, col+1
                                |Stay -> row, col 
                        in
                        match return_opt with
                        |None -> aux acc next_state next_row next_col next_arity
                        |Some return -> aux ((string_of_return return)::acc) next_state next_row next_col next_arity
        in
        match last_non_empty_row_of_matrix matrix with
        |None -> raise (ERROR "empty string")
        |Some i -> List.rev (aux [] (State 0) i 0 [])

let lexer_of_string (trace : bool) (s : string) : string list =
        let matrix : string array array = matrix_of_string s in
        lexer_of_matrix trace matrix

let lexer_of_file (trace : bool) (path : string) : string list =
        lexer_of_string trace (IO.string_of_file path)

let sequence_of_string (trace : bool) (s : string) : string =
        String.concat "" (lexer_of_string trace s)

let sequence_of_file (trace : bool) (path : string) : string =
        String.concat "" (lexer_of_file trace path)
