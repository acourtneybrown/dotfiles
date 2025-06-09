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

# .build-and-release.sh
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
		git tag "$next_version" && # pushing a tag triggers the github release action
		git push --no-progress origin --tags

}

function alfred-get-changes() {
	local git_root
	git_root="$(git rev-parse --show-toplevel)"
	local local_workflow
	local_workflow=$(_alfred-installed-workflow "$git_root")

    rsync --archive --delete "$local_workflow/" "$git_root/Workflow"
}

function alfred-install-changes() {
	local git_root
	git_root="$(git rev-parse --show-toplevel)"
	local local_workflow
	local_workflow=$(_alfred-installed-workflow "$git_root")

    rsync --archive --delete "$git_root/Workflow/" "$local_workflow"
}

function alfred-diff-changes() {
	local git_root
	git_root="$(git rev-parse --show-toplevel)"
	local local_workflow
	local_workflow=$(_alfred-installed-workflow "$git_root")

    diff -urN "$local_workflow/" "$git_root/Workflow"
}
