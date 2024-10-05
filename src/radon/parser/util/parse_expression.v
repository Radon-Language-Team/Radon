module util

import term
import radon.token { TokenType }

struct ParsedExpression {
pub:
	success         bool
	message         string
	expression_type TokenType
}

pub fn parse_expression(tokens []token.Token) ParsedExpression {
	mut i := 0
	mut token_return := token.Token{}
	math_operators := ['+', '-', '*', '/']
	mut expected_type := tokens[0].token_type
	mut expression_type := TokenType.radon_null

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
			i += 1

			if tokens[i].value !in math_operators {
				return ParsedExpression{
					success:         false
					message:         'Expected math operator but got "${tokens[i].value}"'
					expression_type: token_return.token_type
				}
			}

			// This skips the operator. The loop will then continue with the next token
			expected_type = TokenType.type_int
			i += 1
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
		success:         true
		message:         ''
		expression_type: expression_type
	}
}
