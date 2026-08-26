function vim.getVisualSelection()
	vim.cmd('noau normal! "vy"')
	local text = vim.fn.getreg("v")
	vim.fn.setreg("v", {})
	text = string.gsub(text, "\n", "")
	return #text > 0 and text or ""
end

local arrow_disabling_opts = { noremap = true, silent = true }
vim.keymap.set({ "n", "i", "v", "c" }, "<Up>", "<Nop>", arrow_disabling_opts)
vim.keymap.set({ "n", "i", "v", "c" }, "<Down>", "<Nop>", arrow_disabling_opts)
vim.keymap.set({ "n", "i", "v", "c" }, "<Left>", "<Nop>", arrow_disabling_opts)
vim.keymap.set({ "n", "i", "v", "c" }, "<Right>", "<Nop>", arrow_disabling_opts)

vim.keymap.set("n", "<leader>yp", function()
	local abs = vim.fn.expand("%:p")
	local cwd = vim.fn.getcwd() .. "/"
	local path = abs:sub(1, #cwd) == cwd and abs:sub(#cwd + 1) or abs
	vim.fn.setreg("+", path .. ":" .. vim.fn.line("."))
end, { desc = "Yank current file path:line" })

vim.keymap.set("n", "<leader>yb", ":%yank <CR>", { desc = "[Y]ank [B]uffer" })
vim.keymap.set("n", "<leader>YB", ":%yank +<CR>", { desc = "[Y]ank [B]uffer to system clipboard" })
vim.keymap.set("n", "<leader>YP", function()
	vim.fn.setreg("+", vim.fn.expand("%:p") .. ":" .. vim.fn.line("."))
end, { desc = "Yank absolute file path:line to clipboard" })

vim.keymap.set("n", "<leader>cg", function()
	vim.fn.setreg("/", "\\<" .. vim.fn.expand("<cword>") .. "\\>")
	vim.o.hlsearch = true
	return "cgn"
end, { expr = true, desc = "[C]hange [G]lobally (dot-repeat from first match)" })
vim.keymap.set("x", "<leader>cg", function()
	vim.cmd('normal! "zy')
	local text = vim.fn.getreg("z")
	local pat = "\\V" .. vim.fn.escape(text, "\\"):gsub("\n", "\\n")
	vim.fn.setreg("/", pat)
	vim.o.hlsearch = true
	vim.api.nvim_feedkeys("cgn", "n", false)
end, { desc = "[C]hange [G]lobally from visual selection (dot-repeat)" })
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Remove search results highlights" })

vim.keymap.set("n", "<C-Esc>", "<cmd>hide<CR>", { desc = "Hide buffer" })
vim.keymap.set("n", "<leader>bc", "<cmd>CleanHiddenBuffers<CR>", { desc = "[B]uffer [C]lean hidden" })
vim.keymap.set("n", "<leader>bs", "<cmd>BufferStats<CR>", { desc = "[B]uffer [S]tats" })
vim.keymap.set("n", "<leader>e", "<cmd>edit<CR>", { desc = "R[e]load current buffer" })
vim.keymap.set("n", "Y", "y$", { desc = "[Y]ank till the end of the line" })
vim.keymap.set("n", "V", "v$", { desc = "[V]isually select till the end of the line" })

vim.keymap.set("n", "<leader>jq", ":copen<CR>", { desc = "[J]ump to the quickfix list" })

-- Cycle through quickfix items (wrapping)
vim.keymap.set("n", "<C-n>", function()
	local ok = pcall(vim.cmd.cnext)
	if not ok then
		pcall(vim.cmd.cfirst)
	end
end, { desc = "Next quickfix item" })
vim.keymap.set("n", "<C-p>", function()
	local ok = pcall(vim.cmd.cprevious)
	if not ok then
		pcall(vim.cmd.clast)
	end
end, { desc = "Previous quickfix item" })

vim.keymap.set("x", "<leader>p", [["_dP]], { desc = 'Pastes content without losing current "0 contents' })

vim.keymap.set("n", "<leader>jd", function()
	local _, winid = vim.diagnostic.open_float({ focusable = true })
	if winid then
		vim.api.nvim_set_current_win(winid)
	end
end, { desc = "Show diagnostic [E]rror messages" })
vim.keymap.set(
	"n",
	"<leader>qq",
	"<cmd>Trouble diagnostics toggle filter.buf=0<CR>",
	{ desc = "Buffer diagnostics (Trouble)" }
)
vim.keymap.set("n", "<leader>qa", "<cmd>Trouble diagnostics toggle<CR>", { desc = "Workspace diagnostics (Trouble)" })
vim.keymap.set({ "n", "v" }, "<C-s>", ":w<CR>", { desc = "[S]ave" })

vim.keymap.set("n", "<C-.>", ":horizontal resize +5<CR>", { desc = "Increase window horizontal size" })
vim.keymap.set("n", "<C-,>", ":horizontal resize -5<CR>", { desc = "Decrease window horizontal size" })

vim.keymap.set("n", ">", ":vertical resize +5<CR>", { desc = "Increase window vertical size" })
vim.keymap.set("n", "<", ":vertical resize -5<CR>", { desc = "Decrease window vertical size" })

vim.keymap.set("t", "<C-o>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Tmux navigation (terminal-mode): leave terminal mode before navigating
vim.keymap.set("t", "<C-h>", [[<C-\><C-n>:TmuxNavigateLeft<CR>]], { desc = "Tmux navigate left" })
vim.keymap.set("t", "<C-j>", [[<C-\><C-n>:TmuxNavigateDown<CR>]], { desc = "Tmux navigate down" })
vim.keymap.set("t", "<C-k>", [[<C-\><C-n>:TmuxNavigateUp<CR>]], { desc = "Tmux navigate up" })
vim.keymap.set("t", "<C-l>", [[<C-\><C-n>:TmuxNavigateRight<CR>]], { desc = "Tmux navigate right" })

vim.keymap.set("n", "<leader>i", "<cmd>TokenColor<CR>", { desc = "[I]nspect token color (float)" })
vim.keymap.set("n", "<leader>I", ":InspectTree<CR>", { desc = "[I]nspect treesitter tree" })
vim.keymap.set("i", "<C-p>", function()
	vim.cmd.normal("p")
end, { desc = "[P]aste in insert mode" })

vim.keymap.set("n", "g<Enter>", "gF", { desc = "Go to file with line number support" })
vim.keymap.set("n", "gO", function()
	require("aerial.fzf-lua").pick_symbol()
end, { desc = "Outline (aerial, fuzzy picker)" })
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })

-- Plugin keymaps

local fzf = require("fzf-lua")

local grep_winopts = {
	height = 0.9,
	width = 0.9,
	preview = { hidden = "nohidden" },
}

-- LSP pickers via fzf-lua (override default grr/gri/grt)
vim.keymap.set("n", "grr", function()
	fzf.lsp_references({ winopts = grep_winopts, jump1 = false })
end, { desc = "LSP references" })
vim.keymap.set("n", "gri", function()
	fzf.lsp_implementations({ winopts = grep_winopts, jump1 = false })
end, { desc = "LSP implementations" })
vim.keymap.set("n", "grd", function()
	fzf.lsp_definitions({ winopts = grep_winopts, jump1 = false })
end, { desc = "LSP definitions" })
vim.keymap.set("n", "grt", function()
	fzf.lsp_typedefs({ winopts = grep_winopts, jump1 = false })
end, { desc = "LSP type definitions" })

-- Inlay hints are off by default (they shift text around); toggle per buffer
-- when inferred types are worth the noise.
vim.keymap.set("n", "<leader>h", function()
	local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
	vim.lsp.inlay_hint.enable(not enabled, { bufnr = 0 })
	vim.notify("inlay hints " .. (enabled and "off" or "on"))
end, { desc = "Toggle inlay [H]ints (buffer)" })

-- Rename with live preview via inc-rename.nvim
vim.keymap.set("n", "grn", function()
	return ":IncRename " .. vim.fn.expand("<cword>")
end, { expr = true, desc = "LSP rename (incremental)" })
vim.keymap.set("n", "<leader>jw", "<esc>:URLOpenUnderCursor<cr>", { desc = "[J]ump to [W]eb browser" })
vim.keymap.set("n", "<leader>jt", "<cmd>JumpTest<CR>", { desc = "[J]ump to [T]est" })
vim.keymap.set("n", "<leader>fm", fzf.git_status, { desc = "[F]ind [M]odified git files" })
vim.keymap.set("n", "<leader>fM", function()
	fzf.git_files({
		cmd = "git diff --name-only origin/main...HEAD",
		winopts = { title = " Branch Changes (vs main) " },
	})
end, { desc = "[F]ind [M]odified files in branch (vs origin/main)" })
vim.keymap.set("n", "<leader>gsm", function()
	fzf.git_commits({
		cmd = "git log --color --pretty=format:'%C(yellow)%h%Creset %Cgreen(%><(12)%cr%><|(12))%Creset %s %C(blue)<%an>%Creset' main",
	})
end, { desc = "[G]it [S]earch [M]ain branch commits" })

local function piacsek_search_paths()
	local paths = { vim.fn.expand("$HOME/dotfiles") }
	local path = vim.fn.getcwd() .. "/piacsek/fzf.lua"
	if vim.fn.filereadable(path) == 1 then
		local ok, cfg = pcall(dofile, path)
		if ok and cfg and cfg.search_paths then
			vim.list_extend(paths, cfg.search_paths)
		end
	end
	return paths
end

vim.keymap.set("n", "<leader>ff", fzf.files, { desc = "[F]ind [F]iles" })

vim.keymap.set("n", "<leader>fa", function()
	fzf.files({ search_paths = piacsek_search_paths() })
end, { desc = "[F]ind [A]ll (incl. configured search paths)" })

vim.keymap.set("n", "<leader>sa", function()
	fzf.live_grep({ search_paths = piacsek_search_paths(), winopts = grep_winopts })
end, { desc = "[S]earch [A]ll (incl. configured search paths)" })

vim.keymap.set("v", "<leader>sa", function()
	local text = vim.getVisualSelection()
	fzf.live_grep({ search = text, search_paths = piacsek_search_paths(), winopts = grep_winopts })
end, { desc = "[S]earch [A]ll selected (incl. configured search paths)" })
vim.keymap.set("n", "<leader>fh", fzf.help_tags, { desc = "[F]ind [H]elp" })
vim.keymap.set("n", "<leader>ft", fzf.colorschemes, { desc = "[F]ind [T]heme" })
vim.keymap.set("n", "<leader>fk", fzf.keymaps, { desc = "[F]ind [K]eymaps" })
vim.keymap.set("n", "<leader>F", fzf.resume, { desc = "Resume last search" })
vim.keymap.set("n", "<leader><leader>", fzf.buffers, { desc = "Buffers" })
vim.keymap.set("n", "<leader>fo", fzf.oldfiles, { desc = "[F]ind [O] files" })
vim.keymap.set("n", "<leader>fj", fzf.jumps, { desc = "[F]ind [J]ump history" })
vim.keymap.set("n", "<leader>fd", fzf.diagnostics_workspace, { desc = "[F]ind [D]iagnostics" })

vim.keymap.set("v", "<leader>ff", function()
	local text = vim.getVisualSelection()
	fzf.files({ query = text })
end, { noremap = true, silent = true, desc = "[F]ind [F]files with selected text" })

vim.keymap.set("n", "<leader>fp", function()
	fzf.files({ cwd = vim.fn.getcwd() .. "/piacsek" })
end, { desc = "[F]ind [P]iacsek files" })

vim.keymap.set("v", "<leader>fm", function()
	local text = vim.getVisualSelection()
	fzf.git_status({ query = text })
end, { noremap = true, silent = true, desc = "[F]ind [M]odified git files with selection" })

-- Search
vim.keymap.set("v", "<leader>ss", function()
	local text = vim.getVisualSelection()
	fzf.live_grep({ search = text, winopts = grep_winopts })
end, { desc = "[G]rep selected" })

vim.keymap.set("n", "<leader>ss", function()
	fzf.live_grep({ winopts = grep_winopts })
end, { desc = "[F]ind by [G]rep" })

vim.keymap.set("n", "<leader>/", function()
	fzf.blines()
end, { desc = "[/] Fuzzily search in current buffer" })

vim.keymap.set("v", "<leader>/", function()
	local text = vim.getVisualSelection()
	fzf.blines({ query = text })
end, { desc = "[/] Fuzzily search in current buffer" })

vim.keymap.set("n", "<leader>fs", ":ScratchOpen<CR>", { desc = "[J]ump to [S]cratch" })
vim.keymap.set("n", "<leader>n", ":Scratch<CR>", { desc = "[N]ew scratch" })

vim.keymap.set("n", "<leader>jp", function()
	Snacks.explorer({ position = "right" })
end, { desc = "Filetree" })
vim.keymap.set("n", "<leader>jn", function()
	Snacks.notifier.show_history()
end, { desc = "Jump to notifications" })
vim.keymap.set("n", "<leader>gp", function()
	Snacks.picker.gh_pr()
end, { desc = "GitHub Pull Requests (open)" })
vim.keymap.set("n", "<leader>gw", function()
	Snacks.gitbrowse()
end, { desc = "Open current file on GitHub" })
vim.keymap.set({ "n", "v" }, "<leader>gyy", function()
	Snacks.gitbrowse({
		notify = false,
		branch = "main",
		open = function(url)
			vim.fn.setreg("+", url)
			vim.notify("GitHub URL copied (main)", vim.log.levels.INFO)
		end,
	})
end, { desc = "Copy GitHub URL to clipboard (main branch)" })
vim.keymap.set({ "n", "v" }, "<leader>gyc", function()
	Snacks.gitbrowse({
		notify = false,
		open = function(url)
			vim.fn.setreg("+", url)
			vim.notify("GitHub URL copied (current branch)", vim.log.levels.INFO)
		end,
	})
end, { desc = "Copy GitHub URL to clipboard (current branch)" })
vim.keymap.set("n", "<leader>gh", function()
	Snacks.picker.git_log_file()
end, { desc = "Git history for current file" })
vim.keymap.set("n", "<leader>gd", function()
	local file = vim.fn.expand("%")
	Snacks.terminal.open("git diff origin/main -- " .. vim.fn.shellescape(file), {
		win = { style = "float", width = 0.9, height = 0.9 },
	})
end, { desc = "Diff current file vs origin/main" })
vim.keymap.set("n", "<leader>N", function()
	Snacks.win({
		file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
		width = 0.6,
		height = 0.6,
		wo = { spell = false, wrap = false, signcolumn = "yes", statuscolumn = " ", conceallevel = 3 },
	})
end, { desc = "Neovim News" })

local harpoon = require("harpoon")
vim.keymap.set("n", "<leader>o", ":Oil<CR>", { desc = "Open Oil" })
vim.keymap.set("n", "<leader>a", function()
	harpoon:list():add()
end)
vim.keymap.set("n", "<leader>A", function()
	harpoon:list():clear()
	harpoon:list():add()
end)

-- 1..8 only; <leader>9 is the prefix for the 99 AI plugin (see plugins/nine.lua)
for i = 1, 8 do
	vim.keymap.set("n", "<leader>" .. i, function()
		harpoon:list():select(i)
	end)
end

vim.keymap.set("n", "<BS><BS>", function()
	harpoon.ui:toggle_quick_menu(require("harpoon"):list())
end)

vim.keymap.set("n", "<leader>SS", function()
	require("grug-far").toggle_instance({ instanceName = "main", staticTitle = "Find and Replace" })
end, { desc = "Toggle grug-far" })
vim.keymap.set("v", "<leader>SS", function()
	require("grug-far").with_visual_selection()
end, { desc = "grug-far w/ selection" })
vim.keymap.set("n", "<leader>SB", function()
	require("grug-far").open({ prefills = { paths = vim.fn.fnamemodify(vim.fn.expand("%:p"), ":~:.") } })
end, { desc = "grug-far for current buffer" })
vim.keymap.set("v", "<leader>SB", function()
	require("grug-far").with_visual_selection({
		prefills = { paths = vim.fn.fnamemodify(vim.fn.expand("%:p"), ":~:.") },
	})
end, { desc = "grug-far w/ selection for current buffer" })
vim.keymap.set("n", "<leader>tt", "<cmd>TestNearest<cr>", { desc = "Test nearest" })
vim.keymap.set("n", "<leader>tf", "<cmd>TestFile<cr>", { desc = "Test file" })
vim.keymap.set("n", "<leader>tv", "<cmd>TestVisit<cr>", { desc = "Test visit" })
vim.keymap.set("n", "<leader>td", function()
	local snacks = require("snacks")
	local test_root = vim.g._root_test_dir or "test"
	local test_dirs = vim.fn.globpath(test_root, "*", false, true)
	local items = {}

	for _, path in ipairs(test_dirs) do
		if vim.fn.isdirectory(path) == 1 then
			table.insert(items, { text = path, file = path })
		end
	end

	if #items == 0 then
		vim.notify("No directories found under " .. test_root .. "/", vim.log.levels.WARN)
		return
	end

	snacks.picker({
		source = "test_dirs",
		items = items,
		layout = "select",
		actions = {
			confirm = function(picker, item)
				picker:close()
				local sel = picker:selected()
				local paths = {}

				if #sel > 0 then
					for _, s in ipairs(sel) do
						table.insert(paths, vim.fn.fnameescape(s.text))
					end
				elseif item then
					table.insert(paths, vim.fn.fnameescape(item.text))
				end

				if #paths > 0 then
					vim.cmd("TestSuite " .. table.concat(paths, " "))
				else
					vim.notify("No items selected", vim.log.levels.WARN)
				end
			end,
		},
	})
end, { desc = "Test directories" })
vim.keymap.set("n", "<leader>tm", function()
	local test_root = vim.g._root_test_dir or "test"
	local output = vim.fn.systemlist("git diff --relative --name-only main -- " .. test_root)

	if vim.v.shell_error ~= 0 or #output == 0 then
		vim.notify("No modified test files found vs main", vim.log.levels.WARN)
		return
	end

	local paths = {}
	for _, file in ipairs(output) do
		table.insert(paths, vim.fn.fnameescape(file))
	end

	vim.cmd("TestSuite " .. table.concat(paths, " "))
end, { desc = "[T]est [M]odified (vs main)" })
vim.keymap.set("n", "<leader><BS>", function()
	if vim.bo.buftype == "" then
		vim.cmd("w")
	end
	-- vim-test's vimux strategy funnels through VimuxRunCommand too, so
	-- g:VimuxLastCommand holds the last run of either kind (test or <leader>r).
	if vim.g.VimuxLastCommand and vim.g.VimuxLastCommand ~= "" then
		vim.cmd("VimuxRunLastCommand")
	else
		vim.cmd("TestLast")
	end
end, { desc = "Save and rerun last test/file run" })

local run_file_cmd = {
	python = "python3",
	sh = "sh",
	bash = "bash",
	zsh = "zsh",
	javascript = "node",
	typescript = "npx tsx",
	lua = "nvim -l",
	elixir = "elixir",
	ruby = "ruby",
	go = "go run",
}

vim.keymap.set("n", "<leader>r", function()
	local runner = run_file_cmd[vim.bo.filetype]
	if not runner then
		vim.notify("No file runner for filetype: " .. vim.bo.filetype, vim.log.levels.WARN)
		return
	end
	if vim.bo.buftype ~= "" then
		vim.notify("Not a file buffer", vim.log.levels.WARN)
		return
	end
	vim.fn.VimuxRunCommand(runner .. " " .. vim.fn.shellescape(vim.fn.expand("%:p")))
end, { desc = "[R]un current file (vimux)" })

local function snake_to_camel(s)
	return (s:gsub("_(%w)", string.upper))
end

local function camel_to_snake(s)
	return (s:gsub("(%u+)(%u%l)", "%1_%2"):gsub("(%l)(%u)", "%1_%2"):lower())
end

vim.keymap.set("n", "<leader>cc", function()
	local word = vim.fn.expand("<cword>")
	local new = snake_to_camel(word)
	if new == word then
		return
	end
	local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
	vim.api.nvim_feedkeys('"_ciw' .. new .. esc, "n", false)
end, { desc = "snake_case → [c]amel[C]ase (word under cursor)" })

vim.keymap.set("x", "<leader>cc", function()
	vim.cmd('normal! "zy')
	vim.fn.setreg("z", snake_to_camel(vim.fn.getreg("z")))
	vim.api.nvim_feedkeys('gv"_d"zP', "n", false)
end, { desc = "snake_case → [c]amel[C]ase (selection)" })

vim.keymap.set("n", "<leader>cs", function()
	local word = vim.fn.expand("<cword>")
	local new = camel_to_snake(word)
	if new == word then
		return
	end
	local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
	vim.api.nvim_feedkeys('"_ciw' .. new .. esc, "n", false)
end, { desc = "camelCase → [c]amel_[s]nake (word under cursor)" })

vim.keymap.set("x", "<leader>cs", function()
	vim.cmd('normal! "zy')
	vim.fn.setreg("z", camel_to_snake(vim.fn.getreg("z")))
	vim.api.nvim_feedkeys('gv"_d"zP', "n", false)
end, { desc = "camelCase → [c]amel_[s]nake (selection)" })

-- DAP (see plugins/dap.lua)
local dap = require("dap")
vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "[D]ebug toggle [B]reakpoint" })
vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "[D]ebug [C]ontinue / start" })
vim.keymap.set("n", "<leader>dn", dap.step_over, { desc = "[D]ebug step over ([N]ext)" })
vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "[D]ebug step [I]nto" })
vim.keymap.set("n", "<leader>do", dap.step_out, { desc = "[D]ebug step [O]ut" })
vim.keymap.set("n", "<leader>dt", dap.terminate, { desc = "[D]ebug [T]erminate" })
vim.keymap.set({ "n", "v" }, "<leader>de", require("dapui").eval, { desc = "[D]ebug [E]val expression" })
vim.keymap.set("n", "<leader>dC", function()
	dap.clear_breakpoints()
	vim.notify("dap: cleared all breakpoints")
end, { desc = "[D]ebug [C]lear all breakpoints" })
