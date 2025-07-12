module gen_utils

import structs

pub fn insert_decays(app &structs.App) string {
	all_allocs := app.all_allocations
	all_decays := app.decays

	mut final_decays := ''
	mut needed_decays := []string{}

	for alloc in all_allocs {
		if alloc !in all_decays {
			needed_decays << alloc
		}
	}

	if needed_decays.len == 0 {
		return ''
	} else {
		for decay in needed_decays {
			final_decays += '\n// Automatically added by `-auto-decay` \n'
			final_decays += 'free(${decay});\n'
		}
		return final_decays
	}
}
