# zmodload zsh/zprof

# Enable inline comments
setopt INTERACTIVE_COMMENTS

# Set PATH
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# History settings
HISTSIZE=5000
SAVEHIST=5000
setopt hist_ignore_all_dups
setopt share_history

# Preferred editor
export EDITOR='nano'

# Source .profile and .bashrc (if needed)
[ -f ~/.profile ] && source ~/.profile
[ -f ~/.bashrc ] && source ~/.bashrc

# Aliases
alias gs="git status"
alias gc="git commit -m"
alias gp="git pull"

# Initialize completion system
zstyle ':completion:*' verbose no
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path $HOME/.cache/zsh/zcompcache
autoload -Uz compinit
compinit -C

# Redirect npm completion cache
zstyle ':completion:*' cache-path $HOME/.cache/zsh
export npm_config_cache=$HOME/.cache/npm

# Antidote plugin manager
export ANTIDOTE_NO_UPDATE=1
source ${ZDOTDIR:-$HOME}/.antidote/antidote.zsh
antidote load

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#999999"

# ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd history completion)

# Starship prompt
eval "$(starship init zsh)"

# zprof
