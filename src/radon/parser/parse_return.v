module parser

import nodes
import token
import radon.parser.util

struct Return {
	new_index   int
	node_return nodes.NodeReturn
}

pub fn (mut p Parser) parse_return(index int) !Return {
	mut tokens_to_return := []token.Token{}
	mut ret := nodes.NodeReturn{
		new_index:   index
		value:       ''
		return_type: token.TokenType.radon_null
	}

	ret.new_index += 1

	for p.all_tokens[ret.new_index].token_type != token.TokenType.semicolon
		|| ret.new_index >= p.all_tokens.len {
		ret.value += p.all_tokens[ret.new_index].value
		tokens_to_return << p.all_tokens[ret.new_index]
		ret.new_index += 1
	}

	ret_type := util.check_expression(tokens_to_return)

	if !ret_type.success {
		p.throw_parse_error(ret_type.message)
		exit(1)
	}

	ret.return_type = ret_type.token.token_type
	ret.new_index += 1

	return Return{
		new_index:   ret.new_index
		node_return: ret
	}
}
