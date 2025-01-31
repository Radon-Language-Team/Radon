module util

import token { convert_radon_to_c_type }
import nodes { NodeVar, VarAssignOptions }

pub fn gen_assignment(node NodeVar) string {
	mut node_code := ''

	if node.var_assign == VarAssignOptions.assign {
		node_code += '${convert_radon_to_c_type(node.var_type)}'
	}

	// If the value is a function argument, we leave it as is
	if node.is_var {
    node_code += ' ${node.name} = ${node.value};\n'
    return node_code
  }

	node_value := match node.var_type {
		.type_string {
			'"${node.value}"'
		}
		.type_int {
			'${node.value}'
		}
		else {
		println('Error: Unknown type in gen_assignment ${node.var_type}')
			'${node.value}'
		}
	}

	node_code += ' ${node.name} = ${node_value};\n'

	return node_code
}
