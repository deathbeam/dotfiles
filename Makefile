default:update link install

clean:
	find ~ -xtype l -print -delete

link:
	stow --target ~ --restow `ls -d */ | grep -v "^\."` 2> >(grep -v 'BUG in find_stowed_path? Absolute/relative mismatch' 1>&2)

update:
	git submodule sync --recursive
	git submodule update --init --recursive
	git submodule update --recursive --remote

install:
	~/.fzf/install --all --no-update-rc --no-completion --no-bash --no-fish
	gh extension install github/gh-copilot || true
	asdf plugin add protonge && asdf install protonge latest || true
	nvim --headless \
		+MasonUpdate \
		+MasonToolsClean \
		+MasonToolsInstallSync \
		+MasonToolsUpdateSync \
		+TSUpdateSync \
		+UpdateRemotePlugins \
		+'helptags ALL' \
		+qall

uninstall:
	~/.fzf/uninstall
	gh extension remove github/gh-copilot || true
	stow --target ~ --delete `ls -d */ | grep -v "^\."` 2> >(grep -v 'BUG in find_stowed_path? Absolute/relative mismatch' 1>&2)
