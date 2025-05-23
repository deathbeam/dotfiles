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
	~/.fzf/install --all --no-update-rc --no-completion --no-bash --no-fish
	npm install -g mcp-hub@latest
	gh extension install github/gh-copilot || true
	asdf plugin update --all && asdf install protonge latest || true
	hyprpm update || true
	nvim --headless \
		+MasonUpdate \
		+MasonUpdateSync \
		+TSUpdateSync \
		+UpdateRemotePlugins \
		+'helptags ALL' \
		+qall

uninstall:
	~/.fzf/uninstall
	gh extension remove github/gh-copilot || true
	stow --target ~ --delete `ls -d */`
