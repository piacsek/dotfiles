vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- <Normal mode remaps>
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Remove search results highlights" })
vim.keymap.set("n", "<Tab>", "<C-w>w", { desc = "Go to next window" })
vim.keymap.set("n", "<S-Tab>", "<C-w>p", { desc = "Go to previous window" })

vim.keymap.set("n", "<leader><Esc>", ":hide<CR>", { desc = "Hide window" })
vim.keymap.set("n", "<leader>vp", vim.cmd.Ex, { desc = "Hide window" })

vim.keymap.set("n", "<leader><BS>", ":w<CR>", { desc = "Save file" })

vim.keymap.set("n", "Q", "<nop>", { desc = "Avoiding Q" })

vim.keymap.set("n", "n", "nzzzv", { desc = "Auto zz" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Auto zz" })

vim.keymap.set("x", "<leader>p", [["_dP]], { desc = 'Pastes content without losing current "0 contents' })
vim.keymap.set(
	"n",
	"<leader>s",
	[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
	{ desc = "Replace word under the cursor" }
)

vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
vim.keymap.set(
	"n",
	"<leader>y",
	':lua vim.fn.setreg("+", vim.fn.expand("%:p") .. ":" .. vim.fn.line("."))<CR>',
	{ noremap = true, silent = true, desc = "[Y]anks current buffer filepath" }
)

vim.keymap.set("n", "<C-,>", ":horizontal resize +5<CR>", { desc = "Increase window horizontal size" })
vim.keymap.set("n", "<C-.>", ":horizontal resize -5<CR>", { desc = "Decrease window horizontal size" })

vim.keymap.set("n", ">", ":vertical resize +5<CR>", { desc = "Increase window vertical size" })
vim.keymap.set("n", "<", ":vertical resize -5<CR>", { desc = "Decrease window vertical size" })

vim.keymap.set("n", "<leader>kt", function()
	local buffers = vim.api.nvim_list_bufs()
	for _, buffer in ipairs(buffers) do
		if vim.api.nvim_buf_get_option(buffer, "buftype") == "terminal" then
			vim.api.nvim_buf_delete(buffer, { force = true })
		end
	end
end, { desc = "[K]ill all [T]erminal buffers" })

-- Move this to a lego-specific config
local function open_terminal_and_run_tests(test_command)
	local current_file = vim.fn.expand("%:p")
	local current_line = vim.fn.line(".")
	local current_umbrella_app = current_file:match("apps/([^/]+)")
	local cd_command = "cd apps/" .. current_umbrella_app
	local mix_test_command = "mix " .. test_command .. " " .. current_file
	if current_line ~= 1 then
		mix_test_command = mix_test_command .. ":" .. current_line
	end

	vim.cmd("split | terminal")
	vim.cmd("resize 20")
	vim.fn.chansend(vim.b.terminal_job_id, cd_command .. "\n")
	vim.fn.chansend(vim.b.terminal_job_id, mix_test_command .. "\n")
end

vim.keymap.set("n", "<leader>tt", function()
	open_terminal_and_run_tests("test")
end)

vim.keymap.set("n", "<leader>tw", function()
	open_terminal_and_run_tests("test.watch")
end)

-- </Normal mode remaps>

-- <Visual mode remaps>

vim.keymap.set("v", "<leader>s", '"sy:%s/<C-r>s/', { desc = "[S]ubstitute selected word" })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move currently selection one line below" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move currently selection one line above" })

-- </Visual mode remaps>

-- <Terminal mode remaps>
vim.keymap.set("t", "<C-Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
-- </Terminal mode remaps>
