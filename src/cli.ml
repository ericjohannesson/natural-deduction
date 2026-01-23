exception Error of string

let usage : string=
"USAGE:
  nd validate [ <options> ] { <path-to-file> | - }
  nd expand <path-to-file> { <path-to-file> | - }
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
  nd help [ validate | expand | show | edit | replace | decompose | compose |
            options | directions ]"


let headers : string=
"A basic proof assistant for natural deduction in classical first-order logic.

USAGE:

  nd <command>

  COMMANDS:"

let author_website : string =
"Author:  Eric Johannesson, eric@ericjohannesson.com
Website: https://github.com/ericjohannesson/natural-deduction"


let help_validate : string =
"    validate [ <options> ] { <path-to-file> | - }

        Prints an annotated and formatted version of proof contained in file
        to stdout, and a report to stderr, if proof is valid.

        Otherwise prints a report to stderr."

let help_expand : string =
"    expand <path-to-file> { <path-to-file> | - }

        Uses definitions in first file to expand proof in second file
        and prints the result to stdout, if definitions are valid and
        do not yield unintended variable bindings.

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
"    help [ validate | expand | show | edit | replace | decompose | compose |
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
                help_validate;
                help_expand;
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
        |"validate" -> help_validate
        |"expand" -> help_expand
        |"show" -> help_show
        |"edit" -> help_edit
        |"replace" -> help_replace
        |"decompose" -> help_decompose
        |"compose" -> help_compose
        |"options" -> help_options
        |"directions" -> help_directions
        |"" -> manual
        |_ -> raise (Error "invalid argument(s)")

let arg_array : string array = Sys.argv
let arg_list : string list = Array.to_list arg_array

let _ : unit = 
        try
        match arg_list with
        |"nd"::("help" :: tl) -> IO.print_to_stdout (help (String.concat "" tl))
        |"nd"::(command :: tl) -> (
                let options : string list = List.rev (List.tl (List.rev tl)) in
                let path : string = List.hd (List.rev tl) in
                match command, path, options with
                |"validate", "-", _ -> let _ = Main.validate_stdin ("--print-proof"::("--print-report"::options)) in ()
                |"validate", path, _ -> let _ = Main.validate_file ("--print-proof"::("--print-report"::options)) path in ()
                |"show", "-", _ -> let _ = Main.sub_prf_of_stdin options in ()
                |"show", path, _ -> let _ = Main.sub_prf_of_file options path in ()
                |"show-raw", "-", _ -> let _ = Main.sub_prf_raw_of_stdin options in ()
                |"show-raw", path, _ -> let _ = Main.sub_prf_raw_of_file options path in ()
                |"decompose", path, hd::tl -> Main.decompose_file (List.tl (List.rev options)) (List.hd (List.rev options)) path
                |"decompose-raw", path, hd::tl -> Main.decompose_file_raw (List.tl (List.rev options)) (List.hd (List.rev options)) path
                |"compose", path, _ -> let _ = Main.compose_dir options path in ()
                |"compose-raw", path, _ -> let _ = Main.compose_dir_raw options path in ()
                |"edit", path, _ -> Main.edit_file options path
                |"edit-raw", path, _ -> Main.edit_file_raw options path
                |"replace", path, hd::tl -> Main.subst_in_file path (List.tl (List.rev options)) (List.hd (List.rev options))
                |"replace-raw", path, hd::tl -> Main.subst_in_file_raw path (List.tl (List.rev options)) (List.hd (List.rev options))
		|"expand", "-", [path_to_defs] -> let _ = Main.expand_stdin_by_file_opt ["--print-proof";"--print-report"] path_to_defs in ()
		|"expand", path, [path_to_defs] -> let _ = Main.expand_file_by_file_opt ["--print-proof";"--print-report"] path_to_defs path in ()
		|_,_,_ -> raise (Error "invalid argument(s)")
		)
        |_ -> raise (Error "invalid argument(s)")
        with
        |Main.Error e
        |ND_main.Error e
        |FML_main.Error e -> IO.print_to_stderr e
        |Error e -> IO.print_to_stderr (String.concat "\n" [e;usage])
        |_ -> IO.print_to_stderr (String.concat "\n" ["invalid argument(s)";usage])
