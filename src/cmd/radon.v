module main

import term
import os
import symlink
import help

fn main() {
	user_os := os.user_os()
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
	println(term.bg_blue('REPL for the Radon Programming Language'))
	println(term.bg_blue('Current OS: ${user_os}\n\n'))

	println('Run ${term.bg_blue('link')} to symlink the radon exectuable to your PATH. \nFor any other commands, run ${term.bg_blue('help')}. \n${term.bg_blue('exit')} to exit the REPL.')
	command := os.input('')

	match command {
		'link' {
			match user_os {
				'linux' { symlink.link() }
				'windows' { symlink.windows_symlink() }
				else { println('OS not supported') }
			}
		}
		'unlink' {
			symlink.unlink()
		}
		'help' {
			help.help()
		}
		'exit' {
			return
		}
		else {
			println('Invalid command. Please run ${term.bg_blue('help')} for a list of commands')
		}
	}
}
