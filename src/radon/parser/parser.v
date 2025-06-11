module parser

import term
import cmd.util { print_compile_error, print_error }
import parser_utils
import structs

pub fn parse(mut app structs.App) ! {
	for app.index < app.all_tokens.len {
		token := app.all_tokens[app.index]

		match token.t_type {
			.key_mixture {
				app.ast << parse_import(mut app)
			}
			.key_react {
				function_decl := parse_function(mut app)!
				app.ast << function_decl
				app.all_functions << function_decl
			}
			.key_element {
				variable := parse_variable(mut app)
				println(variable)
			}
			else {
				// println(app.ast)
				print_compile_error('Unkown top level token of type `${token.t_type}` and value `${token.t_value}` \nExpected either `mixture`, `react`, or `elem`',
					&app)
				exit(1)
			}
		}
	}

	main_function := parser_utils.get_function(&app, 'main')
	if main_function == structs.FunctionDecl{} {
		print_error('Unkown function `main`')
		println(term.yellow('A `main` function is required as the entry point of your program'))
		exit(1)
	}
}