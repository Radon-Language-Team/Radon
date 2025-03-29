module lexer

import os
import encoding.utf8 { is_letter, is_number, is_space }
import cmd.util { print_error }
import structs

pub fn lex_file(mut app structs.App) ![]structs.Token {
	// Try to open the file
	mut lexed_tokens := []structs.Token{}

	// Read the file content
	file_content := os.read_file(app.file_path)!
	app.file_content = file_content

	if app.file_content.trim_space().len == 0 {
		print_error('`${app.file_path}` is empty - Nothing to do')
		exit(1)
	}

	for app.index < app.file_content.len {
		current_char := app.file_content[app.index].ascii_str().runes().first()

		if is_letter(current_char) {
			println('Found letter: ${current_char}')
		} else if is_number(current_char) {
			println('Found number: ${current_char}')
		} else if is_space(current_char) {
			println('Found space: ${current_char}')
		} else {
			println('Found special character: ${current_char}')
		}

		app.index++
	}

	return lexed_tokens
}
