module structs

pub struct App {
pub mut:
	file_name    string
	file_path    string
	file_content string
	line_count   int
	column_count int
	index        int
	buffer       string
	all_tokens   []Token
	token        Token
	prev_token   Token
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
	open_brace  // {
	close_brace // }
	open_paren  // (
	close_paren // )

	type_int    // int
	type_string // string
	type_void

	plus  // +
	minus // -
	mult  // *
	div   // /

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
}

@[minify]
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
