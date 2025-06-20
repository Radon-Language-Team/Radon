module parser_utils

import regex
import structs
import cmd.util { print_compile_error }

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

pub fn parse_expression(expression []structs.Token, mut app structs.App) structs.AstNode {
	// If the expression is a simple expression (just numbers and operators), we can just return the whole thing
	string_expression := token_array_to_string(expression)
	is_simple_int := is_simple_expr(string_expression)

	if is_simple_int {
		return structs.Expression{
			value:  string_expression
			e_type: .type_int
		}
	} else if expression[0].t_type == .key_true || expression[0].t_type == .key_false {
		return structs.Expression{
			value:  expression[0].t_value
			e_type: .type_bool
		}
	} else if expression[0].t_type == .type_string {
		return structs.Expression{
			value:  expression[0].t_value
			e_type: .type_string
		}
	} else if expression[0].t_type == .variable {
		variable := get_variable(app, expression[0].t_value)

		if variable == structs.VarDecl{} {
			print_compile_error('Variable `${expression[0].t_value}` is not defined',
				&app)
			exit(1)
		}

		return structs.Expression{
			value:       expression[0].t_value
			e_type:      variable.variable_type
			is_variable: true
		}
	} else if expression[0].t_type == .function_call {
		// function_call := parse_func_call(mut app)
		// println(function_call)
		starting_token := expression[0]

		// We get the line and the column of the expression, so we know which expression to later jump back to
		// If, for example, we use the same function twice, without line/column the compiler will get stuck on the first usage of that function
		starting_token_line := starting_token.t_line
		starting_token_column := starting_token.t_column

		mut token_pos := -1
		for i, tok in app.all_tokens {
			if tok.t_type == starting_token.t_type && tok.t_value == starting_token.t_value
				&& tok.t_line == starting_token_line && tok.t_column == starting_token_column {
				token_pos = i
				break
			}
		}
		app.index = token_pos
		// We are parsing the function call, so our index sits at the right position
		function_call := parse_func_call(mut app, true)

		function := get_function(&app, starting_token.t_value)

		if function.return_type == .type_void {
			print_compile_error('Function `${starting_token.t_value}` does not return anything',
				&app)
			exit(1)
		}

		return structs.Expression{
			value:               ''
			e_type:              structs.token_type_to_var_type(function.return_type)
			is_function:         true
			advanced_expression: function_call
		}
	}

	return structs.AstNode{}
}

pub fn token_array_to_string(tokens []structs.Token) string {
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

pub fn get_variable(app structs.App, variable_name string) structs.VarDecl {
	if variable_name in app.decays {
		print_compile_error('Variable `${variable_name}` has already been freed once',
			&app)
		exit(1)
	}
	variables := app.all_variables.filter(it.name == variable_name)

	if variables.len == 0 {
		return structs.VarDecl{}
	} else {
		for variable in variables {
			if variable.function_name == '' {
				// Top level const's have no function name, are being defined earlier and therefor should be returned first
				return variable
			}
		}
		return variables[0]
	}
}
