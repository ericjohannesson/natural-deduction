exception Error of string

let basic_usage : string =
"BASIC USAGE:

  nd [ <options> ] <path-to-file>

        Expands proofs in file according to definitions in file and checks
        validity of each proof according to options.

        Prints a report to stdout."

let usage : string=
"USAGE:
  nd [ <options> ] <path-to-file>
  nd validate [ <options> ] { <path-to-file> | - }
  nd show [ <directions> ] { <path-to-file> | - }
  nd show-raw [ <directions> ] { <path-to-file> | - }
  nd edit [ <directions> ] <path-to-file>
  nd edit-raw [ <directions> ] <path-to-file>
  nd replace [ <directions> ] <path-to-file> { <path-to-file> | - }
  nd replace-raw [ <directions> ] <path-to-file> { <path-to-file> | - }
  nd decompose [ -R ] <path-to-directory> <path-to-file>
  nd decompose-raw [ -R ] <path-to-directory> <path-to-file>
  nd compose [ -R ] <path-to-directory>
  nd compose-raw [ -R ] <path-to-directory>
  nd help [ basic | validate | | show | edit | replace | decompose | compose |
            options | directions ]"

let headers : string=
"A basic proof assistant for natural deduction in classical first-order logic.

USAGE:

  nd <command>

  COMMANDS:"

let author_website : string =
"Author:  Eric Johannesson, eric@ericjohannesson.com
Website: https://github.com/ericjohannesson/natural-deduction"


let help_nd : string =
"    [ <options> ] <path-to-file>

        Expands proofs in file according to definitions in file and checks
        validity of each proof according to options.

        Prints a report to stdout."

let help_validate : string =
"    validate [ <options> ] { <path-to-file> | - }

        Prints an annotated and formatted version of proof contained in file
        to stdout, and a report to stderr, if proof is valid.

        Otherwise prints a report to stderr."


let help_show : string =
"    show [ <directions> ] { <path-to-file> | - }

        Prints a formatted version of proof contained in file to stdout, or
        sub-proof thereof specified by directions.

        Prints message to stderr if no sub-proof matches directions.

    show-raw [ <directions> ] { <path-to-file> | - }

        Same as show, except that formulas are not parsed."

let help_edit : string =
"    edit [ <directions> ] <path-to-file>

        Opens a formatted version of proof contained in file in nano, or
        sub-proof thereof specified by directions. Writes any changes to file,
        and prints the result to stdout.

    edit-raw [ <directions> ] <path-to-file>

        Same as edit, except that formulas are not parsed."

let help_replace : string =
"    replace [ <directions> ] <path-to-file> { <path-to-file> | - }

        Prints to stdout result of replacing proof contained in first file
        (or sub-proof thereof specified by directions) with proof contained
        in second file.

    replace-raw [ <directions> ] <path-to-file> { <path-to-file> | - }

        Same as replace, except that formulas are not parsed."

let help_decompose : string =
"    decompose [ -R ] <path-to-directory> <path-to-file>

        Parses proof contained in file and creates a directory for each
        immediate sub-proof containing a file called 'proof.txt'. Also prints
        main proof to a file called 'proof.txt', and puts everything in
        directory.

        Does it recursively for each sub-proof if '-R' is provided.

    decompose-raw [ -R ] <path-to-directory> <path-to-file>

        Same as decompose, except that formulas are not parsed."


let help_compose : string =
"    compose [ -R ] <path-to-directory>

        Assumes that a proof has been decomposed in directory, and composes a
        proof from its immediate sub-proofs. Prints the result to stdout and
        to the file called 'proof.txt' located in directory.

        Does it recursively for each sub-proof if '-R' is provided.

    compose-raw [ -R ] <path-to-directory>

        Same as compose, except that formulas are not parsed."

let help_help : string =
"    help [ basic | validate | show | edit | replace | decompose | compose |
           options | directions ]

        Prints manual to stdout, or part thereof specified by keyword."

let help_stdin : string =
"    Reads from stdin if '-' is provided instead of a path (and if it may be so
    provided)."

let help_options : string =
"  OPTIONS:

    --discharge, -d

        Checks a version of the proof where all dischargeable assumptions are
        discharged.

    --undischarge, -u

        Checks a version of the proof where all non-dischargeable assumptions
        are undischarged.

    --verbose, -v

        Prints information to stderr about discharged assumptions that may not
        be discharged, undischarged assumptions that may be discharged, and
        sub-proofs not satisfying the conditions of any inferential rule."

let help_directions : string =
"  DIRECTIONS:

    --sub-only, -o

        Matches the (only) sub-proof of a unary proof.

    --sub-left, -l

        Matches the left sub-proof of a binary or trinary proof.

    --sub-right, -r

        Matches the right sub-proof of a binary or trinary proof.

    --sub-center, -c

        Matches the center sub-proof of a trinary proof.

    A space-separated list of directions is interpreted from left to right,
    in such a way that 

        nd show <directions> <direction> <path-to-file>

    is equivalent to

        nd show <directions> <path-to-file> | nd show <direction> -"

let manual : string =
        String.concat "\n\n" [
                headers;
                help_nd;
                help_validate;
                help_show;
                help_edit;
                help_replace;
                help_decompose;
                help_compose;
                help_help;
                help_stdin;
                help_options;
                help_directions;
                author_website;
        ]

let help (keyword : string) : string =
        match keyword with
	|"basic" -> String.concat "\n\n" [basic_usage;help_options] 
        |"validate" -> help_validate
        |"show" -> help_show
        |"edit" -> help_edit
        |"replace" -> help_replace
        |"decompose" -> help_decompose
        |"compose" -> help_compose
        |"options" -> help_options
        |"directions" -> help_directions
        |"" -> manual
        |_ -> raise (Invalid_argument keyword)


let options_of_string (options : Main.t_options) (s : string) : Main.t_options =
	match s with
	|"--verbose" | "-v" -> {
		verbose = true;
		discharge = options.discharge;
		undischarge = options.undischarge;
		print_proof = options.print_proof;
		print_report = options.print_report;
	}
	|"--discharge" | "-d" -> {
		verbose = options.verbose;
		discharge = true;
		undischarge = options.undischarge;
		print_proof = options.print_proof;
		print_report = options.print_report;
	}
	|"--undischarge" | "-u" -> {
		verbose = options.verbose;
		discharge = options.discharge;
		undischarge = true;
		print_proof = options.print_proof;
		print_report = options.print_report;
	}
	|_ -> raise (Invalid_argument s)


let rec options_of_string_list (options : Main.t_options) (string_list : string list) : Main.t_options =
	match string_list with
	|[] -> options
	|hd::tl -> options_of_string_list (options_of_string options hd) tl

let direction_of_string (s : string) : PRF_edit.t_direction =
	match s with
	|"--sub-only" | "-o" -> PRF_edit.Only
	|"--sub-left" | "-l" -> PRF_edit.Left
	|"--sub-right" | "-r" -> PRF_edit.Right
	|"--sub-center" | "-c" -> PRF_edit.Center
	|_ -> raise (Invalid_argument s)

let arg_array : string array = Sys.argv
let arg_list : string list = Array.to_list arg_array


let _ : unit = 
        try
        match arg_list with
	|_::tl -> (
		match tl with
		|"help"::keywords -> (
			match keywords with
			|[] -> IO.print_to_stdout (help "")
			|[keyword] -> IO.print_to_stdout (help keyword)
			|_ -> raise (Invalid_argument (String.concat " " keywords))
		)
		|"validate"::option_list_path -> (
			let default_options : Main.t_options = {
				verbose = false;
				discharge = false;
				undischarge = false;
				print_proof = true;
				print_report = true;
			}
			in
			match List.rev option_list_path with
			|path::option_list -> (
				let options : Main.t_options =
					options_of_string_list default_options option_list
				in
				match path with
				|"-" -> let _ = Main.validate_stdin options in ()
				|_ -> let _ = Main.validate_file options path in ()
			)
			|_ -> raise (Invalid_argument (String.concat " " option_list_path))
		)
                |"show"::direction_list_path -> (
			match List.rev direction_list_path with
			|path::rev_direction_list -> (
				let directions : PRF_edit.t_direction list =
					List.rev (List.map direction_of_string rev_direction_list)
				in
				match path with
				|"-" -> let _ = PRF_edit.sub_prf_of_stdin directions in ()
                		|path -> let _ = PRF_edit.sub_prf_of_file directions path in ()
			)
			|_ -> raise (Invalid_argument (String.concat " " direction_list_path))
		)
                |"show-raw"::direction_list_path -> (
			match List.rev direction_list_path with
			|path::rev_direction_list -> (
				let directions : PRF_edit.t_direction list =
					List.rev (List.map direction_of_string rev_direction_list)
				in
				match path with
				|"-" -> let _ = PRF_edit.sub_prf_raw_of_stdin directions in ()
                		|path -> let _ = PRF_edit.sub_prf_raw_of_file directions path in ()
			)
			|_ -> raise (Invalid_argument (String.concat " " direction_list_path))
		)
                |"edit"::direction_list_path -> (
			match List.rev direction_list_path with
			|path::rev_direction_list -> (
				let directions : PRF_edit.t_direction list =
					List.rev (List.map direction_of_string rev_direction_list)
				in
                		let _ = PRF_edit.edit_file directions path in ()
			)
			|_ -> raise (Invalid_argument (String.concat " " direction_list_path))
		)
                |"edit-raw"::direction_list_path -> (
			match List.rev direction_list_path with
			|path::rev_direction_list -> (
				let directions : PRF_edit.t_direction list =
					List.rev (List.map direction_of_string rev_direction_list)
				in
                		let _ = PRF_edit.edit_file_raw directions path in ()
			)
			|_ -> raise (Invalid_argument (String.concat " " direction_list_path))
		)
                |"decompose"::recopt_dir_file -> (
			match recopt_dir_file with
			|"-R"::dir_file -> (
				match dir_file with
				|dir::[file] -> PRF_edit.decompose_file ["-R"] dir file 
				|_ -> raise (Invalid_argument (String.concat " " dir_file))
			)
			|dir_file -> (
				match dir_file with
				|dir::[file] -> PRF_edit.decompose_file [] dir file 
				|_ -> raise (Invalid_argument (String.concat " " dir_file))
			)
		)
                |"decompose-raw"::recopt_dir_file -> (
			match recopt_dir_file with
			|"-R"::dir_file -> (
				match dir_file with
				|dir::[file] -> PRF_edit.decompose_file_raw ["-R"] dir file 
				|_ -> raise (Invalid_argument (String.concat " " dir_file))
			)
			|dir_file -> (
				match dir_file with
				|dir::[file] -> PRF_edit.decompose_file_raw [] dir file 
				|_ -> raise (Invalid_argument (String.concat " " dir_file))
			)
		)
                |"compose"::recopt_dir -> (
			match recopt_dir with
			|"-R"::[dir] -> let _ = PRF_edit.compose_dir ["-R"] dir in ()
			|[dir] -> let _ = PRF_edit.compose_dir [] dir in ()
			|_ -> raise (Invalid_argument (String.concat " " recopt_dir))
		)
                |"compose-raw"::recopt_dir -> (
			match recopt_dir with
			|"-R"::[dir] -> let _ = PRF_edit.compose_dir_raw ["-R"] dir in ()
			|[dir] -> let _ = PRF_edit.compose_dir_raw [] dir in ()
			|_ -> raise (Invalid_argument (String.concat " " recopt_dir))
		)
                |"replace"::direction_list_path_path -> (
			match List.rev direction_list_path_path with
			|path2::(path1::rev_direction_list) ->
				let directions : PRF_edit.t_direction list =
					List.rev (List.map direction_of_string rev_direction_list)
				in
				PRF_edit.replace_in_file directions path1 path2
			|_ -> raise (Invalid_argument (String.concat " " direction_list_path_path))
		)
                |"replace-raw"::direction_list_path_path -> (
			match List.rev direction_list_path_path with
			|path2::(path1::rev_direction_list) ->
				let directions : PRF_edit.t_direction list =
					List.rev (List.map direction_of_string rev_direction_list)
				in
				PRF_edit.replace_in_file_raw directions path1 path2
			|_ -> raise (Invalid_argument (String.concat " " direction_list_path_path))
		)
		|option_list_path -> (
			let default_options : Main.t_options = {
				verbose = false;
				discharge = false;
				undischarge = false;
				print_proof = false;
				print_report = false;
			}
			in
			match List.rev option_list_path with
			|path::option_list -> (
				let options : Main.t_options = 
					options_of_string_list default_options option_list
				in
				Main.expand_and_validate_file options path
			)
			|_ -> raise (Invalid_argument (String.concat " " option_list_path))
		)
	)
        |_ -> raise (Invalid_argument (String.concat " " arg_list))
        with
	|PRF_edit.Error e
	|ND_main.Parse_error e
        |Main.Error e
        |PRF_main.Parse_error e
        |PRF_main.Error e
        |FML_main.Parse_error e -> IO.print_to_stderr_red e
        |Invalid_argument e -> IO.print_to_stderr (String.concat "" ["invalid argument(s): ";e;"\n";usage])
