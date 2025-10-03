module parser

import ast
import parser_utils

fn parse_emit(mut app ast.App) ast.EmitStmt {
	app.index++

	expression := parser_utils.get_expression(mut app)
	parsed_expression := parser_utils.parse_expression(expression, mut app) as ast.Expression

	emit_stmt := ast.EmitStmt{
		emit:      parsed_expression
		emit_type: parsed_expression.e_type
	}

	return emit_stmt as ast.EmitStmt
}
