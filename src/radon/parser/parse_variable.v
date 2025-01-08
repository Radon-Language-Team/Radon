module parser

import token
import nodes { VarAssignOptions }

pub fn (mut p Parser) parse_variable(index int) nodes.NodeVar {
	mut var_expression := []token.Token{}
	mut var := nodes.NodeVar{
		new_index: index
		name:      ''
		value:     ''
		scope_id:  0
		var_type:  token.TokenType.radon_null
	}

	var.name = p.all_tokens[var.new_index].value
	var.new_index += 1

	var_kind_token := p.all_tokens[var.new_index]
	match var_kind_token.token_type {
		.var_assign {
			var.var_kind = VarAssignOptions.assign
		}
		.equal {
			var.var_kind = VarAssignOptions.reassign
		}
		else {
			p.throw_parse_error('Expected either ":=" or "=" but got ${var_kind_token.value}')
			exit(1)
		}
	}

	var.new_index += 1

	for p.all_tokens[var.new_index].token_type != token.TokenType.semicolon
		|| var.new_index >= p.all_tokens.len {
		var.value += p.all_tokens[var.new_index].value
		var_expression << p.all_tokens[var.new_index]
		var.new_index += 1
	}

	expression := p.parse_expression(var_expression) or {
		p.throw_parse_error('Failed to parse expression')
		exit(1)
	}

	if !expression.success {
		p.throw_parse_error(expression.message)
		exit(1)
	}

	var.var_type = expression.expression_type
	var.value = expression.expression_value
	var.new_index += 1

	return var
}
