module parser

import token { TokenType }
import nodes

pub fn (mut p Parser) parse_proc_call(index int) nodes.NodeProcCall {
	mut proc_call := nodes.NodeProcCall{
		new_index:   index
		called_proc: nodes.NodeProc{}
		name:        ''
		args:        []token.Token{}
	}

	proc_call.name = p.all_tokens[index].value
	function_to_call := p.function_table(nodes.NodeProc{}, proc_call.name, ProcOperation.get)

	proc_call.called_proc = function_to_call.function
	proc_call.new_index++

	// Check if the next token is an open parenthesis
	if p.all_tokens[proc_call.new_index].token_type != TokenType.open_paren {
		p.throw_parse_error('Expected open parenthesis but got "${p.all_tokens[proc_call.new_index].value}"')
		exit(1)
	}

	proc_call.new_index++
	// TODO: Perhaps do this differently. We are kind of doing the same thing twice
	mut unsplit_arguments := []token.Token{}
	mut arguments := []token.Token{}
	// If the next token is a close parenthesis, we can return early because there are no arguments in the function call
	// If not, we need to parse the arguments
	if p.all_tokens[proc_call.new_index].token_type != TokenType.close_paren {
		for p.all_tokens[proc_call.new_index].token_type != TokenType.close_paren {
			unsplit_arguments << p.all_tokens[proc_call.new_index]
			proc_call.new_index++
		}
	}

	proc_call.new_index++

	// Remove all commas from the arguments
	if unsplit_arguments.len > 1 {
		arguments = unsplit_arguments.filter(it.token_type != TokenType.comma)
	} else {
		arguments = unsplit_arguments.clone()
	}

	if arguments.len != proc_call.called_proc.params.len {
		p.throw_parse_error('Expected argument count for function "${proc_call.called_proc.name}": ${proc_call.called_proc.params.len} \nReceived: ${arguments.len}')
		exit(1)
	}

	proc_call.args = arguments
	proc_call.new_index++

	return proc_call
}
