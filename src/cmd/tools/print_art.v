module tools

import term
import os

pub fn print_art() {
	user_os := os.user_os()
	term.clear()

	radon_ascii_art := "
______          _
| ___ \\        | |
| |_/ /__ _  __| | ___  _ __
|    // _` |/ _` |/ _ \\| '_ \\
| |\\ \\ (_| | (_| | (_) | | | |
\\_| \\_\\__,_|\\__,_|\\___/|_| |_|
"

	println(term.blue(radon_ascii_art))
	println(term.bg_blue('REPL for the Radon Programming Language'))
	println(term.bg_blue('Current OS: ${user_os}\n\n'))
}
