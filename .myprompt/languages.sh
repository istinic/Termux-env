get_language_versions() {
    local versions=""
    
    # Node.js version
    if command -v node >/dev/null 2>&1; then
        local node_version=$(node --version 2>/dev/null | sed 's/v//')
        versions+=" %F{green}⬢ $node_version%f"
    fi
    
    # Python version  
    if command -v python >/dev/null 2>&1; then
        local py_version=$(python --version 2>&1 | cut -d' ' -f2 | cut -d'.' -f1,2)
        versions+=" %F{blue}🐍 $py_version%f"
    fi
    
    echo "$versions"
}

