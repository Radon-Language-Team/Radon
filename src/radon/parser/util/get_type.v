module util

import radon.token

pub fn get_type(tokens []token.Token) token.Token {
	mut index := 0
	mut token_return := token.Token{}

	math_operators := ['+', '-', '*', '/']

	println('Trying to figure our return type for ${tokens.len} tokens')

	if tokens.len == 1 {
		// It is a simple expression like '5', 'true' or '"hello"'
		// TODO: This only works for simple expressions that are known at compile time. Stuff like variables or function calls will not work
		token_return = tokens[0]
	} else {
		// It is a more complex expression like '5 + 5', 'a.pop()' or something else

		for token in tokens {
			mut last_type := tokens[index].token_type

			
		}

	}

	return token_return
}
