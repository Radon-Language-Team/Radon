module parser

import term
import nodes

pub enum ProcOperation {
	get
	set
	debug
	clear
}

struct ProcTableResult {
	success  bool
	function nodes.NodeProc
}

// Stores a list of functions and their names
// This makes it easy to look up functions by name
// and to see if a function exists
pub fn (mut p Parser) function_table(proc nodes.NodeProc, proc_name string, operation ProcOperation) ProcTableResult {
	match operation {
		.get {
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
		.debug {
			println(term.yellow('Function table:'))
			for i, table_item in p.procs {
				println(term.yellow('  ${i}: ${table_item.name}'))
			}
			return ProcTableResult{
				success: true
			}
		}
		.set {
			p.proc_names << proc.name
			p.procs << proc
			return ProcTableResult{
				success:  true
				function: proc
			}
		}
		.clear {
			p.proc_names = []
			p.procs = []
			return ProcTableResult{
				success: true
			}
		}
	}
}
