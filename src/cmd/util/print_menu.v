module util

import term

pub fn print_menu() {
	term_colums, term_rows := term.get_terminal_size()

	radon_ascii_art := r"
  ____           _            
 |  _ \ __ _  __| | ___  _ __ 	| The Radon Programming Language
 | |_) / _` |/ _` |/ _ \| '_ \ 	| Run `radon help` for more information
 |  _ < (_| | (_| | (_) | | | |	| `radon run <file>` to compile and run
 |_| \_\__,_|\__,_|\___/|_| |_|	| v0.0.1 - 2025
	"

	small_radon_ascii_art := r"
  ____           _            
 |  _ \ __ _  __| | ___  _ __ 
 | |_) / _` |/ _` |/ _ \| '_ \  
 |  _ < (_| | (_| | (_) | | | |
 |_| \_\__,_|\__,_|\___/|_| |_|

 _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

 The Radon Programming Language
 Run `radon help` for more information
 `radon run <file>` to compile and run
 v0.0.1 - 2025
	"

	if term_colums > 70 && term_rows > 20 {
		println(term.bright_blue(radon_ascii_art))
	} else {
		println(term.bright_blue(small_radon_ascii_art))
	}
}

pub fn print_error(error string) {
	println('${term.bright_blue('Radon Error >> ')}${term.red(error)}')
}
