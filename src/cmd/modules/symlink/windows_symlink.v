module symlink

import os
import term

pub fn windows_symlink() {
	dest_dir := 'C:\\Program Files\\bin\\radon'
	dest_path := '${dest_dir}\\radon.exe'
	src_path := 'radon.exe'
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

	os.rm('radon') or { println(term.yellow('Linux binary already removed')) }

	println(term.gray('Symlinking radon.exe to C:/Program Files/bin/radon/radon.exe'))

	// We are moving the radon executable into C:\Program Files\bin\radon\radon.exe

	if !os.exists(dest_dir) {
		os.mkdir(dest_dir) or {
			println(term.red('Failed to create directory > Try again with with Admin privileges'))
			os.input('Press Enter to exit')
			return
		}
	}

	os.mv(src_path, dest_path) or {
		println(term.red('Failed to move radon.exe to C:/Program Files/bin/radon/radon.exe > Try again with with Admin privileges'))
		os.input('Press Enter to exit')
		return
	}

	existing_path := os.getenv('PATH')
	new_path := '${existing_path};${dest_dir}'
	os.setenv('PATH', new_path, true)

	println(term.green('Successfully symlinked radon.exe to C:/Program Files/bin/radon/radon.exe'))
	os.input('You may now use <radon> in the command line...')
	return
}
