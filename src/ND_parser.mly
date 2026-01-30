%{
open FML_types
open PRF_types
open ND_types
%}


%token					EOF
%token <ND_types.t_def_token>		DEF
%token <string> 			FML PRF

%type <ND_types.t_item list> main
%start main


%%
main:
	|items EOF				{ $1 : t_item list }
	|EOF					{ [] : t_item list }
;

items:
	|item					{ ($1::[]) : t_item list } 
	|item items					{ ($1 :: $2) : t_item list }
;

item:
	|prf					{ Prf $1 : t_item }
	|def_fml				{ Def_fml $1 : t_item }
	|def_prf				{ Def_prf $1 : t_item }
;

def_fml:
	|def fml				{ (PRF_main.fml_of_string $1.content, $2, $1.line) : t_fml * t_fml * int }
;

def_prf:
	|def prf				{ (PRF_main.prf_of_string $1.content, $2, $1.line) : t_prf * t_prf * int }
;

def:
	|DEF					{ $1 : t_def_token }
;

fml:
	|FML					{ PRF_main.fml_of_string $1 : t_fml }
;

prf:
	|PRF					{ PRF_main.prf_of_string $1 : t_prf }
;
