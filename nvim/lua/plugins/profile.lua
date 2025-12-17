return {
	"stevearc/profile.nvim",
	config = function()
		local should_profile = os.getenv("NVIM_PROFILE")
		if should_profile then
			vim.notify("Should profile")
			require("profile").instrument_autocmds()
			if should_profile:lower():match("^start") then
				require("profile").start("*")
			else
				require("profile").instrument("*")
			end
		end

		local function toggle_profile()
			local prof = require("profile")
			vim.notify("Toggling profile...")
			if prof.is_recording() then
				vim.notify("is_recording is true...")
				prof.stop()
				vim.ui.input(
					{ prompt = "Save profile to:", completion = "file", default = "/tmp/profile.json" },
					function(filename)
						if filename then
							prof.export(filename)
							vim.notify(string.format("Wrote %s", filename))
						end
					end
				)
				vim.notify("post ui.input")
			else
				prof.start("*")
			end
		end
		vim.keymap.set("n", "<leader>dp", toggle_profile, { desc = "[D]ebug [P]rofile toggle" })
	end,
}
