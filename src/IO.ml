let string_of_file (path:string):string =
        let ic = open_in path in
        let s = In_channel.input_all ic in
        let _ = close_in ic in s

let string_of_stdin () : string =
        In_channel.input_all stdin


let print_to_file (s : string) (path : string) : unit =
        let oc = open_out path in
        let _ = output_string oc (s ^ "\n") in
        let _ = flush oc in
        let _ = close_out oc in ()

let print_to_stdout (s : string) : unit =
        print_endline s

let print_to_stderr (s:string):unit = 
        Printf.eprintf "%s\n" s

let print_to_stderr_red (s:string):unit = 
        Printf.eprintf "\027[31m%s\027[m\n" s

let print_to_stderr_green (s:string):unit = 
        Printf.eprintf "\027[32m%s\027[m\n" s

let print_to_stderr_yellow (s:string):unit = 
        Printf.eprintf "\027[33m%s\027[m\n" s

