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
		println(term.red('Unlinking for windows is not yet good enough...'))
		exit(1)
		user_home := os.getenv('USERPROFILE')
		radon_symlink_dir := os.join_path(user_home, '.bin')

		if !os.exists(radon_symlink_dir) {
			println(term.red('Symlink does not exist'))
			exit(1)
		}

		radon_symlink := os.join_path(radon_symlink_dir, 'radon.exe')

		os.rm(radon_symlink) or {
			println(term.red('Failed to remove symlink > Try with administator privileges'))
			exit(1)
		}

		println(term.green('Symlink removed successfully'))
	}
}
