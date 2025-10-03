module parser

import ast
import cmd.util { radon_assert }
import parser_utils

fn parse_if(mut app ast.App, function ast.FunctionDecl) ast.IfStmt {
	app.index++
	mut if_expression_buffer := []ast.Token{}

	for app.get_token().t_type != .open_brace {
		radon_assert(app.index + 1 >= app.all_tokens.len, 'If-statement is not properly opened',
			&app)

		if_expression_buffer << app.get_token()
		app.index++
	}

	if_expression := parser_utils.parse_simple_boolean_expr(if_expression_buffer, mut
		app) as ast.BoolCondition

	if if_expression.is_simple {
		expression := if_expression.con_simple as ast.Expression
		radon_assert(expression.e_type != .type_bool, 'Non-bool type used as if-statement',
			&app)
	}

	// Consume the `{`
	app.index++
	app.scope_id++
	then_branch := parse_function_body(mut app, function, true)

	mut else_branch := []ast.AstNode{}

	// Consume the closing `}` of the then branch
	app.index++
	app.scope_id--

	if app.get_token().t_type == .key_else {
		app.scope_id++
		// consume the `else`
		app.index++

		radon_assert(app.get_token().t_type != .open_brace, 'Expected `{` but got `${app.get_token().t_value}`',
			&app)
		app.index++

		else_branch << parse_function_body(mut app, function, true)
		// Consume the closing `}` of the else branch
		app.index++
		app.scope_id--
	}

	if_stmt := ast.IfStmt{
		is_simple:   if_expression.is_simple
		condition:   if_expression
		then_branch: then_branch
		else_branch: else_branch
	}

	return if_stmt
}
