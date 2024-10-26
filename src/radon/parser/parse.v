module parser

import term
import radon.token { Token, TokenType }
import nodes { NodeProc }

@[minify]
pub struct Parser {
pub mut:
	file_name      string
	file_path      string
	token_index    int
	variable_names []string
	variables      []nodes.NodeVar
	all_tokens     []Token
	token          Token

	parsed_nodes []NodeProc
}

pub fn parse(tokens []Token, file_name string, file_path string) !Parser {
	mut parser := Parser{
		file_name:   file_name
		file_path:   file_path
		token_index: 0
		all_tokens:  tokens
		token:       Token{}

		parsed_nodes: []NodeProc{}
	}

	parser.parse_tokens()
	return parser
}

fn (mut p Parser) parse_tokens() {
	for p.token_index < p.all_tokens.len {
		p.token = p.all_tokens[p.token_index]

		if p.token.token_type == TokenType.key_proc {
			proc := p.parse_proc(p.token_index) or {
				p.throw_parse_error('Failed to parse proc')
				exit(1)
			}
			p.token_index = proc.new_index
			println(term.gray('Parsed proc "${proc.name}" with ${proc.params.len} arguments'))
			p.parsed_nodes << proc
			// This only works for ONE function right now... Well, it's a start
			return
		} else {
			// Bad top-level token
			p.throw_parse_error('"${p.token.value}" is not a valid top-level token. Expected either import, proc or const')
			exit(1)
		}
	}
	exit(1)
}

fn (mut p Parser) throw_parse_error(err_msg string) {
	err := term.red(err_msg)
	println('radon_parser Error: \n\n${err} \nOn line: ${p.all_tokens[p.token_index].line_number} - Token-Index: ${p.token_index} \nIn file: ${p.file_name} \nFull path: ${p.file_path}')
}
