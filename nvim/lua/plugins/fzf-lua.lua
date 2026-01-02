local function setup_keymaps()
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

	local fzf = require("fzf-lua")

	vim.keymap.set("n", "<leader>ff", function()
		fzf.files()
	end, { desc = "[F]ind [F]iles" })

	vim.keymap.set("v", "<leader>ff", function()
		local text = vim.getVisualSelection()
		fzf.files({ query = text })
	end, { noremap = true, silent = true, desc = "[F]ind [F]files with selected text" })

	vim.keymap.set("n", "<leader>fh", function()
		fzf.help_tags()
	end, { desc = "[F]ind [H]elp" })

	vim.keymap.set("n", "<leader>ft", function()
		fzf.colorschemes()
	end, { desc = "[F]ind [T]heme" })

	vim.keymap.set("n", "<leader>fk", function()
		fzf.keymaps()
	end, { desc = "[F]ind [K]eymaps" })

	vim.keymap.set("n", "<leader>fg", function()
		fzf.live_grep({ winopts = grep_winopts })
	end, { desc = "[F]ind by [G]rep" })

	vim.keymap.set("n", "<leader>fr", function()
		fzf.resume()
	end, { desc = "[F]ind [R]esume" })

	vim.keymap.set("n", "<leader>F", function()
		fzf.resume()
	end, { desc = "Resume last search" })

	vim.keymap.set("n", "<leader><leader>", function()
		fzf.buffers()
	end, { desc = "[F]ind Recent Files" })

	vim.keymap.set("n", "<leader>gh", function()
		fzf.git_bcommits()
	end, { desc = "[G]it [H]istory" })

	vim.keymap.set("n", "<leader>/", function()
		fzf.lgrep_curbuf()
	end, { desc = "[/] Fuzzily search in current buffer" })

	vim.keymap.set("n", "<leader>fp", function()
		fzf.files({ cwd = vim.fn.getcwd() .. "/piacsek" })
	end, { desc = "[F]ind [P]iacsek files" })

	vim.keymap.set("n", "<leader>fo", function()
		fzf.oldfiles()
	end, { desc = "[F]ind [O] files" })

	vim.keymap.set("n", "<leader>fd", function()
		fzf.files({ cwd = "~/dotfiles" })
	end, { desc = "[F]ind [D]otfiles" })

	vim.keymap.set("n", "<leader>fc", function()
		fzf.live_grep({ cwd = "~/dotfiles", winopts = grep_winopts })
	end, { desc = "Grep config files" })

	vim.keymap.set("n", "<leader>fm", function()
		fzf.git_status()
	end, { desc = "[F]ind [M]odified git files" })

	vim.keymap.set("v", "<leader>fm", function()
		local text = vim.getVisualSelection()
		fzf.git_status({ query = text })
	end, { noremap = true, silent = true, desc = "[F]ind [M]odified git files with selection" })

	vim.keymap.set("v", "<leader>fg", function()
		local text = vim.getVisualSelection()
		fzf.live_grep({ search = text, winopts = grep_winopts })
	end, { desc = "[G]rep selected" })

	vim.keymap.set("v", "<leader>/", function()
		local text = vim.getVisualSelection()
		fzf.lgrep_curbuf({ search = text })
	end, { desc = "[/] Fuzzily search in current buffer" })

	vim.keymap.set("v", "<leader>fc", function()
		local text = vim.getVisualSelection()
		fzf.live_grep({ cwd = vim.fn.stdpath("config"), search = text, winopts = grep_winopts })
	end, { desc = "[G]rep selected [C]onfig" })
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
