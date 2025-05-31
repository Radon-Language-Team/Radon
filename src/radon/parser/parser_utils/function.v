module parser_utils

import term
import structs
import cmd.util { print_error }

pub fn get_function(name string, app &structs.App) structs.FunctionDecl {
	function := app.all_functions.filter(it.name == name)

	if function.len == 0 {
		print_error('Unkown function `${name}`')
		if name == 'main' {
			println(term.yellow('A `main` function is required as the entry point of your program'))
		}
		exit(1)
	} else {
		return function[0]
	}
}
