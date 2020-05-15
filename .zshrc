#
# Plugins
#

# Load antigen for plugin management
source ~/.antigen.zsh

# Fish-like syntax highlighting
antigen bundle zsh-users/zsh-syntax-highlighting

# Show suggestions from history
antigen bundle zsh-users/zsh-autosuggestions

# More completions
antigen bundle zsh-users/zsh-completions

# End plugins
antigen apply

# Disable ctrl-s and ctrl-q.
stty -ixon

# Setup prompt
autoload -U colors; colors
# Requires starship (https://starship.rs)
if [ $(command -v starship) ]; then
	# This will load new config changes but is slower
	eval "$(starship init zsh)"
else
	PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b "
fi

function precmd() {
    # Print a newline before the prompt, unless it's the
    # first prompt in the process.
    if [ -z "$NEW_LINE_BEFORE_PROMPT" ]; then
        NEW_LINE_BEFORE_PROMPT=1
    elif [ "$NEW_LINE_BEFORE_PROMPT" -eq 1 ]; then
		echo "\n"
    fi

	# Set window title
	echo -ne "\033];$USER@$HOST: $(pwd | sed "s|$HOME|~|g")\007"
}

# Globbing and autocompletion
setopt extendedglob     # Use the ^, ~, and # for filename globbing
setopt nocaseglob       # Case insensitive filename globbing
setopt nomatch          # Warn if file globbing didn't match any file
setopt completeinword   # Allow autocompletions inside a word

# Setup completion
# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' completer _expand _complete _ignored _approximate
zstyle ':completion:*' menu select=2
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
zstyle ':completion::complete:*' use-cache 1
autoload -Uz compinit
compinit
zmodload zsh/complist
compinit
_comp_options+=(globdots)		# Include hidden files.

# Misc
# Disable terminal bell
setopt nobeep
# cd if only a directory name was entered
setopt autocd
# Comments in interactive shell
setopt interactivecomments
# Changing/making/removing directory
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushdminus

# Enable vi mode
bindkey -v
export KEYTIMEOUT=1

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# Change cursor shape for different vi modes.
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'
  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

# Use ranger to switch directories and bind it to ctrl-o
function rcd {
    tempfile="$(mktemp -t tmp.XXXXXX)"
    ranger --choosedir="$tempfile" "${@:-$(pwd)}"
    test -f "$tempfile" &&
    if [ "$(cat -- "$tempfile")" != "$(echo -n `pwd`)" ]; then
        cd -- "$(cat "$tempfile")"
    fi
    rm -f -- "$tempfile"
}
# Send escape + dd to delete anything on the line already
bindkey -s '^o' '^[ddircd\n'

# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line

# Turn ctrl-z into a toggle
ctrlz() {
  if [[ $#BUFFER == 0 ]]; then
    fg >/dev/null 2>&1 && zle redisplay
  else
    zle push-input
  fi
}
zle -N ctrlz
bindkey '^Z' ctrlz

# Use ctrl-f to browse directory stack
ctrlf() {
	cd "$(dirs -p | tail | fzf --height 40% --reverse +s --tac | sed "s|~|$HOME|g")"
	zle redisplay
	zle -R
}
zle -N ctrlf
bindkey '^F' ctrlf

# Allow ctrl-w for word deletion (standard behaviour)
export WORDCHARS='~!#$%^&*(){}[]<>?.+;-'
bindkey '^w' backward-kill-word

# Allow ctrl-r to perform fuzzy search in history
frs() {
	zle push-input
	print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf --height 40% --reverse +s --tac | sed -r 's/ *[0-9]*\*? *//' | sed -r 's/\\/\\\\/g')
	zle redisplay
	zle get-line
}
zle -N frs
bindkey '^r' frs
bindkey -M vicmd '/' frs

# Open existing ranger if in a shell where ranger is a bg process
ranger() {
    if [ -z "$RANGER_LEVEL" ]; then
        /usr/bin/ranger "$@"
    else
        exit
    fi
}


# Load aliases
source ~/.aliases
source ~/.shortcuts.zsh
source $HOME/.local/lib/fzf.sh

# Color man
export LESS_TERMCAP_mb=$'\E[01;31m' \
LESS_TERMCAP_md=$'\E[01;38;5;74m' \
LESS_TERMCAP_me=$'\E[0m' \
LESS_TERMCAP_se=$'\E[0m' \
LESS_TERMCAP_so=$'\E[38;5;246m' \
LESS_TERMCAP_ue=$'\E[0m' \
LESS_TERMCAP_us=$'\E[04;38;5;146m'

# Color ls & grep
alias grep='grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn}'
alias ls='ls --color=auto'

# Lazy load nvm
declare -a NODE_GLOBALS=(`find ~/.local/share/nvm/versions/node -maxdepth 3 -type l -wholename '*/bin/*' | xargs -n1 basename | sort | uniq`)

NODE_GLOBALS+=("node")
NODE_GLOBALS+=("nvm")

load_nvm () {
    export NVM_DIR=~/.local/share/nvm
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
}

for cmd in "${NODE_GLOBALS[@]}"; do
    eval "${cmd}(){ unset -f ${NODE_GLOBALS}; load_nvm; ${cmd} \$@ }"
done

# Shell history in .cache
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.cache/zsh/history
setopt hist_ignore_all_dups # Remove duplicates from the history
setopt hist_ignore_space    # Ignore lines prefixed with a space

#alias neofetch="neofetch --ascii_distro windows | sed 's/Arch Linux x86_64/Windows 98/;s/5.5.5-arch1-1/NT/;s/ (pacman)//;s/zsh.*/cmd.exe/;s/GNOME.*/Explorer/;s/Mutter/Desktop Window Manager.exe/;s/\[GTK.*//;s/Tela.*/Windows/;s/xfce.*/conhost.exe/;s/SF Mono.*/Courier New 10/'"

