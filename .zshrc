# Enable inline comments
setopt INTERACTIVE_COMMENTS

# History settings
HISTSIZE=5000
SAVEHIST=5000
setopt hist_ignore_all_dups
setopt share_history

# Preferred editor
export EDITOR='nano'

# Set PATH
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Source .profile and .bashrc if they exist
[ -f ~/.profile ] && source ~/.profile
[ -f ~/.bashrc ] && source ~/.bashrc

# Optional: basic aliases
alias gs="git status"
alias ga="git add ."
alias gc="git commit -m"
alias gpl="git pull"
alias gps="git push"

# Enable command substitution in prompt
setopt prompt_subst

# Source all custom prompt functions
for f in ~/.myprompt/*.sh; do
  source "$f"
done

# Minimal prompt with Git branch
PROMPT='%~ $(git_branch) '

# Completion system
autoload -Uz compinit
compinit
