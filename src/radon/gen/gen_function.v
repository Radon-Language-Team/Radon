module gen

import structs
import gen_utils

fn gen_function(function_decl structs.FunctionDecl) string {
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
			else {
				println('Those kind of nodes are not supported in function bodies for now :)')
				exit(1)
			}
		}
	}

	function_code += '// Generated from react ${function_name}\n'
	function_code += '${function_type} ${function_name}(${function_params}) { \n${function_body_code}} \n'
	return function_code
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

	if var_decl_value.e_type == .type_string && !var_decl_value.is_variable {
		// In case it's a variable, we don't want to put quotes around it
		// element foo = 'Hello'
		// foo -> "foo" > No
		// foo -> foo > Yes
		var_decl_code += gen_utils.gen_string(var_decl_value)
	} else {
		var_decl_code += '${var_decl_value.value.trim_space()}'
	}

	if var_decl.is_top_const {
		return var_decl_code
	} else {
		var_decl_code += '; \n'
	}
	return var_decl_code
}

fn gen_emit_stmt(emit_stmt structs.EmitStmt) string {
	emit_stmt_value := emit_stmt.emit as structs.Expression

	if emit_stmt_value.e_type == .type_string {
		return 'return ${gen_utils.gen_string(emit_stmt_value)}; \n'
	}

	return 'return ${emit_stmt_value.value.trim_space()}; \n'
}

fn gen_call(node structs.Call) string {
	callee_name := node.callee
	mut call_args := ''

	for arg in node.args {
		argument := arg as structs.Expression

		if argument.e_type == .type_string && !argument.is_variable {
			call_args += gen_utils.gen_string(argument)
		} else {
			call_args += argument.value
		}

		if arg != node.args.last() {
			call_args += ','
		}
	}

	function_call := '${callee_name}(${call_args}); \n'
	return function_call
}
