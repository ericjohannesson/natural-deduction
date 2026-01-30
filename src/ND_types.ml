type t_item = Def_fml of (FML_types.t_fml * FML_types.t_fml * int)  | Def_prf of (PRF_types.t_prf * PRF_types.t_prf * int) | Prf of PRF_types.t_prf

type t_def_token = {
	content : string;
	line: int;
}
