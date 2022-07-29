![unit-tests](https://github.com/yegappan/taglist/workflows/unit-tests/badge.svg?branch=master)

# taglist - Source Code Browser plugin for Vim

The "Tag List" plugin is a source code browser plugin for Vim and provides an overview of the structure of source code files and allows you to efficiently browse through source code files for different programming languages.

This plugin works with both Vim and Neovim and will work on all the platforms where Vim/Neovim and ctags are supported.  This plugin will work in both console and GUI Vim. This version of the MRU plugin needs Vim 7.4 and above.

This plugin relies on exuberant or Universal ctags to get the list of tags defined in a source file.

## Installation

You can install this plugin by downloading the .zip or the .tar.gz file for the latest taglist release from the following page:

https://github.com/yegappan/taglist/releases/latest

You can expand the .zip file in the following directory (on Unix/Linux/MacOS systems):

    $ mkdir -p $HOME/.vim/pack/downloads/start/taglist
    $ cd $HOME/.vim/pack/downloads/start/taglist
    $ unzip <downloaded_taglist_file.zip>

You can also install this plugin directly from github using the following steps:

    $ mkdir -p $HOME/.vim/pack/downloads/start/taglist
    $ cd $HOME/.vim/pack/downloads/start/taglist
    $ git clone https://github.com/yegappan/taglist

For NeoVim:

    $ mkdir -p $HOME/.config/nvim/pack/downloads/start/taglist
    $ cd $HOME/.config/nvim/pack/downloads/start/taglist
    $ git clone https://github.com/yegappan/taglist

or you can use any one of the Vim plugin managers ([vim-plug](https://github.com/junegunn/vim-plug), [dein.vim](https://github.com/Shougo/dein.vim), [pathogen](https://github.com/tpope/vim-pathogen), [minpac](https://github.com/k-takata/minpac), [vam](https://github.com/MarcWeber/vim-addon-manager), [volt](https://github.com/vim-volt/volt), [Vundle](https://github.com/VundleVim/Vundle.vim), etc.) to install and manage this plugin.

For more information about using this plugin, after installing the taglist plugin, run the `:helptags ALL` command in Vim and then use the `:help taglist` command.

You can visit the following page for more information:

    http://vim-taglist.sourceforge.net

