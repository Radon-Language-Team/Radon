module parser

import cmd.util { print_compile_error }
import structs

pub fn parse(mut app structs.App) ! {
	for app.index < app.all_tokens.len {
		token := app.all_tokens[app.index]

		match token.t_type {
			.key_mixture {
				parse_import(mut app)
			}
			.key_react {
				parse_function(mut app)
			}
			else {
				print_compile_error('Unkown top level token of type `${token.t_type}` and value `${token.t_value}` \nExpected either `mixture`, `react`, or `isotope`',
					&app)
				exit(1)
			}
		}
	}

	println('Finished parsing all tokens')
	println(app.ast)
}