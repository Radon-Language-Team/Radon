module main

import term
import os
import cmd.tools.run
import cmd.tools.help
import cmd.tools.update
import cmd.tools.symlink
import cmd.tools

fn main() {
	user_os := os.user_os()
	if os.args.len > 1 {
		match os.args[1] {
			'run' { run.radon_run() }
			'update' { update.update() }
			else { println('Invalid command. Please run ${term.bg_blue('help')} for a list of commands \n\n') }
		}
		return
	}

	tools.print_art()
	println('Run ${term.bg_blue('link')} to symlink the Radon exectuable to your PATH. \nFor any other commands, run ${term.bg_blue('help')}. \n${term.bg_blue('exit')} to exit the REPL. \n\nUse ${term.bg_blue('radon run <file>')} to compile & run a radon file. \n\n')
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
		'update' {
			update.update()
		}
		'exit' {
			return
		}
		else {
			println('Invalid command. Please run ${term.bg_blue('help')} for a list of commands')
		}
	}
}
