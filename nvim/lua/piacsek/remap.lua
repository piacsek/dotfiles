vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- <Normal mode remaps> vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Remove search results highlights' })

vim.keymap.set('n', '<leader><Esc>', ':hide<CR>', { desc = 'Hide window' })

vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.keymap.set('n', '<leader><BS>', ':w<CR>', { desc = 'Save file' })

vim.keymap.set('n', 'Q', '<nop>', { desc = 'Avoiding Q' })

vim.keymap.set('n', 'n', 'nzzzv', { desc = 'Auto zz' })
vim.keymap.set('n', 'N', 'Nzzzv', { desc = 'Auto zz' })

vim.keymap.set('n', '<leader>s', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = 'Replace word under the cursor'})


vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- </Normal mode remaps>

-- <Visual mode remaps>

vim.keymap.set('v', '<leader>s', '"sy:%s/<C-r>s/', { desc = '[S]ubstitute selected word' })
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", {desc = 'Move currently selection one line below'})
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", {desc = 'Move currently selection one line above'})

-- </Visual mode remaps>
