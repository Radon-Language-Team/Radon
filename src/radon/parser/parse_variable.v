module parser

import cmd.util { print_compile_error }
import parser_utils
import ast

fn parse_variable(mut app ast.App) ast.AstNode {
	mut variable_decl := ast.VarDecl{}
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
	parsed_expression := parser_utils.parse_expression(expression, mut app) as ast.Expression

	// println('Very old: ${parsed_expression}')

	variable_decl.function_name = app.current_parsing_function
	variable_decl.variable_type = parsed_expression.e_type
	variable_decl.value = parsed_expression

	if variable_decl.function_name == '' {
		variable_decl.is_top_const = true
	}

	variable_look_up := parser_utils.get_variable(&app, variable_decl.name)

	if variable_look_up != ast.VarDecl{} {
		// This variable has already been created
		print_compile_error('Variable `${variable_decl.name}` has already been created',
			&app)
		exit(1)
	}

	if parsed_expression.is_function {
		advanced_expression := parsed_expression.advanced_expression
		match advanced_expression.type_name() {
			'radon.ast.Call' {
				expression_as_call := advanced_expression as ast.Call
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

fn parse_redefinition_var(mut app ast.App) ast.AstNode {
	mut variable_decl := ast.VarDecl{}
	mut token := app.get_token()
	var_name := token.t_value
	possible_variable := parser_utils.get_variable(&app, var_name)

	if possible_variable == ast.VarDecl{} {
		// The variable has not yet been created
		print_compile_error('Variable `${var_name}` is not defined', &app)
		exit(1)
	}

	if !possible_variable.is_mut {
		print_compile_error('Variable `${var_name}` is not mutable > Use `iso ${var_name}` instead',
			&app)
		exit(1)
	}

	app.index++
	token = app.get_token()
	if token.t_type != .equals {
		if token.t_type.is_op() {
			return parse_aug_assign(mut app)
		}
		print_compile_error('Expected `=`, got token of type `${token.t_type}` and value `${token.t_value}`',
			&app)
		exit(1)
	}

	app.index++

	expression := parser_utils.get_expression(mut app)
	parsed_expression := parser_utils.parse_expression(expression, mut app) as ast.Expression

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

fn parse_aug_assign(mut app ast.App) ast.AugAssign {
	mut aug_assign := ast.AugAssign{}
	app.index--

	mut token := app.get_token()
	var_name := token.t_value
	variable := parser_utils.get_variable(&app, var_name)
	aug_assign.target = variable

	app.index++
	operator := app.get_token()
	app.index++
	second_operator := app.get_token()

	possible_ops := ['++', '--', '+=', '-=', '*=']

	// Augmented assignments are only possible on strings or numeric values
	if variable.variable_type != .type_int && variable.variable_type != .type_string {
		print_compile_error('Augmented assignments can only be used on numeric values or strings > Got `${variable.variable_type}`',
			&app)
		exit(1)
	}

	if '${operator.t_value}${second_operator.t_value}' !in possible_ops {
		print_compile_error('Unknown operator `${operator.t_value}${second_operator.t_value}`',
			&app)
		exit(1)
	}

	// ++ / -- > Can only be used on numeric values
	if operator.t_type == second_operator.t_type && variable.variable_type != .type_int {
		print_compile_error('Operator `${operator.t_value}${second_operator}` can only be used on numeric values > Got `${variable.variable_type}`',
			&app)
		exit(1)
	}

	aug_assign.op = '${operator.t_value}${second_operator.t_value}'

	if operator.t_type == second_operator.t_type {
		aug_assign.value = ast.Expression{
			value:               '1'
			e_type:              .type_int
			advanced_expression: ast.AstNode{}
		}

		app.index++
		return aug_assign
	}

	app.index++
	expression := parser_utils.get_expression(mut &app)
	parsed_expression := parser_utils.parse_expression(expression, mut &app)

	aug_assign.value = parsed_expression
	return aug_assign
}
