default: update link install

clean:
	find ~ -xtype l -delete

install:
	touch /tmp/cmd && chmod u+x /tmp/cmd
	mkdir -p ~/.vim/undodir
	~/.fzf/install --all --no-update-rc
	(cd vim/.vim/bundle/tern_for_vim && npm install)
	npm install --global webtorrent-mpv-hook
	mkdir -p ~/.config/mpv/scripts
	ln -sf ~/.npm-global/lib/node_modules/webtorrent-mpv-hook/build/webtorrent.js ~/.config/mpv/scripts/webtorrent.js

link:
	stow --target ~ --restow `ls -d */` || true

update:
	git submodule update --init --recursive
	git submodule update --recursive --remote
