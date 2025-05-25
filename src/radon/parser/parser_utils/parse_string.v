module parser_utils

import cmd.util { print_compile_error }
import structs

pub fn parse_string(mut app structs.App) structs.String {
	mut token := app.get_token()

	app.index++
	token = app.get_token()
	mut buffer := ''

	for app.get_token().t_type != .s_quote {
		if app.index >= app.all_tokens.len {
			print_compile_error('String was not properly closed', &app)
			exit(1)
		}
		token = app.get_token()
		buffer += token.t_value
		app.index++
	}

	return structs.String{
		value: buffer
	}
}

pub fn parse_string_token_array(tokens []structs.Token) structs.String {
	mut i := 0
	mut buffer := ''
	mut token := tokens[i]
	i++

	token = tokens[i]

	for tokens[i].t_type != .s_quote {
		if i + 1 >= tokens.len {
			print_compile_error('String was not properly closed', structs.App{})
			exit(1)
		}

		token = tokens[i]
		buffer += token.t_value
		i++
	}

	return structs.String{
		value: buffer
	}
}
