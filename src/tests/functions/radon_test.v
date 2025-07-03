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
