module parser_utils

import regex
import structs

pub fn get_expression(mut app structs.App) []structs.Token {
	starting_line := app.get_token().t_line
	mut expression := []structs.Token{}
	for app.index < app.all_tokens.len {
		if app.get_token().t_line != starting_line {
			break
		}
		expression << app.get_token()
		app.index++
	}

	return expression
}

pub fn parse_expression(expression []structs.Token) structs.AstNode {
	// If the expression is a simple expression (just numbers and operators), we can just return the whole thing
	string_expression := token_array_to_string(expression)
	is_simple_int := is_simple_expr(string_expression)

	if is_simple_int {
		return structs.Expression{
			value:  string_expression
			e_type: .type_int
		}
	} else if expression[0].t_type == .s_quote {
		simple_string := is_simple_string(expression)

		return structs.Expression{
			value:  simple_string.value
			e_type: .type_string
		}
	} else {
		println('Support for these kind of these expressions is not yet built in :)')
		exit(1)
	}

	return structs.AstNode{}
}

fn token_array_to_string(tokens []structs.Token) string {
	mut token_string := ''

	for token in tokens {
		token_string += '${token.t_value}'
	}

	return token_string
}

fn is_simple_expr(expr string) bool {
	mut re := regex.regex_opt(r'^[0-9+\-*/(). \t]+$') or { panic('Invalid regex') }
	start, end := re.find(expr)
	return start == 0 && end == expr.len
}

fn is_simple_string(expr []structs.Token) structs.String {
	if expr.len == 1 {
		return structs.String{}
	}
	string_expr := parse_string_token_array(expr)

	return string_expr
}
