module tools

import term
import math
import os
import radon.lexer
import radon.opt
import radon.parser

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

	println(term.green('Optimization successful | Tokens after opt: ${optimized_tokens.len} | ${math.round(optimized_tokens.len / lexed_file.all_tokens.len * 100)}%'))

	parser.parse(optimized_tokens, file_name, file_path)

	println(term.green('Parsing successful'))
}
