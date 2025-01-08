module util

import token { convert_radon_to_c_type }
import nodes { NodeVar, VarAssignOptions }

pub fn gen_assignment(node NodeVar) string {
	mut node_code := ''

	if node.var_kind == VarAssignOptions.assign {
		node_code += '${convert_radon_to_c_type(node.var_type)}'
	}

	node_value := match node.var_type {
		.type_string {
			'"${node.value}"'
		}
		.type_int {
			'${node.value}'
		}
		else {
			'${node.value}'
		}
	}

	node_code += ' ${node.name} = ${node_value};\n'

	return node_code
}
