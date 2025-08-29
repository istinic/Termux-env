#!/usr/bin/env zsh
# ~/.myprompt/git_status.sh
# Git branch and status indicator for prompt

git_status() {
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    local branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD)
    local gitstat=""
    
    # Check for staged changes (files in index)
    if ! git diff --cached --quiet 2>/dev/null; then
      gitstat+="+"
    fi
    
    # Check for unstaged changes (modified files in working tree)
    if ! git diff --quiet 2>/dev/null; then
      gitstat+="!"
    fi
    
    # Check for untracked files
    if [[ -n $(git ls-files --others --exclude-standard 2>/dev/null) ]]; then
      gitstat+="?"
    fi
    
    # Choose color based on git status
    if [[ -n "$gitstat" ]]; then
      echo "%F{yellow}($branch$gitstat)%f"  # Yellow if there are changes
    else
      echo "%F{green}($branch)%f"           # Green if clean
    fi
  fi
}