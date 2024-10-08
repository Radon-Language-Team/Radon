module parser

import term
import token
import nodes
import util { Operation }

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

	proc_body := p.parse_proc_inside(proc.new_index, proc.return_type) or {
		p.throw_parse_error('Failed to parse proc body')
		exit(1)
	}

	proc.body = proc_body

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

fn (mut p Parser) parse_proc_inside(i int, proc_return_type token.TokenType) ![]nodes.Node {
	tokens := p.all_tokens
	mut index := i
	mut proc_body_nodes := []nodes.Node{}

	println(term.gray('Parsing ${tokens[i..].len} tokens inside proc'))

	for index < p.all_tokens.len {
		token_to_match := tokens[index].token_type.str()
		match token_to_match {
			'${token.TokenType.key_ret}' {
				return_result := p.parse_return(index)
				index = return_result.new_index
				return_node := return_result

				if proc_return_type != return_result.return_type {
					p.throw_parse_error('Proc has a declared return type of ${proc_return_type} but returns an expression of type ${return_result.return_type}')
					exit(1)
				}

				return_kind_assign := nodes.NodeKind{
					return_node: return_node
				}

				proc_body_nodes << nodes.Node{
					node_kind: return_kind_assign
				}
			}
			'${token.TokenType.var_name}' {
				var_result := p.parse_variable(index)
				index = var_result.new_index
				var_kind_assign := nodes.NodeKind{
					var_node: var_result
				}

				proc_body_nodes << nodes.Node{
					node_kind: var_kind_assign
				}
				util.variable_table(var_result, '', Operation.set)
			}
			'${token.TokenType.close_brace}' {
				index += 1
			}
			else {
				p.throw_parse_error('Unknown token: "${tokens[index].value}"')
				exit(1)
			}
		}
	}

	return proc_body_nodes
}
