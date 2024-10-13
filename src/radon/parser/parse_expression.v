module parser

import term
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

	println(term.gray('Parsing expression of ${tokens.len} tokens'))

	for i < tokens.len {
		current_token := tokens[i]
		last_type := current_token.token_type
		expression_type = last_type

		if last_type != expected_type {
			return ParsedExpression{
				success:         false
				message:         'Expected type "${expected_type}" but got "${last_type}"'
				expression_type: token_return.token_type
			}
		}

		if last_type == TokenType.type_int {
			if i + 1 == tokens.len {
				// break the loop as we have reached the end of the expression
				break
			}
			expression_value += tokens[i].value
			i += 1

			if tokens[i].value !in math_operators {
				return ParsedExpression{
					success:         false
					message:         'Expected math operator but got "${tokens[i].value}"'
					expression_type: token_return.token_type
				}
			}
			expression_value += tokens[i].value

			// This skips the operator. The loop will then continue with the next token
			expected_type = TokenType.type_int
			i += 1
			continue
		} else if last_type == TokenType.var_name {
			variable := p.variable_table(nodes.NodeVar{}, tokens[i].value, VarOperation.get)

			if !variable.success == true {
				return ParsedExpression{
					success:         false
					message:         'Tried to access variable "${tokens[i].value}" but it was not found!'
					expression_type: token_return.token_type
				}
			}

			println('HOLY MOLY I GOT A VARIABLE: ${variable.variable}')
			exit(1)
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
