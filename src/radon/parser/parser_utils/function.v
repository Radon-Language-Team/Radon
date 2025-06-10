module parser_utils

import structs

const core_functions = ['println']

pub fn get_function(app &structs.App, name string) structs.FunctionDecl {
	function := app.all_functions.filter(it.name == name)

	if function.len == 0 {
		if name in core_functions {
			if name == 'println' {
				return structs.FunctionDecl{
					name:        name
					params:      [
						structs.Param{
							name:   'x'
							p_type: .type_string
						},
					]
					return_type: .type_void
					body:        []structs.AstNode{}
					is_core:     true
				}
			} else {
				return structs.FunctionDecl{}
			}
		}
		return structs.FunctionDecl{}
	} else {
		return function[0]
	}
}
