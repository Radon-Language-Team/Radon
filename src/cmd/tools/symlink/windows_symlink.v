module symlink

import os
import term
import tools

pub fn windows_symlink() {
	tools.print_art()
	original_exe := os.real_path('${os.getwd()}/radon/radon.exe')

	user_home := os.getenv('USERPROFILE')
	radon_symlink_dir := os.join_path(user_home, '.bin')

	if !os.exists(radon_symlink_dir) {
		os.mkdir(radon_symlink_dir) or {
			println(term.red('Failed to create symlink directory: ${err}'))
			return
		}
	}

	// Full path to where the symlink will be created
	radon_symlink := os.join_path(radon_symlink_dir, 'radon.exe')

	if os.exists(radon_symlink) {
		os.rm(radon_symlink) or {
			println(term.yellow('Was not able to remove old radon symlink: ${err}'))
		}
	}

	os.symlink(original_exe, radon_symlink) or {
		println(term.red('Failed to create symlink: ${err}'))
		exit(1)
	}

	existing_path := os.getenv('PATH')

	if !existing_path.contains(radon_symlink_dir) {
		new_path := '${existing_path};${radon_symlink_dir}'
		os.setenv('PATH', new_path, true)
	}

	println(term.green('Symlink created successfully!'))
}
