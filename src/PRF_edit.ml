open PRF_types
open FML_types

exception Error of string


type t_direction = Only | Left | Right | Center

let string_of_direction (direction : t_direction) : string =
	match direction with
	|Only -> "-o"
	|Left -> "-l"
	|Right -> "-r"
	|Center -> "-c"

let string_of_directions (directions : t_direction list) : string =
	String.concat "" (List.map string_of_direction directions)

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


(** Decompose *)


let decompose_prf (path : string) (prf : t_prf) : unit =
        let make_dir = String.concat " " ["mkdir -p";path] in
        let _ : int = Sys.command make_dir in
        match prf with
        |Atomic_prf _ 
        |Nullary_prf _ -> IO.print_to_file (string_of_prf prf) (String.concat "" [path;"/";"proof.txt"])
        |Unary_prf (prf1, _, fml) ->
                let _ : unit = IO.print_to_file (string_of_prf prf) (String.concat "" [path;"/proof.txt"]) in
                let path1 = String.concat "" [path;"/sub-only"] in
                let make_dir1 = String.concat " " ["mkdir -p";path1] in
                let _ : int = Sys.command make_dir1 in
                let _ : unit = IO.print_to_file (string_of_prf prf1) (String.concat "" [path1;"/proof.txt"]) in
                ()
        |Binary_prf (prf1, prf2, _, fml) ->
                let _ : unit = IO.print_to_file (string_of_prf prf) (String.concat "" [path;"/proof.txt"]) in
                let path1 = String.concat "" [path;"/sub-left"] in
                let make_dir1 = String.concat " " ["mkdir -p";path1] in
                let _ : int = Sys.command make_dir1 in
                let _ : unit = IO.print_to_file (string_of_prf prf1) (String.concat "" [path1;"/proof.txt"]) in
                let path2 = String.concat "" [path;"/sub-right"] in
                let make_dir2 = String.concat " " ["mkdir -p";path2] in
                let _ : int = Sys.command make_dir2 in
                let _ : unit = IO.print_to_file (string_of_prf prf2) (String.concat "" [path2;"/proof.txt"]) in
                ()
        |Trinary_prf (prf1, prf2, prf3, _, fml) ->
                let _ : unit = IO.print_to_file (string_of_prf prf) (String.concat "" [path;"/proof.txt"]) in
                let path1 = String.concat "" [path;"sub-left"] in
                let make_dir1 = String.concat " " ["mkdir -p";path1] in
                let _ : int = Sys.command make_dir1 in
                let _ : unit = IO.print_to_file (string_of_prf prf1) (String.concat "" [path1;"/proof.txt"]) in
                let path2 = String.concat "" [path;"sub-center"] in
                let make_dir2 = String.concat " " ["mkdir -p";path2] in
                let _ : int = Sys.command make_dir2 in
                let _ : unit = IO.print_to_file (string_of_prf prf2) (String.concat "" [path2;"/proof.txt"]) in
                let path3 = String.concat "" [path;"/sub-right"] in
                let make_dir3 = String.concat " " ["mkdir -p";path3] in
                let _ : int = Sys.command make_dir3 in
                let _ : unit = IO.print_to_file (string_of_prf prf3) (String.concat "" [path3;"/proof.txt"]) in
                ()


let rec decompose_prf_rec (path : string) (prf : t_prf) : unit =
        let make_dir = String.concat " " ["mkdir -p";path] in
        let _ : int = Sys.command make_dir in
        match prf with
        |Atomic_prf _ 
        |Nullary_prf _ -> IO.print_to_file (string_of_prf prf) (String.concat "" [path;"/proof.txt"])
        |Unary_prf (prf1, _, fml) ->
                let _ : unit = IO.print_to_file (string_of_prf prf) (String.concat "" [path;"/proof.txt"]) in
                let path1 = String.concat "" [path;"/sub-only"] in
                let _ : unit = decompose_prf_rec path1 prf1 in ()
        |Binary_prf (prf1, prf2, _, fml) ->
                let _ : unit = IO.print_to_file (string_of_prf prf) (String.concat "" [path;"/proof.txt"]) in
                let path1 = String.concat "" [path;"/sub-left"] in
                let _ : unit = decompose_prf_rec path1 prf1 in
                let path2 = String.concat "" [path;"/sub-right"] in
                let _ : unit = decompose_prf_rec path2 prf2 in ()
        |Trinary_prf (prf1, prf2, prf3, _, fml) ->
                let _ : unit = IO.print_to_file (string_of_prf prf) (String.concat "" [path;"/proof.txt"]) in
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

let decompose_file (options : string list) (dir_path: string) (prf_path : string) : unit =
        let prf : t_prf = prf_of_file prf_path in
        if recursively options then decompose_prf_rec dir_path prf else
        decompose_prf dir_path prf

(** Decompose raw *)


let decompose_prf_raw (path : string) (prf : t_prf_raw) : unit =
        let make_dir = String.concat " " ["mkdir -p";path] in
        let _ : int = Sys.command make_dir in
        match prf with
        |Atomic_prf_raw _ 
        |Nullary_prf_raw _ -> IO.print_to_file (string_of_prf_raw prf) (String.concat "" [path;"/";"proof.txt"])
        |Unary_prf_raw (prf1, _, fml) ->
                let _ : unit = IO.print_to_file (string_of_prf_raw prf) (String.concat "" [path;"/proof.txt"]) in
                let path1 = String.concat "" [path;"/sub-only"] in
                let make_dir1 = String.concat " " ["mkdir -p";path1] in
                let _ : int = Sys.command make_dir1 in
                let _ : unit = IO.print_to_file (string_of_prf_raw prf1) (String.concat "" [path1;"/proof.txt"]) in
                ()
        |Binary_prf_raw (prf1, prf2, _, fml) ->
                let _ : unit = IO.print_to_file (string_of_prf_raw prf) (String.concat "" [path;"/proof.txt"]) in
                let path1 = String.concat "" [path;"/sub-left"] in
                let make_dir1 = String.concat " " ["mkdir -p";path1] in
                let _ : int = Sys.command make_dir1 in
                let _ : unit = IO.print_to_file (string_of_prf_raw prf1) (String.concat "" [path1;"/proof.txt"]) in
                let path2 = String.concat "" [path;"/sub-right"] in
                let make_dir2 = String.concat " " ["mkdir -p";path2] in
                let _ : int = Sys.command make_dir2 in
                let _ : unit = IO.print_to_file (string_of_prf_raw prf2) (String.concat "" [path2;"/proof.txt"]) in
                ()
        |Trinary_prf_raw (prf1, prf2, prf3, _, fml) ->
                let _ : unit = IO.print_to_file (string_of_prf_raw prf) (String.concat "" [path;"/proof.txt"]) in
                let path1 = String.concat "" [path;"sub-left"] in
                let make_dir1 = String.concat " " ["mkdir -p";path1] in
                let _ : int = Sys.command make_dir1 in
                let _ : unit = IO.print_to_file (string_of_prf_raw prf1) (String.concat "" [path1;"/proof.txt"]) in
                let path2 = String.concat "" [path;"sub-center"] in
                let make_dir2 = String.concat " " ["mkdir -p";path2] in
                let _ : int = Sys.command make_dir2 in
                let _ : unit = IO.print_to_file (string_of_prf_raw prf2) (String.concat "" [path2;"/proof.txt"]) in
                let path3 = String.concat "" [path;"/sub-right"] in
                let make_dir3 = String.concat " " ["mkdir -p";path3] in
                let _ : int = Sys.command make_dir3 in
                let _ : unit = IO.print_to_file (string_of_prf_raw prf3) (String.concat "" [path3;"/proof.txt"]) in
                ()


let rec decompose_prf_raw_rec (path : string) (prf : t_prf_raw) : unit =
        let make_dir = String.concat " " ["mkdir -p";path] in
        let _ : int = Sys.command make_dir in
        match prf with
        |Atomic_prf_raw _ 
        |Nullary_prf_raw _ -> IO.print_to_file (string_of_prf_raw prf) (String.concat "" [path;"/proof.txt"])
        |Unary_prf_raw (prf1, _, fml) ->
                let _ : unit = IO.print_to_file (string_of_prf_raw prf) (String.concat "" [path;"/proof.txt"]) in
                let path1 = String.concat "" [path;"/sub-only"] in
                let _ : unit = decompose_prf_raw_rec path1 prf1 in ()
        |Binary_prf_raw (prf1, prf2, _, fml) ->
                let _ : unit = IO.print_to_file (string_of_prf_raw prf) (String.concat "" [path;"/proof.txt"]) in
                let path1 = String.concat "" [path;"/sub-left"] in
                let _ : unit = decompose_prf_raw_rec path1 prf1 in
                let path2 = String.concat "" [path;"/sub-right"] in
                let _ : unit = decompose_prf_raw_rec path2 prf2 in ()
        |Trinary_prf_raw (prf1, prf2, prf3, _, fml) ->
                let _ : unit = IO.print_to_file (string_of_prf_raw prf) (String.concat "" [path;"/proof.txt"]) in
                let path1 = String.concat "" [path;"/sub-left"] in
                let _ : unit = decompose_prf_raw_rec path1 prf1 in
                let path2 = String.concat "" [path;"/sub-center"] in
                let _ : unit = decompose_prf_raw_rec path2 prf2 in
                let path3 = String.concat "" [path;"/sub-right"] in
                let _ : unit = decompose_prf_raw_rec path3 prf3 in ()


let decompose_file_raw (options : string list) (dir_path: string) (prf_path : string) : unit =
        let prf : t_prf_raw = prf_raw_of_file prf_path in
        if recursively options then decompose_prf_raw_rec dir_path prf else
        decompose_prf_raw dir_path prf


(** Compose *)


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

let compose_dir (options : string list) (path : string) : t_prf =
        let func : string -> t_prf =
                match recursively options with
                |true -> compose_prf_rec
                |false -> compose_prf
        in
        let prf : t_prf = func path in
        let prf_string = string_of_prf prf in
        let _ : unit =IO.print_to_stdout prf_string in
        let _ : unit = IO.print_to_file prf_string (String.concat "" [path;"/proof.txt"]) in
        prf

(** Compose raw *)


let rec compose_prf_raw (path : string) : t_prf_raw =
        let prf : t_prf_raw = prf_raw_of_file (path ^ "/proof.txt") in
        match prf with
        |Atomic_prf_raw _ 
        |Nullary_prf_raw _ -> prf
        |Unary_prf_raw (_, rule, fml) ->
                let path1 = String.concat "" [path;"/sub-only/proof.txt"] in
                let prf1 : t_prf_raw = prf_raw_of_file path1 in
                Unary_prf_raw (prf1, rule, fml)
        |Binary_prf_raw (_, _, rule, fml) ->
                let path1 = String.concat "" [path;"/sub-left/proof.txt"] in
                let path2 = String.concat "" [path;"/sub-right/proof.txt"] in
                let prf1 : t_prf_raw = prf_raw_of_file path1 in
                let prf2 : t_prf_raw = prf_raw_of_file path2 in
                Binary_prf_raw (prf1, prf2, rule, fml)
        |Trinary_prf_raw (_, _, _, rule, fml) ->
                let path1 = String.concat "" [path;"/sub-left/proof.txt"] in
                let path2 = String.concat "" [path;"/sub-center/proof.txt"] in
                let path3 = String.concat "" [path;"/sub-right/proof.txt"] in
                let prf1 : t_prf_raw = prf_raw_of_file path1 in
                let prf2 : t_prf_raw = prf_raw_of_file path2 in
                let prf3 : t_prf_raw = prf_raw_of_file path3 in
                Trinary_prf_raw (prf1, prf2, prf3, rule, fml)


let rec compose_prf_raw_rec (path : string) : t_prf_raw =
        let prf : t_prf_raw = prf_raw_of_file (path ^ "/proof.txt") in
        match prf with
        |Atomic_prf_raw _ 
        |Nullary_prf_raw _ -> prf
        |Unary_prf_raw (prf1, rule, fml) ->
                let path1 = String.concat "" [path;"/sub-only"] in
                let new_prf1 : t_prf_raw = 
                        if Sys.is_directory path1 then compose_prf_raw_rec path1 
                        else prf1
                in
                Unary_prf_raw (new_prf1, rule, fml)
        |Binary_prf_raw (prf1, prf2, rule, fml) ->
                let path1 = String.concat "" [path;"/sub-left"] in
                let path2 = String.concat "" [path;"/sub-right"] in
                let new_prf1 : t_prf_raw = 
                        if Sys.is_directory path1 then compose_prf_raw_rec path1 
                        else prf1
                in
                let new_prf2 : t_prf_raw = 
                        if Sys.is_directory path2 then compose_prf_raw_rec path2 
                        else prf2
                in
                Binary_prf_raw (new_prf1, new_prf2, rule, fml)
        |Trinary_prf_raw (prf1, prf2, prf3, rule, fml) ->
                let path1 = String.concat "" [path;"/sub-left"] in
                let path2 = String.concat "" [path;"/sub-center"] in
                let path3 = String.concat "" [path;"/sub-right"] in
                let new_prf1 : t_prf_raw = 
                        if Sys.is_directory path1 then compose_prf_raw_rec path1 
                        else prf1
                in
                let new_prf2 : t_prf_raw = 
                        if Sys.is_directory path2 then compose_prf_raw_rec path2 
                        else prf2
                in
                let new_prf3 : t_prf_raw = 
                        if Sys.is_directory path3 then compose_prf_raw_rec path3 
                        else prf3
                in
                Trinary_prf_raw (new_prf1, new_prf2, new_prf3, rule, fml)

let compose_dir_raw (options : string list) (path : string) : t_prf_raw =
        let func : string -> t_prf_raw =
                match recursively options with
                |true -> compose_prf_raw_rec
                |false -> compose_prf_raw
        in
        let prf : t_prf_raw = func path in
        let prf_string = string_of_prf_raw prf in
        let _ : unit =IO.print_to_stdout prf_string in
        let _ : unit = IO.print_to_file prf_string (String.concat "" [path;"/proof.txt"]) in
        prf

(** Show *)


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

let rec sub (directions : t_direction list) (prf : t_prf) : t_prf =
        match directions with
        |[] -> prf
        |hd::tl -> 
                let sub_prf : t_prf =
                        match hd with
                        |Only -> sub_prf_only_of_prf prf
                        |Left -> sub_prf_left_of_prf prf
                        |Right -> sub_prf_right_of_prf prf
                        |Center -> sub_prf_center_of_prf prf
                in sub tl sub_prf


let sub_prf_of_file (directions : t_direction list) (path : string) : t_prf =
        let prf = sub directions (prf_of_file path) in
        let _ : unit = IO.print_to_stdout (string_of_prf prf) in
        prf

let sub_prf_of_stdin (directions : t_direction list) : t_prf =
        let prf = sub directions (prf_of_stdin ()) in
        let _ : unit = IO.print_to_stdout (string_of_prf prf) in
        prf


(** Show raw *)

let sub_prf_only_of_prf_raw (prf : t_prf_raw) : t_prf_raw =
        match prf with
        |Unary_prf_raw (sub_prf, _, _) -> sub_prf
        |_ -> raise (Error "no such sub-proof")

let sub_prf_left_of_prf_raw (prf : t_prf_raw) : t_prf_raw =
        match prf with
        |Binary_prf_raw (sub_prf, _, _, _)
        |Trinary_prf_raw (sub_prf, _, _, _, _) -> sub_prf
        |_ -> raise (Error "no such sub-proof")

let sub_prf_right_of_prf_raw (prf : t_prf_raw) : t_prf_raw =
        match prf with
        |Binary_prf_raw (_, sub_prf, _, _)
        |Trinary_prf_raw (_, _, sub_prf, _, _) -> sub_prf
        |_ -> raise (Error "no such sub-proof")

let sub_prf_center_of_prf_raw (prf : t_prf_raw) : t_prf_raw =
        match prf with
        |Trinary_prf_raw (_, sub_prf, _, _, _) -> sub_prf
        |_ -> raise (Error "no such sub-proof")

let rec sub_raw (directions : t_direction list) (prf : t_prf_raw) : t_prf_raw =
        match directions with
        |[] -> prf
        |hd::tl -> 
                let sub_prf : t_prf_raw =
                        match hd with
                        |Only -> sub_prf_only_of_prf_raw prf
                        |Left -> sub_prf_left_of_prf_raw prf
                        |Right -> sub_prf_right_of_prf_raw prf
                        |Center -> sub_prf_center_of_prf_raw prf
                in sub_raw tl sub_prf


let sub_prf_raw_of_file (directions : t_direction list) (path : string) : t_prf_raw =
        let prf = sub_raw directions (prf_raw_of_file path) in
        let _ : unit = IO.print_to_stdout (string_of_prf_raw prf) in
        prf

let sub_prf_raw_of_stdin (directions : t_direction list) : t_prf_raw =
        let prf = sub_raw directions (prf_raw_of_stdin ()) in
        let _ : unit = IO.print_to_stdout (string_of_prf_raw prf) in
        prf


(** Edit *)


let rec replace_in_prf (directions : t_direction list) (prf : t_prf) (replacement : t_prf) : t_prf =
        match directions with
        |[] -> replacement
        |hd :: tl -> 
                match prf with
                |Atomic_prf _ | Nullary_prf _ -> raise (Invalid_argument "")
                |Unary_prf (prf1, rule, fml) -> (
                        match hd with
                        |Only -> Unary_prf (replace_in_prf tl prf1 replacement, rule, fml)
                        |_ -> raise (Invalid_argument "")
                )
                |Binary_prf (prf1, prf2, rule, fml) -> (
                        match hd with
                        |Left -> Binary_prf (replace_in_prf tl prf1 replacement, prf2, rule, fml)
                        |Right -> Binary_prf (prf1, replace_in_prf tl prf2 replacement, rule, fml)
                        |_ -> raise (Invalid_argument "")
                )
                |Trinary_prf (prf1, prf2, prf3, rule, fml) -> (
                        match hd with
                        |Left -> Trinary_prf (replace_in_prf tl prf1 replacement, prf2, prf3, rule, fml)
                        |Right -> Trinary_prf (prf1, prf2, replace_in_prf tl prf3 replacement, rule, fml)
                        |Center -> Trinary_prf (prf1, replace_in_prf tl prf2 replacement, prf3, rule, fml)
                        |_ -> raise (Invalid_argument "")
                )


let replace_in_file (directions : t_direction list) (prf_path : string) (replacement_path : string) : unit =
        let replacement = 
		match replacement_path with 
		|"-" -> prf_of_stdin ()
		|_ -> prf_of_file replacement_path
	in
        let prf = prf_of_file prf_path in
        let new_prf = replace_in_prf directions prf replacement in
        let prf_string : string = string_of_prf new_prf in
        let _ : unit = IO.print_to_stdout (prf_string) in
        IO.print_to_file prf_string prf_path


let edit_file (directions : t_direction list) (path : string): unit =
        let prf = prf_of_file path in
        let sub_prf = sub directions prf in
        let temp_path = Filename.temp_file "" (String.concat "" [file_name_of_path path;string_of_directions directions]) in
        let _ : unit = IO.print_to_file (string_of_prf sub_prf) temp_path in
        let exit_code : int = Sys.command (String.concat " " ["nano";temp_path]) in
        match exit_code with
        |0 ->
                let _ : unit = replace_in_file directions path temp_path in
                let _ : int = Sys.command (String.concat " " ["rm";temp_path]) in
                ()
        
        |_ ->
                let _ : int = Sys.command (String.concat " " ["rm";temp_path]) in
                ()

(** Edit raw *)

let rec replace_in_prf_raw (directions : t_direction list) (prf : t_prf_raw) (replacement : t_prf_raw) : t_prf_raw =
        match directions with
        |[] -> replacement
        |hd :: tl -> 
                match prf with
                |Atomic_prf_raw _ | Nullary_prf_raw _ -> raise (Invalid_argument "")
                |Unary_prf_raw (prf1, rule, fml) -> (
                        match hd with
                        |Only -> Unary_prf_raw (replace_in_prf_raw tl prf1 replacement, rule, fml)
                        |_ -> raise (Invalid_argument "")
                )
                |Binary_prf_raw (prf1, prf2, rule, fml) -> (
                        match hd with
                        |Left -> Binary_prf_raw (replace_in_prf_raw tl prf1 replacement, prf2, rule, fml)
                        |Right -> Binary_prf_raw (prf1, replace_in_prf_raw tl prf2 replacement, rule, fml)
                        |_ -> raise (Invalid_argument "")
                )
                |Trinary_prf_raw (prf1, prf2, prf3, rule, fml) -> (
                        match hd with
                        |Left -> Trinary_prf_raw (replace_in_prf_raw tl prf1 replacement, prf2, prf3, rule, fml)
                        |Right -> Trinary_prf_raw (prf1, prf2, replace_in_prf_raw tl prf3 replacement, rule, fml)
                        |Only -> Trinary_prf_raw (prf1, replace_in_prf_raw tl prf2 replacement, prf3, rule, fml)
                        |_ -> raise (Invalid_argument "")
                )


let replace_in_file_raw (directions : t_direction list) (prf_path : string) (replacement_path : string) : unit =
        let replacement = 
		match replacement_path with 
		|"-" -> prf_raw_of_stdin ()
		|_ -> prf_raw_of_file replacement_path
	in
        let prf = prf_raw_of_file prf_path in
        let new_prf = replace_in_prf_raw directions prf replacement in
        let prf_string : string = string_of_prf_raw new_prf in
        let _ : unit = IO.print_to_stdout (prf_string) in
        IO.print_to_file prf_string prf_path


let edit_file_raw (directions : t_direction list) (path : string): unit =
        let prf = prf_raw_of_file path in
        let sub_prf = sub_raw directions prf in
        let temp_path = Filename.temp_file "" (String.concat "" [file_name_of_path path; string_of_directions directions]) in
        let _ : unit = IO.print_to_file (string_of_prf_raw sub_prf) temp_path in
        let exit_code : int = Sys.command (String.concat " " ["nano";temp_path]) in
        match exit_code with
        |0 ->
                let _ : unit = replace_in_file_raw directions path temp_path in
                let _ : int = Sys.command (String.concat " " ["rm";temp_path]) in
                ()
        
        |_ ->
                let _ : int = Sys.command (String.concat " " ["rm";temp_path]) in
                ()



