module util

import token
import nodes { NodeReturn }

pub fn gen_return(node NodeReturn) string {
	mut node_code := ''

	node_value := match '${node.return_type}' {
		'${token.TokenType.type_string}' {
			'"${node.value}"'
		}
		'${token.TokenType.type_int}' {
			'${node.value}'
		}
		else {
			'${node.value}'
		}
	}
	node_code += 'return ${node_value};\n'

	return node_code
}
