module parser

import structs
import parser_utils

fn parse_emit(mut app structs.App) structs.EmitStmt {
	app.index++

	expression := parser_utils.get_expression(mut app)
	parsed_expression := parser_utils.parse_expression(expression) as structs.Expression

	emit_stmt := structs.EmitStmt{
		emit:      parsed_expression
		emit_type: parsed_expression.e_type
	}

	return emit_stmt as structs.EmitStmt
}
