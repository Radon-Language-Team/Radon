module update

import os
import term

pub fn update() {
	mut in_dev_mode := false

	if os.args.len > 2 {
		if os.args[2] == '--dev' {
			in_dev_mode = true
		} else {
			println(term.red('Invalid argument: ${os.args[2]}'))
			return
		}
	}

	println(term.blue('Updating Radon...'))

	// Find the path of the radon executable and change the working directory to it
	radon_path := os.dir(os.executable())

	os.chdir('${radon_path}/..') or {
		println(term.red('Radon not found in ${os.getwd()}'))
		return
	}

	home := os.getwd()
	println(term.gray('Creating tmp directory and storing files...'))

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
			os.mv(os.join_path(os.getwd(), item), os.join_path(tmp_dir, item)) or {
				println(term.red('Failed to move ${item} to temporary directory -> ${err}'))
				return
			}
		}
	}

	println(term.gray('Fetching Radon...'))
	println(term.gray('Cloning Radon repository into ${os.getwd()}...'))
	os.execute('git clone https://github.com/Radon-Language-Team/Radon.git')

	os.chdir('Radon') or {
		println(term.red('Failed to change working directory to Radon'))
		return
	}

	if in_dev_mode {
		println(term.gray('In development mode, switching to dev branch...'))
		os.execute('git checkout new_radon')
		println(term.gray('Pulling latest changes...'))
		os.execute('git pull')
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
	os.execute('make')

	if os.exists('${os.getwd()}/radon/radon') {
		println(term.green('Radon updated successfully!'))
		println(term.bright_green('Temporary files stored in ${tmp_dir} are saved for safety but can be deleted.'))
	} else {
		println(term.red('Failed to build Radon'))
	}
}
