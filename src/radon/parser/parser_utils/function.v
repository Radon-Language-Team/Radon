module parser_utils

import ast
import cmd.util { print_compile_error, print_warning }

const core_functions = ['println', '@read', 'staticRead', '@clone', 'toInt']

fn get_core_function(name string) ast.FunctionDecl {
	match name {
		'println' {
			return ast.FunctionDecl{
				name:        name
				params:      [
					ast.Param{
						name:   'x'
						p_type: .type_string
					},
				]
				return_type: .type_void
				body:        []ast.AstNode{}
				is_core:     true
			}
		}
		'@read' {
			return ast.FunctionDecl{
				name:        name
				params:      [
					ast.Param{
						name:   'message'
						p_type: .type_string
					},
				]
				return_type: .type_string
				body:        []ast.AstNode{}
				is_core:     true
				does_malloc: true
			}
		}
		'staticRead' {
			return ast.FunctionDecl{
				name:        name
				params:      [
					ast.Param{
						name:   'message'
						p_type: .type_string
					},
				]
				return_type: .type_string
				body:        []ast.AstNode{}
				is_core:     true
			}
		}
		'@clone' {
			return ast.FunctionDecl{
				name:        name
				params:      [
					ast.Param{
						name:   'input'
						p_type: .type_string
					},
				]
				return_type: .type_string
				body:        []ast.AstNode{}
				is_core:     true
				does_malloc: true
			}
		}
		'toInt' {
			return ast.FunctionDecl{
				name:        name
				params:      [
					ast.Param{
						name:   'string'
						p_type: .type_string
					},
				]
				return_type: .type_int
				body:        []ast.AstNode{}
				is_core:     true
			}
		}
		else {
			return ast.FunctionDecl{}
		}
	}
}

pub fn get_function(app &ast.App, name string) ast.FunctionDecl {
	function := app.all_functions.filter(it.name == name)

	if function.len == 0 {
		if name in core_functions {
			return get_core_function(name)
		}
		return ast.FunctionDecl{}
	} else {
		return function[0]
	}
}

pub fn parse_func_call(mut app ast.App, inside_variable bool) ast.Call {
	mut call := ast.Call{}

	callee_name := app.get_token().t_value
	call.callee = callee_name

	app.index++

	// We already know the next toke is `(` since we are parsing a function call right now
	app.index++
	callee_function := get_function(&app, callee_name)

	if callee_function == ast.FunctionDecl{} {
		print_compile_error('Unknown function `${callee_name}`', &app)
		exit(1)
	}

	if callee_function.is_core {
		if 'core' !in app.imports {
			print_compile_error('Function `${callee_name}` needs to be imported. Use ` mixture \'core\' ` to import all core functions',
				&app)
			exit(1)
		}
	}

	mut buffer := []ast.Token{}

	for app.get_token().t_type != .close_paren {
		if app.index >= app.all_tokens.len {
			print_compile_error('Function call was not properly closed', &app)
			exit(1)
		}
		token := app.get_token()
		buffer << token
		app.index++
	}

	for i := 0; i < buffer.len; i++ {
		// Values must be at even indices: 0, 2, 4, ...
		if i % 2 == 1 {
			if buffer[i].t_type != .comma {
				print_compile_error('Expected comma between arguments, got `${buffer[i].t_value}`',
					&app)
				exit(1)
			}
		} else {
			if buffer[i].t_type !in [.literal, .variable, .type_string, .key_true, .key_false] {
				if buffer[i].t_category == .operator {
					i++
					continue
				}
				print_compile_error('Invalid value in argument list: `${buffer[i].t_value}`',
					&app)
				exit(1)
			}
		}
	}

	// We ignore all the commas and operators
	final_arg_list := buffer.filter(it.t_type != .comma)

	if callee_function.params.len != final_arg_list.filter(it.t_category != .operator).len {
		print_compile_error('Argument count mismatch: Function `${callee_function.name}` expects ${callee_function.params.len} argument(s), but ${final_arg_list.len} were provided',
			&app)
		exit(1)
	}

	if callee_function.params.len == 1 {
		parsed_arg := parse_expression(final_arg_list, mut &app) as ast.Expression
		parsed_arg_type := parsed_arg.e_type.to_token_type()
		callee_arg := callee_function.params[0]

		if parsed_arg_type != callee_arg.p_type && callee_name != 'println' {
			print_compile_error('Argument type mismatch in function `${callee_function.name}`: Parameter `${callee_arg.name}` expects `${callee_arg.p_type}`, but got `${parsed_arg_type}`',
				&app)
			exit(1)
		}

		if callee_arg.is_mut && parsed_arg.is_variable {
			var := get_variable(&app, parsed_arg.value)

			if !var.is_mut {
				print_warning('Immutable variable `${var.name}` copied when passed to mutable parameter `${callee_arg.name}`',
					&app)
				println('Note: Consider making `${var.name}` mutable via `iso ${var.name}`')
			}
		}

		call.args << parsed_arg
	} else if callee_function.params.len > 1 {
		mut op_buffer := []ast.Token{}
		c := callee_function.params.len + final_arg_list.filter(it.t_category == .operator).len
		for i, arg in final_arg_list {
			if arg.t_category == .operator {
				op_buffer << arg
			} else {
				if i == c {
					break
				}
				mut expression_buffer := []ast.Token{}
				if op_buffer.len != 0 {
					expression_buffer << op_buffer
				}
				expression_buffer << arg

				parsed_arg := parse_expression(expression_buffer, mut &app) as ast.Expression
				parsed_arg_type := parsed_arg.e_type.to_token_type()
				callee_arg := callee_function.params[i - op_buffer.len]

				if parsed_arg_type != callee_arg.p_type {
					print_compile_error('Argument type mismatch in function `${callee_function.name}`: Parameter `${callee_arg.name}` expects `${callee_arg.p_type}`, but got `${parsed_arg_type}`',
						&app)
					exit(1)
				}

				if callee_arg.is_mut && parsed_arg.is_variable {
					var := get_variable(&app, parsed_arg.value)

					if !var.is_mut {
						print_warning('Immutable variable `${var.name}` copied when passed to mutable parameter `${callee_arg.name}`',
							&app)
						println('Note: Consider making `${var.name}` mutable via `iso ${var.name}`')
					}
				}
				call.args << parsed_arg
				op_buffer.clear()
			}
		}
	}

	if callee_name == 'println' {
		println_argument := call.args[0] as ast.Expression

		if println_argument.e_type == .type_string {
			call.callee = 'println_str'
		} else if println_argument.e_type == .type_int {
			call.callee = 'println_int'
		} else if println_argument.e_type == .type_bool {
			call.callee = 'println_bool'
		} else {
			print_compile_error('Function `println` does not support an argument of type `${println_argument.e_type}` yet',
				&app)
			exit(1)
		}
	}

	// We are about to assign a function which allocates memory to no variable -> Nothing to free
	if callee_function.does_malloc && !inside_variable {
		print_compile_error('Cannnot call `${callee_name}` without assigning the result \n> Function returns heap memory — assign it and decay it later',
			&app)
		exit(1)
	}

	app.index++ // Consume the remaining `)`
	return call
}

pub fn parse_decay(mut app ast.App) ast.DecayStmt {
	mut decay := ast.DecayStmt{}

	app.index++
	token := app.get_token()

	// TODO: This will bite me later
	if token.t_type != .variable {
		print_compile_error('Can only manually free variables, got `${token.t_type}` with value `${token.t_value}`',
			&app)
		exit(1)
	}

	expression := get_expression(mut app)
	parsed_expression := parse_expression(expression, mut app) as ast.Expression

	if parsed_expression.e_type != .type_string {
		print_compile_error('Can only free variables of type `string`, got `${parsed_expression.e_type}` with value `${parsed_expression.value}`',
			&app)
		exit(1)
	}

	variable := get_variable(app, parsed_expression.value).value as ast.Expression

	if !variable.is_function {
		print_compile_error('Variable `${parsed_expression.value}` does not represent a heap-allocated function result',
			&app)
		exit(1)
	} else {
		function_to_free := variable.advanced_expression as ast.Call
		function_header := get_function(&app, function_to_free.callee)

		if !function_header.does_malloc {
			print_compile_error('Function `${function_to_free.callee}` does not allocate memory — nothing to free',
				&app)
			exit(1)
		}
	}

	decay.name = parsed_expression.value
	app.decays << parsed_expression.value
	return decay
}
