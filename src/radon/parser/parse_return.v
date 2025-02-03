module parser

import nodes
import token

pub fn (mut p Parser) parse_return(index int) nodes.NodeReturn {
	mut tokens_to_return := []token.Token{}
	mut ret := nodes.NodeReturn{
		new_index:   index
		value:       ''
		return_type: token.TokenType.radon_null
	}

	ret.new_index += 1

	for p.all_tokens[ret.new_index].token_type != token.TokenType.semicolon
		|| ret.new_index >= p.all_tokens.len {
		tokens_to_return << p.all_tokens[ret.new_index]
		ret.new_index += 1
	}

	expression := p.parse_expression(tokens_to_return) or {
		p.throw_parse_error('Error while parsing return expression')
		exit(1)
	}

	if !expression.success {
		p.throw_parse_error(expression.message)
		exit(1)
	}

	ret.return_type = expression.expression_type
	ret.value = expression.expression_value
	ret.new_index += 1

	return ret
}
