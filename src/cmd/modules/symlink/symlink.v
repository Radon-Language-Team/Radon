module symlink

import os
import term

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

	println(term.gray('Symlinking the radon executable to /usr/local/bin/radon...'))
	println(term.gray('Compiling executable...'))

	os.execute('v -o ${os.getwd()}/src/cmd/radon ${os.getwd()}/src/cmd/main.v')

	println(term.gray('Checking if radon executable already exists...'))

	if os.exists('/usr/local/bin/radon') {
		println(term.red('radon executable already exists. Overwriting...'))
		os.execute('sudo rm /usr/local/bin/radon')
		println(term.gray('Moving radon executable to /usr/local/bin...'))
	} else {
		println(term.green('radon executable does not exist.'))
		println(term.gray('Moving radon executable to /usr/local/bin...'))
	}

	os.execute('sudo mv ${os.getwd()}/src/cmd/radon /usr/local/bin/radon')

	println(term.gray('Checking if radon executable was successfully symlinked...'))

	if !os.exists('/usr/local/bin/radon') {
		println(term.red('radon executable was not successfully symlinked.'))
		os.input('Press enter to continue...')
	} else {
		println(term.green('radon executable was successfully symlinked.'))
		os.input('You may now run <radon> in the terminal. Press enter to continue...')
	}
}
