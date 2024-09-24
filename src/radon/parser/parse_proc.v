module parser

import token
import nodes

struct ProcArgs {
	args      []nodes.NodeProcArg
	new_index int
	success   bool
	message   string
}

pub fn (mut p Parser) parse_proc(index int) !nodes.NodeProc {
	mut proc := nodes.NodeProc{
		new_index:     index
		name:          ''
		params:        []nodes.NodeProcArg{}
		return_type:   token.TokenType.radon_null
		body:          []nodes.Node{}
		bracket_count: 0
	}

	proc.new_index += 1

	// Parse the proc name
	// This should either be of token type proc_name or key_main
	if p.all_tokens[proc.new_index].token_type != token.TokenType.proc_name
		&& p.all_tokens[proc.new_index].token_type != token.TokenType.key_main {
		p.throw_parse_error('Expected token of type proc_name or key_main but got ${p.all_tokens[proc.new_index].token_type}')
		exit(1)
	}

	proc.name = p.all_tokens[proc.new_index].value
	proc.new_index += 1

	if p.all_tokens[proc.new_index].token_type != token.TokenType.open_paren {
		p.throw_parse_error('Expected open parenthesis but got ${p.all_tokens[proc.new_index].value}')
		exit(1)
	} else {
		proc.new_index += 1
		proc_args := parse_proc_args(p.all_tokens, proc.new_index) or {
			p.throw_parse_error('Failed to parse proc arguments')
			exit(1)
		}

		if !proc_args.success {
			p.throw_parse_error('Failed to parse proc arguments! Message: ${proc_args.message}')
			exit(1)
		}

		proc.params = proc_args.args
		proc.new_index = proc_args.new_index
	}

	println('${p.all_tokens[proc.new_index].value} - ${p.all_tokens[proc.new_index + 1].value}')

	if p.all_tokens[proc.new_index].token_type != token.TokenType.function_return
		|| token.check_if_token_is_type(p.all_tokens[proc.new_index + 1].token_type) != true {
		p.throw_parse_error('Expected function to have return type but got ${p.all_tokens[
			proc.new_index + 1].token_type}')
		exit(1)
	}
	proc.new_index += 1
	proc.return_type = p.all_tokens[proc.new_index].token_type
	proc.new_index += 1

	if p.all_tokens[proc.new_index].token_type != token.TokenType.open_brace {
		p.throw_parse_error('Expected open brace but got ${p.all_tokens[proc.new_index].value}')
		exit(1)
	} else {
		proc.bracket_count += 1
		proc.new_index += 1
	}

	p.parse_proc_inside(proc.new_index, p.all_tokens)

	return proc
}

fn parse_proc_args(tokens []token.Token, index int) !ProcArgs {
	mut i := index
	mut args := []nodes.NodeProcArg{}
	mut current_arg := nodes.NodeProcArg{}

	for tokens[i].token_type != token.TokenType.close_paren && i <= tokens.len {
		current_arg.is_array = false
		if tokens[i].token_type != token.TokenType.var_name {
			return ProcArgs{
				args:      args
				new_index: i
				success:   false
				message:   'Expected token of type var_name but got ${tokens[i].token_type}'
			}
		} else {
			current_arg.arg_name = tokens[i].value
			i += 1
		}
		if tokens[i].token_type == token.TokenType.array_full {
			current_arg.is_array = true
			i += 1
		}
		arg_is_token_type := token.check_if_token_is_type(tokens[i].token_type)
		if arg_is_token_type {
			current_arg.arg_type = tokens[i].value
			i += 1
		} else {
			return ProcArgs{
				args:      args
				new_index: i
				success:   false
				message:   'Expected token type but got ${tokens[i].token_type}'
			}
		}

		args << current_arg
		if tokens[i].token_type == token.TokenType.comma {
			i += 1
		}
	}
	i += 1
	return ProcArgs{
		args:      args
		new_index: i
		success:   true
	}
}

fn (mut p Parser) parse_proc_inside(index int, t []token.Token) {
	tokens := t[index..]

	println('Parsing ${tokens.len} tokens inside proc')
}
