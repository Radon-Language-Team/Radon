module symlink

import os
import term
import utils

pub fn windows_symlink() {
	utils.print_art()

	radon_dir := os.real_path(os.dir('${os.getwd()}/radon.exe'))
	radon_symlink := os.join_path(radon_dir, 'radon.exe')

	os.symlink('${os.getwd()}/radon.exe', radon_symlink) or {
		println(term.red('Was not able to create symlink > Make sure you have the right permissions'))
		exit(1)
	}

	println(term.green('Symlink created successfully'))
}
