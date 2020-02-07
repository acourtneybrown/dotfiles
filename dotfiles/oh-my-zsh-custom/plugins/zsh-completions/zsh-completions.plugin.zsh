# Include zsh-completions from homebrew if they are installed
if which brew &> /dev/null && [ -d $(brew --prefix)/share/zsh-completions ]; then
	fpath=($(brew --prefix)/share/zsh-completions $fpath)
fi
