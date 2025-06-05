module parser_utils

import term
import structs
import cmd.util { print_error }

const core_functions = ['println']

pub fn get_function(name string, app &structs.App) structs.FunctionDecl {
	function := app.all_functions.filter(it.name == name)

	if function.len == 0 {
		if name in core_functions {
			if name == 'println' {
				return structs.FunctionDecl{
					name:        name
					params:      [
						structs.Param{
							name:   'x'
							p_type: .type_string
						},
					]
					return_type: .type_void
					body:        []structs.AstNode{}
					is_core:     true
				}
			} else {
				return structs.FunctionDecl{
					name:        name
					params:      []structs.Param{}
					return_type: .radon_null
					body:        []structs.AstNode{}
				}
			}
		}
		print_error('Unkown function `${name}`')
		if name == 'main' {
			println(term.yellow('A `main` function is required as the entry point of your program'))
		}
		exit(1)
	} else {
		return function[0]
	}
}
