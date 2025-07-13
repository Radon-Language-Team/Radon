module gen_utils

import structs

pub fn gen_bool_expr(node structs.BoolCondition) string {
	lhs := node.con_lhs
	rhs := node.con_rhs

	mut lhs_code := gen_expression(lhs)
	mut rhs_code := gen_expression(rhs)

	return '${lhs_code} ${node.con_op} ${rhs_code}'
}
