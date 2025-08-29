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
Plugins are managed as git submodules and included automatically:
- `zsh-autosuggestions` - History-based command suggestions
- `zsh-syntax-highlighting` - Real-time command syntax highlighting

If cloning this repository, initialize submodules:
```bash
# When cloning
git clone --recursive <repo-url>

# Or after cloning
git submodule update --init --recursive

# To update plugins to latest versions
git submodule update --remote
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