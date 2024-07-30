module symlink

import term
import os

pub fn unlink() {
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

	println(term.gray('Unlinking the radon executable from /usr/local/bin/radon...'))
	os.execute('sudo rm /usr/local/bin/radon')

	println(term.gray('Checking if radon executable was successfully unlinked...'))

	if os.exists('/usr/local/bin/radon') {
		println(term.red('radon executable was not successfully unlinked.'))
	} else {
		println(term.green('radon executable was successfully unlinked.'))
	}

	os.input('Press enter to exit.')
}
