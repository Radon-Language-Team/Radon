module parser

import structs
import cmd.util { print_compile_error }
import parser_utils

fn parse_if(mut app structs.App) structs.IfStmt {
	app.index++
	mut if_expression_buffer := []structs.Token{}

	for app.get_token().t_type != .open_brace {
		if app.index + 1 >= app.all_tokens.len {
			print_compile_error('If-statement is not properly opened', &app)
			exit(1)
		}

		if_expression_buffer << app.get_token()
		app.index++
	}

	if_expression := parser_utils.parse_expression(if_expression_buffer, mut app) as structs.Expression

	// For now, we just support simple bool expressions in an IfStmt -> So it's length is always one
	if if_expression.e_type != .type_bool {
		print_compile_error('Non-bool type used as if-statement', &app)
		exit(1)
	}

	// Consume the `{`
	app.index++

	then_branch := parser_utils.parse_scoped(mut app)
	mut else_branch := []structs.AstNode{}

	// Consume the closing `}` of the then branch
	app.index++

	if app.get_token().t_type == .key_else {
		else_branch << parser_utils.parse_scoped(mut app)
		// Consume the closing `}` of the else branch
		app.index++
	}

	if_stmt := structs.IfStmt{
		condition:   if_expression
		then_branch: then_branch
		else_branch: else_branch
	}

	return if_stmt
}
