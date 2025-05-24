module parser

import cmd.util { print_compile_error }
import structs

fn parse_string(mut app structs.App) structs.String {
	mut token := app.get_token()

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
