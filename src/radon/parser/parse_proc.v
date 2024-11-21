module parser

import token
import nodes { NodeProc }

struct ProcArgs {
	args      []nodes.NodeProcArg
	new_index int
	success   bool
	message   string
}

pub fn (mut p Parser) parse_proc(index int) !NodeProc {
	mut proc := NodeProc{
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
		p.throw_parse_error('Expected token of type proc_name or key_main but got ${p.all_tokens[proc.new_index].token_type} with value "${p.all_tokens[proc.new_index].value}"')
		exit(1)
	}

	proc.name = p.all_tokens[proc.new_index].value
	proc.new_index += 1

	if p.all_tokens[proc.new_index].token_type != token.TokenType.open_paren {
		p.throw_parse_error('Expected open parenthesis but got ${p.all_tokens[proc.new_index].value}')
		exit(1)
	} else {
		proc.new_index += 1
		proc_args := p.parse_proc_args(p.all_tokens, proc.new_index, proc.name) or {
			p.throw_parse_error('Failed to parse proc arguments')
			exit(1)
		}

		if !proc_args.success {
			p.throw_parse_error('Failed to parse proc arguments: \n\n${proc_args.message}')
			exit(1)
		}

		proc.params = proc_args.args
		proc.new_index = proc_args.new_index
	}

	if p.all_tokens[proc.new_index].token_type != token.TokenType.function_return
		|| token.check_if_token_is_type(p.all_tokens[proc.new_index + 1]) != true {
		p.throw_parse_error('Expected function to have return type but got ${p.all_tokens[
			proc.new_index + 1].token_type} with value "${p.all_tokens[proc.new_index + 1].value}"')
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

	proc_body := p.parse_proc_inside(proc.new_index, proc.return_type, proc.bracket_count) or {
		p.throw_parse_error('Failed to parse proc body')
		exit(1)
	}

	proc.body = proc_body

	return proc
}

fn (mut p Parser) parse_proc_args(tokens []token.Token, index int, proc_name string) !ProcArgs {
	mut i := index
	mut args := []nodes.NodeProcArg{}
	mut current_arg := nodes.NodeProcArg{}

	for tokens[i].token_type != token.TokenType.close_paren && i <= tokens.len {
		current_arg.is_array = false
		current_arg.is_optional = false
		current_arg.proc_name = proc_name
		if tokens[i].token_type != token.TokenType.var_name {
			return ProcArgs{
				args:      args
				new_index: i
				success:   false
				message:   'Expected token of type var_name but got ${tokens[i].token_type}'
			}
		} else {
			current_arg.arg_name = tokens[i].value
			i++
		}
		if tokens[i].token_type == token.TokenType.array_full {
			current_arg.is_array = true
			i++
		}
		arg_is_token_type := token.check_if_token_is_type(tokens[i])
		if arg_is_token_type {
			current_arg.arg_type = tokens[i].value
			i++
		} else {
			return ProcArgs{
				args:      args
				new_index: i
				success:   false
				message:   'Expected token type but got ${tokens[i].token_type} with value "${tokens[i].value}"'
			}
		}

		args << current_arg
		p.function_arg_table(current_arg, '${proc_name}-${current_arg.arg_name}', ArgOperation.set)
		if tokens[i].token_type == token.TokenType.comma {
			i++
		}
	}
	i++
	return ProcArgs{
		args:      args
		new_index: i
		success:   true
	}
}

fn (mut p Parser) parse_proc_inside(i int, proc_return_type token.TokenType, b_count int) ![]nodes.Node {
	tokens := p.all_tokens
	mut index := i
	mut bracket_count := b_count
	mut proc_body_nodes := []nodes.Node{}

	for index < p.all_tokens.len {
		token_to_match := tokens[index].token_type.str()
		match token_to_match {
			'${token.TokenType.key_ret}' {
				return_result := p.parse_return(index)
				index = return_result.new_index
				return_node := return_result

				if proc_return_type != return_result.return_type {
					p.throw_parse_error('Proc has a declared return of ${proc_return_type} but returns an expression of ${return_result.return_type}')
					exit(1)
				}

				return_kind_assign := nodes.NodeKind{
					return_node: return_node
				}

				proc_body_nodes << nodes.Node{
					node_type: nodes.NodeType.return_node
					node_kind: return_kind_assign
				}
				p.token_index = index
			}
			'${token.TokenType.var_name}' {
				var_result := p.parse_variable(index)
				index = var_result.new_index
				var_kind_assign := nodes.NodeKind{
					var_node: var_result
				}

				proc_body_nodes << nodes.Node{
					node_type: nodes.NodeType.var_node
					node_kind: var_kind_assign
				}
				p.variable_table(var_result, '', VarOperation.set)
				p.token_index = index
			}
			'${token.TokenType.proc_call}' {
				p.parse_proc_call(index)
			}
			'${token.TokenType.close_brace}' {
				p.token_index = index++
				bracket_count -= 1

				if bracket_count == 0 {
					return proc_body_nodes
				}
			}
			else {
				p.throw_parse_error('Unknown (inside) token: "${tokens[index].value}" of type ${tokens[index].token_type}')
				exit(1)
			}
		}
	}

	return proc_body_nodes
}
