module parser_utils

import structs
import cmd.util { print_compile_error, radon_assert }

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

pub fn parse_expression(expression_array []structs.Token, mut app structs.App) structs.Expression {
	mut index := 0
	mut expected_operator := false
	mut last_type := structs.TokenType.radon_null
	mut expression_value := ''

	for index < expression_array.len {
		e := expression_array[index]
		next_token := expression_array[index + 1] or { structs.Token{} }

		radon_assert(next_token == structs.Token{} && index != expression_array.len - 1,
			'Unexpected end of expression', &app)

		match e.t_type {
			.literal {
				radon_assert(expected_operator, 'Unsupported expression > Stopped at: `${e.t_value}` with type `${e.t_type}`',
					&app)

				radon_assert(last_type != .type_int && index != 0, 'Can not use `${structs.TokenType.type_int}` (rigth expression) as `${last_type}`',
					&app)

				last_type = .type_int
				expression_value += e.t_value
				expected_operator = true
			}
			.type_string {
				radon_assert(expected_operator, 'Unsupported expression > Stopped at: `${e.t_value}` with type `${e.t_type}`',
					&app)

				radon_assert(last_type != .type_string && index != 0, 'Can not use `${structs.TokenType.type_string}` (rigth expression) as `${last_type}`',
					&app)

				last_type = .type_string
				expression_value += e.t_value
				expected_operator = true
			}
			.key_true, .key_false {
				radon_assert(expected_operator, 'Unsupported expression > Stopped at: `${e.t_value}` with type `${e.t_type}`',
					&app)

				radon_assert(last_type != .type_bool && index != 0, 'Can not use `${structs.TokenType.type_bool}` (rigth expression) as `${last_type}`',
					&app)

				last_type = .type_bool
				expression_value += if e.t_value == 'true' {
					'1'
				} else {
					'0'
				}
				expected_operator = true
			}
			.variable {
				radon_assert(expected_operator, 'Unsupported expression > Stopped at: `${e.t_value}` with type `${e.t_type}`',
					&app)

				variable := get_variable(&app, e.t_value)

				if variable == structs.VarDecl{} {
					print_compile_error('Variable `${e.t_value}` is not defined', &app)
					exit(1)
				}

				radon_assert(last_type != variable.variable_type.to_token_type() && index != 0,
					'Can not use `${variable.variable_type.to_token_type()}` (rigth expression) as `${last_type}`',
					&app)

				last_type = variable.variable_type.to_token_type()
				expression_value += variable.name
				expected_operator = true
			}
			.function_call {
				original_app_index := app.index
				starting_line := e.t_line
				starting_column := e.t_column

				mut token_pos := -1
				for i, tok in app.all_tokens {
					if tok.t_type == e.t_type && tok.t_value == e.t_value
						&& tok.t_line == starting_line && tok.t_column == starting_column {
						token_pos = i
						break
					}
				}

				app.index = token_pos

				parse_func_call(mut app, true)
				parsed_function := get_function(&app, e.t_value)

				radon_assert(parsed_function.return_type == .type_void, 'Function `${e.t_value}` does not return anything',
					&app)

				radon_assert(last_type != parsed_function.return_type && index != 0, 'Can not use `${parsed_function.return_type}` (rigth expression) as `${last_type}`',
					&app)

				last_type = parsed_function.return_type

				expression_value += e.t_value
				expected_operator = true
				app.index = original_app_index

				for expression_array[index].t_type != .close_paren && index < expression_array.len {
					index++
					expression_value += expression_array[index].t_value
				}
			}
			.plus, .mult {
				expression_value += e.t_value
				expected_operator = false
			}
			else {
				print_compile_error('Unkown expression `${e.t_value}` of type `${e.t_type}`',
					&app)
				exit(1)
			}
		}
		index++
	}

	expression := structs.Expression{
		value:               expression_value
		e_type:              last_type.to_var_type()
		is_variable:         false
		is_function:         false
		string_inter:        false
		string_object:       []structs.StringObject{}
		advanced_expression: structs.AstNode{}
	}
	return expression
}

pub fn get_variable(app &structs.App, variable_name string) structs.VarDecl {
	if variable_name in app.decays {
		print_compile_error('Variable `${variable_name}` has already been freed once',
			app)
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

/*
* This function parses simple boolean expressions such as:
* > Expressions of length 1 -> true, [variable], false
* > Simple expressions such as [value] > / >= / < / <= / == [value_two]
* Anything else is still to complicated to parse correctly
*/
pub fn parse_simple_boolean_expr(expression []structs.Token, mut app structs.App) structs.BoolCondition {
	operators := ['<', '>', '<=', '>=', '==', '!=']
	mut final_expr := structs.BoolCondition{}
	mut i := 0

	if expression.len == 0 {
		print_compile_error('Empty expression', &app)
		exit(1)
	}

	if expression.len == 1 {
		final_expr.is_simple = true
		final_expr.con_simple = parse_expression(expression, mut app) as structs.Expression
		return final_expr
	}

	if expression.len >= 3 && expression.len <= 4 {
		lhs := expression[i]
		i++
		mut operator := []structs.Token{}
		mut operator_str := ''
		operator << expression[i]
		operator_str += expression[i].t_value
		if i + 2 < expression.len {
			i++
			operator << expression[i]
			operator_str += expression[i].t_value
		}
		i++
		rhs := expression[i]

		radon_assert(operator_str !in operators, 'Operator `${operator_str}` not available in a boolean expression',
			&app)

		lhs_expr := parse_expression([lhs], mut app) as structs.Expression
		rhs_expr := parse_expression([rhs], mut app) as structs.Expression

		radon_assert(lhs_expr.e_type != rhs_expr.e_type, 'Can not compare `${rhs_expr.e_type}` (right expression) with `${lhs_expr.e_type}`',
			&app)

		final_expr.con_lhs = lhs_expr
		final_expr.con_rhs = rhs_expr
		final_expr.con_op = operator_str
	} else {
		print_compile_error('Boolean expression is too complex (Being worked on...)',
			&app)
		exit(1)
	}

	return final_expr
}
