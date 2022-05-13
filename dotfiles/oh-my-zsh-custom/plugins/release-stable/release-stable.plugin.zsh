# shellcheck disable=SC2148

# Install aliases for working with release stabilization

# rs-sync-forks updates the personal forks (including) tags from the confluentinc repo.
# If no repo names are given, a predefined list of repos is used.
function rs-sync-forks() {
  set -e
  local -a repos
  if [ "${#}" -lt 1 ]; then
    repos=(ce-kafka kafka common rest-utils schema-registry
      ksql cc-docker-ksql confluent-cloud-plugins kafka-rest confluent-security-plugins
      secret-registry schema-registry-plugins)
  else
    repos=("${@}")
  fi

  # ZSH "properly" handles the array (vs. bash)
  # shellcheck disable=SC2128
  for repo in ${repos}; do
    echo "${repo}"
    pint sync-forks -e dev --skip-tags False "${repo}"
  done
}
