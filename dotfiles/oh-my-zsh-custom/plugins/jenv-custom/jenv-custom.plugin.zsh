# shellcheck disable=SC2148

# shellcheck disable=SC2154
if [[ ${commands[jenv]} ]]; then
  # jenv_sync_versions makes sure that all installed JDKs are added to jenv
  function jenv_sync_versions() {
    for dir in /Library/Java/JavaVirtualMachines/*; do
      jenv add "$dir/Contents/Home"
    done
  }

  jenvplugins=(maven gradle export)

  # shellcheck disable=SC2128
  for jenvplugin in ${jenvplugins}; do
    if [[ ! -L "${HOME}/.jenv/plugins/${jenvplugin}" ]]; then
      jenv enable-plugin "${jenvplugin}"
    fi
  done

  # shellcheck disable=SC2016
  RPROMPT+=' j$(jenv_prompt_info)'
fi
