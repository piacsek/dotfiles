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

vim.keymap.set("n", "<C-.>", ":horizontal resize +5<CR>", { desc = "Increase window horizontal size" })
vim.keymap.set("n", "<C-,>", ":horizontal resize -5<CR>", { desc = "Decrease window horizontal size" })

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

local function open_terminal()
	vim.cmd("split | terminal")
	vim.cmd("resize 20")
end

local function cd_to_app_dir_in_umbrella(current_file)
	local current_umbrella_app = current_file:match("apps/([^/]+)")
	local cd_command = "cd apps/" .. current_umbrella_app

	vim.fn.chansend(vim.b.terminal_job_id, cd_command .. "\n")
end

-- Move this to a lego-specific config

vim.keymap.set("n", "<leader>tw", function()
	local current_file = vim.fn.expand("%:p")
	local current_line = vim.fn.line(".")
	local fscommand = "fswatch lib test"

	local mix_test_command = "mix test " .. current_file
	if current_line ~= 1 then
		mix_test_command = mix_test_command .. ":" .. current_line
	end
	local test_run_loop = "while read; do clear; echo '" .. mix_test_command .. "';" .. mix_test_command .. "; done"
	local command = mix_test_command .. " && " .. fscommand .. " | " .. test_run_loop

	open_terminal()
	cd_to_app_dir_in_umbrella(current_file)
	vim.fn.chansend(vim.b.terminal_job_id, command .. "\n")
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

-- <Neotest remaps>
vim.keymap.set("n", "<leader>tt", function()
	require("neotest").run.run()
end, { desc = "[T]est neares[T]" })
vim.keymap.set("n", "<leader>to", function()
	require("neotest").output_panel.open()
end, { desc = "[T]est [O]utput" })
vim.keymap.set("n", "<leader>tf", function()
	require("neotest").run.run(vim.fn.expand("%"))
end, { desc = "[T]est [F]ile" })
vim.keymap.set("n", "<leader>ts", function()
	require("neotest").summary.toggle()
end, { desc = "[T]est [S]ummary" })
vim.keymap.set("n", "<leader>to", function()
	require("neotest").output.open({ enter = true })
end, { desc = "[T]est [O]utput" })
-- </Neotest remaps>
