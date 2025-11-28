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

	vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "[F]ind [H]elp" })
	vim.keymap.set("n", "<leader>ft", builtin.colorscheme, { desc = "[F]ind [T]heme" })
	vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "[F]ind [K]eymaps" })
	vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "[F]ind current [W]ord" })
	vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "[F]ind by [G]rep" })
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

	vim.keymap.set("n", "<leader>fw", function()
		vim.cmd("require'telescope'.extensions.project.project{}")
	end, { desc = "[F]ind [W]orkspaces" })

	vim.keymap.set("n", "<leader>fp", function()
		builtin.find_files({ cwd = vim.fn.getcwd() .. "/piacsek" })
	end, { desc = "[F]ind [P]iacsek files" })

	vim.keymap.set("n", "<leader>fd", function()
		builtin.find_files({ cwd = "~/dotfiles", file_ignore_patterns = { "git/" } })
	end, { desc = "[F]ind [D]otfiles" })

	vim.keymap.set("n", "<leader>fc", function()
		builtin.live_grep({ cwd = "~/dotfiles", file_ignore_patterns = { "git/" } })
	end, { desc = "Grep config files" })

	vim.keymap.set("n", "<leader>fm", function()
		require("telescope.builtin").git_files({
			git_command = { "git", "ls-files", "-m" }, -- only modified files
			prompt_title = "Modified Files",
		})
	end, { desc = "[F]ind [M]odified git files" })

	vim.keymap.set("v", "<leader>fm", function()
		local text = vim.getVisualSelection()
		require("telescope.builtin").git_files({
			git_command = { "git", "ls-files", "-m" },
			default_text = text,
			prompt_title = "Modified Files",
		})
	end, { noremap = true, silent = true, desc = "[F]ind [M]odified git files with selection" })

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
		{ "nvim-telescope/telescope-project.nvim" },
		{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
	},
	config = function()
		local default_config = {
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
		}

		local project_telescope_config = vim.fn.getcwd() .. "/piacsek/telescope/init.lua"
		if vim.fn.filereadable(project_telescope_config) == 1 then
			local project_config = dofile(project_telescope_config)
			if type(project_config) == "table" then
				default_config = vim.tbl_deep_extend("force", default_config, project_config)
			end
		end

		require("telescope").setup(default_config)

		-- pcall(require("telescope").load_extension, "project")
		pcall(require("telescope").load_extension, "fzf")
		pcall(require("telescope").load_extension, "ui-select")

		setup_keymaps()
	end,
}
