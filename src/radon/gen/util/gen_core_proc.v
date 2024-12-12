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

pub fn gen_core_proc(node NodeProc, generated_code &string) string {
	gen_code_so_far := *generated_code
	mut node_code := ''

	return_type := token.convert_radon_to_c_type(node.return_type)
	proc_name := node.name

	match node.name {
		'print' {
			if !gen_code_so_far.contains('#include <stdio.h>') {
				node_code += '#include <stdio.h>\n'
			}
			node_code += '${return_type} ${proc_name}(char* str) \n{ \nprintf("%s", str); \n}\n'
		}
		'println' {
			if !gen_code_so_far.contains('#include <stdio.h>') {
				node_code += '#include <stdio.h>\n'
			}
			node_code += '${return_type} ${proc_name}(char* str) \n{ \nprintf("%s\\n", str); \n}\n'
		}
		else {
			// If the proc is not a core proc, generate an empty proc
			node_code += '${return_type} ${proc_name}() \n{ \n}\n'
		}
	}

	return node_code
}
