exception Error of string

let manual : string=
"==============================================================================
NATURAL DEDUCTION
A basic proof assistant for natural deduction in classical first-order logic.
==============================================================================

USAGE:

  nd <command>

  COMMANDS:

    validate [ <options> ] { <path-to-file> | - }

        Prints an annotated and formatted version of proof contained in file
        to stdout, and a report to stderr, if proof is valid.

        Otherwise prints a report to stderr.

    show [ <directions> ] { <path-to-file> | - }

        Prints a formatted version of proof contained in file to stdout, or
        sub-proof thereof specified by directions.

        Prints message to stderr if no sub-proof matches directions.

    edit [ <directions> ] <path-to-file>

        Opens a formatted version of proof contained in file in nano, or
        sub-proof thereof specified by directions. Writes any changes to file,
        and prints the result to stdout.

    replace <path-to-file> [ <directions> ] <path-to-file>

        Prints to stdout result of replacing proof contained in second file
        (or sub-proof thereof specified by directions) with proof contained
        in first file.

    decompose [ -R ] <path-to-directory> <path-to-file>

        Parses proof contained in file and creates a directory for each
        immediate sub-proof containing a file called 'proof.txt'. Also prints
        main proof to 'proof.txt', and puts everything in path-to-directory.

        Does it recursively for each sub-proof if '-R' is provided.

    compose [ -R ] <path-to-directory>

        Assumes that a proof has been decomposed in directory, and composes a
        proof from its immediate sub-proofs. Prints the result to stdout and
        to the file 'proof.txt' located in directory.

        Does it recursively for each sub-proof if '-R' is provided.

    help

        Prints this manual to stdout.

    Reads from stdin if '-' is provided instead of a path (and if it may be so
    provided).

  OPTIONS:

    --discharge, -d

        Checks a version of the proof where all dischargeable assumptions are
        discharged.

    --undischarge, -u

        Checks a version of the proof where all undischargeable assumptions
        are undischarged.

    --verbose, -v

        Prints information to stderr about discharged assumptions that may not
        be discharged, undischarged assumptions that may be discharged, and
        sub-proofs not satisfying the conditions of any inferential rule.

  DIRECTIONS:

    --sub-only, -o

        Targets the (only) sub-proof of a unary proof.

    --sub-left, -l

        Targets the left sub-proof of a binary or trinary proof.

    --sub-right, -r

        Targets the right sub-proof of a binary or trinary proof.

    --sub-center, -c

        Targets the center sub-proof of a trinary proof.

    A space-separated list of directions is interpreted from left to right,
    in such a way that 

        nd show <directions> <direction> <path-to-file>

    is equivalent to

        nd show <directions> <path-to-file> | nd show <direction> -

Author:  Eric Johannesson, eric@ericjohannesson.com
Website: https://github.com/ericjohannesson/natural-deduction"

let usage : string=
"USAGE:
  nd validate [ <options> ] { <path-to-file> | - }
  nd show [ <directions> ] { <path-to-file> | - }
  nd edit [ <directions> ] <path-to-file>
  nd replace <path-to-file> [ <directions> ] <path-to-file>
  nd decompose [ -R ] <path-to-directory> <path-to-file>
  nd compose [ -R ] <path-to-directory>
  nd help"

let arg_array : string array = Sys.argv
let arg_list : string list = Array.to_list arg_array
let len = Array.length arg_array

let _ : unit = 
try
        let command : string = arg_array.(1) in
        if command = "help" then IO.print_to_stdout manual else
        let path : string = arg_array.(len - 1) in
        let options : string list = List.rev (List.tl (List.rev (List.tl (List.tl arg_list)))) in
        match command, path with
        |"validate", "-" -> let _ = Main.validate_stdin ("--print-proof"::("--print-report"::options)) in ()
        |"validate", path -> let _ = Main.validate_file ("--print-proof"::("--print-report"::options)) path in ()
        |"show", "-" -> let _ = Main.sub_prf_of_stdin options in ()
        |"show", path -> let _ = Main.sub_prf_of_file options path in ()
        |"decompose", path -> Main.decompose_file options path
        |"compose", path -> Main.compose_dir options path
        |"edit", path -> Main.edit_file options path
        |_ -> raise (Error "invalid argument(s)")
with 
|Main.Error e
|ND_main.Error e
|FOL_main.Error e -> IO.print_to_stderr e
|Error e -> IO.print_to_stderr (String.concat "\n" [e;usage])
|_ -> IO.print_to_stderr usage
