{

open PRF_parser

exception ERROR of string

let rule_token (d: char) (name: string) : PRF_parser.token =
        match d with
        |'0' -> NULLARY_RULE name
        |'1' -> UNARY_RULE name
        |'2' -> BINARY_RULE name
        |'3' -> TRINARY_RULE name
        |_ -> raise (ERROR "arity of rule greater than 3")

}

let digit = ['0' '1' '2' '3']
let rule_name = [^ '#' ';' ':']*
let fml = [^ '#' ';' ':']+
let hsep = ';'
let vsep = ':'
let rsep = '#'



rule token = parse
        |hsep                                   { SEP }
        |fml as s                               { FML s }
        |rsep (digit as d) (rule_name as s)     { rule_token d s }
        |vsep                                   { token lexbuf }
        |eof                                    { EOF }
        |_                                      { token lexbuf }


