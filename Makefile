default:update link install

clean:
	find ~ -xtype l -print -delete

link:
	mkdir -p ~/.local/bin
	stow --target ~ --restow `ls -d */`

update:
	git submodule sync --recursive
	git submodule update --init --recursive
	git submodule update --recursive --remote

install:
	zsh/.fzf/install --all --no-update-rc --no-completion --no-bash --no-fish
	npm install -g mcp-hub@latest
	nvim --headless \
		+MasonUpdate \
		+MasonUpdateSync \
		+TSUpdateSync \
		+UpdateRemotePlugins \
		+'helptags ALL' \
		+qall

uninstall:
	zsh/.fzf/uninstall
	stow --target ~ --delete `ls -d */`
