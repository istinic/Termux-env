# Zsh configuration
setopt INTERACTIVE_COMMENTS
setopt APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY
setopt NO_BEEP
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
setopt PROMPT_SUBST       # Enable command substitution in prompts
setopt PROMPT_CR          # Move to new line before each prompt
setopt MULTIOS            # Better handling of multi-line output

# Enhanced 3-line prompt
PROMPT='$(git_status_enhanced)
$(date "+%y.%m.%d %H:%M")$(get_battery_simple)$(get_language_versions)$(get_exit_code)$_cmd_duration
%F{blue}%~%f '

# =============================================================================
# ZSH PLUGINS - Load in optimal order
# =============================================================================

# 1. Load autocomplete first (if available)
[ -f ~/.zsh/zsh-autocomplete/zsh-autocomplete.plugin.zsh ] && source ~/.zsh/zsh-autocomplete/zsh-autocomplete.plugin.zsh

# 2. Load history search (after autocomplete to avoid conflicts)
[ -f ~/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh ] && source ~/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh

# 3. Set key bindings (after both plugins loaded)
bindkey '^[[A' history-substring-search-up      # Up arrow
bindkey '^[[B' history-substring-search-down    # Down arrow  
bindkey '^P' history-substring-search-up        # Ctrl+P
bindkey '^N' history-substring-search-down      # Ctrl+N

# 4. Load syntax highlighting last (always goes last)
[ -f ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh