module parser

import structs

fn parse_import(mut app structs.App) {
	app.index++

	import_string := parse_string(mut app)

	app.ast << structs.ImportStmt{
		path: import_string.value
	}

	app.index++
}
