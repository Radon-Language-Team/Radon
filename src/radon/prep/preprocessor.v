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
		file_path:   file_path
	}

	p.start_prep(file_path)
	return p.new_content
}

fn (mut p Preprocessor) start_prep(file_path string) {
	home_dir := os.home_dir()
	core_path := '.config/radon/core.rad'
	core_script_path := os.join_path(home_dir, core_path)
	
	if !os.exists(core_script_path) {
		println(term.red('radon_prep Error: Was not able to locate standard library'))
		exit(1)
	}

	core_script_content := os.read_file(core_script_path) or {
		println(term.red('radon_prep Error: Was not able to read standard library'))
		exit(1)
	}

	file_path_content := os.read_file(file_path) or {
		println(term.red('radon_prep Error: Was not able to read file'))
		exit(1)
	}

	full_content := core_script_content + '\n' + file_path_content

	p.new_content = &full_content
}
