module opt

import radon.token { Token, TokenType, find_replacement_token_type, remove_token_and_replace }
import term

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
	}

	return optimizer.optimize_tokens()
}

fn (mut o Optimizer) optimize_tokens() []Token {
	token_combos := [
		'->',
		'==',
		'!=',
		'<=',
		'>=',
		'&&',
		'||',
		'+=',
		'-=',
		'*=',
		'/=',
		'%=',
	]
	for token in o.all_tokens {
		current := token
		next := o.all_tokens[o.token_index + 1] or {
			// End of tokens
			break
		}
		if (current.value + next.value) in token_combos {
			println('Found ${current.value} and ${next.value} at line ${current.line_number}')
			replacement_token_type := find_replacement_token_type(current.value, next.value)

			if replacement_token_type == TokenType.radon_null {
				msg := term.yellow('radon_opt warning: Could not find replacement token type -> Searched for ${current.value} and ${next.value} - Skipped token optimization')
				println(msg)
				continue
			}

			replacement_token := Token{
				token_type:  replacement_token_type
				value:       current.value + next.value
				line_number: current.line_number
			}

			new_tokens := remove_token_and_replace(o.all_tokens, o.token_index, replacement_token,
				2) or {
				msg := term.red('radon_opt error: Could not remove and replace tokens -> Skipped token optimization')
				println(msg)
				return o.all_tokens
			}

			o.all_tokens = new_tokens
		} else {
			o.token_index += 1
		}
	}

	return o.all_tokens
}
