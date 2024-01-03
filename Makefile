default: update link install

clean:
	find ~ -xtype l -delete

install:
	touch /tmp/cmd && chmod u+x /tmp/cmd
	mkdir -p ~/.vim/undodir
	~/.fzf/install --all --no-update-rc
	nvim +MasonUpdate +TSUpdateSync +qall

link:
	stow --target ~ --restow `ls -d */` || true

update:
	git submodule sync --recursive
	git submodule update --init --recursive
	git submodule update --recursive --remote
