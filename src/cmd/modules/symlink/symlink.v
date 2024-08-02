// Symlinker for Linux
module symlink

import os
import term

pub fn link() {
	dest_path := '/usr/local/bin/radon'
	radon_exec := 'radon'
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

	// Since we run on linux, we will remove the radon executable for windows
	os.rm('radon.exe') or { println(term.yellow('Windows binary already removed')) }

	println(term.gray('Symlinking the radon executable to /usr/local/bin/radon...'))

	if os.exists('${dest_path}') {
		println(term.yellow('radon executable already exists. Overwriting...'))
		os.rm('${dest_path}') or {
			println(term.red('Failed to remove radon executable > Try again with sudo'))
			os.input('Press enter to continue...')
			return
		}
		println(term.gray('Moving radon executable to /usr/local/bin...'))
	} else {
		println(term.green('radon executable does not exist.'))
		println(term.gray('Copying radon executable to /usr/local/bin...'))
	}

	os.mv('${os.getwd()}/radon', '${dest_path}') or {
		println(term.red('Failed to symlink radon executable > Try again with sudo'))
		os.input('Press enter to continue...')
		return
	}

	println(term.gray('Checking if radon executable was successfully symlinked...'))

	if !os.exists('${dest_path}') {
		println(term.red('radon executable was not successfully symlinked.'))
		os.input('Press enter to continue...')
	} else {
		println(term.green('radon executable was successfully symlinked.'))
		os.input('You may now run <radon> in the terminal...')
	}
}
