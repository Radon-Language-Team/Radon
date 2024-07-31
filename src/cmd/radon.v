module main

import term
import os
import symlink
import help

fn main() {
	term.clear()

	if os.args.len > 1 {
		println('Args found - Implement this later')
	}

	radon_ascii_art := "
 ____             
| ___ \\        | |            
| |_/ /__ _  __| | ___  _ __  
|    // _` |/ _` |/ _ \\| '_ \\ 
| |\\ \\ (_| | (_| | (_) | | | |
\\_| \\_\\__,_|\\__,_|\\___/|_| |_|  
"

	println(term.blue(radon_ascii_art))
	println(term.bg_blue('CLI for the Radon Programming Language'))
	println(term.bg_blue('Current OS: ${os.user_os()}\n\n'))

	println('Run ${term.bg_blue('link')} to symlink the radon exectuable to your PATH. \nFor any other commands, run ${term.bg_blue('help')}. \n${term.bg_blue('exit')} to exit the CLI.')
	command := os.input('')

	match command {
		'link' { symlink.link() }
		'unlink' { symlink.unlink() }
		'help' { help.help() }
		'exit' { return }
		else { println('Invalid command. Please run ${term.bg_blue('help')} for a list of commands') }
	}
}
