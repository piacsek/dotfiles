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
		-- Escape special regex characters for grep/live_grep
		text = vim.fn.escape(text, "()[]{}.*+?^$|\\")
		return text
	end

	local builtin = require("telescope.builtin")
	vim.keymap.set("n", "<leader>ff", function()
		require("telescope.builtin").find_files({
			no_ignore = false,
		})
	end, { desc = "[F]ind [F]iles" })

	vim.keymap.set("v", "<leader>ff", function()
		local text = vim.getVisualSelection()
		require("telescope.builtin").find_files({
			no_ignore = false,
			default_text = text,
		})
	end, { noremap = true, silent = true, desc = "[F]ind [F]files with selected text" })

	vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "[F]find [H]elp" })
	vim.keymap.set("n", "<leader>ft", builtin.colorscheme, { desc = "[F]find [T]heme" })
	vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "[F]find [K]eymaps" })
	vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "[F]find [D]iagnostics" })
	vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "[F]ind current [W]ord" })
	vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "[F]find by [G]rep" })
	vim.keymap.set("n", "<leader>fr", builtin.resume, { desc = "[F]ind [R]esume" })
	vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "[F]ind [B]uffer" })
	vim.keymap.set("n", "<leader>F", builtin.resume, { desc = "Resume last search" })
	vim.keymap.set("n", "<leader><leader>", builtin.oldfiles, { desc = "[F]ind Recent Files" })
	vim.keymap.set("n", "<leader>gh", builtin.git_bcommits, { desc = "[G]it [H]istory" })

	vim.keymap.set("n", "<leader>/", function()
		builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
			winblend = 10,
			previewer = false,
			layout_config = {
				width = 120,
				height = 40,
			},
		}))
	end, { desc = "[/] Fuzzily search in current buffer" })

	vim.keymap.set("n", "<leader>fn", function()
		builtin.find_files({ cwd = vim.fn.stdpath("config") })
	end, { desc = "[F]find [N]eovim files" })

	vim.keymap.set("n", "<leader>fc", function()
		builtin.live_grep({ cwd = vim.fn.stdpath("config") })
	end, { desc = "Grep config files" })

	vim.keymap.set("v", "<leader>fw", function()
		local text = vim.getVisualSelection()
		builtin.grep_string({ default_text = text, hidden = true })
	end, { desc = "[F]ind selected [W]ords" })

	vim.keymap.set("v", "<leader>fg", function()
		local text = vim.getVisualSelectionEscaped()
		builtin.live_grep({ default_text = text, hidden = true })
	end, { desc = "[G]rep selected" })

	vim.keymap.set("v", "<leader>/", function()
		local text = vim.getVisualSelectionEscaped()
		builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
			default_text = text,
			winblend = 10,
			previewer = false,
			layout_config = {
				width = 120,
				height = 40,
			},
		}))
	end, { desc = "[/] Fuzzily search in current buffer" })

	vim.keymap.set("v", "<leader>fc", function()
		local text = vim.getVisualSelectionEscaped()
		builtin.live_grep({ cwd = vim.fn.stdpath("config"), default_text = text })
	end, { desc = "[G]rep selected [C]onfig" })
end

return {
	"nvim-telescope/telescope.nvim",
	event = "VimEnter",
	branch = "0.1.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
			cond = function()
				return vim.fn.executable("make") == 1
			end,
		},
		{ "nvim-telescope/telescope-ui-select.nvim" },
		{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
	},
	config = function()
		require("telescope").setup({
			pickers = {
				find_files = {
					sorting_strategy = "ascending",
					preview = {
						hide_on_startup = true,
					},
					layout_strategy = "center",
					mappings = {
						i = {
							["<C-k>"] = require("telescope.actions.layout").toggle_preview,
						},
						n = {
							["<C-k>"] = require("telescope.actions.layout").toggle_preview,
						},
					},
				},
				live_grep = {
					mappings = {
						i = { ["<c-f>"] = require("telescope.actions").to_fuzzy_refine },
					},
				},
				git_bcommits = {
					mappings = {
						i = {
							["<C-w>"] = function(prompt_bufnr)
								local selection = require("telescope.actions.state").get_selected_entry()
								require("telescope.actions").close(prompt_bufnr)
								local commit_hash = string.match(selection.value, "^(%w+)")

								require("gitlinker").link({
									rev = commit_hash,
									action = require("gitlinker.actions").system,
								})
							end,
						},
					},
				},
			},
			extensions = {
				["ui-select"] = {
					require("telescope.themes").get_dropdown(),
				},
				fzf = {
					fuzzy = true,
					case_mode = "smart_case",
				},
			},
		})

		pcall(require("telescope").load_extension, "fzf")
		pcall(require("telescope").load_extension, "ui-select")

		setup_keymaps()
	end,
}
