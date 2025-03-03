module nodes

import token

pub enum NodeType {
	proc
	return_node
	var_node
	proc_call
	null // For cases where no node type is active
}

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
	proc_call   NodeProcCall
}

pub struct NodeProcArg {
pub mut:
	proc_name   string
	arg_name    string
	arg_type    token.TokenType
	is_array    bool
	is_optional bool
}

// Struct for the proc node
pub struct NodeProc {
pub mut:
	new_index   int
	name        string
	params      []NodeProcArg
	return_type token.TokenType
	body        []Node

	/*
	Bracket count for tracking open and close function brackets
	When parsing a function, the count goes up to at least one, garanteed!
	When parsing the inside of a function and we hit a closing bracket,
	we decrement the count by one. When the count reaches zero, we know
	we have reached the end of the function
	*/
	bracket_count int
}

pub struct NodeProcCall {
pub mut:
	new_index   int
	called_proc NodeProc
	name        string
	args        []token.Token
}

pub struct NodeReturn {
pub mut:
	new_index   int
	value       string
	return_type token.TokenType
}

/*
VarAssignOptions represents the kind of variable assignment
":=" is for assigning a new variable
"=" is for reassigning a variable
*/
pub enum VarAssignOptions {
	assign
	reassign
}

pub enum VarKindOptions {
	proc_var
	scope_var
	const_var
}

/*
NodeVar is a struct that represents a variable in the Radon language

new_index: The new index of the parser after parsing the variable
name: The name of the variable
scope_id: The scope id of the variable [Experimental - Not yet implemented]
var_assign: The kind of variable assignment [assign or reassign]
var_type: The type of the variable [int, string, bool, etc.]
var_kind: The kind of variable [function_var, scope_var, const_var]
is_var: If true, the generator will generate 'x' instead of '"x"' -> Leaving it as a raw variable
*/
pub struct NodeVar {
pub mut:
	new_index  int
	name       string
	value      string
	scope_id   int
	var_assign VarAssignOptions
	var_type   token.TokenType
	var_kind   VarKindOptions
	is_var     bool
}
