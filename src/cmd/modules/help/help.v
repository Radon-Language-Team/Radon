module help

import os
import term
import symlink

pub fn help() {
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

	println('${term.bright_bg_blue('CLI commands:')} - ${term.gray('Run these commands in the CLI')}')
	println('${term.blue('link')} - ${term.gray('Symlink the radon executable to /usr/local/bin/radon')}')
	println('${term.blue('unlink')} - ${term.gray('Unlink the radon executable from /usr/local/bin/radon')}')
	println('${term.blue('help')} - ${term.gray('Display this help message')}')
	println('${term.blue('exit')} - ${term.gray('Exit the CLI')}\n\n')

	println('${term.bright_bg_blue('Compiler commands:')} - ${term.gray('Exit the CLI and run <radon <command>> to use these')}')
	println('${term.blue('radon run file.rad')} - ${term.gray('Run a radon file')}')
	println('${term.blue('radon file.rad')} - ${term.gray('Compile a radon file')}')
	println('${term.blue('radon update')} - ${term.gray('Update the radon compiler and the CLI')}\n\n')

	command := os.input('Enter the CLI command you want to run: ')

	match command {
		'link' { symlink.link() }
		'unlink' { symlink.unlink() }
		'help' { help() }
		'exit' { return }
		else { println('Invalid command. Please run ${term.bg_blue('help')} for a list of commands') }
	}
}
