type t_fml = 
        | PredApp of t_pred * (t_term list)
        | BinopApp of t_binop * t_fml * t_fml
        | UnopApp of t_unop * t_fml
        | QuantApp of t_quant * t_var * t_fml

and t_binop = Binop of string

and t_unop = Unop of string

and t_quant = Quant of string

and t_term = 
        | Atom of t_var
        | FuncApp of t_func * (t_term list)

and t_pred = Pred of string

and t_func = Func of string

and t_var = Var of string

