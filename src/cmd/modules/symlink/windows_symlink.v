module symlink

import os
import term
import utils

pub fn windows_symlink() {
	utils.print_art()

	radon_dir := os.real_path(os.dir('${os.getwd()}/radon.exe'))
	radon_symlink_dir := os.join_path(radon_dir, '.bin')
	radon_symlink := os.join_path(radon_symlink_dir, 'radon.exe')

	if !os.exists(radon_symlink_dir) {
		os.mkdir(radon_symlink_dir) or {
			println(err)
			exit(1)
		}
	}

	os.symlink(radon_dir, radon_symlink) or {
		println(term.red('Was not able to create symlink > Make sure you have the right permissions'))
		println(err)
		exit(1)
	}

	println(term.green('Symlink created successfully'))
}
