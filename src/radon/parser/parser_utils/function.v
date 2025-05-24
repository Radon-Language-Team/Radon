module parser_utils

import structs

pub fn get_function(name string, app &structs.App) structs.FunctionDecl {
	return app.all_functions.filter(it.name == name)[0]
}
