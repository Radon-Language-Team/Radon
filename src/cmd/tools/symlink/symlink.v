// Symlinker for Linux
module symlink

import os
import term
import tools

pub fn link() {
	tools.print_art()
	symlink_path := '/usr/local/bin/radon'

	// Remove old symlink if it exists
	if os.exists(symlink_path) {
		os.rm(symlink_path) or {
			println(term.yellow('Was not able to remove old radon symlink: ${err}'))
		}
	}

	// Create new symlink pointing to the executable
	os.symlink('${os.getwd()}/radon/radon', symlink_path) or {
		println(term.red('Failed to create symlink > Try with sudo > Tried to link to: ${symlink_path} \n> Error: ${err}'))
		exit(1)
	}

	println(term.green('Symlink created successfully'))
}
