module parser

import structs
import parser_utils
import cmd.util { print_compile_error }

fn parse_func_call(mut app structs.App) structs.Call {
	mut call := structs.Call{}

	callee_name := app.get_token().t_value
	call.callee = callee_name

	app.index++
	// We already know the next toke is `(` since we are parsing a function call right now
	app.index++
	callee_function := parser_utils.get_function(callee_name, &app)

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
		arg_expression := parser_utils.parse_expression([arg]) as structs.Expression
		arg_type := structs.var_type_to_token_type(arg_expression.e_type)

		if arg_type != callee_arg.p_type {
			print_compile_error('Argument type mismatch in function `${callee_function.name}`: Parameter `${callee_arg.name}` expects `${callee_arg.p_type}`, but got `${arg_type}`',
				&app)
			exit(1)
		}

		call.args << arg_expression
	}

	app.index++ // Consume the remaining `)`
	return call
}
