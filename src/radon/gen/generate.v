module gen

import term
import nodes { NodeProc }

@[minify]
pub struct Generator {
pub mut:
	file_name      string
	file_path      string
	node_index     int
	nodes          []NodeProc
	node           NodeProc
	generated_code string
}

pub fn generate(parsed_nodes []NodeProc, file_name string, file_path string) string {
	mut generator := Generator{
		file_name:      file_name
		file_path:      file_path
		node_index:     0
		nodes:          parsed_nodes
		node:           NodeProc{}
		generated_code: ''
	}

	generator.generate_code()
	return generator.generated_code
}

fn (mut g Generator) generate_code() {
	// We can include the standard library here
	// This is because built in functions like println or print are being supplied either way
	g.generated_code += '#include <stdio.h>\n\n'
	for g.node_index < g.nodes.len {
		g.node = g.nodes[g.node_index]

		// We only generate functions for now
		g.generate_proc()
		g.node_index += 1
	}
}

fn (mut g Generator) throw_gen_error(err_msg string) {
	err := term.red(err_msg)
	println('${term.blue('radon_generator Error:')} \n\n${err} \nIn file: ${g.file_name} \nFull path: ${g.file_path}')
}
