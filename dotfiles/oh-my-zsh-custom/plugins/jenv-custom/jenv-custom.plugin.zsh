# jenv_sync_versions
function jenv_sync_versions() {
  for dir in /Library/Java/JavaVirtualMachines/*; do
    jenv add "$dir/Contents/Home"
  done
}

jenvplugins=(maven gradle export)

for jenvplugin in ${jenvplugins}; do
  if [[ ! -L "${HOME}/.jenv/plugins/${jenvplugin}" ]]; then
    jenv enable-plugin "${jenvplugin}"
  fi
done

RPROMPT='$(jenv_prompt_info)'
