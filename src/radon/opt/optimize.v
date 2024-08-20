module opt

import radon.token { Token, TokenType }

@[minify]
pub struct Optimizer {
pub mut:
	token_index int
	all_tokens  []Token
	prev_token  Token
	token       Token
	next_token  Token
}

/**
 * I don't think this is very common in compilers, but this function will optimize the tokens
 * It does so by removing tokens that are not needed
 * For example, to declare the return type of a function, you use the tokens `-`, `>`
 * The optimizer will remove the `-` token and replace the `>` token with a `->` token
 * While this is not a big improvement, it still decreases the size of the tokens
 * for the parser to parse
 *
**/
pub fn optimize(tokens []Token) ![]Token {
	mut optimizer := Optimizer{
		token_index: 0
		all_tokens:  tokens
		prev_token:  Token{}
		token:       Token{}
		next_token:  Token{}
	}

	return optimizer.optimize_tokens()
}

fn (mut o Optimizer) optimize_tokens() []Token {
	token_combos_to_remove := [
		['-', '>'], // Remove the `-` token and replace the `>` token with a `->` token
		['!', '='], // Remove the `!` token and replace the `=` token with a `!=` token
		['=', '='], // Remove the `=` token and replace the `=` token with a `==` token
		['<', '='], // Remove the `<` token and replace the `=` token with a `<=` token
		['>', '='], // Remove the `>` token and replace the `=` token with a `>=` token
		['&', '&'], // Remove the `&` token and replace the `&` token with a `&&` token
		['|', '|'], // Remove the `|` token and replace the `|` token with a `||` token
	]

	for token in o.all_tokens {
		o.token = token
		o.next_token = o.all_tokens[o.token_index + 1] or {
			// We have reached the end of the array
			break
		}

		// Remove the `-` token and replace the `>` token with a `->` token
		if o.token.token_type == TokenType.minus && o.next_token.token_type == TokenType.greater {
			replacement_token := Token{
				token_type:  TokenType.function_return
				value:       '->'
				line_number: o.token.line_number
			}
			o.token.remove_token_and_replace(o.all_tokens, o.token_index, replacement_token,
				2) or {
				println('Failed to remove token and replace')
				exit(1)
			}
		} else {
			o.token_index += 1
			continue
		}
	}

	return o.all_tokens
}
