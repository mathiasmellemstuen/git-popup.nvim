local Popup = require("nui.popup")
local Input = require("nui.input")
local event = require("nui.utils.autocmd").event

local input_focused = true

-- Default keymappings
local keymaps = {
	switch = "<TAB>",
	close = "<ESC>",
}

local git_text_field = Popup({
	enter = false,
	focusable = true,
	border = {
		style = "single",
	},
	position = {
		row = 0,
		col = math.floor(vim.fn.winwidth(0) / 2) - 37
	},
	size = {
		width = "75",
		height = "45%",
	},
	win_options = {
		winhighlight = "Normal:Normal,FloatBorder:Normal",
	},
})

local CustomInput = Input:extend("CustomInput")

function CustomInput:init(popup_options, options)
	CustomInput.super.init(self, popup_options, options)
end

function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

function CustomInput:mount()
	local props = self.input_props

	CustomInput.super.super.mount(self)

	if props.on_change then
		vim.api.nvim_buf_attach(self.bufnr, false, {
		  on_lines = props.on_change,
		})
	end

	if #self._.default_value then
		self:on(event.InsertEnter, function()
		  vim.api.nvim_feedkeys(self._.default_value, "n", false)
		end, { once = true })
	end

	vim.fn.prompt_setprompt(self.bufnr, self._.prompt:content())
	if self._.prompt:length() > 0 then
		vim.schedule(function()
			  self._.prompt:highlight(self.bufnr, self.ns_id, 1, 0)
		end)
	end

	function sub(value)
		if string.len(value) > 3 then
			if string.starts(value, "git") then
				value = value:sub(4)
			end
		end
		git_text_field:show()
		local out_value = vim.api.nvim_exec("!git " .. value, true)
		local all_lines = {}
		for line in string.gmatch(tostring(out_value), "[^\r\n]*") do
			if not (line == '' or line == nil or line == ":!git " .. value) then
				table.insert(all_lines, line)
			end
		end
		vim.api.nvim_buf_set_lines(git_text_field.bufnr, -1, -1, false, all_lines)

		-- A hacky method for making the git_text_field move to the bottom
		vim.api.nvim_input(keymaps.switch .. "G" .. keymaps.switch)
	end

	vim.fn.prompt_setcallback(self.bufnr, sub)
	vim.fn.prompt_setinterrupt(self.bufnr, props.on_close)

	vim.api.nvim_command("startinsert!")
end

local git_input_field = CustomInput({
	position = {
		row = "50%",
		col = math.floor(vim.fn.winwidth(0) / 2) + 1 - 37
	},
	size = {
		width = "75",
	},
	border = {
		style = "single",
		text = {
			top = "[Git command]",
			top_align = "center",
		},
	},
	win_options = {
		winhighlight = "Normal:Normal,FloatBorder:Normal",
	},
}, {
	prompt = "> git ",
	default_value = "",
})
local out = {}

function out.switchFocus()
	if input_focused then
		vim.api.nvim_set_current_win(git_text_field.winid)
		input_focused = false
	else
		vim.api.nvim_set_current_win(git_input_field.winid)
		input_focused = true
	end
end

function out.open()

	vim.schedule(function()
		git_input_field:mount()
		git_text_field:mount()
		git_text_field:hide()
		vim.api.nvim_command("startinsert!")
		out.apply_keymap()

	end)
end

function out.close()
	vim.schedule(function()
		git_text_field:unmount()
		git_input_field:unmount()
	end)
end


function out.apply_keymap()
	-- Binding the keymap
	git_input_field:map("i", keymaps.switch, require"git-popup".switchFocus)
	git_text_field:map("i", keymaps.switch, require"git-popup".switchFocus)
	git_text_field:map("n", keymaps.switch, require"git-popup".switchFocus)

	git_text_field:map("n", keymaps.close, require"git-popup".close)
	git_input_field:map("n", keymaps.close, require"git-popup".close)
	git_input_field:map("i", keymaps.close, require"git-popup".close)
end

function out.setup(options)
	git_text_field:on(event.BufWinEnter, function()
		vim.api.nvim_command("set wrap")
	end)

	-- Changing to custom keymap if it was provided
	if not options.keymaps == nil then
		if not options.keymaps.switch == nil then
			keymaps.switch = options.keymaps.switch
		end

		if not options.keymaps.close == nil then
			keymaps.close = options.keymaps.close
		end
	end
end

return out

