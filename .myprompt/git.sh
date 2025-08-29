git_branch() {
  # Only show branch if inside a git repo
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    local branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
    # Red if changes, green if clean
    if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
      echo "%F{red}($branch)%f"
    else
      echo "%F{green}($branch)%f"
    fi
  fi
}
