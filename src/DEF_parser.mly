%token                  DF EOF
%token <string>         FML

%type <(string * string) list> main
%start main


%%
main:
        |defs EOF                                { $1 : (string * string) list }
;

defs:
	|def					{ ($1::[]) : (string * string) list } 
	|def defs				{ ($1 :: $2) : (string * string) list }
;

def:
	|fml DF fml				{ ($1,$3) : string * string }
;

fml:
	|FML					{ $1 : string }
;
