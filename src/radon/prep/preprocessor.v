module prep

import term
import os

@[minify]
struct Preprocessor {
pub mut:
	file_path   string
	std_path    string
	new_content string
}

pub fn preprocess(file_path string, std_path string) !string {
	mut p := Preprocessor{
		file_path: file_path
		std_path:  std_path
	}

	p.start_prep(file_path)!
	return p.new_content
}

fn (mut p Preprocessor) start_prep(file_path string) ! {
	radon_path := os.dir(os.executable())
	if p.std_path.len == 0 {
		// Find the path of the standard library
		p.std_path = os.join_path(('${radon_path}/../src/std/core.rad'))

		if !os.exists(p.std_path) {
			println(term.red('radon_run Error: Was not able to locate standard library under ${p.std_path}'))
			exit(1)
		}
	} else {
		full_custom_path := os.join_path(os.home_dir(), p.std_path)

		if !os.exists(full_custom_path) {
			println(term.red('radon_run Error: Was not able to locate standard library under ${full_custom_path} \n\nMake sure it points to the core.rad file'))
			exit(1)
		}

		p.std_path = full_custom_path
	}
	core_script_content := os.read_file(p.std_path) or {
		println(term.red('radon_prep Error: Was not able to locate standard library under ${p.std_path}'))
		exit(1)
	}
	file_path_content := os.read_file(file_path)!

	full_content := core_script_content + '\n' + file_path_content

	p.new_content = &full_content
}
