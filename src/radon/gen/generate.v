module gen

import term
import nodes { Node, NodeProc }

@[minify]
pub struct Generator {
pub mut:
	file_name  string
	file_path  string
	node_index int
	nodes      []NodeProc
	node       Node
}

pub fn generate(parsed_nodes []NodeProc, file_name string, file_path string) {
	mut generator := Generator{
		file_name:  file_name
		file_path:  file_path
		node_index: 0
		nodes:      parsed_nodes
		node:       Node{}
	}

	generator.generate_code()
}

fn (mut g Generator) generate_code() {
	println(term.gray('Generating code...'))
}
