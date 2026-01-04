local function open_commit_on_browser(selected)
	if not selected or #selected == 0 then
		return
	end
	-- Extract commit hash (first word of the selected line)
	local commit = selected[1]:match("^(%S+)")
	if commit then
		require("snacks").gitbrowse({ commit = commit })
	end
end

local grep_winopts = {
	height = 0.9,
	width = 0.9,
	preview = {
		hidden = "nohidden",
	},
}
function vim.getVisualSelection()
	vim.cmd('noau normal! "vy"')
	local text = vim.fn.getreg("v")

	vim.fn.setreg("v", {})

	text = string.gsub(text, "\n", "")

	return #text > 0 and text or ""
end

local function setup_keymaps()
	local fzf = require("fzf-lua")

	vim.keymap.set("n", "<leader>ff", fzf.files, { desc = "[F]ind [F]iles" })

	vim.keymap.set("v", "<leader>ff", function()
		local text = vim.getVisualSelection()
		fzf.files({ query = text })
	end, { noremap = true, silent = true, desc = "[F]ind [F]files with selected text" })

	vim.keymap.set("n", "<leader>fh", fzf.help_tags, { desc = "[F]ind [H]elp" })

	vim.keymap.set("n", "<leader>ft", fzf.colorschemes, { desc = "[F]ind [T]heme" })

	vim.keymap.set("n", "<leader>fk", function()
		fzf.keymaps()
	end, { desc = "[F]ind [K]eymaps" })

	vim.keymap.set("n", "<leader>F", function()
		fzf.resume()
	end, { desc = "Resume last search" })

	vim.keymap.set("n", "<leader><leader>", function()
		fzf.buffers()
	end, { desc = "Buffers" })

	vim.keymap.set("n", "<leader>gh", function()
		fzf.git_bcommits()
	end, { desc = "[G]it [H]istory" })

	vim.keymap.set("n", "<leader>gsm", function()
		fzf.git_commits({
			cmd = "git log --color --pretty=format:'%C(yellow)%h%Creset %Cgreen(%><(12)%cr%><|(12))%Creset %s %C(blue)<%an>%Creset' main",
		})
	end, { desc = "[G]it [S]earch [M]ain branch commits" })

	vim.keymap.set("n", "<leader>fp", function()
		fzf.files({ cwd = vim.fn.getcwd() .. "/piacsek" })
	end, { desc = "[F]ind [P]iacsek files" })

	vim.keymap.set("n", "<leader>fo", function()
		fzf.oldfiles()
	end, { desc = "[F]ind [O] files" })

	vim.keymap.set("n", "<leader>fd", function()
		fzf.files({ cwd = "~/dotfiles" })
	end, { desc = "[F]ind [D]otfiles" })

	vim.keymap.set("n", "<leader>fm", function()
		fzf.git_status()
	end, { desc = "[F]ind [M]odified git files" })

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

	vim.keymap.set("n", "<leader>sc", function()
		fzf.live_grep({ cwd = "~/dotfiles", winopts = grep_winopts })
	end, { desc = "Grep config files" })

	vim.keymap.set("n", "<leader>/", function()
		fzf.lgrep_curbuf()
	end, { desc = "[/] Fuzzily search in current buffer" })

	vim.keymap.set("v", "<leader>/", function()
		local text = vim.getVisualSelection()
		fzf.lgrep_curbuf({ search = text })
	end, { desc = "[/] Fuzzily search in current buffer" })
end

return {
	"ibhagwan/fzf-lua",
	config = function()
		local fzf = require("fzf-lua")

		local config = {
			winopts = {
				height = 0.4,
				width = 0.5,
				row = 0.5,
				col = 0.5,
				preview = {
					hidden = "hidden",
				},
			},
			keymap = {
				fzf = {
					true,
					["ctrl-q"] = "select-all+accept",
				},
			},
			git = {
				bcommits = { actions = { ["ctrl-w"] = open_commit_on_browser } },
				commits = { actions = { ["ctrl-w"] = open_commit_on_browser } },
			},
		}

		local cwd = vim.fn.getcwd()
		local local_config_path = cwd .. "/piacsek/fzf.lua"

		if vim.fn.filereadable(local_config_path) == 1 then
			local ok, local_config = pcall(dofile, local_config_path)
			if ok and local_config then
				config = vim.tbl_deep_extend("force", config, local_config)
			end
		end

		fzf.setup(config)

		fzf.register_ui_select()

		setup_keymaps()
	end,
}
