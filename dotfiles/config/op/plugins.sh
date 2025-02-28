export OP_PLUGIN_ALIASES_SOURCED=1
function twilio() {
	op plugin run -- twilio "$@"
}
function gh() {
	op plugin run -- gh "$@"
}
function glab() {
	op plugin run -- glab "$@"
}
function tea() {
	op plugin run -- tea "$@"
}
