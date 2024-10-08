module util

import term
import nodes

pub enum Operation {
	get
	set
	delete
}

pub struct VariableTable {
mut:
	variable_names []string
	variables      []nodes.NodeVar
}

struct VariableTableResult {
	success  bool
	variable ?nodes.NodeVar
}

pub fn variable_table(var nodes.NodeVar, variable_name string, operation Operation) VariableTableResult {
	mut table := VariableTable{
		variable_names: []
		variables:      []
	}

	match operation.str() {
		'${Operation.get}' {
			return table.get_variable(variable_name)
		}
		'${Operation.set}' {
			return table.set_variable(var)
		}
		'${Operation.delete}' {
			return table.delete_variable(var)
		}
		else {
			println(term.yellow('Unknown variable operation'))
			return VariableTableResult{
				success: false
			}
		}
	}
}

fn (mut table VariableTable) get_variable(var_name string) VariableTableResult {
	println('Getting variable: ${var_name} with table ${table.variables}')
	var_name_index := table.variable_names.index(var_name)
	if var_name_index == -1 {
		println(term.yellow('[parser_warning] Variable not found at given index'))
		return VariableTableResult{
			success: false
		}
	}
	variable := table.variables[var_name_index]

	variable_result := VariableTableResult{
		success:  true
		variable: variable
	}

	return variable_result
}

fn (mut table VariableTable) set_variable(variable nodes.NodeVar) VariableTableResult {
	table.variable_names << variable.name
	table.variables << variable

	// println('Table after setting variable: ${table.variables}')

	return VariableTableResult{
		success:  true
		variable: variable
	}
}

fn (mut table VariableTable) delete_variable(variable nodes.NodeVar) VariableTableResult {
	println('Deleting variable: ${variable.name}')

	// TODO: implement this when needed :)
	return VariableTableResult{
		success: false
	}
}
