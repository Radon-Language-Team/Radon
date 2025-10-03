module parser

import ast
import cmd.util { print_compile_error }

fn parse_import(mut app ast.App) ast.ImportStmt {
	app.index++

	import_string := app.get_token()

	if import_string.t_type != .type_string {
		print_compile_error('Expected a string as import path but got `${import_string.t_type}` with value: `${import_string.t_value}`',
			&app)
		exit(1)
	}

	import_stmt := ast.ImportStmt{
		path: import_string.t_value
	}

	app.index++
	app.imports << import_string.t_value
	return import_stmt
}
