module parser

import cmd.util { print_compile_error }
import parser_utils
import structs

fn parse_variable(mut app structs.App) structs.VarDecl {
	mut variable_decl := structs.VarDecl{}
	mut token := app.get_token()

	if token.t_type == .variable {
		return parse_redefinition_var(mut app)
	}

	// We can be sure we either have an `element` or an `isotope`
	if token.t_type == .key_isotope {
		variable_decl.is_mut = true
	}

	app.index++

	token = app.get_token()
	if token.t_type != .variable {
		print_compile_error('Expected variable name, got token of type ` ${token.t_type} ` and value ` ${token.t_value} `',
			&app)
		exit(1)
	}

	variable_decl.name = token.t_value

	app.index++

	token = app.get_token()
	if token.t_type != .equals {
		print_compile_error('Expected ` = `, got token of type ` ${token.t_type} ` and value ` ${token.t_value} `',
			&app)
		exit(1)
	}

	app.index++

	expression := parser_utils.get_expression(mut app)
	parsed_expression := parser_utils.parse_expression(expression, mut app) as structs.Expression

	variable_decl.function_name = app.current_parsing_function
	variable_decl.variable_type = parsed_expression.e_type
	variable_decl.value = parsed_expression

	if variable_decl.function_name == '' {
		variable_decl.is_top_const = true
	}

	variable_look_up := parser_utils.get_variable(&app, variable_decl.name)

	if variable_look_up != structs.VarDecl{} {
		// This variable has already been created
		print_compile_error('Variable `${variable_decl.name}` has already been created',
			&app)
		exit(1)
	}

	if parsed_expression.is_function {
		advanced_expression := parsed_expression.advanced_expression
		match advanced_expression.type_name() {
			'radon.structs.Call' {
				expression_as_call := advanced_expression as structs.Call
				if expression_as_call.callee.contains('@') {
					if variable_decl.is_top_const {
						print_compile_error('Can not use function `${expression_as_call.callee}` on top-level expression',
							&app)
						exit(1)
					}

					app.all_allocations << variable_decl.name
				}
			}
			else {
				none
			}
		}
	}

	app.all_variables << variable_decl
	return variable_decl
}

fn parse_redefinition_var(mut app structs.App) structs.VarDecl {
	mut variable_decl := structs.VarDecl{}
	mut token := app.get_token()
	var_name := token.t_value
	possible_variable := parser_utils.get_variable(&app, var_name)

	if possible_variable == structs.VarDecl{} {
		// The variable has not yet been created
		print_compile_error('Variable `${var_name}` is not defined', &app)
		exit(1)
	}

	if !possible_variable.is_mut {
		print_compile_error('Variable `${var_name}` is not mutable > Use `isotope ${var_name} = ...` instead',
			&app)
		exit(1)
	}

	app.index++
	token = app.get_token()
	if token.t_type != .equals {
		print_compile_error('Expected `=`, got token of type `${token.t_type}` and value `${token.t_value}`',
			&app)
		exit(1)
	}

	app.index++

	expression := parser_utils.get_expression(mut app)
	parsed_expression := parser_utils.parse_expression(expression, mut app) as structs.Expression

	if parsed_expression.e_type != possible_variable.variable_type {
		print_compile_error('Can not assign `${parsed_expression.e_type}` to variable `${var_name}` (${possible_variable.variable_type})',
			&app)
		exit(1)
	}

	variable_decl.name = var_name
	variable_decl.function_name = app.current_parsing_function
	variable_decl.variable_type = parsed_expression.e_type
	variable_decl.value = parsed_expression
	variable_decl.is_redi = true
	variable_decl.is_mut = true
	app.all_variables << variable_decl
	return variable_decl
}
