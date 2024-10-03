module tools

import os
import term

pub fn get_git_hash() string {
	current_path := os.getwd()
	radon_path := os.dir(os.executable())

	os.chdir('${radon_path}/..') or {
		println(term.red('Radon not found in ${os.getwd()}'))
		return 'Well...Kind of awkward'
	}

	git_hash := os.execute('git rev-parse --short HEAD')

	os.chdir(current_path) or {
		println(term.red('Failed to change back to ${current_path}'))
		return 'Well...Kind of awkward'
	}

	return git_hash.output
}
