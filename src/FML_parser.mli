type token = 
|	VAR of string
|	UNOP of string
|	RPAR
|	RBR
|	QUANT of string
|	PREFIX_PRED of string
|	PREFIX_FUNC of string
|	POSTFIX_FUNC of string
|	NEG_INFIX_PRED of string
|	LPAR
|	LBR
|	INFIX_PRED of string
|	INFIX_FUNC of string
|	EOF
|	COMMA
|	BINOP of string

exception Error of int

val main : (Stdlib.Lexing.lexbuf -> token) -> Stdlib.Lexing.lexbuf -> FML_types.t_fml
