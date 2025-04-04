module lexer

import os
import encoding.utf8 { is_letter, is_number, is_space }
import cmd.util { print_compile_error }
import structs

pub fn lex_file(mut app structs.App) ![]structs.Token {
	mut lexed_tokens := []structs.Token{}

	file_content := os.read_file(app.file_path)!
	app.file_content = file_content

	if app.file_content.trim_space().len == 0 {
		print_compile_error('`${app.file_path}` is empty - Nothing to do', &app)
		exit(1)
	}

	// Go over each character in the file content
	for app.index < app.file_content.len {
		if app.all_tokens.len > 0 {
			app.prev_token = app.all_tokens.last()
		}

		current_char := app.file_content[app.index].ascii_str()

		if is_letter(current_char[0]) || is_number(current_char[0]) {
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
			}

			mut token_type := match_token_type(app.buffer.str())
			mut token_category := match_token_category(token_type)

			// In case the previous token was a key_element or key_isotope
			// we know that the current token is a variable
			if (app.prev_token.t_type == .key_element || app.prev_token.t_type == .key_isotope)
				&& token_type == .variable {
				token_type = .variable
				token_category = .identifier
			}

			if token_type == .radon_null || token_category == .unknown {
				print_compile_error('Unknown token: `${app.buffer.str()}` >> `t_type: ${token_type}` and `t_category: ${token_category}`',
					&app)
				exit(1)
			}

			app.all_tokens << structs.Token{
				t_type:     token_type
				t_value:    app.buffer.str()
				t_line:     app.line_count
				t_column:   app.column_count
				t_length:   app.buffer.str().len
				t_filename: app.file_name
				t_category: token_category
			}
			app.buffer = '' // Clear the buffer
		} else if is_number(current_char[0]) {
			app.buffer += current_char
			app.column_count++

			if app.index < app.file_content.len && is_number(app.file_content[app.index]) {
				app.index++
				for app.index < app.file_content.len && is_number(app.file_content[app.index]) {
					tmp_char := app.file_content[app.index].ascii_str()
					app.buffer += tmp_char
					app.index++
					app.column_count++
				}
			}

			mut token_type := match_token_type(app.buffer.str())
			mut token_category := match_token_category(token_type)

			if token_type == .radon_null || token_category == .unknown {
				print_compile_error('Unknown token: `${app.buffer.str()}` >> `t_type: ${token_type}` and `t_category: ${token_category}`',
					&app)
				exit(1)
			}

			app.all_tokens << structs.Token{
				t_type:     token_type
				t_value:    app.buffer.str()
				t_line:     app.line_count
				t_column:   app.column_count
				t_length:   app.buffer.str().len
				t_filename: app.file_name
				t_category: token_category
			}
			app.buffer = ''
		} else if is_space(current_char[0]) {
			// We check for both unix and windows line endings
			if current_char == '\n' || current_char == '\r\n' {
				app.line_count++
				app.column_count = 1
			} else {
				println('Called with prev token: ${app.prev_token.t_value}')
				app.column_count++
			}
			app.index++
			continue
		} else {
			print_compile_error('Unknown token: `${current_char}`', &app)
			exit(1)
		}

		app.index++
	}

	return lexed_tokens
}
