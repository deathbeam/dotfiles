SUBMODULES := $(shell git config --file .gitmodules --get-regexp path | awk '{ print $$2 }')
default:format update link install

format:
	@echo "Formatting QML files..."
	@if command -v /usr/lib/qt6/bin/qmlformat >/dev/null 2>&1; then \
		find quickshell/.config/quickshell -name "*.qml" -exec /usr/lib/qt6/bin/qmlformat -i {} \;; \
	fi
	@echo "Formatting Lua files..."
	@if command -v stylua >/dev/null 2>&1; then \
		cd nvim/.config/nvim && stylua .; \
	fi

clean:
	rm -r /home/deathbeam/.cache/nvim/tree-sitter-* || true
	rm -r ~/.local/share/nvim/site/ || true
	rm -r nvim/.config/nvim/pack/bundle/start/nvim-treesitter || true
	find ~ -xtype l -print -delete || true

link:
	mkdir -p ~/.local/bin
	stow --target ~ --restow `ls -d */`

update:
	git submodule sync --recursive
	for sub in $(SUBMODULES); do \
		echo "Updating submodule $$sub"; \
		git submodule update --init --recursive --force --remote "$$sub"; \
	done

install:
	zsh -ic 'fast-theme base16'
	nvim --headless \
		+MasonUpdateSync \
		+TSUpdateSync \
		+UpdateRemotePlugins \
		+'helptags ALL' \
		+qall
	python scripts/generate-cheatsheet.py
	python scripts/generate-menu.py

uninstall:
	stow --target ~ --delete `ls -d */`
