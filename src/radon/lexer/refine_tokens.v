module lexer

import cmd.util { print_compile_error }
import structs

pub fn refine_tokens(mut app structs.App) {
	mut buffer := ''

	for token in app.all_tokens {
		if token.t_type == .s_quote {
			starting_index := app.index
			app.index++

			for app.get_token().t_type != .s_quote {
				if app.index + 1 >= app.all_tokens.len {
					print_compile_error('String was not properly closed', &app)
					exit(1)
				}
				buffer += app.get_token().t_value
				app.index++
			}

			string_token := structs.Token{
				t_type:     .type_string
				t_value:    buffer
				t_line:     token.t_line
				t_column:   token.t_column
				t_length:   token.t_length
				t_filename: app.file_name
				t_category: .literal
				t_var_type: .type_string
			}

			app.index++
			left_side := app.all_tokens[0..starting_index]
			right_side := app.all_tokens[starting_index + (app.index - starting_index)..app.all_tokens.len]

			mut new_tokens := left_side.clone()
			new_tokens << string_token
			new_tokens << right_side
			app.all_tokens = new_tokens
			buffer = ''
		}

		if app.index >= app.all_tokens.len {
			return
		}
		app.index++
	}
}
