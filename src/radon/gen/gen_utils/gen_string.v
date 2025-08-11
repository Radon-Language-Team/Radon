module gen_utils

import structs
import cmd.util { print_error }

pub fn gen_string(node structs.AstNode) string {
	if node.type_name() == 'radon.structs.Expression' {
		expression := node as structs.Expression
		mut string_value := ''

		if expression.string_inter {
			mut final_string := ''
			mut expressions := ''
			mut last_index := 0

			for obj in expression.string_object {
				mut format_part := match obj.replacement_type {
					.type_string {
						'%s'
					}
					.type_int {
						'%d'
					}
					else {
						println('Unknown type, defaulting to %s')
						'%s'
					}
				}

				// Add static string part before this interpolation
				final_string += expression.value[last_index..obj.replacement_pos.start]

				// Add the format specifier
				final_string += format_part

				// Move the last_index forward
				// Move this up by one too, since we stopped on the closing brace
				last_index = obj.replacement_pos.end + 1

				replacement_obj := obj.replacement as structs.VarDecl
				expressions += '${replacement_obj.name} '

				if obj != expression.string_object.last() {
					expressions += ', '
				}
			}

			// Add the remaining part of the string after the last interpolation
			final_string += expression.value[last_index..]

			string_value = '"${final_string}"' + ', ${expressions}'
		} else {
			string_value = '"${expression.value}"'
		}

		return string_value
	} else {
		print_error('${node.type_name()} does not have it\'s string function yet :)')
		exit(1)
	}
}
