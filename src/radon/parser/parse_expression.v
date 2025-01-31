module parser

import nodes
import radon.token { TokenType }

struct ParsedExpression {
pub:
	success          bool
	message          string
	expression_value string
	expression_type  TokenType
	complete_token   token.Token
	is_var           bool
}

pub fn (mut p Parser) parse_expression(tokens []token.Token) ?ParsedExpression {
	mut i := 0
	mut token_return := token.Token{}
	mut expected_type := tokens[0].token_type
	mut expression_type := TokenType.radon_null
	mut expression_value := ''

	// math_operators := ['+', '-', '*', '/']
	math_operators := [TokenType.plus, TokenType.minus, TokenType.star, TokenType.slash]

	// For single token expressions such as "x" or "5"
	// Important: A string is also considered a single token expression as the lexer
	// will return a single token with the type TokenType.string and it's value
	if tokens.len == 1 {
		if tokens[0].token_type == .var_name {
			// Check if the variable exists
			var := p.variable_table(nodes.NodeVar{}, tokens[0].value, VarOperation.get) or {
				exit(1)
			}

			if var.variable.var_kind == nodes.VarKindOptions.proc_var {
				token_expr := tokens[0]
				return ParsedExpression{
					success:          true
					expression_value: token_expr.value
					expression_type:  var.variable.var_type
					is_var:           true
					complete_token:   token.Token{
						value:      token_expr.value
						token_type: token_expr.token_type
					}
				}
			} else {
				return ParsedExpression{
					success:          true
					expression_value: var.variable.value
					expression_type:  var.variable.var_type
					complete_token:   token.Token{
						value:      var.variable.value
						token_type: var.variable.var_type
					}
				}
			}
		} else {
			return ParsedExpression{
				success:          true
				expression_value: tokens[0].value
				expression_type:  tokens[0].token_type
				complete_token:   token.Token{
					value:      tokens[0].value
					token_type: tokens[0].token_type
				}
			}
		}
	}

	for i < tokens.len {
		current_token := tokens[i]
		current_value := current_token.value
		mut last_type := current_token.token_type
		expression_type = last_type

		// We seem to have reached the end of the expression
		if i + 1 > tokens.len {
			break
		}

		if last_type != expected_type {
			if last_type == .var_name {
				variable := p.variable_table(nodes.NodeVar{}, tokens[i].value, VarOperation.get) or {
					exit(1)
				}

				if variable.variable.var_type != expected_type {
					return ParsedExpression{
						success:         false
						message:         'Variable ${tokens[i].value} either not found or not of type ${expected_type}'
						expression_type: token_return.token_type
					}
				}
				expression_type = variable.variable.var_type
			} else {
				current_as_token := token.find_token(current_value)
				if (expected_type == .type_string && current_as_token !in math_operators)
					|| (expected_type == .type_int && current_as_token !in math_operators) {
					return ParsedExpression{
						success:         false
						message:         'Expected "${expected_type}" but got "${last_type}"'
						expression_type: token_return.token_type
					}
				}
			}
		}

		if last_type == .type_int {
			expression_value += tokens[i].value
			expected_type = .type_int

			i++
			continue
		} else if last_type in math_operators {
			if i + 1 >= tokens.len {
				return ParsedExpression{
					success:         false
					message:         'Expected expression after "+"'
					expression_type: token_return.token_type
				}
			}

			mut left_hand := tokens[i - 1].token_type
			mut right_hand := tokens[i + 1].token_type

			if left_hand == .type_string && right_hand == .type_string
				&& last_type != .plus {
				return ParsedExpression{
					success:         false
					message:         'Sign "${last_type}" is not defined/supported for strings. Only "+" is so far.'
					expression_type: token_return.token_type
				}
			}

			if left_hand == .var_name {
				variable := p.variable_table(nodes.NodeVar{}, tokens[i - 1].value, VarOperation.get) or {
					exit(1)
				}
				left_hand = variable.variable.var_type
			}

			if right_hand == .var_name {
				variable := p.variable_table(nodes.NodeVar{}, tokens[i + 1].value, VarOperation.get) or {
					exit(1)
				}
				right_hand = variable.variable.var_type
			}

			if left_hand != right_hand {
				return ParsedExpression{
					success:         false
					message:         'Expected same type on both sides of "${last_type}" but got "${left_hand}" and "${right_hand}"'
					expression_type: token_return.token_type
				}
			}

			expression_value += tokens[i].value
			expected_type = left_hand

			i++
			continue
		} else if last_type == .var_name {
			variable := p.variable_table(nodes.NodeVar{}, tokens[i].value, VarOperation.get) or {
				exit(1)
			}

			if variable.variable.var_kind == nodes.VarKindOptions.proc_var {
				expression_value += current_token.value
				expression_type = variable.variable.var_type
			} else {
				expression_value += variable.variable.value
				expected_type = variable.variable.var_type
			}

			i++
			continue
		} else if last_type == .type_string {
			expression_value += tokens[i].value
			expected_type = .type_string

			i++
			continue
		} else {
			return ParsedExpression{
				success:         false
				message:         'Unsupported expression'
				expression_type: token_return.token_type
			}
		}
	}
	return ParsedExpression{
		success:          true
		expression_value: expression_value
		expression_type:  expression_type
		complete_token:   token.Token{
			value:      expression_value
			token_type: expression_type
		}
	}
}
