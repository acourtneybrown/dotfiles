# shellcheck disable=SC2148

function git_slug() {
	local DIR

	DIR=${1:-.}
	git -C "$DIR" remote get-url origin 2>/dev/null | sed -E 's#.*[:/]([^/]+/[^/]+)(\.git)?#\1#; s#\.git$##'
}

function opencode() {
	local IMAGE
	local GIT_SLUG

	IMAGE="${IMAGE:-ghcr.io/anomalyco/opencode:latest}"
	GIT_SLUG=$(git_slug)

	if [[ ! $GIT_SLUG ]]; then
		echo "Must be called from a git repository"
	    return 1
	fi

	container run -it --rm \
	    -e "LMSTUDIO_API_KEY=$(op read "op://jrew5nqtk5aqdgupcoxqjuevwu/rbbgcx424dsim3tblf2s3kca34/credential")" \
	    -v .:/workspace \
	    -v ~/.config/opencode/opencode.json:/workspace/.opencode/opencode.json:ro \
	    -v ~/.config/opencode/tui.json:/workspace/.opencode/tui.json:ro \
	    --workdir /workspace \
	    --name "opencode-${GIT_SLUG//\//_}" \
	    "$IMAGE" "$@"
}
