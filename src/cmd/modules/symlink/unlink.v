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

		println(term.gray('Checking if radon executable was successfully unlinked...'))

		if os.exists('/usr/local/bin/radon') {
			println(term.red('radon executable was not successfully unlinked.'))
		} else {
			println(term.green('radon executable was successfully unlinked.'))
		}

		os.input('Press enter to exit.')
	} else if user_os == 'windows' {
		// We created a radon directory in C:\Program Files\Radon to store the radon executable
		// Program Files/radon.exe

		println(term.gray('Unlinking the radon executable from C:\\Program Files\\Radon\\radon.exe...'))
		os.rm('C:\\Program Files\\Radon\\radon.exe') or {
			println(term.red('Failed to unlink radon executable'))
			os.input('Press enter to continue...')
			return
		}

		os.rm('C:\\Program Files\\Radon') or {
			println(term.red('Failed to delete radon directory'))
			os.input('Press enter to continue...')
			return
		}

		println(term.gray('Checking if radon executable was successfully unlinked...'))

		if os.exists('C:\\Program Files\\Radon\\radon.exe') {
			println(term.red('radon executable was not successfully unlinked.'))
		} else {
			println(term.green('radon executable was successfully unlinked.'))
		}
	}
}
