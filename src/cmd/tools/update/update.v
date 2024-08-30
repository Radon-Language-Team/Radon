module update

import os
import term

pub fn update() {
	println(term.blue('Updating Radon...'))

	// Find the path of the radon executable and change the working directory to it
	radon_path := os.dir(os.executable())

	os.chdir('${radon_path}/..') or {
		println(term.red('Radon not found in ${os.getwd()}'))
		return
	}

	home := os.getwd()
	println(term.gray('Cleaning Radon directory...'))

	tmp_dir := os.join_path(os.getwd(), 'tmp')
	os.mkdir(tmp_dir) or {
		// already exists - clear it
		os.rmdir_all(tmp_dir) or {
			println(term.red('Failed to clear temporary directory'))
			return
		}
		os.mkdir(tmp_dir) or {
			println(term.red('Failed to create temporary directory'))
			return
		}
	}

	items := os.ls(os.getwd()) or {
		println(term.red('Failed to list Radon directory'))
		return
	}

	for item in items {
		if item != 'tmp' {
			println(term.gray('Moving ${item} to temporary directory...'))
			os.mv(os.join_path(os.getwd(), item), os.join_path(tmp_dir, item)) or {
				println(term.red('Failed to move ${item} to temporary directory -> ${err}'))
				return
			}
		}
	}

	println(term.gray('Updating Radon repository...'))

	println(term.gray('Cloning Radon repository into ${os.getwd()}...'))
	os.execute('git clone https://github.com/Radon-Language-Team/Radon.git')

	os.chdir('Radon') or {
		println(term.red('Failed to change working directory to Radon'))
		return
	}

	println(term.gray('Moving files from Radon Git repository to Radon directory...'))

	git_items := os.ls(os.getwd()) or {
		println(term.red('Failed to list Radon Git repository directory'))
		return
	}

	for item in git_items {
		os.mv(os.join_path(os.getwd(), item), os.join_path(home, item)) or {
			println(term.red('Failed to move ${item} to Radon directory'))
			return
		}
	}

	println(term.gray('Cleaning up...'))

	os.chdir(home) or {
		println(term.red('Failed to change working directory to ${home}'))
		return
	}

	// should be empty
	os.rm('Radon') or {
		println(term.red('Failed to remove Radon Git repository directory'))
		return
	}

	// Build the radon executable
	println(term.gray('Building Radon...'))
	os.execute('./build.sh')

	if os.exists('${os.getwd()}/radon/radon') {
		println(term.green('Radon updated successfully!'))
	} else {
		println(term.red('Failed to build Radon'))
	}
}
