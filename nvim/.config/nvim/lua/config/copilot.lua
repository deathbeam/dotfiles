-- Copilot autosuggestions
vim.g.copilot_no_tab_map = true
vim.g.copilot_hide_during_completion = 0
vim.keymap.set('i', '<S-Tab>', 'copilot#Accept("\\<S-Tab>")', { expr = true, replace_keycodes = false })

-- Copilot chat
require("CopilotChat").setup({})

vim.keymap.set('n', '<leader>ce', '<cmd>CopilotChatExplain<CR>', { desc = "[C]ode [E]xplain" })
vim.keymap.set('n', '<leader>cd', '<cmd>CopilotChatFixDiagnostic<CR>', { desc = "[C]ode Fix [D]iagnostic" })
vim.keymap.set('n', '<leader>ct', '<cmd>CopilotChatTests<CR>', { desc = "[C]ode Generate [T]ests" })
