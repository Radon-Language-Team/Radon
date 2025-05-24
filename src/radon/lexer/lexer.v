module lexer

import os
import encoding.utf8 { is_letter, is_number, is_space }
import cmd.util { print_compile_error }
import structs

pub fn lex_file(mut app structs.App) ! {
	mut lexed_tokens := []structs.Token{}

	file_content := os.read_file(app.file_path)!
	app.file_content = file_content

	if app.file_content.trim_space().len == 0 {
		print_compile_error('`${app.file_path}` is empty - Nothing to do', &app)
		exit(1)
	}

	// Go over each character in the file content
	for app.index < app.file_content.len {
		if lexed_tokens.len > 0 {
			app.prev_token = lexed_tokens.last()
		}

		current_char := app.file_content[app.index].ascii_str()

		if is_letter(current_char[0]) {
			app.buffer += current_char
			app.column_count++

			if app.index < app.file_content.len && is_letter(app.file_content[app.index]) {
				app.index++
				for app.index < app.file_content.len && is_letter(app.file_content[app.index]) {
					tmp_char := app.file_content[app.index].ascii_str()
					app.buffer += tmp_char
					app.index++
					app.column_count++
				}
				// The index was already pointing at the newst non-letter token
				// Because we now advance in the loop by one, we skip the token we were just pointing at
				// So we go back by one
				app.index--
			}

			mut token_type := match_token_type(app.buffer.str())

			if lexed_tokens.len != 0 && app.index + 1 < app.file_content.len {
				if lexed_tokens.last().t_type == .key_react
					&& app.file_content[app.index + 1].ascii_str() == '(' {
					// For Function Decls -> react foo()
					token_type = .function_decl
				} else if app.file_content[app.index + 1].ascii_str() == '(' {
					// For Function Calls -> foo()
					token_type = .function_call
				}
			}

			mut token_category := match_token_category(token_type)
			mut token_var_type := structs.VarType.type_unknown

			// In case the previous token was a key_element or key_isotope
			// we know that the current token is a variable
			if (app.prev_token.t_type == .key_element || app.prev_token.t_type == .key_isotope)
				&& token_type == .variable {
				token_type = .variable
				token_category = .identifier
				token_var_type = structs.VarType.type_string // TODO: Actually find out what kind of variable this is
			}

			if token_type == .variable && token_category == .identifier
				&& token_var_type == .type_unknown {
				print_compile_error('Found an unkown token of type ${token_type}', &app)
				exit(1)
			}

			lexed_tokens << structs.Token{
				t_type:     token_type
				t_value:    app.buffer.str()
				t_line:     app.line_count
				t_column:   app.column_count
				t_length:   app.buffer.str().len
				t_filename: app.file_name
				t_category: token_category
				t_var_type: token_var_type
			}
			app.buffer = ''
		} else if is_number(current_char[0]) {
			app.buffer += current_char
			app.column_count++

			if app.index < app.file_content.len {
				app.index++
				for app.index < app.file_content.len && is_number(app.file_content[app.index]) {
					tmp_char := app.file_content[app.index].ascii_str()
					app.buffer += tmp_char
					app.index++
					app.column_count++
				}
				app.index--
			}

			token_type := match_token_type(app.buffer.str())
			token_category := match_token_category(token_type)

			if token_type == .radon_null {
				print_compile_error('Unknown token: `${app.buffer.str()}` >> `t_type: ${token_type}` and `t_category: ${token_category}`',
					&app)
				exit(1)
			}

			lexed_tokens << structs.Token{
				t_type:     token_type
				t_value:    app.buffer.str()
				t_line:     app.line_count
				t_column:   app.column_count
				t_length:   app.buffer.str().len
				t_filename: app.file_name
				t_category: token_category
				t_var_type: .type_int // We only support normal ints for now anyway
				// TODO: Add support for other types such as floats
			}
			app.buffer = ''
		} else if is_space(current_char[0]) {
			if current_char == '\n' || current_char == '\r\n' {
				app.line_count++
				app.column_count = 1
			} else {
				app.column_count++
			}
		} else {
			// Special characters
			token_type := match_token_type(current_char)

			if token_type == .radon_null {
				print_compile_error('Unkown token `${current_char}`', &app)
				exit(1)
			}

			token_category := match_token_category(token_type)
			lexed_tokens << structs.Token{
				t_type:     token_type
				t_value:    current_char
				t_line:     app.line_count
				t_column:   app.column_count
				t_length:   current_char.len // Should be 1 in all cases, right?
				t_filename: app.file_name
				t_category: token_category
				t_var_type: .type_unknown
			}

			app.column_count++
		}

		app.index++
	}

	app.all_tokens = lexed_tokens
}
