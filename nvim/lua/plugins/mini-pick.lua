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

	local pick = require("mini.pick")

	-- Find files
	vim.keymap.set("n", "<leader>ff", function()
		pick.builtin.files()
	end, { desc = "[F]ind [F]iles" })

	vim.keymap.set("v", "<leader>ff", function()
		local text = vim.getVisualSelection()
		pick.builtin.files({}, { source = { name = text } })
	end, { noremap = true, silent = true, desc = "[F]ind [F]files with selected text" })

	-- Help tags
	vim.keymap.set("n", "<leader>fh", function()
		pick.builtin.help()
	end, { desc = "[F]ind [H]elp" })

	-- Keymaps
	vim.keymap.set("n", "<leader>fk", function()
		-- mini.pick doesn't have builtin keymaps, use vim.ui.select or implement custom
		local keymaps = vim.api.nvim_get_keymap("n")
		local items = vim.tbl_map(function(km)
			return string.format("%-20s %s", km.lhs, km.rhs or "")
		end, keymaps)
		pick.start({
			source = { items = items, name = "Keymaps" },
		})
	end, { desc = "[F]ind [K]eymaps" })

	-- Live grep
	vim.keymap.set("n", "<leader>fg", function()
		pick.builtin.grep_live()
	end, { desc = "[F]ind by [G]rep" })

	-- Resume
	vim.keymap.set("n", "<leader>fr", function()
		pick.builtin.resume()
	end, { desc = "[F]ind [R]esume" })

	vim.keymap.set("n", "<leader>F", function()
		pick.builtin.resume()
	end, { desc = "Resume last search" })

	-- Buffers
	vim.keymap.set("n", "<leader>fb", function()
		pick.builtin.buffers()
	end, { desc = "[F]ind [B]uffer" })

	-- Recent files
	vim.keymap.set("n", "<leader><leader>", function()
		-- mini.pick doesn't have oldfiles builtin, implement custom
		local oldfiles = vim.v.oldfiles
		pick.start({
			source = { items = oldfiles, name = "Recent Files" },
		})
	end, { desc = "[F]ind Recent Files" })

	-- Git history (buffer commits)
	vim.keymap.set("n", "<leader>gh", function()
		-- Custom implementation for git history
		local file = vim.fn.expand("%")
		if file == "" then
			vim.notify("No file in current buffer", vim.log.levels.WARN)
			return
		end
		local commits = vim.fn.systemlist("git log --oneline --follow " .. vim.fn.shellescape(file))
		pick.start({
			source = { items = commits, name = "Git History" },
		})
	end, { desc = "[G]it [H]istory" })

	-- Current buffer fuzzy find
	vim.keymap.set("n", "<leader>/", function()
		pick.builtin.grep({ pattern = "", tool = "git" }, { source = { cwd = vim.fn.expand("%:p:h") } })
	end, { desc = "[/] Fuzzily search in current buffer" })

	-- Find in piacsek directory
	vim.keymap.set("n", "<leader>fp", function()
		pick.builtin.files({}, { source = { cwd = vim.fn.getcwd() .. "/piacsek" } })
	end, { desc = "[F]ind [P]iacsek files" })

	-- Find in dotfiles
	vim.keymap.set("n", "<leader>fd", function()
		pick.builtin.files({}, { source = { cwd = vim.fn.expand("~/dotfiles") } })
	end, { desc = "[F]ind [D]otfiles" })

	-- Grep in dotfiles
	vim.keymap.set("n", "<leader>fc", function()
		pick.builtin.grep_live({}, { source = { cwd = vim.fn.expand("~/dotfiles") } })
	end, { desc = "Grep config files" })

	-- Find modified git files
	vim.keymap.set("n", "<leader>fm", function()
		local modified_files = vim.fn.systemlist("git ls-files -m")
		pick.start({
			source = { items = modified_files, name = "Modified Files" },
		})
	end, { desc = "[F]ind [M]odified git files" })

	vim.keymap.set("v", "<leader>fm", function()
		local text = vim.getVisualSelection()
		local modified_files = vim.fn.systemlist("git ls-files -m")
		local filtered = vim.tbl_filter(function(file)
			return string.find(file, text, 1, true)
		end, modified_files)
		pick.start({
			source = { items = filtered, name = "Modified Files" },
		})
	end, { noremap = true, silent = true, desc = "[F]ind [M]odified git files with selection" })

	-- Visual mode grep
	vim.keymap.set("v", "<leader>fg", function()
		local text = vim.getVisualSelectionEscaped()
		pick.builtin.grep_live({ pattern = text })
	end, { desc = "[G]rep selected" })

	-- Visual mode buffer search
	vim.keymap.set("v", "<leader>/", function()
		local text = vim.getVisualSelectionEscaped()
		pick.builtin.grep({ pattern = text }, { source = { cwd = vim.fn.expand("%:p:h") } })
	end, { desc = "[/] Fuzzily search in current buffer" })

	-- Visual mode grep config
	vim.keymap.set("v", "<leader>fc", function()
		local text = vim.getVisualSelectionEscaped()
		pick.builtin.grep_live({ pattern = text }, { source = { cwd = vim.fn.stdpath("config") } })
	end, { desc = "[G]rep selected [C]onfig" })
end

return {
	"echasnovski/mini.pick",
	enabled = false,
	version = false,
	config = function()
		require("mini.pick").setup({
			-- Configuration options
			mappings = {
				move_down = "<C-n>",
				move_up = "<C-p>",
			},
			window = {
				config = function()
					local height = math.floor(0.618 * vim.o.lines)
					local width = math.floor(0.618 * vim.o.columns)
					return {
						anchor = "NW",
						height = height,
						width = width,
						row = math.floor(0.5 * (vim.o.lines - height)),
						col = math.floor(0.5 * (vim.o.columns - width)),
					}
				end,
			},
		})

		-- Use mini.pick for vim.ui.select
		vim.ui.select = require("mini.pick").ui_select

		setup_keymaps()
	end,
}
