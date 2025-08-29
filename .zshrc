# Zsh configuration
setopt INTERACTIVE_COMMENTS
setopt hist_ignore_all_dups
setopt share_history
HISTSIZE=5000
SAVEHIST=5000
export EDITOR='nano'
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Source .profile and .bashrc if they exist
[ -f ~/.profile ] && source ~/.profile
[ -f ~/.bashrc ] && source ~/.bashrc

# Source all custom configurations
for f in ~/.myprompt/*.sh; do
  source $f
done

# Multi-line prompt support
setopt PROMPT_SUBST       # already enabled
setopt PROMPT_CR          # move to new line before each prompt
setopt MULTIOS            # optional, better handling of multi-line output

# Two-line prompt:
# Top line: Git branch
# Bottom line: current directory and input
PROMPT='$(git_status)$(date "+%y.%m.%d %H:%M")
%F{blue}%~%f '