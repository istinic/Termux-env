#!/bin/bash
# detect-changes.sh - Intelligent Change Detection System
# Part of Termux Environment Hybrid Automation - Milestone 2.1
# Analyzes environment changes and generates smart insights

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$HOME"
DATA_DIR="$BASE_DIR/main/data"
CHANGES_DIR="$DATA_DIR/changes"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

log() {
    local level=$1
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case $level in
        "INFO") echo -e "${GREEN}[INFO]${NC} $message" ;;
        "WARN") echo -e "${YELLOW}[WARN]${NC} $message" ;;
        "ERROR") echo -e "${RED}[ERROR]${NC} $message" ;;
        "DEBUG") echo -e "${BLUE}[DEBUG]${NC} $message" ;;
        "CHANGE") echo -e "${PURPLE}[CHANGE]${NC} $message" ;;
        "INSIGHT") echo -e "${CYAN}[INSIGHT]${NC} $message" ;;
    esac
}

# Create changes directory structure
setup_changes_tracking() {
    log "INFO" "Setting up change tracking structure..."
    
    mkdir -p "$CHANGES_DIR"/{packages,configs,system,analysis,summaries}
    
    # Create change tracking metadata
    if [ ! -f "$CHANGES_DIR/.tracking_metadata" ]; then
        cat > "$CHANGES_DIR/.tracking_metadata" << 'EOF'
# Change Detection Metadata
# This file tracks change detection history and configuration

TRACKING_START_DATE="$(date -Iseconds)"
LAST_ANALYSIS_DATE=""
DETECTION_VERSION="2.1.0"
CHANGE_THRESHOLD_PACKAGES=1
CHANGE_THRESHOLD_CONFIGS=1
SIGNIFICANT_CHANGE_THRESHOLD=5
EOF
        log "INFO" "Created change tracking metadata"
    fi
}

# Compare package lists between snapshots
detect_package_changes() {
    log "INFO" "Analyzing package changes..."
    
    local changes_file="$CHANGES_DIR/packages/package-changes_${TIMESTAMP}.md"
    local current_packages="$DATA_DIR/packages/current-packages.txt"
    
    # Get list of all package snapshots, sorted by date
    local snapshots=($(ls -t "$DATA_DIR/packages/installed-packages_"*.txt 2>/dev/null || echo ""))
    
    if [ ${#snapshots[@]} -lt 2 ]; then
        log "WARN" "Need at least 2 package snapshots for comparison"
        echo "# Package Changes Analysis" > "$changes_file"
        echo "**Status**: Insufficient data for comparison (need 2+ snapshots)" >> "$changes_file"
        echo "**Snapshots available**: ${#snapshots[@]}" >> "$changes_file"
        return
    fi
    
    local latest_snapshot="${snapshots[0]}"
    local previous_snapshot="${snapshots[1]}"
    
    log "DEBUG" "Comparing: $(basename $latest_snapshot) vs $(basename $previous_snapshot)"
    
# Create temporary files for comparison in local directory
    local temp_dir="$CHANGES_DIR/packages/temp"
    mkdir -p "$temp_dir"
    local current_sorted="$temp_dir/current_packages.sorted"
    local previous_sorted="$temp_dir/previous_packages.sorted"
    
    sort "$latest_snapshot" > "$current_sorted"
    sort "$previous_snapshot" > "$previous_sorted"
    
    # Find added, removed, and unchanged packages
    local added_packages="$temp_dir/added_packages.txt"
    local removed_packages="$temp_dir/removed_packages.txt"
    local unchanged_packages="$temp_dir/unchanged_packages.txt"
    
    comm -13 "$previous_sorted" "$current_sorted" > "$added_packages"
    comm -23 "$previous_sorted" "$current_sorted" > "$removed_packages"
    comm -12 "$previous_sorted" "$current_sorted" > "$unchanged_packages"
    
    # Count changes
    local added_count=$(wc -l < "$added_packages")
    local removed_count=$(wc -l < "$removed_packages")
    local unchanged_count=$(wc -l < "$unchanged_packages")
    local total_current=$(wc -l < "$current_sorted")
    local total_previous=$(wc -l < "$previous_sorted")
    
    # Generate detailed change report
    cat > "$changes_file" << EOF
# Package Changes Analysis

**Generated**: $(date)  
**Comparison**: $(basename $latest_snapshot) vs $(basename $previous_snapshot)  
**Analysis ID**: $TIMESTAMP

## Summary

- **Current Packages**: $total_current
- **Previous Packages**: $total_previous
- **Net Change**: $((total_current - total_previous))
- **Packages Added**: $added_count
- **Packages Removed**: $removed_count
- **Packages Unchanged**: $unchanged_count

EOF

    # Add detailed sections if there are changes
    if [ $added_count -gt 0 ]; then
        echo "## 📦 Added Packages ($added_count)" >> "$changes_file"
        echo '```' >> "$changes_file"
        cat "$added_packages" >> "$changes_file"
        echo '```' >> "$changes_file"
        echo "" >> "$changes_file"
        
        log "CHANGE" "🆕 $added_count packages added"
        
        # Try to categorize new packages
        echo "### Package Categories" >> "$changes_file"
        cat "$added_packages" | while read pkg; do
            if [[ $pkg == *python* ]]; then
                echo "- 🐍 **Python**: $pkg" >> "$changes_file"
            elif [[ $pkg == *node* || $pkg == *npm* || $pkg == *js* ]]; then
                echo "- 🟨 **JavaScript/Node**: $pkg" >> "$changes_file"
            elif [[ $pkg == *git* || $pkg == *gh* ]]; then
                echo "- 🌿 **Git/VCS**: $pkg" >> "$changes_file"
            elif [[ $pkg == *lib* ]]; then
                echo "- 📚 **Library**: $pkg" >> "$changes_file"
            else
                echo "- 📦 **Other**: $pkg" >> "$changes_file"
            fi
        done
        echo "" >> "$changes_file"
    fi
    
    if [ $removed_count -gt 0 ]; then
        echo "## 🗑️ Removed Packages ($removed_count)" >> "$changes_file"
        echo '```' >> "$changes_file"
        cat "$removed_packages" >> "$changes_file"
        echo '```' >> "$changes_file"
        echo "" >> "$changes_file"
        
        log "CHANGE" "🗑️ $removed_count packages removed"
    fi
    
# Replace all main/data/changes/temp/ with local temp directory
mkdir -p main/data/changes/temp
sed -i 's|main/data/changes/temp/|main/data/changes/temp/|g' main/scripts/Termux-env/detect-changes.sh

    # Log summary
    if [ $added_count -eq 0 ] && [ $removed_count -eq 0 ]; then
        log "INFO" "No package changes detected"
    else
        log "CHANGE" "Package changes: +$added_count, -$removed_count"
    fi
    
    # Return change counts for use by other functions
    echo "$added_count,$removed_count,$total_current" > "$CHANGES_DIR/packages/latest_change_summary.txt"
}

# Detect configuration changes using checksums
detect_config_changes() {
    log "INFO" "Analyzing configuration changes..."
    
    local changes_file="$CHANGES_DIR/configs/config-changes_${TIMESTAMP}.md"
    
    # Get list of config checksum files
    local checksums=($(ls -t "$DATA_DIR/config/config-checksums_"*.txt 2>/dev/null || echo ""))
    
    if [ ${#checksums[@]} -lt 2 ]; then
        log "WARN" "Need at least 2 config snapshots for comparison"
        echo "# Configuration Changes Analysis" > "$changes_file"
        echo "**Status**: Insufficient data for comparison" >> "$changes_file"
        return
    fi
    
    local latest_checksums="${checksums[0]}"
    local previous_checksums="${checksums[1]}"
    
    log "DEBUG" "Comparing config checksums: $(basename $latest_checksums) vs $(basename $previous_checksums)"
    
    cat > "$changes_file" << EOF
# Configuration Changes Analysis

**Generated**: $(date)  
**Comparison**: $(basename $latest_checksums) vs $(basename $previous_checksums)  
**Analysis ID**: $TIMESTAMP

## Configuration File Changes

EOF
    
    local changes_detected=false
    
    # Compare each configuration file
    while IFS=': ' read -r config_file current_checksum_info; do
        local current_checksum=$(echo "$current_checksum_info" | awk '{print $1}')
        
        # Look for this file in the previous checksums
        local previous_checksum=""
        if grep -q "^$config_file:" "$previous_checksums" 2>/dev/null; then
            previous_checksum=$(grep "^$config_file:" "$previous_checksums" | awk '{print $2}')
        fi
        
        if [ -z "$previous_checksum" ]; then
            echo "### 🆕 New Configuration: $config_file" >> "$changes_file"
            echo "- **Status**: Newly tracked" >> "$changes_file"
            echo "- **Checksum**: $current_checksum" >> "$changes_file"
            echo "" >> "$changes_file"
            log "CHANGE" "🆕 New config file: $config_file"
            changes_detected=true
        elif [ "$current_checksum" != "$previous_checksum" ]; then
            echo "### 🔄 Modified Configuration: $config_file" >> "$changes_file"
            echo "- **Status**: Modified" >> "$changes_file"
            echo "- **Previous Checksum**: $previous_checksum" >> "$changes_file"
            echo "- **Current Checksum**: $current_checksum" >> "$changes_file"
            echo "" >> "$changes_file"
            log "CHANGE" "🔄 Modified config: $config_file"
            changes_detected=true
        fi
        
    done < "$latest_checksums"
    
    # Check for deleted configurations
    while IFS=': ' read -r config_file previous_checksum_info; do
        if ! grep -q "^$config_file:" "$latest_checksums" 2>/dev/null; then
            echo "### 🗑️ Removed Configuration: $config_file" >> "$changes_file"
            echo "- **Status**: No longer tracked or deleted" >> "$changes_file"
            echo "- **Previous Checksum**: $(echo "$previous_checksum_info" | awk '{print $1}')" >> "$changes_file"
            echo "" >> "$changes_file"
            log "CHANGE" "🗑️ Removed config: $config_file"
            changes_detected=true
        fi
    done < "$previous_checksums"
    
    if [ "$changes_detected" = false ]; then
        echo "### ✅ No Configuration Changes" >> "$changes_file"
        echo "All tracked configuration files remain unchanged." >> "$changes_file"
        log "INFO" "No configuration changes detected"
    fi
}

# Analyze system changes
detect_system_changes() {
    log "INFO" "Analyzing system changes..."
    
    local changes_file="$CHANGES_DIR/system/system-changes_${TIMESTAMP}.md"
    
    # Get system snapshots
    local system_snapshots=($(ls -t "$DATA_DIR/system/system-info_"*.txt 2>/dev/null || echo ""))
    local hash_files=($(ls -t "$DATA_DIR/system/environment-hash_"*.txt 2>/dev/null || echo ""))
    
    if [ ${#hash_files[@]} -lt 2 ]; then
        log "WARN" "Need at least 2 system snapshots for comparison"
        echo "# System Changes Analysis" > "$changes_file"
        echo "**Status**: Insufficient data for comparison" >> "$changes_file"
        return
    fi
    
    local latest_hash_file="${hash_files[0]}"
    local previous_hash_file="${hash_files[1]}"
    
    cat > "$changes_file" << EOF
# System Changes Analysis

**Generated**: $(date)  
**Comparison**: $(basename $latest_hash_file) vs $(basename $previous_hash_file)  
**Analysis ID**: $TIMESTAMP

## Environment Hash Comparison

EOF
    
    # Compare environment hashes
    local current_system_hash=$(grep "System info hash:" "$latest_hash_file" 2>/dev/null | cut -d' ' -f4 || echo "unknown")
    local previous_system_hash=$(grep "System info hash:" "$previous_hash_file" 2>/dev/null | cut -d' ' -f4 || echo "unknown")
    
    local current_package_hash=$(grep "Package list hash:" "$latest_hash_file" 2>/dev/null | cut -d' ' -f4 || echo "unknown")
    local previous_package_hash=$(grep "Package list hash:" "$previous_hash_file" 2>/dev/null | cut -d' ' -f4 || echo "unknown")
    
    echo "### System Information Hash" >> "$changes_file"
    if [ "$current_system_hash" != "$previous_system_hash" ]; then
        echo "- **Status**: 🔄 **CHANGED**" >> "$changes_file"
        echo "- **Previous**: $previous_system_hash" >> "$changes_file"
        echo "- **Current**: $current_system_hash" >> "$changes_file"
        log "CHANGE" "🔄 System information changed"
    else
        echo "- **Status**: ✅ **UNCHANGED**" >> "$changes_file"
        echo "- **Hash**: $current_system_hash" >> "$changes_file"
        log "INFO" "System information unchanged"
    fi
    echo "" >> "$changes_file"
    
    echo "### Package Environment Hash" >> "$changes_file"
    if [ "$current_package_hash" != "$previous_package_hash" ]; then
        echo "- **Status**: 🔄 **CHANGED**" >> "$changes_file"
        echo "- **Previous**: $previous_package_hash" >> "$changes_file"
        echo "- **Current**: $current_package_hash" >> "$changes_file"
        log "CHANGE" "🔄 Package environment changed"
    else
        echo "- **Status**: ✅ **UNCHANGED**" >> "$changes_file"
        echo "- **Hash**: $current_package_hash" >> "$changes_file"
        log "INFO" "Package environment unchanged"
    fi
}

# Generate intelligent change summary and insights
generate_change_insights() {
    log "INFO" "Generating change insights and recommendations..."
    
    local insights_file="$CHANGES_DIR/analysis/change-insights_${TIMESTAMP}.md"
    local summary_file="$CHANGES_DIR/summaries/change-summary_${TIMESTAMP}.json"
    
    # Read package change data
    local package_changes=""
    if [ -f "$CHANGES_DIR/packages/latest_change_summary.txt" ]; then
        package_changes=$(cat "$CHANGES_DIR/packages/latest_change_summary.txt")
        IFS=',' read -r added_count removed_count total_packages <<< "$package_changes"
    else
        added_count=0
        removed_count=0
        total_packages=0
    fi
    
    # Calculate change significance
    local total_changes=$((added_count + removed_count))
    local change_percentage=0
    if [ $total_packages -gt 0 ]; then
        change_percentage=$((total_changes * 100 / total_packages))
    fi
    
    local significance="LOW"
    if [ $total_changes -ge 10 ]; then
        significance="HIGH"
    elif [ $total_changes -ge 5 ]; then
        significance="MEDIUM"
    fi
    
    # Generate JSON summary
    cat > "$summary_file" << EOF
{
    "timestamp": "$(date -Iseconds)",
    "analysis_id": "$TIMESTAMP",
    "package_changes": {
        "added": $added_count,
        "removed": $removed_count,
        "total_current": $total_packages,
        "change_percentage": $change_percentage
    },
    "significance": "$significance",
    "recommendations": []
}
EOF
    
    # Generate insights report
    cat > "$insights_file" << EOF
# Change Detection Insights & Recommendations

**Generated**: $(date)  
**Analysis ID**: $TIMESTAMP  
**Change Significance**: **$significance**

## 📊 Change Summary

- **Package Changes**: $total_changes total ($added_count added, $removed_count removed)
- **Current Packages**: $total_packages
- **Change Rate**: $change_percentage% of environment
- **Significance Level**: $significance

## 🔍 Insights

EOF
    
    # Generate specific insights based on changes
    if [ $total_changes -eq 0 ]; then
        cat >> "$insights_file" << EOF
### ✅ Stable Environment
- No package changes detected
- Environment appears stable
- Regular maintenance recommended

### 💡 Recommendations
- Continue monitoring for changes
- Consider running system updates
- Review configuration files periodically
EOF
        log "INSIGHT" "Environment is stable - no significant changes"
        
    elif [ $total_changes -le 5 ]; then
        cat >> "$insights_file" << EOF
### 🟡 Minor Changes
- Small number of package changes detected
- Changes appear routine
- Environment remains stable

### 💡 Recommendations
- Review new packages for necessity
- Update documentation if needed
- Monitor for related configuration changes
EOF
        log "INSIGHT" "Minor environment changes detected"
        
    else
        cat >> "$insights_file" << EOF
### 🔴 Significant Changes
- Major package environment changes detected
- $change_percentage% of environment modified
- Review recommended

### 💡 Recommendations
- **PRIORITY**: Review all package changes
- Update environment documentation
- Test critical functionality
- Consider creating backup snapshot
- Update installation scripts
EOF
        log "INSIGHT" "Significant environment changes - review recommended"
    fi
    
    # Add package-specific insights
    if [ $added_count -gt 0 ]; then
        echo "" >> "$insights_file"
        echo "### 📦 New Package Analysis" >> "$insights_file"
        echo "- $added_count new packages installed" >> "$insights_file"
        echo "- Review: \`main/data/changes/packages/package-changes_${TIMESTAMP}.md\`" >> "$insights_file"
        echo "- Action: Document new packages and their purpose" >> "$insights_file"
    fi
    
    if [ $removed_count -gt 0 ]; then
        echo "" >> "$insights_file"
        echo "### 🗑️ Package Removal Analysis" >> "$insights_file"
        echo "- $removed_count packages removed" >> "$insights_file"
        echo "- Review: Check for broken dependencies" >> "$insights_file"
        echo "- Action: Update scripts that may depend on removed packages" >> "$insights_file"
    fi
    
    cat >> "$insights_file" << EOF

## 📈 Trend Analysis
*Note: Trend analysis will be enhanced in future versions*

## 🎯 Next Steps
1. Review detailed change reports in \`main/data/changes/\`
2. Update documentation if significant changes detected
3. Test environment functionality
4. Consider running fresh data collection: \`./main/scripts/Termux-env/collect-env-data.sh\`

---
*Generated by Termux Environment Change Detection System*
EOF
    
    log "INSIGHT" "Change analysis complete - check $insights_file"
    
    # Output summary to console
    echo ""
    echo "🎯 CHANGE DETECTION SUMMARY"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📦 Package Changes: +$added_count, -$removed_count"
    echo "🔍 Significance: $significance ($change_percentage% change rate)"
    echo "📊 Total Packages: $total_packages"
    echo "📝 Full Analysis: $insights_file"
    echo ""
}

# Main execution function
main() {
    log "INFO" "🔍 Starting Termux Environment Change Detection"
    log "INFO" "Timestamp: $TIMESTAMP"
    
    setup_changes_tracking
    detect_package_changes
    detect_config_changes  
    detect_system_changes
    generate_change_insights
    
    log "INFO" "🎉 Change detection analysis completed!"
    log "INFO" "📊 Results available in: $CHANGES_DIR/"
    
    echo ""
    echo "📁 Generated Analysis Files:"
    find "$CHANGES_DIR" -name "*${TIMESTAMP}*" -type f | head -10 | while read file; do
        echo "  📄 $(basename "$file")"
    done
    
    echo ""
    echo "🔄 Next Steps:"
    echo "1. Review change analysis files"
    echo "2. Run: git add main/data/changes && git commit -m 'Change detection analysis: $TIMESTAMP'"
    echo "3. Push to trigger GitHub Actions processing"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi