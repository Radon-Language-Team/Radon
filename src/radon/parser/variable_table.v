module parser

import term
import nodes

pub enum VarOperation {
	get
	set
	delete
}

struct VariableTableResult {
	success  bool
	variable ?nodes.NodeVar
}

pub fn (mut p Parser) variable_table(var nodes.NodeVar, variable_name string, operation VarOperation) VariableTableResult {
	match operation.str() {
		'${VarOperation.get}' {
			var_name_index := p.variable_names.index(variable_name)
			if var_name_index == -1 {
				println(term.yellow('[parser_warning] Variable not found at given index'))
				return VariableTableResult{
					success: false
				}
			}

			variable := p.variables[var_name_index]

			variable_result := VariableTableResult{
				success:  true
				variable: variable
			}

			return variable_result
		}
		'${VarOperation.set}' {
			p.variable_names << var.name
			p.variables << var
			return VariableTableResult{
				success:  true
				variable: var
			}
		}
		'${VarOperation.delete}' {
			return VariableTableResult{
				success: false
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
