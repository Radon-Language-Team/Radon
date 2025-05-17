module gen

import structs
import cmd.util { print_compile_error }

pub fn generate(mut app structs.App) {
	for node in app.ast {
		match node {
			structs.FunctionDecl {
				gen_function(node)
			}
			else {
				print_compile_error('Unkown node of type `${node.type_name()}', &app)
			}
		}
	}
}
