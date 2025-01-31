module util

import token
import nodes { NodeProcCall }

pub fn gen_proc_call(node NodeProcCall) string {
	mut proc_call_code := ''
	mut proc_args := ''

	called_proc_name := node.name
	proc_call_args := node.args

	for i, arg in proc_call_args {
		last_arg := i == proc_call_args.len - 1
		if arg.token_type == token.TokenType.type_string {
			if last_arg {
				proc_args += '"${arg.value}"'
			} else {
				proc_args += '"${arg.value}", '
			}
			continue
		} else if arg.token_type == token.TokenType.type_int {
			if last_arg {
				proc_args += '${arg.value}'
			} else {
				proc_args += '${arg.value}, '
			}
			continue
		} else {
			if last_arg {
				proc_args += '${arg.value}'
			} else {
				proc_args += '${arg.value}, '
			}
			continue
		}
	}

	proc_call_code += '${called_proc_name}(${proc_args});\n'

	return proc_call_code
}
