# MyPrompt Functions

This directory contains custom prompt functions for Zsh.  
The goal is to provide a lightweight, modular, and Git-aware prompt.

## Files

### `git_status.sh`
- Detects if the current directory is a Git repository.
- Shows the branch name.
- Shows status symbols:
  - `+` → staged changes
  - `!` → unstaged changes
  - `?` → untracked files
- Colors:
  - Yellow for branch and status symbols
- Usage: `$(git_status)` in your Zsh prompt.

## Adding More Functions
- Create a new `.sh` file in this folder.
- Make it executable (`chmod +x file.sh`).
- Source it in `.zshrc` or rely on the auto-source loop:
  ```bash
  for f in ~/.myprompt/*.sh; do
    source $f
  done