# Add the (old) versions of Ansible & Terraform used at Confleunt to the path

if [[ -d "/usr/local/opt/ansible@2.9" ]]; then
  path+=("/usr/local/opt/ansible@2.9/bin")
  typeset -U path
  export PATH
fi

# terraform_path adds the given Homebrew terraform version to the end of PATH
function terraform_path() {
  local version
  local bindir
  version="$1"
  bindir="/usr/local/opt/terraform@${version}/bin"
  if [[ -d ${bindir} ]]; then
    path+=("${bindir}")
  else
    echo "error: ${bindir} does not exist"
  fi

  typeset -U path
  export PATH
}
