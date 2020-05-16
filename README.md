# Dotfiles
My fedora dotfiles

# Installation
The installation itself requires git and bash, the following programs are configured by this repo

 - zsh
 - neovim
 - Jetbrains IDEs (ideavim)
 - tilix
 - marker
 - GNOME shell

To install my configs, run the following commands

```sh
cd
alias config='/usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME"'
git clone --bare https://github.com/Spindlyskit/dotfiles/ .dotfiles
config checkout
```

Then, restart the shell and run `gnome-setup` to configure GNOME (keybinds, {gtk,icon,shell,cursor} theme, extensions)
