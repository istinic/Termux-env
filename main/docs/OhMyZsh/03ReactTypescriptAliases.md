React + TypeScript workflow in Termux.
You’ll keep them in ~/.aliases/ and load them only when needed with load_aliases <name>.


---

📁 Folder structure

mkdir -p ~/.aliases

You’ll have:

~/.aliases/
  ├── react.aliases
  └── typescript.aliases


---

⚛️ 1. React aliases → ~/.aliases/react.aliases

# React / Frontend aliases

# Common npm scripts
alias start='npm start'
alias dev='npm run dev'
alias build='npm run build'
alias test='npm test'
alias lint='npm run lint'
alias format='npm run format'

# Yarn (if you use it)
alias ydev='yarn dev'
alias ybuild='yarn build'

# Vite / Next.js helpers
alias vdev='vite'
alias vbuild='vite build'
alias ndev='next dev'
alias nbuild='next build'

# Package.json quick view
alias pj='cat package.json | jq .scripts'


---

📘 2. TypeScript aliases → ~/.aliases/typescript.aliases

# TypeScript / Node aliases

# Compile
alias tscb='tsc --build'
alias tscw='tsc --watch'

# Show files included
alias tsfiles='tsc --listFiles'

# Run TS directly (requires ts-node)
alias tsn='ts-node'
alias tsn-watch='ts-node-dev --respawn'

# Type checking only
alias tscheck='tsc --noEmit'

# Clean build artifacts
alias tsclean='rm -rf dist && rm -rf build'


---

⚡ 3. How to load them

Add this function to ~/.zshrc (if you didn’t yet):

# Function to load project-specific aliases
load_aliases() {
  local file="$HOME/.aliases/$1.aliases"
  if [ -f "$file" ]; then
    source "$file"
    echo "✅ Loaded aliases: $1"
  else
    echo "⚠
