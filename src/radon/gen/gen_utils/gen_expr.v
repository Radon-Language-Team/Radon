module gen_utils

import structs
import cmd.util { print_error }

@[inline]
pub fn gen_expression(expr structs.AstNode) string {
	expr_type := expr.type_name()

	match expr_type {
		'radon.structs.Expression' {
			e := expr as structs.Expression
			e_type := e.e_type

			if e_type == .type_int {
				// Literal expressions > 10, 54, -10
				return e.value
			} else if e_type == .type_string && !e.is_variable {
				// String epxressions > "Hello ${name}", "Bye"
				return gen_string(expr)
			} else if e_type == .type_bool {
				// Boolean expressions > true, false, result -> Any variable with a bool type
				if e.is_variable {
					return e.value
				}
				return match e.value {
					'true' {
						1
					}
					'false' {
						0
					}
					else {
						println('Unkown bool value > Defaulting to 0')
						0
					}
				}.str()
			} else {
				print_error('Hit unknown expression branch_type > ${e.e_type}')
				exit(1)
			}
		}
		'radon.structs.Literal' {
			l := expr as structs.Literal
			return l.value.str()
		}
		else {
			print_error('Can not generate expression of type `${expr_type}`')
			exit(1)
		}
	}
}
