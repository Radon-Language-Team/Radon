module token

import encoding.utf8 { is_letter }

pub enum Token {
	// keywords
	key_proc   // proc
	key_main   // main
	key_if     // if
	key_else   // else
	key_mut    // mut
	key_record // record
	key_loop   // loop
	key_ret    // return
	key_match  // match
	key_for    // for
	key_in     // in
	key_import // import
	// Types
	type_int    // int
	type_float  // float
	type_bool   // bool
	type_string // string
	// Symbols
	open_paren  // (
	close_paren // )
	open_brace  // {
	close_brace // }
	open_brack  // [
	close_brack // ]
	semicolon   // ;
	comma       // ,
	colon       // :
	dot         // .
	slash       // /
	backslash   // \
	star        // *
	plus        // +
	minus       // -
	equal       // =
	less        // <
	greater     // >
	exclamation // !
	percent     // %
	ampersand   // &
	pipe        // |
	radon_null	// Only used for the compiler
}


pub fn (mut t Token) is_alpha(letter rune) bool {
	return is_letter(letter)
}

pub fn (mut t Token) find_token(token string) Token {
	match token {
		'proc' { return Token.key_proc }
		'main' { return Token.key_main }
		'if' { return Token.key_if }
		'else' { return Token.key_else }
		'mut' { return Token.key_mut }
		'record' { return Token.key_record }
		'loop' { return Token.key_loop }
		'return' { return Token.key_ret }
		'match' { return Token.key_match }
		'for' { return Token.key_for }
		'in' { return Token.key_in }
		'import' { return Token.key_import }
		'int' { return Token.type_int }
		'float' { return Token.type_float }
		'bool' { return Token.type_bool }
		'string' { return Token.type_string }
		'(' { return Token.open_paren }
		')' { return Token.close_paren }
		'{' { return Token.open_brace }
		'}' { return Token.close_brace }
		'[' { return Token.open_brack }
		']' { return Token.close_brack }
		';' { return Token.semicolon }
		',' { return Token.comma }
		':' { return Token.colon }
		'.' { return Token.dot }
		'/' { return Token.slash }
		'\\' { return Token.backslash }
		'*' { return Token.star }
		'+' { return Token.plus }
		'-' { return Token.minus }
		'=' { return Token.equal }
		'<' { return Token.less }
		'>' { return Token.greater }
		'!' { return Token.exclamation }
		'%' { return Token.percent }
		'&' { return Token.ampersand }
		'|' { return Token.pipe }
		else { return Token.radon_null }
	}
}