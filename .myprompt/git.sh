git_branch() {
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    local branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
    if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
      print -P "%F{red}($branch)%f"
    else
      print -P "%F{green}($branch)%f"
    fi
  fi
}
