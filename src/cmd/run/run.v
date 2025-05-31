module run

import os
import term
import json
import util
import radon.structs { App }
import radon.lexer
import radon.parser
import radon.gen

struct Context {
mut:
	display_json_tokens bool
	use_diff_compiler   bool
	preserve_files      bool

	args        []string
	c_compilers []string
	c_compiler  string
}

fn new_context() Context {
	return Context{
		display_json_tokens: '--json-tokens' in os.args
		use_diff_compiler:   '-cc' in os.args
		preserve_files:      '-p' in os.args

		args:        os.args.clone()
		c_compilers: ['tcc', 'gcc', 'clang', 'cc']
	}
}

pub fn run() ! {
	mut ctx := new_context()

	if !ctx.use_diff_compiler {
		for c in ctx.c_compilers {
			result := os.execute('${c}')
			if result.exit_code == 0 {
				ctx.c_compiler = c
				break
			}
		}
	} else {
		compiler_flag_index := ctx.args.index('-cc')
		if compiler_flag_index + 1 == os.args.len {
			println(term.red('Expected compiler after `-cc` flag'))
			return
		}
		ctx.c_compiler = ctx.args[ctx.args.index('-cc') + 1]
		println('${term.gray('Using manual C Compiler:')} ${term.yellow(ctx.c_compiler)}')
	}

	if ctx.c_compiler == '' {
		println(term.red('No C compiler found! Install one of the default ones: `${ctx.c_compilers}` or specify your own by using the `-cc` flag'))
		return
	}

	// Check if the user provided a file path
	if ctx.args.len < 3 {
		util.print_error('Usage: radon run <file_path>')
		return
	}

	file_path := ctx.args[2]

	// Check if the file exists
	if !os.exists(file_path) {
		util.print_error('File `${file_path}` does not exist')
		return
	}

	mut app := App{
		file_path:    file_path
		file_name:    os.file_name(file_path)
		index:        0
		line_count:   1
		column_count: 1
	}

	lexer.lex_file(mut app)!

	if ctx.display_json_tokens {
		json_tokens := json.encode_pretty(app.all_tokens)
		println(json_tokens)
	}

	app.index = 0
	app.done_lexing = true
	parser.parse(mut app)!
	gen.generate(mut app)

	gen_file_name := app.file_name.replace('.rad', '.c')
	gen_file_exec := gen_file_name.replace('.c', '')
	gen_file_path := os.join_path(os.getwd(), gen_file_name)

	if os.exists(gen_file_path) {
		os.rm(gen_file_path)!
	}

	mut gen_file := os.create(gen_file_path)!
	os.write_file(gen_file_path, app.gen_code)!

	gen_file.close()
	mut compile_code := 0
	mut compiler_command := ''

	if ctx.c_compiler != 'msvc' {
		compiler_command = '${ctx.c_compiler} -o ${gen_file_exec} ${gen_file_name}'
		compile_code = os.system(compiler_command)
	} else {
		compiler_command = 'cl ${gen_file_name} /link /out:${gen_file_exec}.exe'
		compile_code = os.system(compiler_command)
	}

	println('${term.gray('Final compiler command:')} ${term.yellow(compiler_command)}')

	if compile_code != 0 {
		println(term.red('Got non zero exit code after compiling generated C file!'))
		println(term.bright_blue('If this is a mistake in the generated code, please open an issue on GitHub!'))
	} else {
		user_os := os.user_os()
		if user_os == 'linux' {
			os.system('./${gen_file_exec}')
		} else if user_os == 'windows' {
			os.system('${gen_file_exec}.exe')
		}
	}

	if !ctx.preserve_files {
		os.rm(gen_file_path)!

		if os.user_os() != 'windows' {
			os.rm(gen_file_exec)!
		}
		println('\nDone!')
	} else {
		println('\n${term.gray('Preserving files:')} ${term.yellow(ctx.preserve_files.str())}')
	}
}
