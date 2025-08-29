#!/usr/bin/env zsh
# ~/.myprompt/git_status.sh
# Git branch and status indicator for prompt

git_status() {
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    local branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD)
    local gitstat=""
    [[ -n $(git diff --cached --quiet; echo $?) ]] && gitstat+="+"
    [[ -n $(git diff --quiet; echo $?) ]] && gitstat+="!"
    [[ -n $(git ls-files --others --exclude-standard) ]] && gitstat+="?"
    echo "%F{yellow}($branch$gitstat)%f"
  fi
}