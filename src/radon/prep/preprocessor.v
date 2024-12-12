module prep

import term
import os

@[minify]
struct Preprocessor {
pub mut:
	file_path   string
	new_content string
}

pub fn preprocess(file_path string) string {
	mut p := Preprocessor{
		file_path: file_path
	}

	p.start_prep(file_path) or {
		println(term.red('radon_prep Error: Was either not able to locate the standard library or to read the core.rad file'))
		exit(1)
	}
	return p.new_content
}

fn (mut p Preprocessor) start_prep(file_path string) ! {
	// Find the path of the radon executable
	radon_path := os.dir(os.executable())

	// Find the path of the standard library
	core_script_path := os.join_path(('${radon_path}/../src/std/core.rad'))

	if !os.exists(core_script_path) {
		println(term.red('radon_prep Error: Was not able to locate standard library'))
		exit(1)
	}

	core_script_content := os.read_file(core_script_path)!
	file_path_content := os.read_file(file_path)!

	full_content := core_script_content + '\n' + file_path_content

	p.new_content = &full_content
}
