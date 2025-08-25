#!/bin/bash
# add-eruda-console.sh - Mobile debugging console integration
# Adds Eruda mobile console to any HTML file for development

add_eruda_to_file() {
    local file="$1"
    if [ ! -f "$file" ]; then
        echo "File not found: $file"
        return 1
    fi
    
    # Check if Eruda is already present
    if grep -q "eruda" "$file"; then
        echo "Eruda already present in $file"
        return 0
    fi
    
    # Add Eruda before closing body tag
    sed -i 's|</body>|    <!-- Eruda Mobile Console for Development -->\n    <script src="https://cdn.jsdelivr.net/npm/eruda"></script>\n    <script>eruda.init();</script>\n</body>|' "$file"
    echo "Added Eruda console to $file"
}

# Usage examples
if [ "$#" -eq 0 ]; then
    echo "Usage: $0 <html-file>"
    echo "Example: $0 docs/index.html"
    echo "         $0 main/data/dashboards/html/index.html"
    exit 1
fi

add_eruda_to_file "$1"
