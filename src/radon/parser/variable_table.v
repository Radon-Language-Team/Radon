module parser

import term
import nodes

pub enum VarOperation {
	get
	set
	delete
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
			for i, table_itemt in p.variables {
				println(term.yellow('  ${i}: ${table_itemt.name} = ${table_itemt.value}'))
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
		'${VarOperation.delete}' {
			return VariableTableResult{
				success: false
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
