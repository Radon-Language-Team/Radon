module parser

import term
import radon.token { Token, TokenType }
import nodes { NodeProc, NodeVar }

@[minify]
pub struct Parser {
pub mut:
	file_name      string
	file_path      string
	token_index    int
	variable_names []string
	variables      []NodeVar
	proc_names     []string
	procs          []NodeProc
	all_tokens     []Token
	token          Token

	parsed_nodes []NodeProc
}

pub fn parse(tokens []Token, file_name string, file_path string) !Parser {
	mut parser := Parser{
		file_name:      file_name
		file_path:      file_path
		token_index:    0
		variable_names: []
		variables:      []
		proc_names:     []
		procs:          []
		all_tokens:     tokens
		token:          Token{}

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
			p.parsed_nodes << proc
			p.function_table(proc, proc.name, ProcOperation.set)

			if p.token_index >= p.all_tokens.len {
				// We reached the end of the file
				// Leave this here for the future, in case we want to do something after parsing :)
				// println('End of file with ${p.token_index} tokens from ${p.all_tokens.len}')
				break
			} else {
				// parse_proc updates the token_index while parsing the insides of the proc
				// When done, we want to jump to the next token, which is why we increment here
				p.token_index++
				continue
			}
		} else {
			// Bad top-level token
			p.throw_parse_error('"${p.token.value}" is not a valid top-level token. Expected either import, proc or const')
			exit(1)
		}
	}

	// We don't use the function table ".get" method here because we
	// want to throw the error here, at the end of the parsing
	if 'main' !in p.proc_names {
		// In case there is only one proc and it's not a main proc
		// the input ends afer that proc, meaning the index is already at the end
		if p.token_index >= p.all_tokens.len {
			p.token_index--
		}
		p.throw_parse_error('Expected a function called "main" but none was found')
		exit(1)
	}

	return
}

fn (mut p Parser) throw_parse_error(err_msg string) {
	err := term.red(err_msg)
	println('radon_parser Error: \n\n${err} \nOn line: ${p.all_tokens[p.token_index].line_number} - Token-Index: ${p.token_index} \nIn file: ${p.file_name} \nFull path: ${p.file_path}')
}
