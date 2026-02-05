type token = 
|	UNARY_RULE of string
|	TRINARY_RULE of string
|	SEP
|	NULLARY_RULE of string
|	FML of string
|	EOF
|	BINARY_RULE of string

exception Error of int

val main : (Stdlib.Lexing.lexbuf -> token) -> Stdlib.Lexing.lexbuf -> PRF_types.t_prf_raw
