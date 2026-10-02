export LMSTUDIO_API_KEY
export SBX_MODEL=qwen/qwen3.6-27b

function opencode() {
  sbx run -e ${LMSTUDIO_API_KEY:=$(op read "op://jrew5nqtk5aqdgupcoxqjuevwu/rbbgcx424dsim3tblf2s3kca34/credential")} \
      --provider lms-openai --model "$SBX_MODEL" opencode "$@"
}

function claude() {
  sbx run -e ${LMSTUDIO_API_KEY:=$(op read "op://jrew5nqtk5aqdgupcoxqjuevwu/rbbgcx424dsim3tblf2s3kca34/credential")} \
	  --provider lms-anthropic --model "$SBX_MODEL" claude" "$@
}

function codex() {
  sbx run -e ${LMSTUDIO_API_KEY:=$(op read "op://jrew5nqtk5aqdgupcoxqjuevwu/rbbgcx424dsim3tblf2s3kca34/credential")} \
  --provider lms-openai --model "$SBX_MODEL" codex "$@"
}
