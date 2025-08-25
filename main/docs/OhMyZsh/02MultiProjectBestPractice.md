# 🗂 Best-practice structure for Zsh + Termux

 👌 The setup scalable and clean.
When you grow into multiple projects (React, TS, maybe Python later), dumping everything in .profile will get messy. Instead, we’ll structure things:

---

# 1. Global aliases (things you want everywhere) → ~/.profile

# ~/.profile (personal, portable)

# File management
alias ll='ls -la --color=auto'
alias la='ls -A'
alias l='ls -CF'

# Git shortcuts
alias gs='git status'
alias gp='git push'
alias gl='git pull'

# NPM / Node
alias dev='npm run dev'
alias build='npm run build'

# Safety
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

---

2. Custom PATH exports (global) → ~/.bashrc

# ~/.bashrc (env setup)

# Local scripts
export PATH="$HOME/scripts:$PATH"

# Local binaries
export PATH="$HOME/.local/bin:$PATH"

# Android/Termux specific (example)
export PATH="$PREFIX/share/ndk:$PATH"

---

3. Zsh init → ~/.zshrc

This bridges everything:

# ~/.zshrc

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="agnoster"

plugins=(
  git
  github
  npm
  zsh-autosuggestions
  zsh-syntax-highlighting
  extract
  aliases
)

source $ZSH/oh-my-zsh.sh

# ✅ Load your configs
[ -f ~/.profile ] && source ~/.profile
[ -f ~/.bashrc ] && source ~/.bashrc


---

4. Project-specific aliases

Instead of polluting .profile, keep them in a folder.

Example:

~/.aliases/
  ├── react.aliases
  ├── typescript.aliases
  └── python.aliases

react.aliases

# ~/.aliases/react.aliases
alias start='npm start'
alias test='npm test'
alias lint='npm run lint'

typescript.aliases

# ~/.aliases/typescript.aliases
alias tsb='tsc --build'
alias tsl='tsc --listFiles'

---

5. Load project aliases only when you need

In .zshrc, add a function:

# Function to load project-specific aliases
load_aliases() {
  local file="$HOME/.aliases/$1.aliases"
  if [ -f "$file" ]; then
    source "$file"
    echo "Loaded aliases: $1"
  else
    echo "No alias file for $1"
  fi
}

Usage:

load_aliases react
load_aliases typescript

---

✅ Result

Global stuff → .profile + .bashrc

Per-project stuff → ~/.aliases/project.aliases

Zsh loads both automatically

Easy to keep things tidy and portable (you can sync .profile across devices).