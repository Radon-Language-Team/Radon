module gen

import structs
import cmd.util { print_error }

pub fn generate(mut app structs.App) {
	for node in app.ast {
		match node {
			structs.FunctionDecl {
				app.gen_code += gen_function(node, &app)
			}
			structs.ImportStmt {
				app.gen_code += gen_import(node)
			}
			structs.VarDecl {
				app.gen_code += gen_var_decl(node)
			}
			else {
				print_error('Unkown node of type `${node.type_name()}`')
				exit(1)
			}
		}
	}
}
