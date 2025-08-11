module lexer

import structs { TokenType }
import encoding.utf8 { is_letter, is_number }

fn match_token_type(token string) TokenType {
	match token {
		'mixture' {
			return .key_mixture
		}
		'react' {
			return .key_react
		}
		'elem' {
			return .key_element
		}
		'iso' {
			return .key_isotope
		}
		'decay' {
			return .key_decay
		}
		'if' {
			return .key_if
		}
		'else' {
			return .key_else
		}
		'true' {
			return .key_true
		}
		'false' {
			return .key_false
		}
		'emit' {
			return .key_emit
		}
		':' {
			return .colon
		}
		',' {
			return .comma
		}
		'.' {
			return .dot
		}
		'!' {
			return .exclamation
		}
		'{' {
			return .open_brace
		}
		'}' {
			return .close_brace
		}
		'(' {
			return .open_paren
		}
		')' {
			return .close_paren
		}
		'int' {
			return .type_int
		}
		'@int' {
			return .type_int
		}
		'string' {
			return .type_string
		}
		'@string' {
			return .type_string
		}
		'void' {
			return .type_void
		}
		'bool' {
			return .type_bool
		}
		'@bool' {
			return .type_bool
		}
		'+' {
			return .plus
		}
		'-' {
			return .minus
		}
		'*' {
			return .mult
		}
		'/' {
			return .div
		}
		'>' {
			return .greater
		}
		'<' {
			return .smaller
		}
		'=' {
			return .equals
		}
		"'" {
			return .s_quote
		}
		'@' {
			return .at
		}
		else {
			if is_letter(token[0]) {
				return .variable
			} else if is_number(token[0]) {
				return .literal
			} else {
				return .radon_null
			}
		}
	}
}

fn match_token_category(token_type TokenType) structs.TokenCategory {
	match token_type {
		.key_mixture, .key_react, .key_if, .key_else, .key_emit, .key_element, .key_isotope,
		.key_decay, .key_true, .key_false {
			return .keyword
		}
		.plus, .minus, .mult, .div, .greater, .smaller {
			return .operator
		}
		.variable, .literal {
			return .literal
		}
		.type_int, .type_string, .type_void, .type_bool {
			return .token_type
		}
		else {
			return .unknown
		}
	}
}
