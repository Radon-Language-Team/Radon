module run

import term
import os
import radon.lexer
import radon.opt
import radon.parser
import radon.gen

pub fn radon_run() {
	mut preserve_files := false
	args := os.args

	if '--p' in args || '--preserve' in args {
		preserve_files = true
	}

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

	lexed_file := lexer.lex(file_name, file_path) or {
		println(term.red('radon_lexer Error: Error while trying to lex file'))
		exit(1)
	}

	optimized_tokens := opt.optimize(lexed_file.all_tokens) or {
		println(term.red('radon_opt Error: Error while trying to optimize tokens'))
		exit(1)
	}

	parsed_nodes := parser.parse(optimized_tokens, file_name, file_path) or {
		println(term.red('radon_parser Error: Error while trying to parse tokens'))
		exit(1)
	}

	code := gen.generate(parsed_nodes.parsed_nodes, file_name, file_path)

	gen_file_name := file_name.replace('.rad', '.c')
	gen_file_name_exec := file_name.replace('.rad', '')
	gen_file_path := os.join_path(os.getwd(), gen_file_name)

	if os.exists(gen_file_path) {
		os.rm(gen_file_path) or {
			println(term.red('radon_run Error: Error while trying to remove existing generated file'))
			exit(1)
		}
	}

	mut gen_file := os.create(gen_file_path) or {
		println(term.red('radon_run Error: Error while trying to create generated file'))
		exit(1)
	}

	os.write_file(gen_file_path, code) or {
		println(term.red('radon_run Error: Error while trying to write to generated file'))
		exit(1)
	}

	gen_file.close()
	compile_code := os.system('tcc -o ${gen_file_name_exec} -c ${gen_file_name}')

	if compile_code != 0 {
		println(term.red('radon_run Error: Error while trying to compile generated file'))
		exit(1)
	}

	exec_code := os.system('./${gen_file_name_exec}')

	if exec_code != 0 {
		println(term.yellow('Proc "${gen_file_name_exec}" in "${file_name}" returned non-zero exit code! Possible error: \n${os.last_error()}'))
	}

	if !preserve_files {
		// Remove generated file after execution
		os.rm(gen_file_path) or {
			println(term.red('radon_run Error: Error while trying to remove generated file'))
			exit(1)
		}
		os.rm('${gen_file_name_exec}') or {
			println(term.red('radon_run Error: Error while trying to remove compiled radon file'))
			exit(1)
		}
	}

	println(term.green('[RADON] Execution successful'))
}
