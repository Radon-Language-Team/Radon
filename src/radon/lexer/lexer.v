module lexer

import token { Token }

@[minify]
pub struct Lexer {
mut:
	file_name  string
	file_path  string
	line_count int
	token      Token
	prev_token Token
	next_token Token
}

pub fn lexer_test() {
	println('test lexer')
}
