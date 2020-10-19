paths=($HOME/go/bin /usr/local/sbin)

for dir in $paths; do
  if [ -d "$dir" ]; then
    path=($dir $path)
  fi
done

typeset -U path
export PATH
