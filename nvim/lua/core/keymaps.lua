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
	vim.fn.setreg("+", vim.fn.expand("%:p"))
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

vim.keymap.set("n", "[", vim.diagnostic.get_next, { desc = "Go to previous diagnostic message" })
vim.keymap.set("n", "]", vim.diagnostic.get_prev, { desc = "Go to next diagnostic message" })
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
vim.keymap.set({ "n", "v" }, "<C-s>", ":w<CR>", { desc = "[S]ave" })

vim.keymap.set("n", "<C-.>", ":horizontal resize +5<CR>", { desc = "Increase window horizontal size" })
vim.keymap.set("n", "<C-,>", ":horizontal resize -5<CR>", { desc = "Decrease window horizontal size" })

vim.keymap.set("n", ">", ":vertical resize +5<CR>", { desc = "Increase window vertical size" })
vim.keymap.set("n", "<", ":vertical resize -5<CR>", { desc = "Decrease window vertical size" })

vim.keymap.set("v", "<leader>s", function()
	vim.cmd('normal! "sy')
	local selected = vim.fn.getreg("s")
	local escaped = vim.fn.escape(selected, [[\/.*$^~[]])
	vim.api.nvim_feedkeys(":%s/" .. escaped .. "/", "n", false)
end, { desc = "[S]ubstitute with escaped chars" })

vim.keymap.set("t", "<C-o>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

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
	"<leader>jc",
	singleton_term.make({
		key = "claude",
		open = function()
			vim.ui.input({ prompt = "CWD (1=current dir[default], 2=nvim): " }, function(input)
				if input == nil then
					return
				end

				local dir = ""
				if input == "1" or input == "" then
					dir = "$PWD"
				elseif input == "2" then
					dir = "$HOME/dotfiles/nvim/"
				end

				if dir == "" then
					vim.notify("Claude: invalid selection " .. input, vim.log.levels.WARN)
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
				if input == nil then
					return
				end

				local env = nil
				if input == "1" or input == "" then
					env = "staging"
				elseif input == "2" then
					env = "production"
				end

				if env == nil then
					vim.notify("K9s: invalid selection " .. input, vim.log.levels.WARN)
				else
					vim.cmd("terminal tsh kube login " .. env .. "-gke-cluster-1 && k9s -n nova")
				end
			end)
		end,
	}),
	{ desc = "[J]ump to [K]9s (singleton)" }
)

vim.keymap.set("n", "<leader><Del>", ":BufOnly<CR>", { desc = "[T]est [S]ummary" })
vim.keymap.set("n", "<leader>i", ":Inspect<CR>", { desc = "[I]nspect" })
vim.keymap.set("i", "<C-p>", function()
	vim.cmd.normal("p")
end, { desc = "[P]aste in insert mode" })

vim.keymap.set("n", "g<Enter>", "gF", { desc = "Go to file with line number support" })
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })

-- Lua code evaluation with persistent output buffer
local lua_output_buf = nil

local function open_lua_output_buffer()
	local buf_valid = lua_output_buf and vim.api.nvim_buf_is_valid(lua_output_buf)

	if not buf_valid then
		-- Create new buffer
		vim.cmd("vnew")
		lua_output_buf = vim.api.nvim_get_current_buf()
		vim.bo[lua_output_buf].buftype = "nofile"
		vim.bo[lua_output_buf].bufhidden = "hide"
		vim.bo[lua_output_buf].filetype = "lua"
		vim.api.nvim_buf_set_name(lua_output_buf, "[Lua Output]")
	else
		-- Find window with the buffer or open it
		local win = vim.fn.bufwinid(lua_output_buf)
		if win == -1 then
			vim.cmd("vsplit")
			vim.api.nvim_set_current_buf(lua_output_buf)
		else
			vim.api.nvim_set_current_win(win)
		end
	end

	return lua_output_buf
end

local function eval_lua()
	local code
	local mode = vim.fn.mode()

	if mode == "v" or mode == "V" or mode == "\22" then
		-- Get visual selection
		vim.cmd('noautocmd normal! "vy')
		code = vim.fn.getreg("v")
	else
		-- Get current line
		code = vim.fn.getline(".")
	end

	if code == "" then
		vim.notify("No code to evaluate", vim.log.levels.WARN)
		return
	end

	-- Try to evaluate as expression first, then as statement
	local func, err = loadstring("return " .. code)
	if not func then
		func, err = loadstring(code)
	end

	if not func then
		vim.notify("Lua eval error: " .. tostring(err), vim.log.levels.ERROR)
		return
	end

	-- Execute and capture result
	local success, result = pcall(func)
	if not success then
		vim.notify("Lua execution error: " .. tostring(result), vim.log.levels.ERROR)
		return
	end

	-- Format output
	local output
	if result == nil then
		output = "-- Code executed successfully (no return value)"
	else
		output = "-- Result:\n" .. vim.inspect(result)
	end

	-- Add the original code as a comment at the top
	local code_lines = vim.split("-- Code:\n-- " .. code:gsub("\n", "\n-- ") .. "\n", "\n")
	local output_lines = vim.split(output, "\n")
	local all_lines = vim.list_extend(code_lines, output_lines)

	-- Open buffer and append content
	local buf = open_lua_output_buffer()
	vim.bo[buf].modifiable = true

	-- Get current line count and append
	local line_count = vim.api.nvim_buf_line_count(buf)

	-- Add separator if buffer already has content
	if line_count > 0 and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] ~= "" then
		vim.api.nvim_buf_set_lines(buf, line_count, line_count, false, { "" })
		line_count = line_count + 1
	end

	vim.api.nvim_buf_set_lines(buf, line_count, line_count, false, all_lines)
	vim.bo[buf].modifiable = false
end

vim.keymap.set({ "n", "v" }, "<M-r>", eval_lua, { desc = "[R]un Lua code under cursor" })
vim.keymap.set("n", "<leader>jl", open_lua_output_buffer, { desc = "[J]ump to [L]ua output buffer" })
