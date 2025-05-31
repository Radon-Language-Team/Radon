module util

import term

pub fn display_help() {
	println(term.bold(term.bright_blue('Radon Help utility \n')))

	println('${term.yellow('radon run [file]')}    Compile and run a Radon file \n')
	println('${term.gray('run [arguments]')}')
	println('${term.yellow('--json-tokens')}       Output lexed tokens as JSON data \n')

	println('${term.yellow('radon symlink')}       Put\'s Radon inside your System %PATH')
}
