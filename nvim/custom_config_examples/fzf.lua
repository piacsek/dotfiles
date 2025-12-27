return {
	file_ignore_patterns = { "priv/gettext/" },
	files = {
		fd_opts = "--hidden -E priv/gettext/",
	},
	grep = {
		rg_opts = "--hidden -g '!priv/gettext/'",
	},
}
