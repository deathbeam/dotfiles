default: update link install

install:
	~/.fzf/install --all --no-update-rc

link:
	stow --restow `ls -d */`

update:
	git submodule update --init --recursive
	git submodule update --recursive --remote
