module run

import term
import os
import radon.lexer
import radon.opt

pub fn radon_run() {
	args := os.args

	// [0]: radon | [1]: run | [2]: file_name
	file_name := args[2] or {
		println(term.red('radon_run Error: No file name provided'))
		return
	}

	if !file_name.contains('.rad') {
		println(term.red('radon_run Error: Invalid file type'))
		return
	}

	file_path := os.join_path(os.getwd(), file_name)

	if !os.exists(file_path) {
		println(term.red('radon_run Error: File does not exist'))
		return
	}

	println(term.gray('[INFO]: Running file: ${file_name}'))
	lexed_file := lexer.lex(file_name, file_path) or {
		println(term.red('radon_lexer Error: Error while trying to lex file'))
		exit(1)
	}

	println(term.green('Lexing successful | Lexed tokens: ${lexed_file.all_tokens.len}'))

	optimized_tokens := opt.optimize(lexed_file.all_tokens) or {
		println(term.red('radon_opt Error: Error while trying to optimize tokens'))
		exit(1)
	}

	println(term.green('Optimization successful | Optimized tokens: ${optimized_tokens.len} | Original tokens: ${lexed_file.all_tokens.len}'))

	// println('Optimized tokens: ${optimized_tokens}')
}
