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
				app.ast << parse_function(mut app)!
			}
			else {
				// println(app.ast)
				print_compile_error('Unkown top level token of type `${token.t_type}` and value `${token.t_value}` \nExpected either `mixture`, `react`, or `isotope`',
					&app)
				exit(1)
			}
		}
	}
}
