module run

import term
import os
import radon.prep
import radon.lexer
import radon.opt
import radon.parser
import radon.gen

pub fn radon_run() {
	mut preserve_files := false
	mut use_different_compiler := false
	c_compilers := ['tcc', 'gcc', 'clang']
	mut compiler_to_use := ''
	args := os.args

	if '-p' in args || '--preserve' in args {
		preserve_files = true
	} else if '-cc' in args {
		compiler_to_use = args[args.index('-cc') + 1] or {
			println(term.red('radon_run Error: No C Compiler provided after "--cc" flag'))
			return
		}
		println(term.gray('Using "${compiler_to_use}" as C Compiler'))
		use_different_compiler = true
	}

	if !use_different_compiler {
		for compiler in c_compilers {
			result := os.execute('${compiler} --version')
			if result.exit_code == 0 {
				compiler_to_use = compiler
				break
			}
		}
	} else {
		result := os.execute('${compiler_to_use} --version')
		if result.exit_code != 0 {
			println(term.red('radon_run Error: "${compiler_to_use}" is either not a valid C Compiler or not installed'))
			return
		}
	}

	if compiler_to_use == '' {
		println(term.red('radon_run Error: No C Compiler found! \nEither install one of the following ${c_compilers} or use the "--cc" flag to specify a C Compiler'))
		return
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

	file_content := prep.preprocess(file_path)

	lexed_file := lexer.lex(file_name, file_path, file_content) or {
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
	compile_code := os.system('${compiler_to_use} -o ${gen_file_name_exec} ${gen_file_name}')

	if compile_code != 0 {
		println(term.red('radon_run Error: Error while trying to compile generated file'))

		// This would mean that the Radon Compiler messed up the generated code
		// This should never happen
		msg := term.blue('\nThis means that the Radon Compiler has generated invalid C code. \nThis is something that should never ever happen! \nPlease report this issue on the Radon GitHub Repository')
		println(msg)
		exit(1)
	}

	os.system('./${gen_file_name_exec}')

	// We'll leave this for now as it's not really necessary - Even if the C Compliation fails, the error will be shown
	// if exec_code != 0 {
	// 	println(term.yellow('Proc "${gen_file_name_exec}" in "${file_name}" returned non-zero exit code! Possible error: \n${os.last_error()}'))
	// }

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
