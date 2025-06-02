module gen

import structs

fn gen_import(node structs.ImportStmt) string {
	
	if node.path.contains('.rad') {
		return gen_custom_import(node)
	} else {
		return gen_radon_import(node)
	}
}

fn gen_radon_import(node structs.ImportStmt) string {
	println('[NOT YET GENERATED] Radon import -> ${node.path}')
	return ''
}

fn gen_custom_import(node structs.ImportStmt) string {
	println('[NOT YET GENERATED] Custom import -> ${node.path}')
	return ''
}