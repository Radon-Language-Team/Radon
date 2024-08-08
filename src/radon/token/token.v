module token

pub enum Token {
	// keywords
	key_proc   // proc
	key_main   // main
	key_if     // if
	key_else   // else
	key_mut    // mut
	key_record // record
	key_loop   // loop
	key_ret    // return
	key_match  // match
	key_for    // for
	key_in     // in
	key_import // import
	// Types
	type_int    // int
	type_float  // float
	type_bool   // bool
	type_string // string
	// Symbols
	open_paren  // (
	close_paren // )
	open_brace  // {
	close_brace // }
	open_brack  // [
	close_brack // ]
	semicolon   // ;
	comma       // ,
	colon       // :
	dot         // .
	slash       // /
	backslash   // \
	star        // *
	plus        // +
	minus       // -
	equal       // =
	less        // <
	greater     // >
	exclamation // !
	percent     // %
	ampersand   // &
	pipe        // |
}
