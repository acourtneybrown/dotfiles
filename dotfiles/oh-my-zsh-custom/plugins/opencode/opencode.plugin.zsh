# shellcheck disable=SC2148

function opencode() {
	container run -it --rm \
	    -e "LMSTUDIO_API_KEY=$(op read "op://jrew5nqtk5aqdgupcoxqjuevwu/rbbgcx424dsim3tblf2s3kca34/credential")" \
	    -v .:/workspace \
	    -v ~/.config/opencode/opencode.json:/workspace/.opencode/opencode.json:ro \
	    -v ~/.config/opencode/tui.json:/workspace/.opencode/tui.json:ro \
	    --workdir /workspace \
	    ghcr.io/anomalyco/opencode "$@"
}
