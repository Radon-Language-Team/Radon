module parser

import cmd.util { print_compile_error }
import structs

fn parse_string(mut app structs.App) structs.String {
	mut token := app.all_tokens[app.index]

	if token.t_type != .d_quote && token.t_type != .s_quote {
		print_compile_error('Expected ` " ` or ` \' ` but got ` ${token.t_value} `', &app)
		exit(1)
	}

	closing_string := token.t_type
	app.index++
	token = app.all_tokens[app.index]
	mut buffer := ''

	for token.t_type != closing_string {
		if app.index >= app.all_tokens.len {
			print_compile_error('String was not properly closed', &app)
			exit(1)
		}
		token = app.all_tokens[app.index]
		buffer += token.t_value
		app.index++
	}

	// Skip the closing string
	app.index++

	return structs.String{
		value: buffer
	}
}
