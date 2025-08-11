module util

import term
import radon.structs { App }

pub fn print_menu() {
	term_colums, term_rows := term.get_terminal_size()

	radon_ascii_art := r"
  ____           _            
 |  _ \ __ _  __| | ___  _ __ 	| The Radon Programming Language
 | |_) / _` |/ _` |/ _ \| '_ \ 	| Run `radon help` for more information
 |  _ < (_| | (_| | (_) | | | |	| `radon run <file>` to compile and run
 |_| \_\__,_|\__,_|\___/|_| |_|	| v0.0.1 - 2025
	"

	small_radon_ascii_art := r"
  ____           _            
 |  _ \ __ _  __| | ___  _ __ 
 | |_) / _` |/ _` |/ _ \| '_ \  
 |  _ < (_| | (_| | (_) | | | |
 |_| \_\__,_|\__,_|\___/|_| |_|

 _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

 The Radon Programming Language
 Run `radon help` for more information
 `radon run <file>` to compile and run
 v0.0.1 - 2025
	"

	if term_colums > 70 && term_rows > 20 {
		println(term.bright_blue(radon_ascii_art))
	} else {
		println(term.bright_blue(small_radon_ascii_art))
	}
}

pub fn radon_assert(assertion bool, message string, possible_app ?&App) {
	if assertion {
		app := possible_app or { exit(1) }

		if app != App{} {
			print_compile_error(message, app)
		} else {
			print_error(message)
		}
		exit(1)
	}
}

pub fn print_error(error string) {
	println('${term.bright_blue('Radon Error >> ')}${term.red(error)}')
}

pub fn print_compile_error(error string, app &App) {
	mut line_string := ''

	if app.done_lexing {
		line_string = '${app.file_name}:${app.all_tokens[app.index].t_line}:${app.all_tokens[app.index].t_column}'
	} else {
		line_string = '${app.file_name}:${app.line_count}:${app.column_count}'
	}

	println('${term.bright_blue('${line_string}: Radon Error >> ')}${term.red(error)}')

	if app.index - 1 >= 0 {
		if app.done_lexing {
			println('Previous token type: `${app.all_tokens[app.index - 1].t_type}` with value: `${app.all_tokens[app.index - 1].t_value}`')
		} else {
			println('Previous token: `${app.prev_token.t_value}` of type `${app.prev_token.t_type}`')
		}
	}

	structs.clean_up(app)
}
