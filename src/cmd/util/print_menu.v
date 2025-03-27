module util

import term

pub fn print_menu() {
	term.clear()

	radon_ascii_art := r"
  ____           _            
 |  _ \ __ _  __| | ___  _ __ 	| 
 | |_) / _` |/ _` |/ _ \| '_ \ 	| The Radon Programming Language
 |  _ < (_| | (_| | (_) | | | |	| Radon REPL - Menu
 |_| \_\__,_|\__,_|\___/|_| |_|	|          
	"

	println(term.blue(radon_ascii_art))
}
