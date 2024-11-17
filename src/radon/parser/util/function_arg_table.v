module util

import parser { Parser }

//TODO: See if I can call this inside the parser
fn (mut p Parser) foo() {
	println('${p.file_name}')
}