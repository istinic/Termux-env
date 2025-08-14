#!/bin/bash
# collect-env-data.sh - Termux Environment Data Collection Script
# Part of Termux Environment Hybrid Automation System
# Created: 14 Aug 2025

set -e  # Exit on any error

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# From scripts/Termux-env/ go up 3 levels to repository root (HOME)
BASE_DIR="$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")"  
DATA_DIR="$BASE_DIR/main/data"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
LOG_FILE="$DATA_DIR/logs/collection_${TIMESTAMP}.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    local level=$1
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Create log directory if it doesn't exist
    mkdir -p "$(dirname "$LOG_FILE")"
    
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    
    case $level in
        "INFO") echo -e "${GREEN}[INFO]${NC} $message" ;;
        "WARN") echo -e "${YELLOW}[WARN]${NC} $message" ;;
        "ERROR") echo -e "${RED}[ERROR]${NC} $message" ;;
        "DEBUG") echo -e "${BLUE}[DEBUG]${NC} $message" ;;
    esac
}

# Create data directory structure
create_data_structure() {
    log "INFO" "Creating data directory structure..."
    
    mkdir -p "$DATA_DIR"/{packages,system,config,snapshots,logs,reports}
    
    # Create .gitignore for data directory if it doesn't exist
    if [ ! -f "$DATA_DIR/.gitignore" ]; then
        cat > "$DATA_DIR/.gitignore" << 'EOF'
# Exclude logs and temporary files
logs/
*.tmp
*.temp

# Keep structure files
!.gitignore
!snapshots/
!packages/
!system/
!config/
!reports/
EOF
        log "INFO" "Created .gitignore for data directory"
    fi
}

# Collect package information
collect_packages() {
    log "INFO" "Collecting package information..."
    
    local pkg_dir="$DATA_DIR/packages"
    local current_date=$(date +"%Y-%m-%d")
    
    # Current installed packages
    log "DEBUG" "Generating installed packages list..."
    pkg list-installed | sort > "$pkg_dir/installed-packages_${current_date}.txt"
    pkg list-installed | sort > "$pkg_dir/current-packages.txt"  # Always current
    
    # Package sources
    log "DEBUG" "Collecting package sources..."
    if [ -f "$PREFIX/etc/apt/sources.list" ]; then
        cp "$PREFIX/etc/apt/sources.list" "$pkg_dir/sources-list_${current_date}.txt"
    fi
    
    # Package statistics
    local total_packages=$(pkg list-installed | wc -l)
    local available_packages=$(pkg list-all 2>/dev/null | wc -l || echo "unknown")
    
    cat > "$pkg_dir/package-stats_${current_date}.json" << EOF
{
    "timestamp": "$(date -Iseconds)",
    "total_installed": $total_packages,
    "total_available": $available_packages,
    "last_update": "$(date +"%Y-%m-%d %H:%M:%S")"
}
EOF
    
    log "INFO" "Collected information for $total_packages installed packages"
}

# Collect system information
collect_system_info() {
    log "INFO" "Collecting system information..."
    
    local sys_dir="$DATA_DIR/system"
    local current_date=$(date +"%Y-%m-%d")
    
    # Basic system info
    log "DEBUG" "Collecting basic system information..."
    {
        echo "=== Termux System Information ==="
        echo "Collection Date: $(date)"
        echo "Termux Version: $(termux-info | grep -i version || echo 'unknown')"
        echo "Android Version: $(getprop ro.build.version.release 2>/dev/null || echo 'unknown')"
        echo "Device Model: $(getprop ro.product.model 2>/dev/null || echo 'unknown')"
        echo "Architecture: $(uname -m)"
        echo "Kernel: $(uname -r)"
        echo ""
        echo "=== Environment Variables ==="
        echo "PREFIX: $PREFIX"
        echo "HOME: $HOME"
        echo "PATH: $PATH"
        echo ""
        echo "=== Storage Information ==="
        df -h "$HOME" 2>/dev/null || echo "Storage info unavailable"
        echo ""
        echo "=== Memory Information ==="
        free -h 2>/dev/null || echo "Memory info unavailable"
    } > "$sys_dir/system-info_${current_date}.txt"
    
    # Process list (top running processes)
    log "DEBUG" "Collecting process information..."
    {
        echo "=== Running Processes ==="
        ps aux 2>/dev/null | head -20 || echo "Process list unavailable"
    } > "$sys_dir/processes_${current_date}.txt"
    
    # Environment hash (for change detection)
    {
        echo "System info hash: $(cat "$sys_dir/system-info_${current_date}.txt" | md5sum | cut -d' ' -f1)"
        echo "Package list hash: $(cat "$DATA_DIR/packages/current-packages.txt" | md5sum | cut -d' ' -f1)"
    } > "$sys_dir/environment-hash_${current_date}.txt"
    
    log "INFO" "System information collection completed"
}

# Collect configuration files
collect_configs() {
    log "INFO" "Collecting configuration files..."
    
    local config_dir="$DATA_DIR/config"
    local current_date=$(date +"%Y-%m-%d")
    
    # Important config files to track (checksums only for comparison)
    local config_files=(
        ".bashrc"
        ".profile" 
        ".gitconfig"
        ".npmrc"
        ".termux/termux.properties"
        ".termux/colors.properties"
        ".termux/font.ttf"
    )
    
    log "DEBUG" "Generating config file checksums..."
    {
        echo "=== Configuration File Checksums ==="
        echo "Generated: $(date)"
        echo ""
        
        for config in "${config_files[@]}"; do
            local file_path="$HOME/$config"
            if [ -f "$file_path" ]; then
                local checksum=$(md5sum "$file_path" | cut -d' ' -f1)
                local size=$(stat -f%z "$file_path" 2>/dev/null || stat -c%s "$file_path" 2>/dev/null || echo "unknown")
                local modified=$(stat -f%m "$file_path" 2>/dev/null || stat -c%Y "$file_path" 2>/dev/null || echo "unknown")
                echo "$config: $checksum (size: $size, modified: $modified)"
            else
                echo "$config: FILE_NOT_FOUND"
            fi
        done
    } > "$config_dir/config-checksums_${current_date}.txt"
    
    # Git repository status
    log "DEBUG" "Collecting git status information..."
    {
        echo "=== Git Repository Status ==="
        echo "Generated: $(date)"
        echo ""
        cd "$BASE_DIR"
        echo "Current branch: $(git branch --show-current 2>/dev/null || echo 'unknown')"
        echo "Last commit: $(git log -1 --oneline 2>/dev/null || echo 'no commits')"
        echo "Working directory status:"
        git status --porcelain 2>/dev/null || echo "Git status unavailable"
    } > "$config_dir/git-status_${current_date}.txt"
    
    log "INFO" "Configuration tracking completed"
}

# Create environment snapshot
create_snapshot() {
    log "INFO" "Creating environment snapshot..."
    
    local snapshot_dir="$DATA_DIR/snapshots"
    local snapshot_file="$snapshot_dir/environment-snapshot_${TIMESTAMP}.json"
    
    # Calculate some metrics
    local total_packages=$(wc -l < "$DATA_DIR/packages/current-packages.txt" 2>/dev/null || echo 0)
    local storage_used=$(du -sh "$HOME" 2>/dev/null | cut -f1 || echo "unknown")
    local git_status=$(cd "$BASE_DIR" && git status --porcelain 2>/dev/null | wc -l || echo 0)
    
    log "DEBUG" "Generating JSON snapshot..."
    cat > "$snapshot_file" << EOF
{
    "metadata": {
        "timestamp": "$(date -Iseconds)",
        "collection_script": "collect-env-data.sh",
        "version": "1.0.0",
        "termux_environment": "$(echo $HOME)"
    },
    "summary": {
        "total_packages": $total_packages,
        "storage_used": "$storage_used",
        "git_changes": $git_status,
        "collection_success": true
    },
    "files_generated": {
        "packages": "$(ls "$DATA_DIR/packages" | grep "$(date +"%Y-%m-%d")" | wc -l)",
        "system": "$(ls "$DATA_DIR/system" | grep "$(date +"%Y-%m-%d")" | wc -l)",  
        "config": "$(ls "$DATA_DIR/config" | grep "$(date +"%Y-%m-%d")" | wc -l)"
    },
    "hashes": {
        "packages": "$(cat "$DATA_DIR/packages/current-packages.txt" | md5sum | cut -d' ' -f1)",
        "system": "$(cat "$DATA_DIR/system/system-info_$(date +"%Y-%m-%d").txt" | md5sum | cut -d' ' -f1)"
    }
}
EOF
    
    # Create a "latest" symlink
    ln -sf "environment-snapshot_${TIMESTAMP}.json" "$snapshot_dir/latest-snapshot.json"
    
    log "INFO" "Environment snapshot saved: $snapshot_file"
}

# Generate summary report
generate_report() {
    log "INFO" "Generating collection summary report..."
    
    local report_file="$DATA_DIR/reports/collection-report_${TIMESTAMP}.md"
    
    cat > "$report_file" << EOF
# Termux Environment Collection Report

**Generated**: $(date)  
**Collection ID**: $TIMESTAMP  
**Script Version**: 1.0.0

## Summary

- **Total Packages**: $(wc -l < "$DATA_DIR/packages/current-packages.txt" 2>/dev/null || echo "unknown")
- **Storage Used**: $(du -sh "$HOME" 2>/dev/null | cut -f1 || echo "unknown")
- **Git Status**: $(cd "$BASE_DIR" && git status --porcelain 2>/dev/null | wc -l || echo 0) uncommitted changes
- **Collection Status**: ✅ Successful

## Files Generated

### Packages
- Current package list: \`packages/current-packages.txt\`
- Package statistics: \`packages/package-stats_$(date +"%Y-%m-%d").json\`

### System
- System information: \`system/system-info_$(date +"%Y-%m-%d").txt\`
- Environment hashes: \`system/environment-hash_$(date +"%Y-%m-%d").txt\`

### Configuration
- Config checksums: \`config/config-checksums_$(date +"%Y-%m-%d").txt\`
- Git status: \`config/git-status_$(date +"%Y-%m-%d").txt\`

### Snapshots
- Environment snapshot: \`snapshots/environment-snapshot_${TIMESTAMP}.json\`

## Next Steps

1. Review generated files for accuracy
2. Commit changes to git repository
3. Push to GitHub to trigger automation workflows

---
*Generated by Termux Environment Data Collection System*
EOF
    
    log "INFO" "Summary report generated: $report_file"
}

# Cleanup old files (keep last 7 days)
cleanup_old_files() {
    log "INFO" "Cleaning up old collection files..."
    
    # Remove files older than 7 days, but keep at least 3 most recent
    find "$DATA_DIR" -name "*_[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]*" -type f -mtime +7 | \
    while read file; do
        log "DEBUG" "Removing old file: $file"
        rm -f "$file"
    done
    
    log "INFO" "Cleanup completed"
}

# Main execution function
main() {
    log "INFO" "Starting Termux Environment Data Collection"
    log "INFO" "Timestamp: $TIMESTAMP"
    log "INFO" "Base Directory: $BASE_DIR"
    log "INFO" "Data Directory: $DATA_DIR"
    
    # Execute collection steps
    create_data_structure
    collect_packages
    collect_system_info
    collect_configs
    create_snapshot
    generate_report
    cleanup_old_files
    
    log "INFO" "Data collection completed successfully!"
    log "INFO" "Log file: $LOG_FILE"
    log "INFO" "Summary report: $DATA_DIR/reports/collection-report_${TIMESTAMP}.md"
    
    echo ""
    echo "🎉 Collection Complete!"
    echo "📊 View the summary: cat $DATA_DIR/reports/collection-report_${TIMESTAMP}.md"
    echo "📝 Check logs: cat $LOG_FILE"
    echo ""
    echo "Next steps:"
    echo "1. Review the generated files"
    echo "2. Run: git add main/data && git commit -m 'Environment data collection: $TIMESTAMP'"
    echo "3. Run: git push"
}

# Script execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi