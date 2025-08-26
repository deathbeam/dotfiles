return {
    filetypes = { 'python' },
    cmd = { 'pylance', '--stdio' },
    root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'Pipfile' },
    single_file_support = true,
    settings = {
        python = {},
    },
}
