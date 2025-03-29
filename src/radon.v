module main

import os
import term
import cmd.util
import cmd.run

fn main() {
	user_args := os.args
	if user_args.len > 1 {
		match user_args[1] {
			'run' {
				run.run() or {
					util.print_error('${err}')
					exit(1)
				}
				exit(0)
			}
			'help' {
				println('Help menu...')
				exit(0)
			}
			else {
				util.print_error('Unknown command: ${term.bright_red(user_args[1])}')
				exit(1)
			}
		}
	}

	util.print_menu()
}
