{
open DEF_parser
}

let fml = [^ ':' '\n']+
let eq = ":="

rule token = parse
	|fml as s	{ FML s }
	|eq		{ DF }
	|eof		{ EOF }
	|_		{ token lexbuf }
