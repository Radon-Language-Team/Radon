module main

import os
import term
import cmd.util
import cmd.run

fn match_input(input string) {
	match input {
		'run' {
			run.run() or {
				util.print_error('${err}')
				return
			}
			return
		}
		'help' {
			util.display_help()
			return
		}
		'symlink' {
			util.symlink_radon()
		}
		'exit' {
			return
		}
		else {
			util.print_error('Unknown command: `${input}`')
			return
		}
	}
}

fn main() {
	user_args := os.args
	if user_args.len > 1 {
		match_input(user_args[1])
		return
	}

	util.print_menu()
	input := os.input('Type ${term.yellow('help')} to bring up the help menu: ')

	match_input(input)
}
