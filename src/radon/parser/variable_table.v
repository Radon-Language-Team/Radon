module parser

import term
import nodes

pub enum VarOperation {
	get
	set
	debug
	clear
}

struct VariableTableResult {
	success  bool
	variable ?nodes.NodeVar
}

// Stores a list of variables and their names
pub fn (mut p Parser) variable_table(var nodes.NodeVar, variable_name string, operation VarOperation) VariableTableResult {
	match operation.str() {
		'${VarOperation.get}' {
			var_name_index := p.variable_names.index(variable_name)
			if var_name_index == -1 {
				// Check if the variable is a function argument
				current_proc := p.function_arg_table(nodes.NodeProcArg{}, '${p.current_proc_name}-${variable_name}',
					ArgOperation.get)

				if current_proc.success {
					arag_as_var := nodes.NodeVar{
						new_index: 0
						name:      current_proc.arg!.arg_name
						// As for args, we don't know the value yet
						// It is for the user to set
						value:    current_proc.arg!.arg_name
						var_type: current_proc.arg!.arg_type
					}

					return VariableTableResult{
						success:  true
						variable: arag_as_var
					}
				}
				p.throw_parse_error('Expected variable "${variable_name}" to exist but it does not')
				exit(1)
			}

			variable := p.variables[var_name_index]

			variable_result := VariableTableResult{
				success:  true
				variable: variable
			}

			return variable_result
		}
		'${VarOperation.debug}' {
			println(term.yellow('Variable table:'))
			for i, table_item in p.variables {
				println(term.yellow('  ${i}: ${table_item.name} = ${table_item.value}'))
			}
			return VariableTableResult{
				success: true
			}
		}
		'${VarOperation.set}' {
			p.variable_names << var.name
			p.variables << var
			return VariableTableResult{
				success:  true
				variable: var
			}
		}
		'${VarOperation.clear}' {
			p.variable_names = []
			p.variables = []
			return VariableTableResult{
				success: true
			}
		}
		else {
			println(term.yellow('Unknown variable operation'))
			return VariableTableResult{
				success: false
			}
		}
	}
}
