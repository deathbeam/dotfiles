return {
    rooter = {
        dirs = {
            '.git',
            '.git/',
            '_darcs/',
            '.hg/',
            '.bzr/',
            '.svn/',
            '.editorconfig',
            'Makefile',
            '.pylintrc',
            'requirements.txt',
            'setup.py',
            'package.json',
            'mvnw',
            'gradlew',
        },
    },
    session = {
        dirs = {
            vim.fn.expand('~/git'),
        },
    },
    wiki = {
        dir = vim.fn.expand('~/vimwiki'),
    },
}
