# Setup & activate python virtual env

# Creates a virtualenv for the given name, or .venv/ if not given
function ve() {
	local env
	if [ $# -eq 0 ]; then
		env=.venv
	else
		env="$1"
	fi
	python3 -m venv ${env}
}

# Creates a virtualenv for Python2 for the given name, or .venv if not given
function ve2() {
	local env
	if [ $# -eq 0 ]; then
		env=.venv
	else
		env="$1"
	fi
	virtualenv ${env}
}

# Activates a virtualenv for the given name, or .venv/ if not given
function va() {
	local env
	if [ $# -eq 0 ]; then
		env=.venv
	else
		env="$1"
	fi
	source ${env}/bin/activate
}