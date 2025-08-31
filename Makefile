default:update link install

clean:
	find ~ -xtype l -print -delete
	rm -r /home/deathbeam/.cache/nvim/tree-sitter-*
	rm -r ~/.local/share/nvim/site/
	rm -r nvim/.config/pack/bundle/start/nvim-treesitter

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
		+MasonUpdateSync \
		+TSUpdateSync \
		+UpdateRemotePlugins \
		+'helptags ALL' \
		+qall
	python scripts/generate-cheatsheet.py

uninstall:
	zsh/.fzf/uninstall
	stow --target ~ --delete `ls -d */`
