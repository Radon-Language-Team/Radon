module lexer

import os
import term
import token { Token, TokenType }

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

fn (mut l Lexer) token_manager(new_token Token) {

	if new_token.token_type == TokenType.radon_null {
		println(term.red('radon_lexer Error: Invalid token: ${new_token.value} on line: ${new_token.line_number}'))
		exit(1)
	}
	l.prev_token = l.token
	l.token = new_token
	l.all_tokens << new_token
}

pub fn (mut l Lexer) lex_file(content string) {
	for c in content {
		if l.index >= content.len {
			println(term.gray('[INFO]: Finished lexing file: ${l.file_name} - ${c}'))
			break
		}
		if l.token.is_alpha(content[l.index]) {
			l.buffer += content[l.index].ascii_str()
			l.index += 1

			for l.token.is_alpha(content[l.index]) {
				l.buffer += content[l.index].ascii_str()
				l.index += 1

				if l.index >= content.len {
					break
				}
			}
			new_token := Token{
				token_type:  l.token.find_token(l.buffer)
				value:       l.buffer
				line_number: l.line_count
			}
			l.token_manager(new_token)
			l.buffer = ''
		} else if l.token.is_int(content[l.index]) {
			l.buffer += content[l.index].ascii_str()
			l.index += 1

			for l.token.is_int(content[l.index]) {
				l.buffer += content[l.index].ascii_str()
				l.index += 1

				if l.index >= content.len {
					break
				}
			}
			new_token := Token{
				token_type:  TokenType.type_int
				value:       l.buffer
				line_number: l.line_count
			}
			l.token_manager(new_token)
			l.buffer = ''
		} else if l.token.is_white(content[l.index]) {
			if content[l.index].ascii_str() == '\n' {
				l.line_count += 1
			} else if content[l.index].ascii_str() == '\r\n' {
				// Windows line ending
				l.index += 1
			}
			l.index += 1
		} else {
			println(term.red('radon_lexer Error: Invalid character: "${content[l.index].ascii_str()}" on line: ${l.line_count}'))
			exit(1)
		}
	}
}
