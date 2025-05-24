module parser

import cmd.util { print_compile_error }
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
			else {
				// println(app.ast)
				print_compile_error('Unkown top level token of type `${token.t_type}` and value `${token.t_value}` \nExpected either `mixture`, `react`, or `element`',
					&app)
				exit(1)
			}
		}
	}
}
