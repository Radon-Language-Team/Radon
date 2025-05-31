module parser

import structs
import cmd.util { print_compile_error }

fn parse_import(mut app structs.App) structs.ImportStmt {
	app.index++

	import_string := app.get_token()

	if import_string.t_type != .type_string {
		print_compile_error('Expected a string as import path but got `${import_string.t_type}` with value: `${import_string.t_value}`',
			&app)
		exit(1)
	}

	import_stmt := structs.ImportStmt{
		path: import_string.t_value
	}

	app.index++
	return import_stmt
}
