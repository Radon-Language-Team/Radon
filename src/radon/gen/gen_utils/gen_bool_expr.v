module gen_utils

import structs

pub fn gen_bool_expr(node structs.BoolCondition) string {
	lhs := node.con_lhs
	rhs := node.con_rhs
	op := node.con_op

	mut lhs_code := gen_expression(lhs)
	mut rhs_code := gen_expression(rhs)

	lhs_as_expr := lhs as structs.Expression
	rhs_as_expr := rhs as structs.Expression

	mut bool_expr := ''

	if lhs_as_expr.e_type == .type_string && rhs_as_expr.e_type == .type_string {
		if !op.contains('!') {
			bool_expr += '!'
		}

		bool_expr += 'strcmp(${lhs_code}, ${rhs_code})'
	} else {
		bool_expr += '${lhs_code} ${node.con_op} ${rhs_code}'
	}

	return bool_expr
}
