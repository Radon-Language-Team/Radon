module parser

import cmd.util { print_compile_error }
import parser_utils
import structs

fn parse_variable(mut app structs.App) structs.VarDecl {
	mut variable_decl := structs.VarDecl{}
	mut token := app.get_token()

	// We can be sure we either have an `element` or an `isotope`
	if token.t_type == .key_isotope {
		variable_decl.is_mut = true
	}

	app.index++

	token = app.get_token()
	if token.t_type != .variable {
		print_compile_error('Expected variable name, got token of type ` ${token.t_type} ` and value ` ${token.t_value} `',
			&app)
		exit(1)
	}

	variable_decl.name = token.t_value

	app.index++

	token = app.get_token()
	if token.t_type != .equals {
		print_compile_error('Expected ` = `, got token of type ` ${token.t_type} ` and value ` ${token.t_value} `',
			&app)
		exit(1)
	}

	app.index++

	expression := parser_utils.get_expression(mut app)
	parsed_expression := parser_utils.parse_expression(expression) as structs.Expression

	variable_decl.variable_type = parsed_expression.e_type
	variable_decl.value = parsed_expression

	return variable_decl
}
