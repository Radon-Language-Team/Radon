module util

import token
import nodes { NodeProc }

pub fn is_core_proc(node NodeProc) bool {
	match node.name {
		'print' {
			return true
		}
		'println' {
			return true
		}
		else {
			return false
		}
	}
}

pub fn gen_core_proc(node NodeProc) string {
	mut node_code := ''

	return_type := token.convert_radon_to_c_type(node.return_type)
	proc_name := node.name
	proc_args := node.params

	match node.name {
		'print' {
			// In case of print, we only have one argument meaning we can just use node.params[0]
			node_code += '${return_type} ${proc_name}(${token.convert_radon_to_c_type(proc_args[0].arg_type)} x) \n{ \nprintf("%s", x); \n}\n'
		}
		'println' {
			node_code += '${return_type} ${proc_name}(${token.convert_radon_to_c_type(proc_args[0].arg_type)} x) \n{ \nprintf("%s\\n", x); \n}\n'
		}
		else {
			// If the proc is not a core proc, generate an empty proc
			node_code += '${return_type} ${proc_name}() \n{ \n}\n'
		}
	}

	return node_code
}
