module lexer

import token { Token }

@[minify]
pub struct Lexer {
mut:
	file_name  string
	file_path  string
	token      Token
	prev_token Token
	next_token Token
}
