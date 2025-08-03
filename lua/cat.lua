local utf8 = require("utf8")

local M = {}
local _braille_blanc = "⠀"
M.frames = {
	{
		"  ᨈ⠀ܢ    ",
		" (^˕^)ᜪ_⎠",
		" |ˎ⠀⠀⠀⠀⠀)",
		' ૮ᒐ⠀""૮ᒐᐟ',
	},
	{
		" /ᐠ_^    ",
		"(^˕^⠀)__⎠",
		" |ˎ⠀⠀⠀⠀⠀)",
		' ᒐ૮⠀""ᒐ૮ᐟ',
	},
	{
		" ᨈ⠀/\\    ",
		"(^˕^)___/",
		" |ˎ⠀⠀⠀⠀⠀)",
		' ૮ᒐ⠀""૮ᒐᐟ',
	},
	{
		" /ᐠ_^    ",
		"(^˕^⠀)__/",
		" |ˎ⠀⠀⠀⠀⠀)",
		' ᒐ૮⠀""ᒐ૮ᐟ',
	},
}

M.setup = function(opts)
	local buf = vim.api.nvim_create_buf(false, true)

	local win = vim.api.nvim_open_win(buf, false, {
		relative = "editor",
		style = "minimal",
		anchor = "SW",
		row = 0,
		-- col = 3,
		col = vim.opt.columns:get() / 2,
		width = 9,
		height = 4,
		border = "none",
		focusable = false,
		noautocmd = true,
	})
	local namespace = vim.api.nvim_create_namespace("cat-window")
	vim.api.nvim_set_hl(namespace, "CatBlend", { fg = "#ff0000", blend = 100 })

	local rainbow = {
		"#ff0000",
		"#ff1e00",
		"#ff3d00",
		"#ff5b00",
		"#ff7a00",
		"#ff9900",
		"#ffb700",
		"#ffd600",
		"#fff400",
		"#eaff00",
		"#cbff00",
		"#adff00",
		"#8eff00",
		"#70ff00",
		"#51ff00",
		"#33ff00",
		"#14ff00",
		"#00ff0a",
		"#00ff28",
		"#00ff47",
		"#00ff66",
		"#00ff84",
		"#00ffa3",
		"#00ffc1",
		"#00ffe0",
		"#00ffff",
		"#00e0ff",
		"#00c1ff",
		"#00a3ff",
		"#0084ff",
		"#0066ff",
		"#0047ff",
		"#0028ff",
		"#000aff",
		"#1400ff",
		"#3200ff",
		"#5100ff",
		"#7000ff",
		"#8e00ff",
		"#ad00ff",
		"#cc00ff",
		"#ea00ff",
		"#ff00f4",
		"#ff00d6",
		"#ff00b7",
		"#ff0098",
		"#ff007a",
		"#ff005b",
		"#ff003d",
		"#ff001e",
	}
	local rainbow_index = 1
	local c_timer = vim.uv.new_timer()
	vim.uv.timer_start(
		c_timer,
		1000,
		100,
		vim.schedule_wrap(function()
			local color = rainbow[rainbow_index]
			vim.api.nvim_set_hl(namespace, "CatBlend", { fg = color, blend = 100, force = true })
			vim.hl.range(buf, namespace, "CatBlend", { 0, 0 }, { 4, -1 })

			rainbow_index = rainbow_index + 1
			if rainbow_index > #rainbow then
				rainbow_index = 1
			end
		end)
	)

	vim.api.nvim_win_set_hl_ns(win, namespace)
	vim.api.nvim_set_option_value("winblend", 100, { win = win })

	local f = require("fidget")

	local i = 1
	local timer = vim.uv.new_timer()

	vim.uv.timer_start(
		timer,
		1000,
		500,
		vim.schedule_wrap(function()
			local config = vim.api.nvim_win_get_config(win)
			local col = config.col - 1
			local frame = M.frames[i]
			local frame_width = utf8.len(frame[1])
			local screen_width = vim.opt.columns:get()
			if col + frame_width <= 0 then
				col = screen_width - 1
			end
			if col >= screen_width then
				col = screen_width - 1
			end

			local left = col
			local right = col + frame_width

			local statusline_height = 0
			local laststatus = vim.opt.laststatus:get()
			if laststatus == 2 or laststatus == 3 or (laststatus == 1 and #vim.api.nvim_tabpage_list_wins(0) > 1) then
				statusline_height = 1
			end

			local screen_height = vim.opt.lines:get() - (statusline_height + vim.opt.cmdheight:get())

			config["row"] = screen_height
			config["col"] = col
			vim.api.nvim_win_set_config(win, config)

			if left < 0 then
				frame = vim.tbl_map(function(line)
					return string.sub(line, utf8.offset(line, -left + 1), -1)
				end, frame)
			elseif right > screen_width then
				local visible_count = screen_width - left
				local empty_space = frame_width - visible_count
				local a = string.rep(" ", empty_space)
				frame = vim.tbl_map(function(line)
					local b = string.sub(line, 1, utf8.offset(line, visible_count + 1) - 1)
					return a .. b
				end, frame)
			end

			vim.api.nvim_buf_set_lines(buf, 0, -1, false, frame)
			vim.hl.range(buf, namespace, "CatBlend", { 0, 0 }, { 4, -1 })

			i = i + 1
			if i > #M.frames then
				i = 1
			end
		end)
	)
end

return M
