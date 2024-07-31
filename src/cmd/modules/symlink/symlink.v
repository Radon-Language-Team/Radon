// Symlinker for Linux
module symlink

import os
import term

const user_os = os.user_os()

pub fn link() {
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
	println(term.bg_blue('CLI for the Radon Programming Language\n\n'))

	if symlink.user_os == 'linux' {
		// Since we run on linux, we will remove the radon executable for windows
		os.rm('radon.exe') or {
			println(term.yellow('Failed to remove radon.exe for windows'))
		}

		println(term.gray('Symlinking the radon executable to /usr/local/bin/radon...'))
		println(term.gray('Checking if radon executable already exists...'))

		if os.exists('/usr/local/bin/radon') {
			println(term.yellow('radon executable already exists. Overwriting...'))
			os.rm('/usr/local/bin/radon') or {
				println(term.red('Failed to remove radon executable > Try again with sudo'))
				os.input('Press enter to continue...')
				return
			}
			println(term.gray('Moving radon executable to /usr/local/bin...'))
		} else {
			println(term.green('radon executable does not exist.'))
			println(term.gray('Copying radon executable to /usr/local/bin...'))
		}

		// We copy the radon executable instead of moving it so that you always have a backup
		os.cp('${os.getwd()}/radon', '/usr/local/bin/radon') or {
			println(term.red('Failed to copy radon executable > Try again with sudo'))
			os.input('Press enter to continue...')
			return
		}

		println(term.gray('Checking if radon executable was successfully symlinked...'))

		if !os.exists('/usr/local/bin/radon') {
			println(term.red('radon executable was not successfully symlinked.'))
			os.input('Press enter to continue...')
		} else {
			println(term.green('radon executable was successfully symlinked.'))
			os.input('You may now run <radon> in the terminal. Press enter to continue...')
		}
	} else if symlink.user_os == 'windows' {
		os.rm('radon') or {
			println(term.red('Failed to remove radon executable for linux'))
			os.input('Press enter to continue...')
			return
		}

		// We will create a dir in C:\Program Files called radon
		// This is where we will store the radon executable
		println(term.gray('Checking if radon directory already exists...'))

		if os.exists('C:\\Program Files\\radon') {
			println(term.yellow('radon directory already exists. Overwriting...'))
			os.rm('C:\\Program Files\\radon') or {
				println(term.red('Failed to remove radon directory > Try again with admin privileges'))
				os.input('Press enter to continue...')
				return
			}
			println(term.gray('Creating radon directory in C:\\Program Files...'))
		} else {
			println(term.green('radon directory does not exist.'))
			println(term.gray('Creating radon directory in C:\\Program Files...'))
		}

		os.mkdir('C:\\Program Files\\radon') or {
			println(term.red('Failed to create radon directory > Try again with admin privileges'))
			os.input('Press enter to continue...')
			return
		}

		println(term.gray('Copying radon executable to C:\\Program Files\\radon...'))

		os.cp('${os.getwd()}/radon.exe', 'C:\\Program Files\\radon\\radon.exe') or {
			println(term.red('Failed to copy radon executable > Try again with admin privileges'))
			os.input('Press enter to continue...')
			return
		}

		println(term.gray('Checking if radon executable was successfully symlinked...'))

		if !os.exists('C:\\Program Files\\radon\\radon.exe') {
			println(term.red('radon executable was not successfully symlinked.'))
			os.input('Press enter to continue...')
		} else {
			println(term.green('radon executable was successfully symlinked.'))
			os.input('You may now run <radon> in the terminal. Press enter to continue...')
		}
	}
}
