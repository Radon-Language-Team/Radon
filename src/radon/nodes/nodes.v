module nodes

@[minify]
pub struct Node {
pub:
	node_kind NodeKind
}

struct NodeKind {
pub:
	proc NodeProc
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
	new_index int
	name      string
	params    []NodeProcArg
	body      []Node
}
