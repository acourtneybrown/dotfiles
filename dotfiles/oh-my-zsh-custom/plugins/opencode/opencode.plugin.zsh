# shellcheck disable=SC2148

export LMSTUDIO_API_KEY=$(op read "op://jrew5nqtk5aqdgupcoxqjuevwu/rbbgcx424dsim3tblf2s3kca34/credential")

# requires `git-custom` plugin has also been loaded for `git_slug` function

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
	    -e "LMSTUDIO_API_KEY=${LMSTUDIO_API_KEY}" \
	    -v .:/workspace \
	    -v ${HOME}/.config/opencode/opencode.json:/root/.config/opencode/opencode.json:ro \
	    -v ${HOME}/.config/opencode/tui.json:/root/.config/opencode/tui.json:ro \
	    -v "opencode-${GIT_SLUG//\//_}":/root/.local/share/opencode \
	    --workdir /workspace \
	    --name "opencode-${GIT_SLUG//\//_}" \
	    "$IMAGE" "$@"
}
