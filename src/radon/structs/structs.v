module structs

@[heap]
pub struct App {
pub mut:
	file_name                string
	file_path                string
	file_content             string
	line_count               int
	column_count             int
	index                    int
	scope_id                 int
	buffer                   string
	all_tokens               []Token
	current_parsing_function string
	all_functions            []FunctionDecl
	all_variables            []VarDecl
	all_allocations          []string
	decays                   []string
	imports                  []string
	token                    Token
	prev_token               Token

	ast []AstNode

	gen_code string

	done_lexing bool
}

pub fn (mut a App) get_token() Token {
	return a.all_tokens[a.index] or {
		println('Compiler panic: token index `${a.index}` out of range -> Token array length: ${a.all_tokens.len}')
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
	key_decay   // decay
	key_if      // if
	key_else    // else
	key_emit    // emit
	key_true    // true
	key_false   // false
	colon       // :
	comma       // ,
	s_quote     // '
	dot         // .
	exclamation //!
	at          // @
	open_brace  // {
	close_brace // }
	open_paren  // (
	close_paren // )

	type_int    // int
	type_string // string
	type_void   // void
	type_bool   // bool

	plus   // +
	minus  // -
	mult   // *
	div    // /
	equals // =

	variable // variable
	literal  // literal

	function_decl // For Function decls -> react foo()
	function_call // For Function calls -> foo()

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

pub fn var_type_to_token_type(var_type VarType) TokenType {
	return match var_type {
		.type_string {
			.type_string
		}
		.type_int {
			.type_int
		}
		.type_bool {
			.type_bool
		}
		else {
			.radon_null
		}
	}
}

pub fn token_type_to_var_type(token_type TokenType) VarType {
	return match token_type {
		.type_string {
			.type_string
		}
		.type_int {
			.type_int
		}
		.type_bool {
			.type_bool
		}
		else {
			.type_unknown
		}
	}
}

// TODO: What is this... They both do the same stuff
pub fn radon_type_to_c_type(radon_type TokenType) string {
	return match radon_type {
		.type_string {
			'char*'
		}
		.type_int {
			'int'
		}
		.type_void {
			'void'
		}
		.type_bool {
			'int'
		}
		else {
			''
		}
	}
}

pub fn radon_var_type_to_c_type(radon_type VarType) string {
	return match radon_type {
		.type_string {
			'char*'
		}
		.type_int {
			'int'
		}
		.type_void {
			'void'
		}
		.type_bool {
			'int'
		}
		else {
			''
		}
	}
}

pub type AstNode = Literal
	| Identifier
	| BinaryOp
	| Call
	| DecayStmt
	| VarDecl
	| EmitStmt
	| Expression
	| FunctionDecl
	| ReturnStmt
	| ImportStmt
	| IfStmt

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

pub struct Call {
pub mut:
	callee string
	args   []AstNode
}

pub struct VarDecl {
pub mut:
	name          string
	function_name string
	value         AstNode
	is_mut        bool
	is_redi       bool
	is_top_const  bool
	variable_type VarType
}

pub struct Expression {
pub mut:
	value               string
	e_type              VarType
	is_variable         bool
	is_function         bool
	advanced_expression AstNode
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
	is_core     bool
	does_malloc bool
}

struct ReturnStmt {
	value AstNode
}

pub struct ImportStmt {
pub:
	path string
}

pub struct EmitStmt {
pub:
	emit      AstNode
	emit_type VarType
}

pub struct DecayStmt {
pub mut:
	name string
}

pub struct IfStmt {
pub:
	condition   AstNode
	then_branch []AstNode
	else_branch ?[]AstNode
}
