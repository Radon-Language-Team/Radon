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
		'element' {
			return .key_element
		}
		'isotope' {
			return .key_isotope
		}
		'if' {
			return .key_if
		}
		'else' {
			return .key_else
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
		'string' {
			return .type_string
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
		'=' {
			return .equals
		}
		'"' {
			return .d_quote
		}
		"'" {
			return .s_quote
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
		.key_mixture, .key_react, .key_if, .key_else, .key_emit, .key_element, .key_isotope {
			return .keyword
		}
		.plus, .minus, .mult, .div {
			return .operator
		}
		.variable, .literal {
			return .literal
		}
		.type_int, .type_string, .type_void {
			return .token_type
		}
		else {
			return .unknown
		}
	}
}
