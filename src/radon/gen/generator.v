module gen

import structs
import cmd.util { print_compile_error }

pub fn generate(mut app structs.App) {
	app.gen_code += '#include <stdio.h> \n'
	for node in app.ast {
		match node {
			structs.FunctionDecl {
				app.gen_code += gen_function(node)
			}
			else {
				print_compile_error('Unkown node of type `${node.type_name()}', &app)
			}
		}
	}
}
