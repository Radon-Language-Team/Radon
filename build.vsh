import os
import term

src := 'src/cmd/radon.v'
output_dir := 'radon'
mut executable_name := ''

match os.user_os() {
	'linux' {
		executable_name = 'radon'
	}
	'windows' {
		executable_name = 'radon.exe'
	}
	'darwin' {
		println(term.red('Unsupported OS'))
		exit(1)
	}
	else {
		println(term.red('Unsupported OS'))
		exit(1)
	}
}

mkdir(output_dir) or {
	if !os.exists(output_dir) {
		println(term.red('Failed to create output directory with error: ${os.last_error()}'))
		exit(1)
	}
}

println(term.bright_blue('Building Radon for ${os.user_os()}...'))

response := os.system('v -os ${os.user_os()} -o ${output_dir}/${executable_name} ${src}')

println(term.bright_blue('Validating build...'))

if response != 0 {
	println(term.red('Failed to build Radon with error: ${os.last_error()}'))
	exit(1)
}

println(term.green('Radon built successfully!'))
exit(0)
