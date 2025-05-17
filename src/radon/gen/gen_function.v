module gen

import structs

fn gen_function(function_decl structs.FunctionDecl) string {
	mut function_code := ''

	function_type := structs.radon_type_to_c_type(function_decl.return_type)
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
			else {
				println('Those kind of nodes are not supported in function bodies for now :)')
				exit(1)
			}
		}
	}

	function_code += '${function_type} ${function_name}(${function_params}) { \n\n${function_body_code}\n}'

	println(function_code)
	return function_code
}

fn gen_var_decl(var_decl structs.VarDecl) string {
	mut var_decl_code := ''

	var_decl_code += structs.radon_var_type_to_c_type(var_decl.variable_type)
	var_decl_code += ' ${var_decl.name} = '

	var_decl_value := var_decl.value as structs.Expression

	var_decl_code += '${var_decl_value.value.trim_space()}; \n'

	return var_decl_code
}

fn gen_emit_stmt(emit_stmt structs.EmitStmt) string {
	emit_stmt_value := emit_stmt.emit as structs.Expression

	return 'return ${emit_stmt_value.value.trim_space()}; \n'
}
