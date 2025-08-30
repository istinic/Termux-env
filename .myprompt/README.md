# MyPrompt Functions

This directory contains custom prompt functions and configurations for Zsh.
The goal is to provide a lightweight, modular, and Git-aware prompt with enhanced shell features.

## Files

### `git_status.sh`
Git integration for the prompt:
- Detects if the current directory is a Git repository
- Shows the branch name with conditional coloring
- Shows status symbols:
  - `+` → staged changes
  - `!` → unstaged changes
  - `?` → untracked files
- Colors:
  - **Green** → clean working tree (no changes)
  - **Yellow** → dirty working tree (has changes)
- Usage: `$(git_status)` in your Zsh prompt

### `completion.sh`
Advanced shell enhancements:
- **Enhanced autocompletion**: Case-insensitive, partial matching, colored output
- **History-based autosuggestions**: Shows gray suggestions as you type (requires plugin)
- **Syntax highlighting**: Commands turn green/red based on validity (requires plugin)
- **Smart history search**: Up/Down arrows search based on current input
- **Improved keybindings**: Ctrl+R for reverse search, Ctrl+Left/Right for word navigation

#### Plugin Dependencies
Optional but recommended plugins (auto-detected):
```bash
# Install autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions

# Install syntax highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.zsh/zsh-syntax-highlighting
```

## Current Prompt Format
```
(branch-name) YY.MM.DD HH:MM
~/current/directory 
```

## Adding More Functions
1. Create a new `.sh` file in this folder
2. Make it executable: `chmod +x file.sh`
3. Add your functions/configurations
4. Reload shell: `source ~/.zshrc`

Files are automatically sourced via the loop in `.zshrc`:
```bash
for f in ~/.myprompt/*.sh; do
  source $f
done
```

## Features Summary
- ✅ Git-aware prompt with status indicators
- ✅ Clean working tree detection (green/yellow coloring)
- ✅ Enhanced tab completion
- ✅ History-based autosuggestions
- ✅ Syntax highlighting
- ✅ Smart history search
- ✅ Improved keybindings
- ✅ Modular configuration approach