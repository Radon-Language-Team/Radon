module gen_utils

import structs
import cmd.util { print_error }

pub fn gen_string(node structs.AstNode) string {
	if node.type_name() == 'radon.structs.Expression' {
		expression := node as structs.Expression
		println(expression.value)
		return '"${expression.value}"'
	}

	print_error('${node.type_name()} does not have it\'s string function yet :)')
	exit(1)
}
