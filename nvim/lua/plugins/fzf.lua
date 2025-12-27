local function setup_keymaps()
	function vim.getVisualSelection()
		vim.cmd('noau normal! "vy"')
		local text = vim.fn.getreg("v")

		vim.fn.setreg("v", {})

		text = string.gsub(text, "\n", "")

		return #text > 0 and text or ""
	end

	function vim.getVisualSelectionEscaped()
		local text = vim.getVisualSelection()
		-- Escape special regex characters for grep
		text = vim.fn.escape(text, "()[]{}.*+?^$|\\")
		return text
	end

	local fzf = require("fzf-lua")

	-- Find files
	vim.keymap.set("n", "<leader>ff", function()
		fzf.files()
	end, { desc = "[F]ind [F]iles" })

	vim.keymap.set("v", "<leader>ff", function()
		local text = vim.getVisualSelection()
		fzf.files({ query = text })
	end, { noremap = true, silent = true, desc = "[F]ind [F]files with selected text" })

	-- Help tags
	vim.keymap.set("n", "<leader>fh", function()
		fzf.help_tags()
	end, { desc = "[F]ind [H]elp" })

	-- Colorscheme
	vim.keymap.set("n", "<leader>ft", function()
		fzf.colorschemes()
	end, { desc = "[F]ind [T]heme" })

	-- Keymaps
	vim.keymap.set("n", "<leader>fk", function()
		fzf.keymaps()
	end, { desc = "[F]ind [K]eymaps" })

	-- Live grep
	vim.keymap.set("n", "<leader>fg", function()
		fzf.live_grep()
	end, { desc = "[F]ind by [G]rep" })

	-- Resume
	vim.keymap.set("n", "<leader>fr", function()
		fzf.resume()
	end, { desc = "[F]ind [R]esume" })

	vim.keymap.set("n", "<leader>F", function()
		fzf.resume()
	end, { desc = "Resume last search" })

	-- Buffers
	vim.keymap.set("n", "<leader>fb", function()
		fzf.buffers()
	end, { desc = "[F]ind [B]uffer" })

	-- Recent files
	vim.keymap.set("n", "<leader><leader>", function()
		fzf.oldfiles()
	end, { desc = "[F]ind Recent Files" })

	-- Git history (buffer commits)
	vim.keymap.set("n", "<leader>gh", function()
		fzf.git_bcommits()
	end, { desc = "[G]it [H]istory" })

	-- Current buffer fuzzy find
	vim.keymap.set("n", "<leader>/", function()
		fzf.lgrep_curbuf()
	end, { desc = "[/] Fuzzily search in current buffer" })

	-- Find in piacsek directory
	vim.keymap.set("n", "<leader>fp", function()
		fzf.files({ cwd = vim.fn.getcwd() .. "/piacsek" })
	end, { desc = "[F]ind [P]iacsek files" })

	-- Find in dotfiles
	vim.keymap.set("n", "<leader>fd", function()
		fzf.files({ cwd = "~/dotfiles" })
	end, { desc = "[F]ind [D]otfiles" })

	-- Grep in dotfiles
	vim.keymap.set("n", "<leader>fc", function()
		fzf.live_grep({ cwd = "~/dotfiles" })
	end, { desc = "Grep config files" })

	-- Find modified git files
	vim.keymap.set("n", "<leader>fm", function()
		fzf.git_status()
	end, { desc = "[F]ind [M]odified git files" })

	vim.keymap.set("v", "<leader>fm", function()
		local text = vim.getVisualSelection()
		fzf.git_status({ query = text })
	end, { noremap = true, silent = true, desc = "[F]ind [M]odified git files with selection" })

	-- Visual mode grep
	vim.keymap.set("v", "<leader>fg", function()
		local text = vim.getVisualSelectionEscaped()
		fzf.live_grep({ search = text })
	end, { desc = "[G]rep selected" })

	-- Visual mode buffer search
	vim.keymap.set("v", "<leader>/", function()
		local text = vim.getVisualSelectionEscaped()
		fzf.lgrep_curbuf({ search = text })
	end, { desc = "[/] Fuzzily search in current buffer" })

	-- Visual mode grep config
	vim.keymap.set("v", "<leader>fc", function()
		local text = vim.getVisualSelectionEscaped()
		fzf.live_grep({ cwd = vim.fn.stdpath("config"), search = text })
	end, { desc = "[G]rep selected [C]onfig" })
end

return {
	"ibhagwan/fzf-lua",
	config = function()
		local fzf = require("fzf-lua")

		fzf.setup({
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
					["ctrl-q"] = "select-all+accept",
				},
			},
		})

		-- Use fzf-lua for vim.ui.select
		fzf.register_ui_select()

		setup_keymaps()
	end,
}
