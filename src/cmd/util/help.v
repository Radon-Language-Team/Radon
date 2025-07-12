module util

import term

pub fn display_help() {
	println(term.bold(term.bright_blue('Radon Help utility \n')))

	println('${term.yellow('radon run [file]')}    Compile and run a Radon file \n')
	println('${term.gray('run [arguments]')}')
	println('${term.yellow('-json-tokens')}        Output lexed tokens as JSON data')
	println('${term.yellow('-cc')}                 Choose the compiler you want to use')
	println('${term.yellow('-p')}                  Preserve the generated files')
	println('${term.yellow('-v')}                  Enable verbose output')
	println('${term.yellow('-no-run')}             Only generates the binary without running it')
	println('${term.yellow('-auto-decay')}         [Very early and not safe]: The compiler adds necessary free calls automatially at the end of a function\n')

	println('${term.yellow('radon symlink')}       Put\'s Radon inside your System %PATH')
}
