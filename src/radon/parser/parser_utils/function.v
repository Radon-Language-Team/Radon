module parser_utils

import structs
import cmd.util { print_compile_error }

const core_functions = ['println', 'read']

fn get_core_function(name string) structs.FunctionDecl {
	if name == 'println' {
		return structs.FunctionDecl{
			name:        name
			params:      [
				structs.Param{
					name:   'x'
					p_type: .type_string
				},
			]
			return_type: .type_void
			body:        []structs.AstNode{}
			is_core:     true
		}
	} else if name == 'read' {
		return structs.FunctionDecl{
			name:        name
			params:      [
				structs.Param{
					name:   'message'
					p_type: .type_string
				},
			]
			return_type: .type_string
			body:        []structs.AstNode{}
			is_core:     true
			does_malloc: false
		}
	} else {
		return structs.FunctionDecl{}
	}
}

pub fn get_function(app &structs.App, name string) structs.FunctionDecl {
	function := app.all_functions.filter(it.name == name)

	if function.len == 0 {
		if name in core_functions {
			return get_core_function(name)
		}
		return structs.FunctionDecl{}
	} else {
		return function[0]
	}
}

pub fn parse_func_call(mut app structs.App, inside_variable bool) structs.Call {
	mut call := structs.Call{}

	callee_name := app.get_token().t_value
	call.callee = callee_name

	app.index++
	// We already know the next toke is `(` since we are parsing a function call right now
	app.index++
	callee_function := get_function(&app, callee_name)

	if callee_function == structs.FunctionDecl{} {
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

	mut buffer := []structs.Token{}

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
			if buffer[i].t_type !in [.literal, .variable, .type_string] {
				print_compile_error('Invalid value in argument list: `${buffer[i].t_value}`',
					&app)
				exit(1)
			}
		}
	}

	final_arg_list := buffer.filter(it.t_type != .comma)

	if callee_function.params.len != final_arg_list.len {
		print_compile_error('Argument count mismatch: Function `${callee_function.name}` expects ${callee_function.params.len} argument(s), but ${final_arg_list.len} were provided',
			&app)
		exit(1)
	}

	for i, arg in final_arg_list {
		if i >= callee_function.params.len {
			panic('Compiler panic: Argument index out of bounds')
			unsafe {
				free(app)
			}
		}
		callee_arg := callee_function.params[i]
		arg_expression := parse_expression([arg], mut app) as structs.Expression
		arg_type := structs.var_type_to_token_type(arg_expression.e_type)

		if arg_type != callee_arg.p_type && callee_name != 'println' {
			print_compile_error('Argument type mismatch in function `${callee_function.name}`: Parameter `${callee_arg.name}` expects `${callee_arg.p_type}`, but got `${arg_type}`',
				&app)
			exit(1)
		}

		call.args << arg_expression
	}

	if callee_name == 'println' {
		println_argument := call.args[0] as structs.Expression

		if println_argument.e_type == .type_string {
			call.callee = 'println_str'
		} else if println_argument.e_type == .type_int {
			call.callee = 'println_int'
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

pub fn parse_decay(mut app structs.App) structs.DecayStmt {
	mut decay := structs.DecayStmt{}

	app.index++
	token := app.get_token()

	// TODO: This will bite me later
	if token.t_type != .variable {
		print_compile_error('Can only manually free variables, got `${token.t_type}` with value `${token.t_value}`',
			&app)
		exit(1)
	}

	expression := get_expression(mut app)
	parsed_expression := parse_expression(expression, mut app) as structs.Expression

	if parsed_expression.e_type != .type_string {
		print_compile_error('Can only free variables of type `string`, got `${parsed_expression.e_type}` with value `${parsed_expression.value}`',
			&app)
		exit(1)
	}

	variable := get_variable(app, parsed_expression.value).value as structs.Expression

	if !variable.is_function {
		print_compile_error('Variable `${parsed_expression.value}` does not represent a heap-allocated function result',
			&app)
		exit(1)
	} else {
		function_to_free := variable.advanced_expression as structs.Call
		function_header := get_function(&app, function_to_free.callee)

		if !function_header.does_malloc {
			print_compile_error('Function `${function_to_free.callee}` does not allocate memory — nothing to free',
				&app)
			exit(1)
		}
	}

	decay.name = parsed_expression.value
	return decay
}
