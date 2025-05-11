module structs

pub struct App {
pub mut:
	file_name    string
	file_path    string
	file_content string
	line_count   int
	column_count int
	index        int
	scope_id     int
	buffer       string
	all_tokens   []Token
	token        Token
	prev_token   Token
	ast          []AstNode

	display_json_tokens bool
}

pub fn (mut a App) get_token() Token {
	return a.all_tokens[a.index] or {
		println('Compiler panic: token index `${a.index}` out of range')
		print_backtrace()
		unsafe { free(a) }
		exit(1)
	}
}

pub enum TokenType {
	key_mixture // mixture
	key_react   // react
	key_element // element
	key_isotope // isotope
	key_if      // if
	key_else    // else
	key_emit    // emit
	colon       // :
	comma       // ,
	d_quote     // "
	s_quote     // '
	dot         // .
	exclamation //!
	open_brace  // {
	close_brace // }
	open_paren  // (
	close_paren // )

	type_int    // int
	type_string // string
	type_void

	plus   // +
	minus  // -
	mult   // *
	div    // /
	equals // =

	variable // variable
	literal  // literal

	radon_null // Only used by the compiler for unmatched token
}

pub enum TokenCategory {
	keyword
	operator
	literal
	identifier
	token_type
	unknown
}

pub enum VarType {
	type_string
	type_int
	type_void
	type_float
	type_bool
	type_unknown
}

pub struct Token {
pub mut:
	t_type     TokenType
	t_value    string
	t_line     int
	t_column   int
	t_length   int
	t_filename string
	t_category TokenCategory
	t_var_type VarType
}

pub type AstNode = Literal
	| Identifier
	| BinaryOp
	| Call
	| VarDecl
	| Expression
	| FunctionDecl
	| ReturnStmt
	| ImportStmt

struct Literal {
	value int
}

pub struct String {
pub:
	value string
}

struct Identifier {
	name string
}

struct BinaryOp {
	op    string
	left  AstNode
	right AstNode
}

struct Call {
	callee string
	args   []AstNode
}

pub struct VarDecl {
pub mut:
	name   string
	value  AstNode
	is_mut bool
	variable_type VarType
}

pub struct Expression {
pub mut:
	value string
	e_type VarType
}

pub struct Param {
pub mut:
	name   string
	p_type TokenType
}

pub struct FunctionDecl {
pub mut:
	name        string
	params      []Param
	return_type TokenType
	body        []AstNode
}

struct ReturnStmt {
	value AstNode
}

pub struct ImportStmt {
pub:
	path string
}
