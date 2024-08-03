// Unlinker for Linux
module symlink

import term
import os

pub fn unlink() {
	user_os := os.user_os()
	term.clear()

	radon_ascii_art := "
 ____
| ___ \\        | |
| |_/ /__ _  __| | ___  _ __
|    // _` |/ _` |/ _ \\| '_ \\
| |\\ \\ (_| | (_| | (_) | | | |
\\_| \\_\\__,_|\\__,_|\\___/|_| |_|
"

	println(term.blue(radon_ascii_art))
	println(term.bg_blue('REPL for the Radon Programming Language\n\n'))

	if user_os == 'linux' {
		println(term.gray('Unlinking the radon executable from /usr/local/bin/radon...'))
		os.rm('/usr/local/bin/radon') or {
			println(term.red('Failed to unlink radon executable > Try again with sudo'))
			os.input('Press enter to continue...')
			return
		}

		if os.exists('/usr/local/bin/radon') {
			println(term.red('radon executable was not successfully unlinked.'))
		} else {
			println(term.green('radon executable was successfully unlinked.'))
		}

		os.input('Press enter to exit.')
	} else if user_os == 'windows' {
		dest_dir := 'C:/Program Files/radon'
		dest_path := '${dest_dir}/radon.exe'

		println(term.gray('Unlinking the radon executable from ${dest_path}...'))

		os.rm(dest_path) or {
			println(term.red('Failed to unlink radon executable > Try again with admin privileges'))
			os.input('Press enter to continue...')
			return
		}

		os.rm(dest_dir) or {
			println(term.red('Failed to remove the directory ${dest_dir}'))
			os.input('Press enter to continue...')
			return
		}

		if os.exists(dest_path) {
			println(term.red('radon executable was not successfully unlinked.'))
		} else {
			println(term.green('radon executable was successfully unlinked.'))
		}
	}
}
