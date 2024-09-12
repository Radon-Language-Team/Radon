module parser

import token
import nodes

pub fn (mut p Parser) parse_proc(index int) ![]nodes.Node {
	mut proc_node := nodes.NodeProc{
		new_index: index
		body: 		[]nodes.Node{}
	}
	p.token_index = index + 1

	// Parse the proc name
	if p.all_tokens[p.token_index].token_type != token.TokenType.proc_name {
		p.throw_parse_error('Expected a proc name')
		exit(1)
	}

	proc_node.name = p.all_tokens[p.token_index].value

	return proc_node.body
}
