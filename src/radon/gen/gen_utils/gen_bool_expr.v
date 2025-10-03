module gen_utils

import ast

pub fn gen_bool_expr(node ast.BoolCondition) string {
	lhs := node.con_lhs
	rhs := node.con_rhs
	op := node.con_op

	mut lhs_code := gen_expression(lhs)
	mut rhs_code := gen_expression(rhs)

	lhs_as_expr := lhs as ast.Expression
	rhs_as_expr := rhs as ast.Expression

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
