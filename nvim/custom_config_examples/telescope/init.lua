return {
	defaults = {
		file_ignore_patterns = { "priv/gettext/" },
	},
	pickers = {
		find_files = {
			hidden = true,
			search_dirs = { ".", "../../.github" },
		},
		live_grep = {
			additional_args = function()
				return { "--hidden" }
			end,
			search_dirs = { ".", "../../.github" },
		},
	},
}
