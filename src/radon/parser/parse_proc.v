module parser

import token
import nodes

pub fn (mut p Parser) parse_proc(index int) !nodes.NodeProc {
	mut proc := nodes.NodeProc{
		new_index: index
		name:      ''
		params:    []nodes.NodeProcArg{}
		body:      []nodes.Node{}
	}

	proc.new_index += 1

	// Parse the proc name
	// This should either be of token type proc_name or key_main
	if p.all_tokens[p.token_index].token_type != token.TokenType.proc_name
		&& p.all_tokens[p.token_index].token_type != token.TokenType.key_main {
		p.throw_parse_error('Expected token of type proc_name or key_main but got ${p.all_tokens[p.token_index].token_type}')
		exit(1)
	}

	proc.name = p.all_tokens[p.token_index].value
	proc.new_index += 1

	if p.all_tokens[p.token_index].token_type != token.TokenType.open_paren {
		p.throw_parse_error('Expected open parenthesis but got ${p.all_tokens[p.token_index].value}')
		exit(1)
	} else {
		proc.new_index += 1
		parse_proc_args(p.all_tokens, p.token_index) or {
			p.throw_parse_error('Failed to parse proc arguments')
			exit(1)
		}
	}

	return proc
}

fn parse_proc_args(tokens []token.Token, index int) ![]nodes.NodeProcArg {
	mut i := index
	mut args := []nodes.NodeProcArg{}
	mut current_arg := nodes.NodeProcArg{}

	for tokens[i].token_type != token.TokenType.close_paren {
		if tokens[i].token_type != token.TokenType.var_name {
			return args
		} else {
			current_arg.arg_name = tokens[i].value
			i += 1
		}

		
	}

	return args
}
