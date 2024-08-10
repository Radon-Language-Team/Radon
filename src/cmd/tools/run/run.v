module run

import term
import os
// import src.radon.lexer

pub fn radon_run() {
	// lexer.lexer_test()
	args := os.args

	// [0]: radon | [1]: run | [2]: file_name
	file_name := args[2] or {
		println(term.red('radon_run Error: No file name provided'))
		return
	}
	file_path := os.join_path(os.getwd(), file_name)

	if !os.exists(file_path) {
		println(term.red('radon_run Error: File does not exist'))
		return
	}

	println(term.gray('Running ${file_name}...'))
}
