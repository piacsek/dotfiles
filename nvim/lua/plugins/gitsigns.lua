return {
	"lewis6991/gitsigns.nvim",
	opts = {
		signs = {
			add = { text = "+" },
			change = { text = "~" },
			delete = { text = "_" },
			topdelete = { text = "‾" },
			changedelete = { text = "~" },
		},
		on_attach = function(bufnr)
			local function get_github_url()
				local file_path = vim.fn.expand("%")
				local remote_url = vim.fn.system("git remote get-url origin"):gsub("\n", "")
				if remote_url:match("github.com") then
					remote_url = remote_url:gsub("%.git$", ""):gsub("git@github.com:", "https://github.com/")
					local commit_hash = vim.fn.system("git rev-parse HEAD"):gsub("\n", "")
					local base_url = remote_url .. "/blob/" .. commit_hash .. "/" .. file_path
					
					local mode = vim.fn.mode()
					if mode == "v" or mode == "V" or mode == "\22" then
						local start_pos = vim.fn.getpos("v")
						local end_pos = vim.fn.getpos(".")
						local start_line = math.min(start_pos[2], end_pos[2])
						local end_line = math.max(start_pos[2], end_pos[2])
						if start_line == end_line then
							base_url = base_url .. "#L" .. start_line
						else
							base_url = base_url .. "#L" .. start_line .. "-L" .. end_line
						end
					else
						local current_line = vim.fn.line(".")
						base_url = base_url .. "#L" .. current_line
					end
					
					return base_url
				end
				return nil
			end

			vim.keymap.set(
				"n",
				"<leader>u",
				"<cmd>Gitsigns reset_hunk<CR>",
				{ desc = "Reset git hunk", buffer = bufnr }
			)
			vim.keymap.set(
				"n",
				"<leader>gh",
				"<cmd>Gitsigns blame<CR>",
				{ desc = "[G]it [H]istory(blame)", buffer = bufnr }
			)
			vim.keymap.set(
				"n",
				"<leader>gl",
				"<cmd>Telescope git_bcommits<CR>",
				{ desc = "[G]it [L]og for current file", buffer = bufnr }
			)
			vim.keymap.set(
				{ "n", "v" },
				"<leader>gw",
				function()
					local url = get_github_url()
					if url then vim.fn.system("open " .. url) end
				end,
				{ desc = "[G]it open in [W]eb", buffer = bufnr }
			)
			vim.keymap.set(
				{ "n", "v" },
				"<leader>gy",
				function()
					local url = get_github_url()
					if url then
						vim.fn.system("echo '" .. url .. "' | pbcopy")
						print("GitHub URL copied to clipboard")
					end
				end,
				{ desc = "[G]it [Y]ank URL to clipboard", buffer = bufnr }
			)
		end,
	},
}
