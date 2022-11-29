# shellcheck disable=SC2148

alias ecr_login="gimme-aws-creds --profile devprod-prod && aws ecr get-login-password --region us-west-2 --profile devprod-prod | docker login --username AWS --password-stdin 519856050701.dkr.ecr.us-west-2.amazonaws.com"
alias pip_login='gimme-aws-creds --profile devprod-prod && aws codeartifact login --profile devprod-prod --tool pip --domain confluent --domain-owner 519856050701 --region us-west-2 --repository pypi'
alias twine_login='gimme-aws-creds --profile devprod-prod && aws codeartifact login --profile devprod-prod --tool twine --domain confluent --domain-owner 519856050701 --region us-west-2 --repository pypi-internal'
alias ecr-login=ecr_login
alias pip-login=pip_login
alias twine-login=twine_login
function maven_login() {
  local CA_TOKEN_FILE=~/.config/confluent/codeartifact_auth_token
  local force=false
  if [[ "$1" == "-f" ]]; then
    force=true
  fi

  if [[ "$force" == "true" ]]; then
    echo "Forcing login"
    rm -f ${CA_TOKEN_FILE}
  fi

  if [[ -f ${CA_TOKEN_FILE} ]] && ! [[ $(find "${CA_TOKEN_FILE}" -mmin +660 -print) ]]; then
    echo "Skipping token generation. File ${CA_TOKEN_FILE} exists and is newer than 11 hours. Use -f to force login."
    echo "Exporting CODEARTIFACT_AUTH_TOKEN"
    # shellcheck disable=SC2155
    export CODEARTIFACT_AUTH_TOKEN=$(cat ${CA_TOKEN_FILE})
    return
  fi

  mkdir -p "$(dirname $CA_TOKEN_FILE)"
  if [[ ! -f ${CA_TOKEN_FILE} ]]; then
    touch ${CA_TOKEN_FILE}
  fi

  chmod 600 ${CA_TOKEN_FILE}
  gimme-aws-creds --profile devprod-prod
  # shellcheck disable=SC2155
  export CODEARTIFACT_AUTH_TOKEN=$(aws codeartifact get-authorization-token --domain confluent --region us-west-2 --query authorizationToken --output text --profile devprod-prod)
  sed -i'.bak' "s/mavenPassword=.*/mavenPassword=$CODEARTIFACT_AUTH_TOKEN/" "$(readlink -f ~/.gradle/gradle.properties)"
  sed -i'.bak' "s/cflt.password=.*/cflt.password=${CODEARTIFACT_AUTH_TOKEN}/" "$(readlink -f ~/.config/coursier/credentials.properties)"
  echo "${CODEARTIFACT_AUTH_TOKEN}" >${CA_TOKEN_FILE}
}
alias maven-login=maven_login

if command -v gcloud >/dev/null; then
  if ! gcloud components list --only-local-state 2>/dev/null | grep -q gke-gcloud-auth-plugin; then
    gcloud components install gke-gcloud-auth-plugin
  else
    gcloud components update
  fi
  export USE_GKE_GCLOUD_AUTH_PLUGIN=True
else
  echo "gcloud tool not installed"
fi
