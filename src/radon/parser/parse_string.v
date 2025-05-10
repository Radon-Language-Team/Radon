module parser

import cmd.util { print_compile_error }
import structs

fn parse_string(mut app structs.App) structs.String {
	mut token := app.get_token()

	if token.t_type != .d_quote && token.t_type != .s_quote {
		print_compile_error('Expected ` " ` or ` \' `, got ` ${token.t_value} `', &app)
		exit(1)
	}

	closing_string := token.t_type
	app.index++
	token = app.get_token()
	mut buffer := ''

	for app.get_token().t_type != closing_string {
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
