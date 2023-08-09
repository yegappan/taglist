![unit-tests](https://github.com/yegappan/taglist/workflows/unit-tests/badge.svg?branch=master)

# taglist - Source Code Browser plugin for Vim

The "Tag List" plugin is a source code browser plugin for Vim and provides an overview of the structure of source code files and allows you to efficiently browse through source code files for different programming languages.

This plugin works with both Vim and Neovim and will work on all the platforms where Vim/Neovim and ctags are supported.  This plugin will work in both console and GUI Vim. This version of the taglist plugin needs Vim 7.4.1304 and above.

This plugin relies on exuberant or Universal ctags to get the list of tags defined in a source file.

## Features
- Displays the tags (functions, classes, structures, variables, etc.) defined in a file in a vertically or horizontally split Vim window.
- In GUI Vim, optionally displays the tags in the Tags drop-down menu and in the popup menu.
- Automatically updates the taglist window as you switch between files/buffers. As you open new files, the tags defined in the new files are added to the existing file list and the tags defined in all the files are displayed grouped by the filename.
- When a tag name is selected from the taglist window, positions the cursor at the definition of the tag in the source file.
- Automatically highlights the current tag name.
- Groups the tags by their type and displays them in a foldable tree.
- Can display the prototype and scope of a tag.
- Can optionally display the tag prototype instead of the tag name in the taglist window.
- The tag list can be sorted either by name or by chronological order.
- Supports the following language files: Assembly, ASP, Awk, Beta, C, C++, C#, Cobol, Eiffel, Erlang, Fortran, HTML, Java, Javascript, Lisp, Lua, Make, Pascal, Perl, PHP, Python, Rexx, Ruby, Scheme, Shell, Slang, SML, Sql, TCL, Verilog, Vim and Yacc.
- Can be easily extended to support new languages. Support for existing languages can be modified easily.
- Provides functions to display the current tag name in the Vim status line or the window title bar.
- The list of tags and files in the taglist can be saved and restored across Vim sessions.
- Provides commands to get the name and prototype of the current tag.
- Supports both Vim and Neovim.
- Runs in both console/terminal and GUI versions of Vim.
- Can be used in Linux/Unix, MacOS and MS-Windows systems.

## Installation

You can install this plugin from github using the following steps:

    $ mkdir -p $HOME/.vim/pack/downloads/start
    $ cd $HOME/.vim/pack/downloads/start
    $ git clone https://github.com/yegappan/taglist

For NeoVim:

    $ mkdir -p $HOME/.config/nvim/pack/downloads/start
    $ cd $HOME/.config/nvim/pack/downloads/start
    $ git clone https://github.com/yegappan/taglist

or you can use any one of the Vim plugin managers ([vim-plug](https://github.com/junegunn/vim-plug), [dein.vim](https://github.com/Shougo/dein.vim), [pathogen](https://github.com/tpope/vim-pathogen), [minpac](https://github.com/k-takata/minpac), [vam](https://github.com/MarcWeber/vim-addon-manager), [volt](https://github.com/vim-volt/volt), [Vundle](https://github.com/VundleVim/Vundle.vim), etc.) to install and manage this plugin.

For more information about using this plugin, after installing the taglist plugin, run the `:helptags ALL` command in Vim and then use the `:help taglist.txt` command.

You can visit the following page for more information:

    http://vim-taglist.sourceforge.net

