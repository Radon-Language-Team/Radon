module nodes

import token

@[minify]
pub struct Node {
pub:
	node_kind NodeKind
}

pub struct NodeKind {
pub:
	proc NodeProc
	return_node NodeReturn
}

pub struct NodeProcArg {
pub mut:
	arg_name string
	arg_type string
	is_array bool
}

// Struct for the proc node
pub struct NodeProc {
pub mut:
	new_index   int
	name        string
	params      []NodeProcArg
	return_type token.TokenType
	body        []Node

	// Bracket count for tracking open and close function brackets
	// In the case of us parsing more open brackets than close brackets
	// we know that the function is not closed properly and we can throw an error
	// Is this smart? I don't know, but it works
	bracket_count int
}

pub struct NodeReturn {
pub mut:
	new_index int
	value     string
	return_type token.TokenType
}
