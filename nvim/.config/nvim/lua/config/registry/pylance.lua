local Pkg = require('mason-core.package')
local configs = require('lspconfig.configs')
local path = require('mason-core.path')
local util = require('lspconfig.util')

configs['pylance'] = {
    default_config = {
        filetypes = { 'python' },
        cmd = { 'pylance', '--stdio' },
        root_dir = util.root_pattern('pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'Pipfile'),
        single_file_support = true,
        settings = {
            python = {},
        },
    },
}

return {
    name = "pylance",
    description = "Fast, feature-rich language support for Python",
    categories = { "LSP" },
    homepage = "https://github.com/microsoft/pylance",
    languages = { "python" },
    licenses = { "Proprietary" },
    source = {
        id = "pkg:mason/pylance",
        ---@param ctx InstallContext
        install = function(ctx)
            ctx.spawn.bash({
                "-c",
                [[
                curl -s -c cookies.txt 'https://marketplace.visualstudio.com/items?itemName=ms-python.vscode-pylance' > /dev/null &&
                curl -s "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/ms-python/vsextensions/vscode-pylance/latest/vspackage" -j -b cookies.txt --compressed --output "pylance.vsix"
                ]],
            })
            ctx.spawn.unzip({ "pylance.vsix" })
            ctx.spawn.bash({
                "-c",
                [[
                perl -pe 's/if\(!process.*?\)return!\[\];/if(false)return false;/g; s/throw new//g' extension/dist/server.bundle.js > extension/dist/server_nvim.js
                ]],
            })
            ctx.fs:mkdir("bin")
            ctx.fs:write_file("bin/pylance", [[
#!/usr/bin/env bash
node "$(dirname "$0")/../extension/dist/server_nvim.js" "$@"
            ]])
            ctx.fs:chmod("+x", "bin/pylance")
        end,
    },
    bin = {
        ["pylance"] = "bin/pylance",
    },
}
