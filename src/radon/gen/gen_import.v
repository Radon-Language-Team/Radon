module gen

import structs

const core_import_string = '#include <stdio.h>

void println(char* x) 
{ 
	printf("%s\\n", x);
}
'

fn gen_import(node structs.ImportStmt) string {
	if node.path.contains('.rad') {
		return gen_custom_import(node)
	} else {
		return gen_radon_import(node)
	}
}

fn gen_radon_import(node structs.ImportStmt) string {
	if node.path == 'core' {
		return core_import_string
	} else {
		return ''
	}
}

fn gen_custom_import(node structs.ImportStmt) string {
	println('[NOT YET GENERATED] Custom import -> ${node.path}')
	return ''
}
