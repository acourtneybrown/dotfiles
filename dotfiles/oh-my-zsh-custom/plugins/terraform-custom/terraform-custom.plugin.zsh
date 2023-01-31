# shellcheck disable=SC2148

# Add the (old) versions of Ansible & Terraform used at Confleunt to the path

if [[ -d "/usr/local/opt/ansible@2.9" ]]; then
  path+=("/usr/local/opt/ansible@2.9/bin")
  typeset -U path
  export PATH
fi
alias tfpc='terraform plan -no-color 2>&1 | pbcopy'
