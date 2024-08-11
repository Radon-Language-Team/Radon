module lexer

import os
import term
import token { Token }

@[minify]
pub struct Lexer {
mut:
	file_name  string
	file_path  string
	line_count int
	index      int
	buffer     string
	all_tokens []Token
	token      Token
	prev_token Token
	next_token Token
}

pub fn lex(file_name string, file_path string) ![]Token {
	mut lexer := Lexer{
		file_name:  file_name
		file_path:  file_path
		line_count: 1
		all_tokens: []
	}

	mut file_to_lex := os.open(file_path) or {
		println(term.red('radon_lexer Error: Could not open file ${file_name} - ${err}'))
		exit(1)
	}

	defer {
		file_to_lex.close()
		println(term.gray('[INFO]: Closed file: ${file_name}'))
	}

	content := os.read_file(file_path) or {
		println(term.red('radon_lexer Error: Could not read file'))
		exit(1)
	}

	lexer.lex_file(content)

	return lexer.all_tokens
}

pub fn (mut l Lexer) lex_file(content string) {
	for c in content {
		if l.token.is_alpha(c) {
			l.buffer += content[l.index].ascii_str()
			l.index += 1

			for l.token.is_alpha(content[l.index]) {
				l.buffer += content[l.index].ascii_str()
				l.index += 1

				if l.index >= content.len {
					break
				}
			}
			l.all_tokens << l.token.find_token(l.buffer)
			l.buffer = ''
			break
		}
	}
	println('All tokens: ${l.all_tokens}')
}
