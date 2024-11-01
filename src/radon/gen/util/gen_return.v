module util

import nodes { NodeReturn }

pub fn gen_return(node NodeReturn) string {
	mut node_code := ''

	node_code += 'return ${node.value};\n'

	return node_code
}
