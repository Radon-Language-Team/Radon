module lexer

import os
import term
import token { Token, TokenType }

@[minify]
pub struct Lexer {
pub mut:
	file_name    string
	file_path    string
	file_content string
	line_count   int
	index        int
	buffer       string
	all_tokens   []Token
	token        Token
	prev_token   Token
}

pub fn lex(file_name string, file_path string) !Lexer {
	mut lexer := Lexer{
		file_name:  file_name
		file_path:  file_path
		line_count: 1
		all_tokens: []
	}

	mut file_to_lex := os.open(file_path) or {
		lexer.throw_lex_error('Could not open file: ${file_name}')
		exit(1)
	}

	defer {
		file_to_lex.close()
	}

	content := os.read_file(file_path) or {
		lexer.throw_lex_error('Could not read file: ${file_name}')
		exit(1)
	}

	lexer.file_content = content

	if lexer.file_content.trim_space().len == 0 {
		lexer.throw_lex_error('File is empty')
		exit(1)
	}

	lexer.lex_file()

	return lexer
}

fn (mut l Lexer) lex_file() {
	for c in l.file_content {
		if l.index >= l.file_content.len {
			break
		}
		if l.token.is_alpha(l.file_content[l.index]) {
			l.lex_alpha()
		} else if l.token.is_int(l.file_content[l.index]) {
			l.lex_int()
		} else if l.token.is_white(l.file_content[l.index]) {
			l.lex_white()
		} else if l.token.is_special(l.file_content[l.index]) {
			l.lex_special()
		} else {
			l.throw_lex_error('Invalid character: "${l.file_content[l.index].ascii_str()}" - ${c}')
			exit(1)
		}
	}
}

fn (mut l Lexer) lex_alpha() {
	l.buffer += l.file_content[l.index].ascii_str()
	l.index += 1

	for l.token.is_alpha(l.file_content[l.index]) {
		l.buffer += l.file_content[l.index].ascii_str()
		l.index += 1

		if l.index >= l.file_content.len {
			break
		}
	}
	mut new_token := Token{
		token_type:  l.token.find_token(l.buffer)
		value:       l.buffer
		line_number: l.line_count
	}

	if new_token.token_type == TokenType.radon_null {
		// If the previous token was not a keyword, then it must be a variable
		if l.prev_token.token_type == TokenType.key_proc {
			new_token.token_type = TokenType.proc_name
		} else if l.prev_token.token_type == TokenType.key_mut {
			new_token.token_type = TokenType.var_name
		} else {
			new_token.token_type = TokenType.var_name
		}
	}

	l.token_manager(new_token)
	l.buffer = ''
}

fn (mut l Lexer) lex_int() {
	l.buffer += l.file_content[l.index].ascii_str()
	l.index += 1

	for l.token.is_int(l.file_content[l.index]) {
		l.buffer += l.file_content[l.index].ascii_str()
		l.index += 1

		if l.index >= l.file_content.len {
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
}

fn (mut l Lexer) lex_special() {
	// Special chars are only passed in as single characters

	if l.file_content[l.index].ascii_str() == "'" || l.file_content[l.index].ascii_str() == '"' {
		l.lex_string()
		return
	}

	new_token := Token{
		token_type:  l.token.find_token(l.file_content[l.index].ascii_str())
		value:       l.file_content[l.index].ascii_str()
		line_number: l.line_count
	}
	l.token_manager(new_token)
	l.index += 1
}

fn (mut l Lexer) lex_string() {
	string_type := l.file_content[l.index].ascii_str()
	l.index += 1
	l.buffer = ''

	// As long as we don't hit the closing quote, keep adding to the buffer
	for l.file_content[l.index].ascii_str() != string_type {
		l.buffer += l.file_content[l.index].ascii_str()
		l.index += 1

		if l.index >= l.file_content.len {
			l.throw_lex_error('String not closed')
			exit(1)
		}
	}

	new_token := Token{
		token_type:  TokenType.type_string
		value:       l.buffer
		line_number: l.line_count
	}
	l.token_manager(new_token)
	l.buffer = ''
	l.index += 1
}

fn (mut l Lexer) lex_white() {
	if l.file_content[l.index].ascii_str() == '\n' {
		l.line_count += 1
	} else if l.file_content[l.index].ascii_str() == '\r\n' {
		// Windows line ending
		l.index += 1
	}
	l.index += 1
}

fn (mut l Lexer) token_manager(new_token Token) {
	if new_token.token_type == TokenType.radon_null {
		l.throw_lex_error('Invalid token type')
		exit(1)
	}
	l.prev_token = l.token
	l.token = new_token
	l.all_tokens << new_token
}

fn (mut l Lexer) throw_lex_error(err_msg string) {
	err := term.red(err_msg)
	println('radon_lexer Error: \n\n${err} \nOn line: ${l.line_count} - Index: ${l.index} \nIn file: ${l.file_name} \nFull path: ${l.file_path}')
}
