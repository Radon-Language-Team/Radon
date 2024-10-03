// Symlinker for Linux
module tools

import os
import term

pub fn link() {
	tools.print_art()
	mut dest_dir := '/usr/local/bin'
	println('${os.getwd()}')

	if !os.exists(dest_dir) {
		os.mkdir_all(dest_dir) or {
			println(term.red('Failed to create symlink > Try with sudo'))
			exit(1)
		}
	}
	dest_dir = dest_dir + '/radon'

	os.rm(dest_dir) or { println(term.yellow('Was not able to remove old symlink')) }
	os.symlink('${os.getwd()}/radon', dest_dir) or {
		println(term.red('Failed to create symlink > Try with sudo -> ${dest_dir}'))
		exit(1)
	}

	println(term.green('Symlink created successfully'))
}
