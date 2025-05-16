module run

import os
import json
import util
import radon.structs { App }
import radon.lexer
import radon.parser

pub fn run() ! {
	// Check if the user provided a file path
	if os.args.len < 3 {
		util.print_error('Usage: radon run <file_path>')
		exit(1)
	}

	file_path := os.args[2]

	// Check if the file exists
	if !os.exists(file_path) {
		util.print_error('File `${file_path}` does not exist')
		exit(1)
	}

	mut app := App{
		file_path:    file_path
		file_name:    os.file_name(file_path)
		index:        0
		line_count:   1
		column_count: 1
	}

	if '--json-tokens' in os.args {
		app.display_json_tokens = true
	}

	lexer.lex_file(mut app)!
	app.index = 0
	parser.parse(mut app)!

	if app.display_json_tokens {
		json_tokens := json.encode_pretty(app.all_tokens)
		println(json_tokens)
	}
}
