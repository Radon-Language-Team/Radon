module gen

import structs

fn gen_import(node structs.ImportStmt) string {
	println('[NOT YET GENERATED] Got import with path: ${node.path}')
	return ''
}