module tests

import os

fn test_simple_print() {
	file_path := 'src/tests/functions/simple_print.rad'
	output := os.execute('radon run ${file_path}')

	assert output.exit_code == 0
	assert output.output == 'Success!\n'
}

fn test_complex_print() {
	file_path := 'src/tests/functions/complex_print.rad'
	output := os.execute('radon run ${file_path}')

	assert output.exit_code == 0
	assert output.output == 'Success!\n'
}

fn test_if_statements() {
	file_path := 'src/tests/control/if_statements.rad'
	output := os.execute('radon run ${file_path}')

	exit_code := output.exit_code

	if exit_code != 0 {
		println(output.output)
	}

	assert exit_code == 0
	assert output.output == 'All if tests passed!\n'
}
