module nodes

import token

pub enum NodeType {
	proc
	return_node
	var_node
	none // For cases where no node type is active
}

@[minify]
pub struct Node {
pub:
	node_type NodeType
	node_kind NodeKind
}

pub struct NodeKind {
pub:
	proc        NodeProc
	return_node NodeReturn
	var_node    NodeVar
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
	new_index   int
	value       string
	return_type token.TokenType
}

pub enum VarAssignOptions {
	assign
	reassign
}

/*
NodeVar is a struct that represents a variable in the Radon language

new_index: The new index of the parser after parsing the variable
name: The name of the variable
scope_id: The scope id of the variable [Experimental - Not yet implemented]
var_kind: The kind of variable assignment [assign or reassign]
var_type: The type of the variable [int, string, bool, etc.]
*/
pub struct NodeVar {
pub mut:
	new_index int
	name      string
	value     string
	scope_id  int
	var_kind  VarAssignOptions
	var_type  token.TokenType
}
