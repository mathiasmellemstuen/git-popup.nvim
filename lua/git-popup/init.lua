local Popup = require("nui.popup")
local Input = require("nui.input")
local event = require("nui.utils.autocmd").event

local input_focused = true

local git_text_field = Popup({
	enter = false,
	focusable = true,
	border = {
		style = "single",
	},
	position = {
		row = 0,
		col = "50%"
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

		git_text_field:show()
		local out_value = vim.api.nvim_exec("!git " .. value, true)
		local all_lines = {}
		for line in string.gmatch(tostring(out_value), "[^\r\n]*") do
			if not (line == '' or line == nil or line == ":!git " .. value) then
				table.insert(all_lines, line)
			end
		end
		vim.api.nvim_buf_set_lines(git_text_field.bufnr, -1, -1, false, all_lines)
	end

	vim.fn.prompt_setcallback(self.bufnr, sub)
	vim.fn.prompt_setinterrupt(self.bufnr, props.on_close)

	vim.api.nvim_command("startinsert!")
end

local git_input_field = CustomInput({
	position = "50%",
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
	git_text_field:mount()
	git_text_field:hide()
	git_input_field:mount()
end

function out.close()
	git_text_field:unmount()
	git_input_field:unmount()
end

function out.setup(options)
	git_text_field:on(event.BufWinEnter, function()
		vim.api.nvim_command("set wrap")
	end)
	if not (options.keymaps.switch == nil and options.keymaps.close == nil and options.keymaps.open == nil) then

	git_input_field:map("i", options.keymaps.switch, out.switchFocus)
	git_text_field:map("i", options.keymaps.switch, out.switchFocus)
	git_text_field:map("n", options.keymaps.switch, out.switchFocus)
	git_text_field:map("n", options.keymaps.close, out.close)
	git_input_field:map("n", options.keymaps.close, out.close)

	vim.keymap.set("n", options.keymaps.open, out.open)

	print(options.keymaps.open)

	else

	git_input_field:map("i", "<TAB>", out.switchFocus)
	git_text_field:map("i", "<TAB>", out.switchFocus)
	git_text_field:map("n", "<TAB>", out.switchFocus)
	git_text_field:map("n", "<ESC>", out.close)
	git_input_field:map("n", "<ESC>", out.close)

	vim.keymap.set("n", "<leader>g", out.open)
	end
end

return out
