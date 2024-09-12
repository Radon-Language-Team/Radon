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

// Struct for the proc node
pub struct NodeProc {
pub mut:
	new_index int
	name   string
	params []string
	body   []Node
}
