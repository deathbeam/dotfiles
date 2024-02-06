default: link update install

clean:
	find ~ -xtype l -print -delete

link:
	stow --target ~ --restow `ls -d */ | grep -v "^\."` 2> >(grep -v 'BUG in find_stowed_path? Absolute/relative mismatch' 1>&2)

update:
	git submodule sync --recursive
	git submodule update --init --recursive
	git submodule update --recursive --remote
	nvim --headless \
		+MasonUpdate \
		+MasonToolsInstallSync \
		+MasonToolsUpdateSync \
		+TSUpdateSync \
		+'helptags ALL' \
		+qall

install:
	mkdir -p ~/.vim/undodir
	~/.fzf/install --all --no-update-rc --no-completion --no-bash --no-fish
	gh extension install github/gh-copilot || true

uninstall:
	~/.fzf/uninstall
	gh extension remove github/gh-copilot || true
	stow --target ~ --delete `ls -d */ | grep -v "^\."` 2> >(grep -v 'BUG in find_stowed_path? Absolute/relative mismatch' 1>&2)
