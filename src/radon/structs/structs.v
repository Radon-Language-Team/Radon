module structs

pub struct App {
pub mut:
	file_name    string
	file_path    string
	file_content string
	line_count   int
	index        int
	buffer       string
	all_tokens   []Token
	token        Token
	prev_token   Token
}

pub enum TokenType {
	key_react   // react
	key_if      // if
	key_else    // else
	key_emit    // emit
	colon       // :
	open_brace  // {
	close_brace // }
	open_paren  // (
	close_paren // )

	type_int    // int
	type_string // string

	plus  // +
	minus // -
	mult  // *
	div   // /

	variable // variable
}

pub enum TokenCategory {
	keyword
	operator
	literal
	identifier
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
}
