module token

import term
import regex
import encoding.utf8 { is_letter, is_number, is_space }

pub enum TokenType {
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
	type_void   // void
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
	var_name    // reserved for variables
	proc_name   // reserved for proc names
	proc_call   // reserved for proc calls
	radon_null  // Only used for the compiler

	// replacement tokens
	function_return // ->
	var_assign      // :=
	equal_equal     // ==
	array_full      // []
}

pub struct Token {
pub mut:
	token_type  TokenType
	value       string
	line_number int
}

pub fn (mut t Token) is_alpha(letter rune) bool {
	return is_letter(letter)
}

pub fn (mut t Token) is_int(letter rune) bool {
	return is_number(letter)
}

pub fn (mut t Token) is_white(letter rune) bool {
	return is_space(letter)
}

pub fn (mut t Token) is_special(letter rune) bool {
	mut special_regex := regex.regex_opt('[!@#$%^&*()_+-{}|.:="\'<>?]') or {
		println('radon_token Error: Failed to create special_chars regex')
		exit(1)
	}
	res, res_two := special_regex.find(letter.str())

	if res == 0 || res_two == 0 {
		return true
	} else {
		return false
	}
}

pub fn find_token(token_to_find string) TokenType {
	match token_to_find {
		'proc' { return TokenType.key_proc }
		'main' { return TokenType.key_main }
		'if' { return TokenType.key_if }
		'else' { return TokenType.key_else }
		'mut' { return TokenType.key_mut }
		'record' { return TokenType.key_record }
		'loop' { return TokenType.key_loop }
		'return' { return TokenType.key_ret }
		'match' { return TokenType.key_match }
		'for' { return TokenType.key_for }
		'in' { return TokenType.key_in }
		'import' { return TokenType.key_import }
		'int' { return TokenType.type_int }
		'float' { return TokenType.type_float }
		'bool' { return TokenType.type_bool }
		'string' { return TokenType.type_string }
		'void' { return TokenType.type_void }
		'(' { return TokenType.open_paren }
		')' { return TokenType.close_paren }
		'{' { return TokenType.open_brace }
		'}' { return TokenType.close_brace }
		'[' { return TokenType.open_brack }
		']' { return TokenType.close_brack }
		';' { return TokenType.semicolon }
		',' { return TokenType.comma }
		':' { return TokenType.colon }
		'.' { return TokenType.dot }
		'/' { return TokenType.slash }
		'\\' { return TokenType.backslash }
		'*' { return TokenType.star }
		'+' { return TokenType.plus }
		'-' { return TokenType.minus }
		'=' { return TokenType.equal }
		'<' { return TokenType.less }
		'>' { return TokenType.greater }
		'!' { return TokenType.exclamation }
		'%' { return TokenType.percent }
		'&' { return TokenType.ampersand }
		'|' { return TokenType.pipe }
		'variable' { return TokenType.var_name }
		else { return TokenType.radon_null }
	}
}

// This function is used to remove an abitrary amount of tokens from a list of tokens
// and replace them with a new token
pub fn remove_token_and_replace(tokens []Token, token_index int, replacement_token Token, skip_amount int) ![]Token {
	if skip_amount >= tokens.len || token_index >= tokens.len || token_index < 0 {
		println(term.yellow('radon_opt warning: Skipped opt due to multiple reasons'))
		return tokens
	}

	// Capture the tokens to the left and right of the section to be replaced
	left_side := tokens[0..token_index]
	right_side := tokens[token_index + skip_amount..tokens.len]

	mut new_tokens := left_side.clone()
	new_tokens << replacement_token

	new_tokens << right_side

	return new_tokens
}

// Replaces two tokens with a new token
// Only possible for some token combinations
pub fn find_replacement_token_type(token_str_one string, token_str_two string) TokenType {
	combo := [token_str_one, token_str_two]

	match combo {
		['-', '>'] { return TokenType.function_return }
		[':', '='] { return TokenType.var_assign }
		['=', '='] { return TokenType.equal_equal }
		['[', ']'] { return TokenType.array_full }
		else { return TokenType.radon_null }
	}
}

// Checks if a token is a token type and also if the token value
// is a valid type name
pub fn check_if_token_is_type(token Token) bool {
	result := match token.token_type {
		.type_int { true }
		.type_float { true }
		.type_bool { true }
		.type_string { true }
		.type_void { true }
		else { false }
	}

	name_result := match token.value {
		'int' { true }
		'float' { true }
		'bool' { true }
		'string' { true }
		'void' { true }
		else { false }
	}

	if result && name_result {
		return true
	} else {
		return false
	}
}

pub fn convert_radon_to_c_type(token_type TokenType) string {
	result := match token_type {
		.type_int { 'int' }
		.type_float { 'float' }
		.type_bool { 'bool' }
		.type_string { 'char*' }
		else { 'void' }
	}
	return result
}

pub fn convert_radon_arg_to_c_type(arg_type string) string {
	result := match arg_type {
		'int' { 'int' }
		'float' { 'float' }
		'bool' { 'bool' }
		'string' { 'char*' }
		else { 'void' }
	}
	return result
}
