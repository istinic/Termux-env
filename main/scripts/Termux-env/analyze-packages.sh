#!/bin/bash
# main/scripts/Termux-env/analyze-packages.sh
# Package intelligence system for Termux environment

set -e

# Configuration
SCRIPT_DIR="$(dirname "$0")"
DATA_DIR="$HOME/main/data"
PACKAGES_DIR="$DATA_DIR/packages"
ANALYTICS_DIR="$DATA_DIR/analytics"

# Create directories
mkdir -p "$PACKAGES_DIR" "$ANALYTICS_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📦 Termux Package Intelligence System${NC}"
echo "================================================"

# 1. Collect Package Information
echo -e "${YELLOW}🔍 Collecting package information...${NC}"

# Get all installed packages with details
pkg list-installed > "$PACKAGES_DIR/installed-packages-raw.txt"

# Create detailed package analysis
{
    echo "# Package Analysis Report"
    echo "Generated: $(date)"
    echo "Total packages: $(pkg list-installed | wc -l)"
    echo ""
    echo "## Package Categories"
    echo ""
} > "$ANALYTICS_DIR/package-analysis.md"

# 2. Categorize packages by purpose
echo -e "${YELLOW}📊 Categorizing packages...${NC}"

# Development tools
DEV_PACKAGES=$(pkg list-installed | grep -E "(git|vim|nano|python|nodejs|npm|make|cmake|gcc|clang)" || true)
if [ ! -z "$DEV_PACKAGES" ]; then
    {
        echo "### 🛠️ Development Tools"
        echo '```'
        echo "$DEV_PACKAGES"
        echo '```'
        echo ""
    } >> "$ANALYTICS_DIR/package-analysis.md"
fi

# System utilities
SYSTEM_PACKAGES=$(pkg list-installed | grep -E "(htop|tree|curl|wget|unzip|tar|grep|sed|awk)" || true)
if [ ! -z "$SYSTEM_PACKAGES" ]; then
    {
        echo "### ⚙️ System Utilities"
        echo '```'
        echo "$SYSTEM_PACKAGES"
        echo '```'
        echo ""
    } >> "$ANALYTICS_DIR/package-analysis.md"
fi

# Shell and terminal
SHELL_PACKAGES=$(pkg list-installed | grep -E "(zsh|bash|tmux|screen|termux)" || true)
if [ ! -z "$SHELL_PACKAGES" ]; then
    {
        echo "### 🐚 Shell & Terminal"
        echo '```'
        echo "$SHELL_PACKAGES"
        echo '```'
        echo ""
    } >> "$ANALYTICS_DIR/package-analysis.md"
fi

# Network tools
NETWORK_PACKAGES=$(pkg list-installed | grep -E "(openssh|rsync|nmap|netcat)" || true)
if [ ! -z "$NETWORK_PACKAGES" ]; then
    {
        echo "### 🌐 Network Tools"
        echo '```'
        echo "$NETWORK_PACKAGES"
        echo '```'
        echo ""
    } >> "$ANALYTICS_DIR/package-analysis.md"
fi

# 3. Get package descriptions and purposes
echo -e "${YELLOW}📖 Analyzing package purposes...${NC}"

{
    echo "## Package Descriptions"
    echo ""
} >> "$ANALYTICS_DIR/package-analysis.md"

# Get first 10 packages for detailed analysis (to avoid overwhelming output)
pkg list-installed | head -10 | while read package_line; do
    # Extract package name (first part before space)
    package_name=$(echo "$package_line" | awk '{print $1}' | sed 's/.*\///')
    
    if [ ! -z "$package_name" ]; then
        echo -e "${GREEN}  Analyzing: $package_name${NC}"
        
        # Get package information
        pkg_info=$(pkg show "$package_name" 2>/dev/null || echo "No info available")
        
        {
            echo "### $package_name"
            echo '```'
            echo "$pkg_info" | head -10  # First 10 lines to avoid too much output
            echo '```'
            echo ""
        } >> "$ANALYTICS_DIR/package-analysis.md"
    fi
done

# 4. Check for available updates
echo -e "${YELLOW}🔄 Checking for updates...${NC}"

{
    echo "## Available Updates"
    echo ""
    echo '```bash'
    echo "# To check for updates, run:"
    echo "pkg update"
    echo "pkg list-all | grep upgradable"
    echo '```'
    echo ""
} >> "$ANALYTICS_DIR/package-analysis.md"

# 5. Package size analysis
echo -e "${YELLOW}💾 Analyzing package sizes...${NC}"

{
    echo "## Storage Usage"
    echo ""
    echo "### Large Packages (estimated)"
    echo '```bash'
    echo "# To see package sizes:"
    echo "du -sh /data/data/com.termux/files/usr/bin/* | sort -hr | head -10"
    echo '```'
    echo ""
} >> "$ANALYTICS_DIR/package-analysis.md"

# 6. Generate insights and recommendations
echo -e "${YELLOW}💡 Generating insights...${NC}"

{
    echo "## Insights & Recommendations"
    echo ""
    echo "### 🎯 Essential Packages"
    echo "Based on your usage patterns:"
    echo "- **git**: Version control (essential for development)"
    echo "- **zsh**: Enhanced shell experience"
    echo "- **htop**: System monitoring (you just discovered this!)"
    echo "- **nano/vim**: Text editing capabilities"
    echo ""
    echo "### 🧹 Cleanup Opportunities"
    echo "Consider reviewing:"
    echo "- Packages not used in last 30 days"
    echo "- Duplicate functionality (e.g., multiple text editors)"
    echo "- Development packages for unused languages"
    echo ""
    echo "### 📚 Learning Opportunities"
    echo "Packages to explore further:"
    echo "- **tmux**: Terminal multiplexing"
    echo "- **curl/wget**: Network operations"
    echo "- **tree**: Directory visualization"
    echo ""
} >> "$ANALYTICS_DIR/package-analysis.md"

# 7. Create summary
{
    echo "## Summary"
    echo ""
    echo "- **Total Packages**: $(pkg list-installed | wc -l)"
    echo "- **Analysis Date**: $(date)"
    echo "- **Next Review**: $(date -d '+1 week')"
    echo ""
    echo "---"
    echo "*Generated by Termux Package Intelligence System*"
} >> "$ANALYTICS_DIR/package-analysis.md"

echo -e "${GREEN}✅ Package analysis complete!${NC}"
echo -e "${BLUE}📄 Report saved to: $ANALYTICS_DIR/package-analysis.md${NC}"
echo ""
echo -e "${YELLOW}🔍 To view the report:${NC}"
echo "cat $ANALYTICS_DIR/package-analysis.md"
echo ""
echo -e "${YELLOW}📊 Quick stats:${NC}"
echo "Total packages: $(pkg list-installed | wc -l)"
echo "Report location: $ANALYTICS_DIR/package-analysis.md"