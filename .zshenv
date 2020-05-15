# Default applications
export TERMINAL=tilix
export VISUAL=nvim
export EDITOR=nvim
export GIT_EDITOR=nvim
export BROWSER=firefox
export READER=evince
export MEDIA=celluloid
export QT_QPA_PLATFORMTHEME=qt5ct

# Move stuff out of ~/
export CARGO_HOME="$HOME/.local/share/cargo"
export RUSTUP_HOME="$HOME/.local/share/rustup"
export ANDROID_AVD_HOME="$HOME/.local/share/android"
export ADOTDIR="$HOME/.cache/antigen"
export GNUPGHOME="$HOME/.cache/gnupg"
export LESSHISTFILE=-

export GOPATH="$HOME/go"

# Fzf options
export FZF_DEFAULT_COMMAND='rg --files --hidden'

# Ruby gems
if which ruby >/dev/null && which gem >/dev/null; then
	PATH="$(ruby -r rubygems -e 'puts Gem.user_dir')/bin:$PATH"
fi

# Install npm packages without root
export NPM_PACKAGES="${HOME}/.node_modules"
export NODE_PATH="$NPM_PACKAGES/lib/node_modules:$NODE_PATH"
export PATH=$HOME/.local/bin:$PATH:$HOME/bin:$GOPATH/bin:$HOME/.gem/ruby/2.6.0/bin:$NPM_PACKAGES/bin:$HOME/.cargo/bin

# Unset manpath so we can inherit from /etc/manpath via the `manpath`
# command
unset MANPATH
MANPATH="$NPM_PACKAGES/share/man:$(manpath)"

export PATH=$PATH:$GOPATH/bin
