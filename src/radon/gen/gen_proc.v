module gen

import nodes { Node }
import token
import util { gen_assignment, gen_core_proc, gen_proc_call, gen_return }

fn (mut g Generator) generate_proc() {
	node := g.node

	mut temp_proc_args := ''
	if node.params.len != 0 {
		for arg in node.params {
			temp_proc_args += token.convert_radon_to_c_type(arg.arg_type) + ' ' + arg.arg_name
			// If the argument is not the last one, add a comma
			if arg != node.params[node.params.len - 1] {
				temp_proc_args += ', '
			}
		}
	}

	proc_name := node.name
	proc_args := '(${temp_proc_args})'
	proc_type := token.convert_radon_to_c_type(node.return_type)
	proc_body := g.gen_proc_body(node.body)

	if util.is_core_proc(node) {
		proc_code := gen_core_proc(node)
		g.generated_code += proc_code
	} else {
		proc_code := '${proc_type} ${proc_name}${proc_args} \n{ \n${proc_body} \n}\n'
		g.generated_code += proc_code
	}
}

fn (mut g Generator) gen_proc_body(proc_body []Node) string {
	mut temp_proc_body := ''

	for tmp_node in proc_body {
		node_code := match tmp_node.node_type {
			.var_node {
				gen_assignment(tmp_node.node_kind.var_node)
			}
			.return_node {
				gen_return(tmp_node.node_kind.return_node)
			}
			.proc_call {
				gen_proc_call(tmp_node.node_kind.proc_call)
			}
			else {
				g.throw_gen_error('Unknown node type: ${tmp_node.node_type}')
				''
			}
		}
		// If, for some reason, the node code is empty, skip it
		if node_code == '' {
			continue
		}
		temp_proc_body += node_code
	}

	return temp_proc_body
}
