type token = 
|	EOF
|	DEF of ND_types.t_def_token
|	FML of string
|	PRF of string

val main : (Stdlib.Lexing.lexbuf -> token) -> Stdlib.Lexing.lexbuf -> ND_types.t_item list
