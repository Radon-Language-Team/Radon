module util

import term
import radon.token { TokenType }

struct TypeReturn {
pub:
	success bool
	message string
	token   token.Token
}

pub fn check_expression(tokens []token.Token) TypeReturn {
	mut i := 0
	mut token_return := token.Token{}
	math_operators := ['+', '-', '*', '/']
	mut expected_type := tokens[0].token_type

	println(term.gray('Trying to figure our return type for ${tokens.len} tokens'))

	if tokens.len == 1 {
		// It is a simple expression like '5', 'true' or '"hello"'
		// TODO: This only works for simple expressions that are known at compile time. Stuff like variables or function calls will not work
		token_return = tokens[0]
	} else {
		for token in tokens {
			last_type := tokens[i].token_type

			println('Reading ${token.value} with ${last_type} - Expected type: ${expected_type}')

			if last_type != expected_type {
				return TypeReturn{
					success: false
					message: 'Expected type ${expected_type} but got ${last_type}'
					token:   token_return
				}
			}

			if last_type == TokenType.type_int {
				i += 1

				println('Now reading ${tokens[i].value} with ${tokens[i].token_type}')

				if tokens[i].value !in math_operators {
					return TypeReturn{
						success: false
						message: 'Expected math operator but got ${tokens[i].value}'
						token:   token_return
					}
				}
				// This skips the operator. The loop will then continue with the next token
				expected_type = TokenType.type_int
				i += 1
				continue
			} else {
				// yet unsupported expression
				return TypeReturn{
					success: false
					message: 'Unsupported expression'
					token:   token_return
				}
			}
		}
	}

	return TypeReturn{
		success: true
		message: ''
		token:   token_return
	}
}
