#!/usr/bin/env zsh
# ~/.myprompt/completion.sh
# Zsh completion, autosuggestion, and enhancement configurations

# Enhanced Completion System
autoload -Uz compinit
compinit

# Completion options
setopt AUTO_LIST              # List choices on ambiguous completion
setopt AUTO_MENU              # Use menu completion after the second tab
setopt COMPLETE_IN_WORD       # Complete from both ends of a word
setopt ALWAYS_TO_END          # Move cursor to the end of a completed word
setopt PATH_DIRS              # Perform path search even on command names with slashes
setopt AUTO_PARAM_SLASH       # If completed parameter is a directory, add a trailing slash
setopt AUTO_PARAM_KEYS        # Intelligently add a space after other completed parameters

# Make completion case-insensitive and partial-word matching
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Use colors in completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Group matches and describe
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'

# Directory completion improvements
zstyle ':completion:*' special-dirs true
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

# Process completion
zstyle ':completion:*:processes' command 'ps -u $USER -o pid,user,comm -w -w'

# History-based autosuggestions (requires zsh-autosuggestions plugin)
# Install with: git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
if [[ -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
  
  # Autosuggestion settings
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'  # Gray suggestions
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
  ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
fi

# Syntax highlighting (requires zsh-syntax-highlighting plugin)
# Install with: git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.zsh/zsh-syntax-highlighting
if [[ -f ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Better history search
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search   # Up arrow
bindkey "^[[B" down-line-or-beginning-search # Down arrow

# Additional useful keybindings
bindkey '^R' history-incremental-search-backward  # Ctrl+R for reverse search
bindkey '^S' history-incremental-search-forward   # Ctrl+S for forward search
bindkey '^[[1;5C' forward-word                    # Ctrl+Right arrow
bindkey '^[[1;5D' backward-word                   # Ctrl+Left arrow