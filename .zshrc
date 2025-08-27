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

# Antidote plugin manager
source ${ZDOTDIR:-$HOME}/.antidote/antidote.zsh
antidote load

# Starship prompt
eval "$(starship init zsh)"
