type t_fml_raw = Fml_raw of string

type t_nullary_rule = Nullary_rule of string
type t_unary_rule = Unary_rule of string
type t_binary_rule = Binary_rule of string
type t_trinary_rule = Trinary_rule of string

type t_prf_raw = 
        | Atomic_prf_raw of t_fml_raw
        | Nullary_prf_raw of (t_nullary_rule * t_fml_raw)
        | Unary_prf_raw of (t_prf_raw * t_unary_rule * t_fml_raw)
        | Binary_prf_raw of (t_prf_raw * t_prf_raw * t_binary_rule * t_fml_raw)
        | Trinary_prf_raw of (t_prf_raw * t_prf_raw * t_prf_raw * t_trinary_rule * t_fml_raw)

type t_prf =
        | Atomic_prf of FML_types.t_fml
        | Nullary_prf of (t_nullary_rule * FML_types.t_fml)
        | Unary_prf of (t_prf * t_unary_rule * FML_types.t_fml)
        | Binary_prf of (t_prf * t_prf * t_binary_rule * FML_types.t_fml)
        | Trinary_prf of (t_prf * t_prf * t_prf * t_trinary_rule * FML_types.t_fml)

