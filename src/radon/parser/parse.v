module parser

import radon.token { Token }

@[minify]
pub struct Parser {
pub mut:
	token_index int
	all_tokens  []Token
	prev_token  Token
	token       Token
	next_token  Token
}

pub fn parse(tokens []Token) {
	mut parser := Parser{
		token_index: 0
		all_tokens:  tokens
		prev_token:  Token{}
		token:       Token{}
		next_token:  Token{}
	}

	parser.parse_tokens()
}

fn (mut p Parser) parse_tokens() {
	println('Hello from parser')
}
