export LMSTUDIO_API_KEY

function opencode() {
	local IMAGE
	local DIRNAME

	IMAGE="${IMAGE:-ghcr.io/anomalyco/opencode:latest}"
	DIRNAME=$(basename $(pwd))

	container run -it --rm \
	    -e "LMSTUDIO_API_KEY=${LMSTUDIO_API_KEY:=$(op read "op://jrew5nqtk5aqdgupcoxqjuevwu/rbbgcx424dsim3tblf2s3kca34/credential")}" \
	    -v .:/workspace \
	    -v ${HOME}/.config/opencode/opencode.json:/root/.config/opencode/opencode.json:ro \
	    -v ${HOME}/.config/opencode/tui.json:/root/.config/opencode/tui.json:ro \
	    -v "opencode-${DIRNAME}":/root/.local/share/opencode \
	    --workdir /workspace \
	    --name "opencode-${DIRNAME}" \
	    "$IMAGE" "$@"
}
