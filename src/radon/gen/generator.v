module gen

import ast
import cmd.util { print_error }

pub fn generate(mut app ast.App) {
	for node in app.ast {
		match node {
			ast.FunctionDecl {
				app.gen_code += gen_function(node, &app)
			}
			ast.ImportStmt {
				app.gen_code += gen_import(node)
			}
			ast.VarDecl {
				app.gen_code += gen_var_decl(node)
			}
			else {
				print_error('Unkown node of type `${node.type_name()}`')
				exit(1)
			}
		}
	}
}
