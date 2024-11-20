// Unlinker for Linux
module symlink

import term
import os
import tools

pub fn unlink() {
	tools.print_art()
	user_os := os.user_os()
	if user_os == 'linux' {
		println(term.gray('Unlinking radon from /usr/local/bin'))
		dest_dir := '/usr/local/bin/radon'

		if !os.exists(dest_dir) {
			println(term.red('Symlink does not exist'))
			exit(1)
		}

		os.rm(dest_dir) or {
			println(term.red('Failed to remove symlink > Try with sudo'))
			exit(1)
		}

		println(term.green('Symlink removed successfully'))
	} else if user_os == 'windows' {
		user_home := os.getenv('USERPROFILE')
		radon_symlink_dir := os.join_path(user_home, '.bin')

		if !os.exists(radon_symlink_dir) {
			println(term.red('Symlink dir does not exist'))
			exit(1)
		}

		radon_symlink := os.join_path(radon_symlink_dir, 'radon.exe')

		if !os.exists(radon_symlink) {
			println(term.red('Symlink does not exist'))
			exit(1)
		}

		existing_path := os.getenv('PATH')

		if existing_path.contains(radon_symlink_dir) {
			new_path := existing_path.replace(radon_symlink_dir, '')
			os.setenv('PATH', new_path, true)
		}

		os.rm(radon_symlink) or {
			println(term.red('Failed to remove symlink > Try with administator privileges \n> Error ${err}'))
			exit(1)
		}

		println(term.green('Symlink removed successfully'))
	}
}
