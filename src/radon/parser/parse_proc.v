module parser

import nodes

struct ParseProcStruct {
	new_index int
	proc_node nodes.NodeProc
}

pub fn (mut p Parser) parse_proc() !ParseProcStruct {
	test := ParseProcStruct{
		new_index: p.token_index + 1
		proc_node: nodes.NodeProc{}
	}

	return test
}
