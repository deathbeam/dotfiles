default: clean update link install

clean:
	find ~ -xtype l -delete

install:
	touch /tmp/cmd && chmod u+x /tmp/cmd
	mkdir -p ~/.vim/undodir
	~/.fzf/install --all --no-update-rc
	(cd vim/.vim/bundle/tern_for_vim && npm install)

link:
	stow --target ~ --restow `ls -d */`

update:
	git submodule update --init --recursive
	git submodule update --recursive --remote
