%{

open ND_types

%}

%token                  SEP EOF
%token <string>         NULLARY_RULE UNARY_RULE BINARY_RULE TRINARY_RULE FML

%type <t_prf_raw> main prf
%type <t_fml_raw> fml
%type <t_nullary_rule> nullary_rule
%type <t_unary_rule> unary_rule
%type <t_binary_rule> binary_rule
%type <t_trinary_rule> trinary_rule

%start main


%%
main:
        |prf EOF                                { $1 : t_prf_raw }
;

prf:
        |fml                                    { Atomic_prf_raw $1 : t_prf_raw }
        |nullary_rule fml                       { Nullary_prf_raw ($1, $2) : t_prf_raw }
        |prf unary_rule fml                     { Unary_prf_raw ($1, $2, $3) : t_prf_raw }
        |prf SEP prf binary_rule fml            { Binary_prf_raw ($1, $3, $4, $5) : t_prf_raw }
        |prf SEP prf SEP prf trinary_rule fml   { Trinary_prf_raw ($1, $3, $5, $6, $7) : t_prf_raw }
;

fml:
        |FML                                    { Fml_raw $1 : t_fml_raw }
;

nullary_rule:
        |NULLARY_RULE                           { Nullary_rule $1 : t_nullary_rule }
;

unary_rule:
        |UNARY_RULE                             { Unary_rule $1 : t_unary_rule }
;

binary_rule:
        |BINARY_RULE                            { Binary_rule $1 : t_binary_rule }
;

trinary_rule:
        |TRINARY_RULE                           { Trinary_rule $1 : t_trinary_rule }
;
