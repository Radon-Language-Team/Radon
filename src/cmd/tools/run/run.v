module run

import term
import os
import radon.prep
import radon.lexer
import radon.opt
import radon.parser
import radon.gen

struct App {
mut:
	preserve_files         bool
	use_different_compiler bool
	use_different_std_path bool

	args            []string
	c_compilers     []string
	compiler_to_use string
	std_path        string
}

fn new_app() App {
	return App{
		preserve_files:         '-p' in os.args || '--preserve' in os.args
		use_different_compiler: '-cc' in os.args
		use_different_std_path: '-std' in os.args

		args:        os.args.clone()
		c_compilers: ['tcc', 'gcc', 'clang', 'cc']
		std_path:    ''
	}
}

pub fn radon_run() ! {
	mut app := new_app()

	if !app.use_different_compiler {
		for compiler in app.c_compilers {
			result := os.execute('${compiler}')
			if result.exit_code == 0 {
				app.compiler_to_use = compiler
				break
			}
		}
	} else {
		app.compiler_to_use = app.args[app.args.index('-cc') + 1]
		println(term.gray('Using "${app.compiler_to_use}" as C Compiler'))
		result := os.execute('${app.compiler_to_use} --version')
		if result.exit_code != 0 {
			println(term.red('radon_run Error: "${app.compiler_to_use}" is either not a valid C Compiler or not installed'))
			return
		}
	}

	if app.use_different_std_path {
		app.std_path = app.args[app.args.index('-std') + 1]
		println(term.gray('Using "${app.std_path}" as standard library path'))
	} else {
		app.std_path = ''
	}

	if app.compiler_to_use == '' {
		println(term.red('radon_run Error: No C Compiler found! \nEither install one of the following ${app.c_compilers} or use the "--cc" flag to specify a C Compiler'))
		return
	}

	// [0]: radon | [1]: run | [2]: file_name
	file_name := app.args[2] or {
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

	file_content := prep.preprocess(file_path, app.std_path)!
	lexed_file := lexer.lex(file_name, file_path, file_content)!
	optimized_tokens := opt.optimize(lexed_file.all_tokens)!
	parsed_nodes := parser.parse(optimized_tokens, file_name, file_path)!
	code := gen.generate(parsed_nodes.parsed_nodes, file_name, file_path)

	gen_file_name := file_name.replace('.rad', '.c')
	gen_file_name_exec := file_name.replace('.rad', '')
	gen_file_path := os.join_path(os.getwd(), gen_file_name)

	if os.exists(gen_file_path) {
		os.rm(gen_file_path)!
	}

	mut gen_file := os.create(gen_file_path)!
	os.write_file(gen_file_path, code)!

	gen_file.close()
	compile_code := os.system('${app.compiler_to_use} -o ${gen_file_name_exec} ${gen_file_name}')

	if compile_code != 0 {
		println(term.red('radon_run Error: Error while trying to compile generated file'))

		// This would mean that the Radon Compiler messed up the generated code
		// This should never happen
		msg := term.blue('\nThis means that the Radon Compiler has generated invalid C code. \nThis is something that should never ever happen! \nPlease report this issue on the Radon GitHub Repository')
		println(msg)
		exit(1)
	}

	os.system('./${gen_file_name_exec}')

	if app.preserve_files {
		println(term.gray('Preserving generated files'))
	} else {
		os.rm(gen_file_path)!
		os.rm('${gen_file_name_exec}')!
	}
}
