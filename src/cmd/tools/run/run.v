module run

import term
import os
import radon.lexer

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
	lexer.lex(file_name, file_path) or {
		println(term.red('radon_lexer Error: Error while trying to lex file'))
	}
}
