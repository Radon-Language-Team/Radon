module parser

import term
import nodes

pub enum ProcOperation {
	get
	set
	delete
	debug
	clear
}

struct ProcTableResult {
	success  bool
	function ?nodes.NodeProc
}

// Stores a list of functions and their names
// This makes it easy to look up functions by name
// and to see if a function exists
pub fn (mut p Parser) function_table(proc nodes.NodeProc, proc_name string, operation ProcOperation) ProcTableResult {
	match operation.str() {
		'${ProcOperation.get}' {
			proc_name_index := p.proc_names.index(proc_name)
			if proc_name_index == -1 {
				p.throw_parse_error('Expected function "${proc_name}" to exist but it does not')
				exit(1)
			}

			function := p.procs[proc_name_index]

			proc_result := ProcTableResult{
				success:  true
				function: function
			}

			return proc_result
		}
		'${ProcOperation.debug}' {
			println(term.yellow('Function table:'))
			for i, table_itemt in p.procs {
				println(term.yellow('  ${i}: ${table_itemt.name}'))
			}
			return ProcTableResult{
				success: true
			}
		}
		'${ProcOperation.set}' {
			p.proc_names << proc.name
			p.procs << proc
			return ProcTableResult{
				success:  true
				function: proc
			}
		}
		'${ProcOperation.delete}' {
			return ProcTableResult{
				success: false
			}
		}
		'${ProcOperation.clear}' {
			p.proc_names = []
			p.procs = []
			return ProcTableResult{
				success: true
			}
		}
		else {
			println(term.yellow('Unknown function operation'))
			return ProcTableResult{
				success: false
			}
		}
	}
}
