module parser

import nodes
import radon.token { TokenType }

struct ParsedExpression {
pub:
	success          bool
	message          string
	expression_value string
	expression_type  TokenType
}

pub fn (mut p Parser) parse_expression(tokens []token.Token) ParsedExpression {
	mut i := 0
	mut token_return := token.Token{}
	math_operators := ['+', '-', '*', '/']
	mut expected_type := tokens[0].token_type
	mut expression_type := TokenType.radon_null
	mut expression_value := ''

	// For single token expressions such as "x" or "5"
	// Important: A string is also considered a single token expression as the lexer
	// will return a single token with the type TokenType.string and it's value
	if tokens.len == 1 {
		if tokens[0].token_type == TokenType.var_name {
			variable := p.variable_table(nodes.NodeVar{}, tokens[0].value, VarOperation.get)
			return ParsedExpression{
				success:          true
				message:          ''
				expression_value: variable.variable?.value
				expression_type:  variable.variable?.var_type
			}
		} else {
			return ParsedExpression{
				success:          true
				message:          ''
				expression_value: tokens[0].value
				expression_type:  tokens[0].token_type
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
			if last_type == TokenType.var_name {
				variable := p.variable_table(nodes.NodeVar{}, tokens[i].value, VarOperation.get)

				if variable.variable?.var_type != expected_type {
					return ParsedExpression{
						success:         false
						message:         'Variable ${tokens[i].value} either not found or not of type ${expected_type}'
						expression_type: token_return.token_type
					}
				}
				expression_type = variable.variable?.var_type
			} else {
				if (expected_type == TokenType.type_string && current_value !in math_operators)
					|| (expected_type == TokenType.type_int && current_value !in math_operators) {
					return ParsedExpression{
						success:         false
						message:         'Expected "${expected_type}" but got "${last_type}"'
						expression_type: token_return.token_type
					}
				}
			}
		}

		if last_type == TokenType.type_int {
			expression_value += tokens[i].value
			expected_type = TokenType.type_int

			i++
			continue
		} else if last_type == TokenType.plus {
			if i + 1 >= tokens.len {
				return ParsedExpression{
					success:         false
					message:         'Expected expression after "+"'
					expression_type: token_return.token_type
				}
			}

			mut left_hand := tokens[i - 1].token_type
			mut right_hand := tokens[i + 1].token_type

			if left_hand == TokenType.var_name {
				variable := p.variable_table(nodes.NodeVar{}, tokens[i - 1].value, VarOperation.get)
				left_hand = variable.variable?.var_type
			}

			if right_hand == TokenType.var_name {
				variable := p.variable_table(nodes.NodeVar{}, tokens[i + 1].value, VarOperation.get)
				right_hand = variable.variable?.var_type
			}

			if left_hand != right_hand {
				return ParsedExpression{
					success:         false
					message:         'Expected same type on both sides of "+" but got "${left_hand}" and "${right_hand}"'
					expression_type: token_return.token_type
				}
			}

			expression_value += tokens[i].value
			expected_type = left_hand

			i++
			continue
		} else if last_type == TokenType.var_name {
			variable := p.variable_table(nodes.NodeVar{}, tokens[i].value, VarOperation.get)

			expression_value += variable.variable?.value
			expected_type = variable.variable?.var_type

			i++
			continue
		} else if last_type == TokenType.type_string {
			expression_value += tokens[i].value
			expected_type = TokenType.type_string

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
		message:          ''
		expression_value: expression_value
		expression_type:  expression_type
	}
}
