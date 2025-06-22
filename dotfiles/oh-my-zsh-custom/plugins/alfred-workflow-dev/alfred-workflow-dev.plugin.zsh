# shellcheck disable=SC2148

# Adapted from https://github.com/chrisgrieser/alfred-workflow-template

function _alfred-installed-workflow() {
	local git_root=$1
	local workflow_uid
	workflow_uid=$(basename "$git_root")
	local prefs_location
	prefs_location=$(eval echo "$(defaults read com.runningwithcrayons.Alfred-Preferences syncfolder)")

	echo "$prefs_location/Alfred.alfredpreferences/workflows/$workflow_uid"
}

# alfred-build-and-release updates the local git repo to set the release
# version & then pushes the changes to the origin remote (github), assuming
# that this will trigger the actual release process.
# see: .build-and-release.sh
function alfred-build-and-release() {
	local next_version
	local git_root
	git_root="$(git rev-parse --show-toplevel)"

	[[ $# == 1 ]] || return 1
	next_version=$1

	# Prompt for next version number
	current_version=$(plutil -extract version raw "$git_root/Workflow/info.plist")
	echo "current version: $current_version, next version: $next_version"

	# GUARD
	if [[ -z "$next_version" || "$next_version" == "$current_version" ]]; then
		# shellcheck disable=SC2154
		print "${fg[red]}Invalid version number.${reset_color}"
		return 1
	fi

	# update version number in THE REPO'S `info.plist`
	plutil -replace version -string "$next_version" "$git_root/Workflow/info.plist"

	#───────────────────────────────────────────────────────────────────────────────
	# INFO this assumes the local folder is named the same as the github repo
	# 1. update version number in LOCAL `info.plist`

	# update version number in LOCAL `info.plist`
	# prefs_location=$(defaults read com.runningwithcrayons.Alfred-Preferences syncfolder | sed "s|^~|$HOME|")
	# workflow_uid="$(basename "$git_root")"
	# local_info_plist="$prefs_location/Alfred.alfredpreferences/workflows/$workflow_uid/info.plist"
	local local_info_plist
	local_info_plist=$(_alfred-installed-workflow "$git_root")/info.plist
	if [[ -f "$local_info_plist" ]] ; then
		plutil -replace version -string "$next_version" "$local_info_plist"
	else
		print "${fg[yellow]}Could not increment version, local \`info.plist\` not found: '$local_info_plist'${reset_color}"
		return 1
	fi

	#───────────────────────────────────────────────────────────────────────────────

	# commit and push
	git add --all &&
		git commit -m "release: $next_version" &&
		git pull --no-progress &&
		git push --no-progress &&
		git tag -a "$next_version" -m "release: $next_version" && # pushing a tag triggers the github release action
		git push --no-progress origin --tags
}

# alfred-get-changes copies changes to the installed workflow of the same name
# into the current directory
# see: transfer-changes-FROM-local in Justfile
function alfred-get-changes() {
	local git_root
	git_root="$(git rev-parse --show-toplevel)"
	local local_workflow
	local_workflow=$(_alfred-installed-workflow "$git_root")

    rsync --archive --delete --exclude prefs.plist "$local_workflow/" "$git_root/Workflow"
    # TODO: ignore fields/files taht Alfred workflow packaging would
}

# alfred-install-changes installs the local directory changes to the workflow
# to the installed workflow of the same name
# see: transfer-changes-TO-local in Justfile
function alfred-install-changes() {
	local git_root
	git_root="$(git rev-parse --show-toplevel)"
	local local_workflow
	local_workflow=$(_alfred-installed-workflow "$git_root")

    rsync --archive --delete --exclude prefs.plist "$git_root/Workflow/" "$local_workflow"
    # TODO: ignore fields/files taht Alfred workflow packaging would
}

# alfred-diff-changes compares the contents of the local workflow directory
# to the currently installed one of the same name
function alfred-diff-changes() {
	local git_root
	git_root="$(git rev-parse --show-toplevel)"
	local local_workflow
	local_workflow=$(_alfred-installed-workflow "$git_root")

    diff -urN --exclude prefs.plist "$local_workflow/" "$git_root/Workflow"
    # TODO: ignore fields/files taht Alfred workflow packaging would
}

# alfred-cd-installed changes the current directory to the installed
# workflow directory of the same name
function alfred-cd-installed() {
	local git_root
	git_root="$(git rev-parse --show-toplevel)"

	builtin cd "$(_alfred-installed-workflow "$git_root")" || return 1
}

# alfred-link-workflow creates a symlink from the installed Alfred workflow directory
# to the `Workflow/` directory in this git repo
function alfred-link-workflow() {
  	local git_root
	git_root="$(git rev-parse --show-toplevel)"

    ln -s "$(pwd)/Workflow" "$(_alfred-installed-workflow "$git_root")"
}

# alfred-package-workflow zips up the installed workflow directory while
# omitting files & variables that Alfred's `export` functionality would.
# see: https://www.alfredforum.com/topic/9873-how-to-package-workflows-via-the-command-line/
# shellcheck disable=SC2155
function alfred-package-workflow() {
	readonly workflow_dir="${1}"
	readonly info_plist="${workflow_dir}/info.plist"

	if [[ "$#" -ne 1 ]] || [[ ! -f "${info_plist}" ]]; then
	  echo 'You need to give this script a single argument: the path to a valid workflow directory.'
	  echo 'The workflow will be saved to the Desktop.'
	  exit 1
	fi

	readonly workflow_name="$(/usr/libexec/PlistBuddy -c 'print name' "${info_plist}")"
	readonly workflow_file="${HOME}/Desktop/${workflow_name}.alfredworkflow"

	if /usr/libexec/PlistBuddy -c 'print variablesdontexport' "${info_plist}" &> /dev/null; then
	  readonly workflow_dir_to_package="$(mktemp -d)"
	  /bin/cp -R "${workflow_dir}/"* "${workflow_dir_to_package}"

	  readonly tmp_info_plist="${workflow_dir_to_package}/info.plist"
	  /usr/libexec/PlistBuddy -c 'Print variablesdontexport' "${tmp_info_plist}" | grep '    ' | sed -E 's/ {4}//' | xargs -I {} /usr/libexec/PlistBuddy -c "Set variables:'{}' ''" "${tmp_info_plist}"
	else
	  readonly workflow_dir_to_package="${workflow_dir}"
	fi

	DITTONORSRC=1 /usr/bin/ditto -ck "${workflow_dir_to_package}" "${workflow_file}"
	/usr/bin/zip "${workflow_file}" --delete 'prefs.plist' > /dev/null
	echo "Exported worflow to ${workflow_file}"
}

# alfred-workflow-name displays the name of an Alfred workflow directory or `info.plist`
# given as a argument.  The default is to look at the `info.plist` in the current
# directory.
function alfred-workflow-name() {
	local info_file=${1:-.}

	[[ -d "$info_file" ]] && info_file="${info_file}/info.plist"
	plutil -extract name raw "$info_file"
}
