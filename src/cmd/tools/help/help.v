module help

import os
import term
import symlink
import update
import tools

pub fn help() {
	tools.print_art()
	println('${term.bright_bg_blue('REPL commands:')} - ${term.gray('Run these commands in the REPL')}')
	println('${term.blue('link')} - ${term.gray('Symlink the radon executable to /usr/local/bin/radon')}')
	println('${term.blue('unlink')} - ${term.gray('Unlink the radon executable from /usr/local/bin/radon')}')
	println('${term.blue('help')} - ${term.gray('Display this help message')}')
	println('${term.blue('update')} - ${term.gray('Update the radon compiler and the REPL')}')
	println('${term.blue('exit')} - ${term.gray('Exit the REPL')}\n\n')

	println('${term.bright_bg_blue('Compiler commands:')} - ${term.gray('Exit the REPL and run <radon <command>> to use these')}')
	println('${term.blue('radon run file.rad')} - ${term.gray('Run a radon file')}')
	println('${term.blue('radon file.rad')} - ${term.gray('Compile a radon file')}')
	println('${term.blue('radon update')} - ${term.gray('Update the radon compiler and the REPL')}\n\n')

	command := os.input('Enter the REPL command you want to run: ')

	match command {
		'link' { symlink.link() }
		'unlink' { symlink.unlink() }
		'help' { help() }
		'update' { update.update() }
		'exit' { return }
		else { println('Invalid command. Please run ${term.bg_blue('help')} for a list of commands') }
	}
}
