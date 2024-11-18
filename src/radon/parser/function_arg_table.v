module parser

import term
import nodes

pub enum ArgOperation {
	get
	set
	debug
	clear
}

pub struct ArgTableResult {
	success bool
	arg     ?nodes.NodeProcArg
}

/*
Stores a list of function arguments and their names

arg: The current function argument
proc_name_arg_name: The name of the function and the argument ('main-arg') - ${proc_name}_${arg-name}
operation: The operation to perform on the function argument table
*/
pub fn (mut p Parser) function_arg_table(arg nodes.NodeProcArg, proc_name_arg_name string, operation ArgOperation) ArgTableResult {
	match operation.str() {
		'${ArgOperation.get}' {
			arg_name_index := p.proc_arg_proc_names.index(proc_name_arg_name)

			if arg_name_index == -1 {
				p.throw_parse_error('Expected function argument "${proc_name_arg_name}" to exist but it does not')
				exit(1)
			}

			arg_to_send := p.proc_args[arg_name_index]

			arg_result := ArgTableResult{
				success: true
				arg:     arg_to_send
			}
			return arg_result
		}
		'${ArgOperation.debug}' {
			println(term.yellow('Function argument table:'))
			for i, table_item in p.proc_args {
				println(term.yellow('  ${i}: Argument ${table_item.arg_name} in function ${table_item.proc_name} with type ${table_item.arg_type}: isArray: ${table_item.is_array} | isOptional: ${table_item.is_optional}'))
			}
			return ArgTableResult{
				success: true
			}
		}
		'${ArgOperation.set}' {
			p.proc_arg_proc_names << '${arg.proc_name}-${arg.arg_name}'
			p.proc_args << arg
			return ArgTableResult{
				success: true
				arg:     arg
			}
		}
		'${ArgOperation.clear}' {
			p.proc_arg_proc_names = []
			p.proc_args = []
			return ArgTableResult{
				success: true
			}
		}
		else {
			p.throw_parse_error('Invalid operation: ${operation}')
			exit(1)
		}
	}
}
