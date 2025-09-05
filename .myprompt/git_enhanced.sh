git_status_enhanced() {
    if git rev-parse --git-dir >/dev/null 2>&1; then
        local branch=$(git branch --show-current 2>/dev/null)
        local git_info=""
        
        # Count different types of changes
        local modified=$(git diff --name-only 2>/dev/null | wc -l)
        local staged=$(git diff --cached --name-only 2>/dev/null | wc -l)
        local untracked=$(git status --porcelain 2>/dev/null | grep "^??" | wc -l)
        
        # Show counts if > 0
        [[ $modified -gt 0 ]] && git_info+="%F{red}M$modified%f"
        [[ $staged -gt 0 ]] && git_info+="%F{green}S$staged%f"
        [[ $untracked -gt 0 ]] && git_info+="%F{yellow}U$untracked%f"
        
        # Ahead/behind
        local ahead_behind=$(git rev-list --count --left-right @{upstream}...HEAD 2>/dev/null)
        if [[ -n "$ahead_behind" ]]; then
            local behind=$(echo $ahead_behind | cut -f1)
            local ahead=$(echo $ahead_behind | cut -f2)
            [[ $behind -gt 0 ]] && git_info+=" %F{red}↓$behind%f"
            [[ $ahead -gt 0 ]] && git_info+=" %F{green}↑$ahead%f"
        fi
        
        # Stash count
        local stash_count=$(git stash list 2>/dev/null | wc -l)
        [[ $stash_count -gt 0 ]] && git_info+=" %F{cyan}⚑$stash_count%f"
        
        echo "%F{magenta}⎇ $branch%f$git_info "
    fi
}