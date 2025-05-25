module parser

import structs
import parser_utils

fn parse_import(mut app structs.App) structs.ImportStmt {
	app.index++

	import_string := parser_utils.parse_string(mut app)

	import_stmt := structs.ImportStmt{
		path: import_string.value
	}

	app.index++
	return import_stmt
}
