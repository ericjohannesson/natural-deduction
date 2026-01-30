{
open ND_parser

let line_of_lexbuf (lexbuf : Lexing.lexbuf) : int =
	(lexbuf.Lexing.lex_curr_p).Lexing.pos_lnum

let new_lines (s : string) (b : Lexing.lexbuf) : unit =
	let rec aux (string_list : string list) : unit =
		match string_list with
		|[] -> ()
		|hd::[] -> ()
		|hd::tl-> let _ : unit = Lexing.new_line b in aux tl
	in
	aux (String.split_on_char '\n' s)
}

let prf_line = [^ '=' '\n' ':' '#']+ [^ '\n' ':' '#']* "\n"?
let prf = prf_line+
let nls = "\n"+
let fml = [^ '=' '\n' ':' '#']+ [^ ':' '\n' '#']*
(*let prf = [^ '=' '\n' ':' '#']+ [^ ':' '#']* *)
let comment = "#" [^ '\n']* "\n"
let colon = ":"
let eq = "="

rule token = parse 
	|prf as s		{ let _ : unit = new_lines s lexbuf in PRF s }
	|eq nls (prf as s) nls	{ let _ : unit = new_lines s lexbuf in PRF s }
	|(fml as s) colon	{ DEF { content = s ; line = line_of_lexbuf lexbuf } }
	|eq (fml as s)		{ FML s }
	|comment as s		{ let _ : unit = new_lines s lexbuf in token lexbuf }
	|nls as s		{ let _ : unit = new_lines s lexbuf in token lexbuf }
	|eof			{ EOF }
