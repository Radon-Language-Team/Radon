module gen_utils

import structs

pub fn gen_bool_expr(node structs.BoolCondition) string {
	lhs := node.con_lhs as structs.Expression
	rhs := node.con_rhs as structs.Expression

	mut lhs_code := ''
	mut rhs_code := ''

	// TODO: FINALLY PUT THIS CRAP INTO A SEPERATE FUNCTION JESUS

	if lhs.e_type == .type_string && !lhs.is_variable {
		lhs_code = gen_string(lhs)
	} else if lhs.e_type == .type_bool {
		bool_return := match lhs.value {
			'true' {
				1
			}
			'false' {
				0
			}
			else {
				println('Unknown bool value > Defaulting to 0')
				0
			}
		}.str()
		lhs_code = bool_return
	} else {
		lhs_code += lhs.value.trim_space()
	}

	if rhs.e_type == .type_string && !rhs.is_variable {
		rhs_code = gen_string(rhs)
	} else if rhs.e_type == .type_bool {
		bool_return := match rhs.value {
			'true' {
				1
			}
			'false' {
				0
			}
			else {
				println('Unknown bool value > Defaulting to 0')
				0
			}
		}.str()
		rhs_code = bool_return
	} else {
		rhs_code += rhs.value.trim_space()
	}

	return '${lhs_code} ${node.con_op} ${rhs_code}'
}

pub fn gen_single_bool_expr(node structs.Expression) string {
	mut if_con_code := ''
	if node.value in ['false', 'true'] {
		if_con_code = match node.value {
			'true' {
				'1'
			}
			'false' {
				'0'
			}
			else {
				println('Unknown bool value > Defaulting to 0')
				'0'
			}
		}
	} else {
		if_con_code = node.value
	}
	return if_con_code
}
