module parser

import nodes
import token

struct Return {
	new_index int
	node_return nodes.NodeReturn
}

pub fn (mut p Parser) parse_return(index int) !Return {

	mut ret := nodes.NodeReturn {
		new_index: index,
		value:     '',
		return_type: token.TokenType.radon_null,
	}

	ret.new_index += 1

	return Return {
		new_index: ret.new_index,
		node_return: ret,
	}
}
