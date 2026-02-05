SUBMODULES := $(shell git config --file .gitmodules --get-regexp path | awk '{ print $$2 }')

default:update link install

clean:
	rm -r /home/deathbeam/.cache/nvim/tree-sitter-*
	rm -r ~/.local/share/nvim/site/
	rm -r nvim/.config/nvim/pack/bundle/start/nvim-treesitter
	find ~ -xtype l -print -delete || true

link:
	mkdir -p ~/.local/bin
	stow --target ~ --restow `ls -d */`

update:
	git submodule sync --recursive
	for sub in $(SUBMODULES); do \
		echo "Updating submodule $$sub"; \
		if [ "$$sub" != "zsh/.fzf" ]; then \
			git submodule update --init --recursive "$$sub"; \
			git submodule update --remote "$$sub"; \
		fi; \
	done

install:
	zsh/.fzf/install --all --no-update-rc --no-completion --no-bash --no-fish
	zsh -ic 'fast-theme base16'
	nvim --headless \
		-c "lua require('vim._extui').enable({ enable = false })" \
		+MasonUpdateSync \
		+TSUpdateSync \
		+UpdateRemotePlugins \
		+'helptags ALL' \
		+qall
	python scripts/generate-cheatsheet.py
	python scripts/generate-menu.py

uninstall:
	zsh/.fzf/uninstall
	stow --target ~ --delete `ls -d */`
