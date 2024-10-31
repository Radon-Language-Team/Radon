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

pub fn generate(parsed_nodes []NodeProc, file_name string, file_path string) {
	mut generator := Generator{
		file_name:      file_name
		file_path:      file_path
		node_index:     0
		nodes:          parsed_nodes
		node:           NodeProc{}
		generated_code: ''
	}

	generator.generate_code()
}

fn (mut g Generator) generate_code() {
	println(term.gray('Generating code...'))
	println(term.gray('Going through ${g.nodes.len} nodes'))

	for g.node_index < g.nodes.len {
		g.node = g.nodes[g.node_index]

		// We only generate functions for now
		g.generate_proc()
		g.node_index += 1
	}

	println('Generated code: ${g.generated_code}')
}

fn (mut g Generator) throw_gen_error(err_msg string) {
	err := term.red(err_msg)
	println('radon_gen Error: \n\n${err} \nIn file: ${g.file_name} \nFull path: ${g.file_path}')
}
