cat > main/utils/README.md << 'EOF'
# Development Utilities

## Mobile Debugging Tools

### Eruda Mobile Console
**Script**: `add-eruda-console.sh`
**Purpose**: Adds mobile debugging console to HTML files
**Usage**: `./add-eruda-console.sh docs/index.html`

Eruda provides:
- JavaScript console on mobile browsers
- Element inspection capabilities  
- Network monitoring
- Storage inspection
- Performance monitoring

**Why needed**: Mobile browsers lack developer tools, making debugging difficult. Eruda provides desktop-like debugging capabilities on mobile devices.

### Integration Examples
```bash
# Add to GitHub Pages dashboard
./main/utils/add-eruda-console.sh docs/index.html

# Add to local dashboard
./main/utils/add-eruda-console.sh main/data/dashboards/html/index.html

# Add to any HTML file
./main/utils/add-eruda-console.sh path/to/file.html
Access on Mobile
Load the HTML page in mobile browser
Look for floating Eruda icon (usually bottom-right)
Tap to open debugging console
Use Console tab for JavaScript debugging
Use Elements tab for DOM inspection
Part of Termux Environment Development Toolkit 
EOF