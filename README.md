# Git-Popup

![](https://github.com/mathiasmellemstuen/git-popup/blob/main/resources/demo.gif)

This plugin provides a easy way to quickly execute git commands in Neovim.

## How to install
The plugin can easily be installed with Plug, Nui needs to be installed alongside this
```
Plug 'MunifTanjim/nui.nvim'
Plug 'mathiasmellemstuen/git-popup.nvim'
```
The setup function needs to be configured, with optional keybindings
```
require"git-popup".setup{
	keymaps = {
		switch = "<TAB>",
		close = "<ESC>",
	}
}
```
A mapping for open the plugin can be added like this
```
nnoremap <leader>g <cmd> lua require"git-popup".open()<cr>
```

## Features
This is a very small plugin with just a handful of features. The features is listed below
### Open
Opening the plugin popup window and placing cursor in input field ready for entering a git command. A keymapping running `lua require"git-popup".open()` is recommended for executing this functionality. 
### Close
Closing the plugin popup window. Default mapping for this is `<ESC>`. 
### Switch
When the plugin popup window is already open, switch can be used with the default mapped key `<TAB>`. This will make the cursor switch from the input field window to the command output window and vice versa. 
