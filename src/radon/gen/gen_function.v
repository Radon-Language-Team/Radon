module gen

import structs
import gen_utils

fn gen_function(function_decl structs.FunctionDecl, app &structs.App) string {
	mut function_code := ''

	mut function_type := structs.radon_type_to_c_type(function_decl.return_type)

	if function_decl.name == 'main' && function_decl.return_type == .type_void {
		function_type = 'int'
	}

	function_name := function_decl.name
	mut function_params := ''
	mut i := 0
	for arg in function_decl.params {
		function_params += structs.radon_type_to_c_type(arg.p_type)
		function_params += ' ${arg.name}'
		i++

		if i != function_decl.params.len {
			function_params += ','
		}
	}

	mut function_body_code := ''
	for node in function_decl.body {
		match node {
			structs.VarDecl {
				function_body_code += gen_var_decl(node)
			}
			structs.EmitStmt {
				function_body_code += gen_emit_stmt(node)
			}
			structs.Call {
				function_body_code += gen_call(node)
			}
			structs.DecayStmt {
				function_body_code += gen_decay(node)
			}
			structs.IfStmt {
				function_body_code += gen_if(node)
			}
			else {
				println('Those kind of nodes are not supported in function bodies for now :)')
				exit(1)
			}
		}
	}

	if app.auto_decay {
		added_decays := gen_utils.insert_decays(app)
		function_body_code += added_decays
	}

	function_code += '// Generated from react ${function_name}\n'
	function_code += '${function_type} ${function_name}(${function_params}) { \n${function_body_code}} \n'
	return function_code
}

fn gen_function_body_scope(node structs.AstNode) string {
	match node {
		structs.VarDecl {
			return gen_var_decl(node)
		}
		structs.EmitStmt {
			return gen_emit_stmt(node)
		}
		structs.Call {
			return gen_call(node)
		}
		structs.DecayStmt {
			return gen_decay(node)
		}
		structs.IfStmt {
			return gen_if(node)
		}
		else {
			println('Those kind of nodes are not supported in function bodies for now :)')
			exit(1)
		}
	}
}

fn gen_var_decl(var_decl structs.VarDecl) string {
	mut var_decl_code := ''

	if var_decl.is_top_const {
		var_decl_code += '#define ${var_decl.name} '
	} else {
		if !var_decl.is_redi {
			// In case of a redefinition, we don't need the type
			var_decl_code += structs.radon_var_type_to_c_type(var_decl.variable_type)
			var_decl_code += ' ${var_decl.name} = '
		} else {
			var_decl_code += '${var_decl.name} = '
		}
	}

	var_decl_value := var_decl.value as structs.Expression

	if var_decl_value.is_function {
		type_name_of_expression := var_decl_value.advanced_expression.type_name()
		match type_name_of_expression {
			'radon.structs.Call' {
				var_decl_as_call := var_decl_value.advanced_expression as structs.Call
				var_decl_code += gen_call(var_decl_as_call)
			}
			else {
				println('That kind of expression can not yet be generated :)')
				exit(1)
			}
		}
	} else {
		var_decl_code += gen_utils.gen_expression(var_decl.value)
	}

	if var_decl.is_top_const {
		return '${var_decl_code} \n'
	} else {
		if var_decl_value.is_function == false {
			var_decl_code += '; \n'
		}
	}
	return var_decl_code
}

fn gen_emit_stmt(emit_stmt structs.EmitStmt) string {
	emit_value := gen_utils.gen_expression(emit_stmt.emit)
	return 'return ${emit_value}; \n'
}

fn gen_call(node structs.Call) string {
	mut callee_name := node.callee

	if callee_name.contains('@') {
		callee_name = callee_name.replace('@', '')
	}

	mut call_args := ''

	for arg in node.args {
		argument := arg as structs.Expression
		call_args += gen_utils.gen_expression(argument)

		if arg != node.args.last() {
			call_args += ','
		}
	}
	function_call := '${callee_name}(${call_args}); \n'
	return function_call
}

fn gen_decay(node structs.DecayStmt) string {
	return 'free(${node.name}); \n'
}

fn gen_if(node structs.IfStmt) string {
	mut if_stmt_code := ''
	mut if_con_code := ''

	if node.is_simple {
		if_con_code = gen_utils.gen_expression(node.condition.con_simple)
	} else {
		if_con_code = gen_utils.gen_bool_expr(node.condition)
	}

	mut if_then_code := ''
	for ast_node in node.then_branch {
		if_then_code += '${gen_function_body_scope(ast_node)}'
	}

	mut if_else_code := ''
	for ast_node in node.else_branch {
		if_else_code += '${gen_function_body_scope(ast_node)}'
	}

	if_stmt_code += 'if (${if_con_code}) 
	{
	${if_then_code}  }\n'

	if if_else_code != '' {
		if_stmt_code += 'else 
	{
	${if_else_code}  }\n'
	}
	return if_stmt_code
}
