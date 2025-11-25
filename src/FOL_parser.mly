%{

open FOL_types

%}


%token <string> VAR
%token <string> PREFIX_PRED INFIX_PRED NEG_INFIX_PRED
%token <string> PREFIX_FUNC INFIX_FUNC POSTFIX_FUNC
%token <string> UNOP BINOP QUANT
%token LPAR RPAR COMMA
%token EOF

%start main
%type <FOL_types.t_fml> main

%%
main:
	|fml EOF			{ $1 }
;

fml:
	|nullary_pred			{ PredApp ($1,[]) }
	|prefix_pred terms		{ PredApp ($1,$2) }
	|prefix_pred LPAR terms RPAR	{ PredApp ($1,$3) }
	|fml binop fml			{ BinopApp ($2,$1,$3) }
	|LPAR fml binop fml RPAR	{ BinopApp ($3,$2,$4) }
	|unop fml			{ UnopApp ($1,$2) }
	|quant var fml			{ QuantApp ($1,$2,$3) }
	|term infix_pred term		{ PredApp ($2,[$1;$3]) }
	|term neg_infix_pred term	{ UnopApp (Unop "¬", PredApp ($2,[$1;$3])) }
	|LPAR term infix_pred term RPAR	{ PredApp ($3,[$2;$4]) }
;

term:
	|var				{ Atom $1 }
	|nullary_func			{ FuncApp ($1,[]) }
	|prefix_func LPAR terms RPAR	{ FuncApp ($1,$3) }
	|term infix_func term		{ FuncApp ($2,[$1;$3]) }
	|term postfix_func		{ FuncApp ($2,[$1]) }
	|LPAR term infix_func term RPAR	{ FuncApp ($3,[$2;$4]) }
;

var:
	|VAR				{ Var $1 }
;

nullary_pred:
	|PREFIX_PRED			{ Pred $1 }
;

prefix_pred:
	|PREFIX_PRED			{ Pred $1 }
;

infix_pred:
	|INFIX_PRED			{ Pred $1 }
;

neg_infix_pred:
	|NEG_INFIX_PRED			{ Pred $1 }
;


nullary_func:
	|PREFIX_FUNC			{ Func $1 }
;

prefix_func:
	|PREFIX_FUNC			{ Func $1 }
;

infix_func:
	|INFIX_FUNC			{ Func $1 }
;

postfix_func:
	|POSTFIX_FUNC			{ Func $1 }
;


terms:
	|term				{ $1::[] }
	|term COMMA terms		{ $1::$3 }
;

binop:
	|BINOP				{ Binop $1 }
;

unop:
	|UNOP				{ Unop $1 }
;

quant:
	|QUANT				{ Quant $1 }
;

