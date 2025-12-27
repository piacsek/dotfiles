local singleton_term = require("core.singleton_term")

local arrow_disabling_opts = { noremap = true, silent = true }
vim.keymap.set({ "n", "i", "v", "c" }, "<Up>", "<Nop>", arrow_disabling_opts)
vim.keymap.set({ "n", "i", "v", "c" }, "<Down>", "<Nop>", arrow_disabling_opts)
vim.keymap.set({ "n", "i", "v", "c" }, "<Left>", "<Nop>", arrow_disabling_opts)
vim.keymap.set({ "n", "i", "v", "c" }, "<Right>", "<Nop>", arrow_disabling_opts)

vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { desc = "[Y]ank to system clipboard" })
vim.keymap.set("n", "<leader>yp", function()
	vim.fn.setreg('"', vim.fn.fnamemodify(vim.fn.expand("%:p"), ":~:."))
end, { desc = "Yank current file path" })

vim.keymap.set("n", "<leader>yb", ":%yank <CR>", { desc = "[Y]ank [B]uffer" })
vim.keymap.set("n", "<leader>YB", ":%yank +<CR>", { desc = "[Y]ank [B]uffer to system clipboard" })
vim.keymap.set("n", "<leader>YP", function()
	vim.fn.setreg("+", vim.fn.fnamemodify(vim.fn.expand("%:p"), ":~:."))
end, { desc = "Yank current file path" })

vim.keymap.set("n", "<C-g>", "#*viw", { desc = "Multiple cursor replacement" })
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Remove search results highlights" })

vim.keymap.set("n", "<leader><Esc>", "<cmd>hide<CR>", { desc = "Hide buffer" })
vim.keymap.set("n", "<leader>bc", "<cmd>CleanHiddenBuffers<CR>", { desc = "[B]uffer [C]lean hidden" })
vim.keymap.set("n", "<leader>bs", "<cmd>BufferStats<CR>", { desc = "[B]uffer [S]tats" })
vim.keymap.set("n", "Y", "y$", { desc = "[Y]ank till the end of the line" })
vim.keymap.set("n", "V", "v$", { desc = "[V]isually select till the end of the line" })

vim.keymap.set("n", "Q", "<nop>", { desc = "Avoiding Q" })

-- Quickfix
vim.keymap.set("n", "<leader>jq", ":copen<CR>", { desc = "[J]ump to the quickfix list" })
vim.keymap.set("n", "<M-n>", ":cnext<CR>", { desc = "Go to the [n]ext item in the quickfix list" })
vim.keymap.set("n", "<M-p>", ":cprev<CR>", { desc = "Go to the [p]revious item in the quickfix list" })

vim.keymap.set("n", "<M-h>", "<C-w>h", { desc = "Go to the buffer on the left" })
vim.keymap.set("n", "<M-j>", "<C-w>j", { desc = "Go to the buffer on the bottom" })
vim.keymap.set("n", "<M-k>", "<C-w>k", { desc = "Go to the buffer on the top" })
vim.keymap.set("n", "<M-l>", "<C-w>l", { desc = "Go to the buffer on the right" })

vim.keymap.set("x", "<leader>p", [["_dP]], { desc = 'Pastes content without losing current "0 contents' })

vim.keymap.set("n", "[", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
vim.keymap.set("n", "]", vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
vim.keymap.set({ "n", "v" }, "<C-s>", ":w<CR>", { desc = "[S]ave" })

vim.keymap.set("n", "<C-.>", ":horizontal resize +5<CR>", { desc = "Increase window horizontal size" })
vim.keymap.set("n", "<C-,>", ":horizontal resize -5<CR>", { desc = "Decrease window horizontal size" })

vim.keymap.set("n", ">", ":vertical resize +5<CR>", { desc = "Increase window vertical size" })
vim.keymap.set("n", "<", ":vertical resize -5<CR>", { desc = "Decrease window vertical size" })

vim.keymap.set("v", "<leader>s", function()
	-- Yank the selected text to register s
	vim.cmd('normal! "sy')
	local selected = vim.fn.getreg("s")
	local escaped = vim.fn.escape(selected, [[\/.*$^~[]])
	vim.api.nvim_feedkeys(":%s/" .. escaped .. "/", "n", false)
end, { desc = "[S]ubstitute with escaped chars" })

vim.keymap.set("t", "<C-o>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

vim.keymap.set("n", "<leader>o", function()
	require("oil").open()
end, { desc = "[J]ump to [O]il" })

vim.keymap.set(
	"n",
	"<leader>js",
	singleton_term.make({
		key = "shell",
		open = function()
			vim.cmd("terminal")
		end,
	}),
	{ desc = "[J]ump to [S]hell (singleton)" }
)

vim.keymap.set(
	"n",
	"<leader>lg",
	singleton_term.make({
		key = "shell",
		open = function()
			vim.cmd("terminal lazygit")
		end,
	}),
	{ desc = "[J]ump to [S]hell (singleton)" }
)

vim.keymap.set(
	"n",
	"<leader>jc",
	singleton_term.make({
		key = "claude",
		open = function()
			vim.ui.input({ prompt = "CWD (1=current dir[default], 2=nvim): " }, function(input)
				local dir = ""
				if input == "1" or input == "" then
					dir = "$PWD"
				elseif input == "2" then
					dir = "$HOME/dotfiles/nvim/"
				end

				if dir == "" then
					vim.notify("Claude: invalid selection " .. input)
				else
					vim.cmd("terminal cd " .. dir .. " && claude")
				end
			end)
		end,
	}),
	{ desc = "[J]ump to [C]laude (singleton)" }
)

vim.keymap.set(
	"n",
	"<leader>jk",
	singleton_term.make({
		key = "k9s",
		open = function()
			vim.ui.input({ prompt = "Environment (1=staging[default], 2=production): " }, function(input)
				local env = ""
				if input == "1" or input == "" then
					env = "staging"
				elseif input == "2" then
					env = "production"
				end

				if env == "" then
					vim.notify("K9s: invalid selection " .. input)
				else
					vim.cmd("terminal tsh kube login " .. env .. "-gke-cluster-1 && k9s -n nova")
				end
			end)
		end,
	}),
	{ desc = "[J]ump to [K]9s (singleton)" }
)

vim.keymap.set("n", "<leader>fs", ":ScratchOpen<CR>", { desc = "[F]ump to [S]cratch" })
vim.keymap.set("n", "<leader>n", ":Scratch<CR>", { desc = "[N]ew scrach" })

vim.keymap.set("n", "<leader><Del>", ":BufOnly<CR>", { desc = "[T]est [S]ummary" })
vim.keymap.set("n", "<leader>i", ":Inspect<CR>", { desc = "[I]nspect" })
vim.keymap.set("i", "<C-p>", function()
	vim.cmd.normal("p")
end, { desc = "[P]aste in insert mode" })

vim.keymap.set("n", "g<Enter>", "gF", { desc = "Go to file with line number support" })
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to file with line number support" })

-- Git
vim.keymap.set("n", "<leader>ga", "<cmd>Gitsigns attach<CR>", { desc = "[G]itsigns [A]ttach" })
vim.keymap.set("n", "<leader>gq", "<cmd>Gitsigns detach_all<CR>", { desc = "[G]itsigns detach all" })
