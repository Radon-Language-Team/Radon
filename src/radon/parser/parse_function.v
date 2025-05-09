module parser

import cmd.util { print_compile_error }
import structs

fn parse_function(mut app structs.App) {
	mut function_decl := structs.FunctionDecl{}

	app.index++

	mut token := app.get_token()
	if token.t_type != .variable && token.t_category != .literal {
		print_compile_error('Expected function name but got ` ${token.t_value} ` with type `${token.t_type}`',
			&app)
		exit(1)
	}

	function_decl.name = token.t_value

	app.index++

	function_decl.params = parse_function_args(mut app)

	app.index++

	function_decl.return_type = parse_function_return_type(mut app)

	app.index++

	println(function_decl)
	println(app.get_token().t_value)
}

fn parse_function_args(mut app structs.App) []structs.Param {
	mut function_params := []structs.Param{}
	mut token := app.get_token()
	if token.t_type != .open_paren {
		print_compile_error('Expected ` ( ` but got ` ${token.t_value} ` with type `${token.t_type}`',
			&app)
		exit(1)
	}

	app.index++
	mut args_buffer := []structs.Token{}

	for app.get_token().t_type != .close_paren {
		if app.index >= app.all_tokens.len {
			print_compile_error('Parenthesis were not properly closed', &app)
			exit(1)
		}
		token = app.get_token()
		args_buffer << token
		app.index++
	}

	if args_buffer.len != 0 {
		for i := 0; i < args_buffer.len; i += 2 {
			if i + 1 >= args_buffer.len {
				print_compile_error('Expected a type followed by a name', &app)
				exit(1)
			}

			tok_type := args_buffer[i]
			tok_name := args_buffer[i + 1]

			if tok_type.t_type == .comma || tok_name.t_type == .comma {
				print_compile_error('Unexpected comma in parameter list', &app)
				exit(1)
			}

			// TODO: Make this a function or something
			if tok_type.t_type !in [.type_int, .type_string] {
				print_compile_error('Expected a type before the parameter name, got ` ${tok_type.t_value} `',
					&app)
				exit(1)
			}

			if tok_name.t_type != .variable {
				print_compile_error('Expected parameter name, got ` ${tok_name.t_value} `',
					&app)
				exit(1)
			}

			function_params << structs.Param{
				name:   tok_name.t_value
				p_type: tok_type.t_type
			}

			// Skip comma if any
			if i + 2 < args_buffer.len && args_buffer[i + 2].t_type == .comma {
				i++
			}
		}
	}
	return function_params
}

fn parse_function_return_type(mut app structs.App) structs.TokenType {
	token := app.get_token()

	if token.t_type == .colon {
		app.index++

		return_type := app.get_token()

		// TODO: Same as above, turn this into a function
		if return_type.t_type !in [.type_string, .type_int, .type_void] {
			print_compile_error('Expected a function return type, got ` ${return_type.t_value} `',
				&app)
			exit(1)
		}

		app.index++

		if app.get_token().t_type != .open_brace {
			print_compile_error('Expected ` { `, got ` ${token.t_value} `', &app)
			exit(1)
		}

		return return_type.t_type
	} else {
		if token.t_type != .open_brace {
			print_compile_error('Expected ` { `, got ` ${token.t_value} `', &app)
			exit(1)
		}
		return .type_void
	}
}
