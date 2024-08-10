module main

import term
import os
import tools.symlink
import tools.help
import tools.run
import tools

fn main() {
	user_os := os.user_os()
	if os.args.len > 1 {
		match os.args[1] {
			'run' { run.radon_run() }
			else { println('Invalid command. Please run ${term.bg_blue('help')} for a list of commands \n\n') }
		}
		return
	}

	tools.print_art()
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
