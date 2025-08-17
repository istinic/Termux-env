#!/bin/bash
# generate-analytics.sh - Smart Reporting & Analytics Engine
# Part of Termux Environment Hybrid Automation - Milestone 2.2
# Generates comprehensive analytics, trends, and intelligent reports

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$HOME"
DATA_DIR="$BASE_DIR/main/data"
ANALYTICS_DIR="$DATA_DIR/analytics"
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
    
    case $level in
        "INFO") echo -e "${GREEN}[ANALYTICS]${NC} $message" ;;
        "WARN") echo -e "${YELLOW}[WARN]${NC} $message" ;;
        "ERROR") echo -e "${RED}[ERROR]${NC} $message" ;;
        "DEBUG") echo -e "${BLUE}[DEBUG]${NC} $message" ;;
        "TREND") echo -e "${PURPLE}[TREND]${NC} $message" ;;
        "INSIGHT") echo -e "${CYAN}[INSIGHT]${NC} $message" ;;
    esac
}

# Initialize analytics directory structure
setup_analytics() {
    log "INFO" "Setting up analytics framework..."
    
    mkdir -p "$ANALYTICS_DIR"/{trends,reports,dashboards,metrics,summaries}
    
    # Create analytics metadata
    if [ ! -f "$ANALYTICS_DIR/.analytics_config" ]; then
        cat > "$ANALYTICS_DIR/.analytics_config" << EOF
# Analytics Configuration
ANALYTICS_VERSION="2.2.0"
ANALYSIS_START_DATE="$(date -Iseconds)"
TREND_ANALYSIS_DAYS=30
REPORT_RETENTION_DAYS=90
DASHBOARD_UPDATE_FREQUENCY="daily"
METRICS_COLLECTION_ENABLED=true
EOF
        log "INFO" "Created analytics configuration"
    fi
}

# Analyze package trends over time
analyze_package_trends() {
    log "INFO" "Analyzing package installation trends..."
    
    local trends_file="$ANALYTICS_DIR/trends/package-trends_${TIMESTAMP}.md"
    local metrics_file="$ANALYTICS_DIR/metrics/package-metrics_${TIMESTAMP}.json"
    
    # Get all package snapshots sorted by date
    local package_files=($(find "$DATA_DIR/packages" -name "installed-packages_*.txt" | sort))
    
    if [ ${#package_files[@]} -lt 2 ]; then
        log "WARN" "Need at least 2 package snapshots for trend analysis"
        echo "# Package Trends Analysis" > "$trends_file"
        echo "**Status**: Insufficient data for trend analysis" >> "$trends_file"
        return
    fi
    
    log "DEBUG" "Analyzing ${#package_files[@]} package snapshots"
    
    # Initialize trends report
    cat > "$trends_file" << EOF
# Package Installation Trends Analysis

**Generated**: $(date)  
**Analysis Period**: $(basename "${package_files[0]}" .txt | sed 's/installed-packages_//') to $(basename "${package_files[-1]}" .txt | sed 's/installed-packages_//')  
**Snapshots Analyzed**: ${#package_files[@]}  
**Analysis ID**: $TIMESTAMP

## 📊 Package Count Timeline

| Date | Total Packages | Change | Trend |
|------|---------------|---------|-------|
EOF
    
    # Analyze each snapshot
    local previous_count=0
    local trend_data=()
    local total_growth=0
    
    for i in "${!package_files[@]}"; do
        local file="${package_files[$i]}"
        local date=$(basename "$file" .txt | sed 's/installed-packages_//')
        local count=$(wc -l < "$file")
        local change=0
        local trend_indicator=""
        
        if [ $i -gt 0 ]; then
            change=$((count - previous_count))
            if [ $change -gt 0 ]; then
                trend_indicator="📈 +$change"
                total_growth=$((total_growth + change))
            elif [ $change -lt 0 ]; then
                trend_indicator="📉 $change"
                total_growth=$((total_growth + change))
            else
                trend_indicator="➡️ 0"
            fi
        else
            trend_indicator="🎯 baseline"
        fi
        
        echo "| $date | $count | $change | $trend_indicator |" >> "$trends_file"
        
        # Store data for analysis
        trend_data+=("$date:$count:$change")
        previous_count=$count
    done
    
    # Calculate trend statistics
    local first_count=$(wc -l < "${package_files[0]}")
    local last_count=$(wc -l < "${package_files[-1]}")
    local growth_rate=0
    if [ $first_count -gt 0 ]; then
        growth_rate=$(((last_count - first_count) * 100 / first_count))
    fi
    
    cat >> "$trends_file" << EOF

## 📈 Trend Analysis

### Overall Statistics
- **Initial Package Count**: $first_count
- **Current Package Count**: $last_count
- **Net Growth**: $total_growth packages
- **Growth Rate**: $growth_rate%
- **Average per Snapshot**: $((total_growth / ${#package_files[@]})) packages

### Growth Pattern
EOF
    
    if [ $growth_rate -gt 10 ]; then
        cat >> "$trends_file" << EOF
- **Pattern**: 🚀 **Rapid Growth** (>10% increase)
- **Analysis**: Environment is actively expanding
- **Recommendation**: Monitor for bloat, ensure all packages are necessary
EOF
        log "TREND" "🚀 Rapid package growth detected: $growth_rate%"
        
    elif [ $growth_rate -gt 5 ]; then
        cat >> "$trends_file" << EOF
- **Pattern**: 📈 **Steady Growth** (5-10% increase)
- **Analysis**: Healthy environment expansion
- **Recommendation**: Continue monitoring, document new packages
EOF
        log "TREND" "📈 Steady package growth: $growth_rate%"
        
    elif [ $growth_rate -gt -5 ]; then
        cat >> "$trends_file" << EOF
- **Pattern**: ➡️ **Stable** (-5% to +5% change)
- **Analysis**: Environment is mature and stable
- **Recommendation**: Maintain current state, periodic reviews
EOF
        log "TREND" "➡️ Package environment is stable: $growth_rate%"
        
    else
        cat >> "$trends_file" << EOF
- **Pattern**: 📉 **Declining** (<-5% decrease)
- **Analysis**: Packages being removed, cleanup in progress
- **Recommendation**: Verify functionality after removals
EOF
        log "TREND" "📉 Package environment declining: $growth_rate%"
    fi
    
    # Generate JSON metrics
    cat > "$metrics_file" << EOF
{
    "timestamp": "$(date -Iseconds)",
    "analysis_id": "$TIMESTAMP",
    "package_trends": {
        "snapshots_analyzed": ${#package_files[@]},
        "first_count": $first_count,
        "current_count": $last_count,
        "net_growth": $total_growth,
        "growth_rate_percent": $growth_rate,
        "analysis_period_start": "$(basename "${package_files[0]}" .txt | sed 's/installed-packages_//')",
        "analysis_period_end": "$(basename "${package_files[-1]}" .txt | sed 's/installed-packages_//')"
    }
}
EOF
    
    log "INFO" "Package trends analysis completed: $growth_rate% growth rate"
}

# Analyze storage and system metrics
analyze_system_metrics() {
    log "INFO" "Analyzing system performance metrics..."
    
    local metrics_file="$ANALYTICS_DIR/metrics/system-metrics_${TIMESTAMP}.json"
    local report_file="$ANALYTICS_DIR/reports/system-analysis_${TIMESTAMP}.md"
    
    # Get all system snapshots
    local system_files=($(find "$DATA_DIR/system" -name "system-info_*.txt" | sort))
    local snapshot_files=($(find "$DATA_DIR/snapshots" -name "environment-snapshot_*.json" | sort))
    
    if [ ${#snapshot_files[@]} -lt 2 ]; then
        log "WARN" "Need at least 2 environment snapshots for system analysis"
        return
    fi
    
    log "DEBUG" "Analyzing ${#snapshot_files[@]} system snapshots"
    
    # Extract storage data from snapshots
    local storage_data=()
    for snapshot in "${snapshot_files[@]}"; do
        local date=$(basename "$snapshot" .json | sed 's/environment-snapshot_//')
        local storage=$(jq -r '.summary.storage_used // "unknown"' "$snapshot" 2>/dev/null || echo "unknown")
        local packages=$(jq -r '.summary.total_packages // 0' "$snapshot" 2>/dev/null || echo 0)
        
        if [ "$storage" != "unknown" ]; then
            storage_data+=("$date:$storage:$packages")
        fi
    done
    
    # Generate system analysis report
    cat > "$report_file" << EOF
# System Performance & Resource Analysis

**Generated**: $(date)  
**Analysis ID**: $TIMESTAMP  
**Snapshots Analyzed**: ${#storage_data[@]}

## 💾 Storage Utilization Timeline

| Date | Storage Used | Total Packages | Storage/Package |
|------|--------------|----------------|-----------------|
EOF
    
    for entry in "${storage_data[@]}"; do
        IFS=':' read -r date storage packages <<< "$entry"
        
        # Convert storage to MB for calculation (rough approximation)
        local storage_mb=""
        if [[ $storage =~ ^[0-9]+M$ ]]; then
            storage_mb=${storage%M}
        elif [[ $storage =~ ^[0-9]+G$ ]]; then
            local storage_gb=${storage%G}
            storage_mb=$((storage_gb * 1024))
        else
            storage_mb="unknown"
        fi
        
        local storage_per_package="N/A"
        if [ "$storage_mb" != "unknown" ] && [ "$packages" -gt 0 ]; then
            storage_per_package=$(echo "scale=1; $storage_mb / $packages" | bc 2>/dev/null || echo "N/A")
            if [ "$storage_per_package" != "N/A" ]; then
                storage_per_package="${storage_per_package}MB"
            fi
        fi
        
        echo "| $date | $storage | $packages | $storage_per_package |" >> "$report_file"
    done
    
    cat >> "$report_file" << EOF

## 📊 System Health Indicators

### Resource Efficiency
EOF
    
    # Get latest snapshot data
    local latest_snapshot="${snapshot_files[-1]}"
    local current_storage=$(jq -r '.summary.storage_used // "unknown"' "$latest_snapshot" 2>/dev/null)
    local current_packages=$(jq -r '.summary.total_packages // 0' "$latest_snapshot" 2>/dev/null)
    local git_changes=$(jq -r '.summary.git_changes // 0' "$latest_snapshot" 2>/dev/null)
    
    cat >> "$report_file" << EOF
- **Current Storage**: $current_storage
- **Package Count**: $current_packages packages
- **Uncommitted Changes**: $git_changes files
- **Collection Success**: $(jq -r '.summary.collection_success // false' "$latest_snapshot" 2>/dev/null)

### System Status
EOF
    
    if [ "$current_storage" != "unknown" ]; then
        local storage_num=""
        if [[ $current_storage =~ ^[0-9]+M$ ]]; then
            storage_num=${current_storage%M}
            if [ "$storage_num" -lt 100 ]; then
                echo "- **Storage Status**: ✅ **Optimal** (<100MB)" >> "$report_file"
            elif [ "$storage_num" -lt 500 ]; then
                echo "- **Storage Status**: 🟡 **Moderate** (100-500MB)" >> "$report_file"
            else
                echo "- **Storage Status**: 🔴 **High** (>500MB)" >> "$report_file"
            fi
        fi
    fi
    
    if [ "$git_changes" -eq 0 ]; then
        echo "- **Git Status**: ✅ **Clean** (no uncommitted changes)" >> "$report_file"
    elif [ "$git_changes" -lt 5 ]; then
        echo "- **Git Status**: 🟡 **Minor Changes** ($git_changes files)" >> "$report_file"
    else
        echo "- **Git Status**: 🔴 **Many Changes** ($git_changes files)" >> "$report_file"
    fi
    
    # Generate JSON metrics
    cat > "$metrics_file" << EOF
{
    "timestamp": "$(date -Iseconds)",
    "analysis_id": "$TIMESTAMP",
    "system_metrics": {
        "current_storage": "$current_storage",
        "current_packages": $current_packages,
        "git_changes": $git_changes,
        "snapshots_analyzed": ${#storage_data[@]},
        "collection_success": $(jq -r '.summary.collection_success // false' "$latest_snapshot" 2>/dev/null)
    }
}
EOF
    
    log "INFO" "System metrics analysis completed"
}

# Generate comprehensive dashboard
generate_analytics_dashboard() {
    log "INFO" "Generating comprehensive analytics dashboard..."
    
    local dashboard_file="$ANALYTICS_DIR/dashboards/environment-dashboard_${TIMESTAMP}.md"
    
    # Get latest metrics
    local latest_package_metrics=$(find "$ANALYTICS_DIR/metrics" -name "package-metrics_*.json" | sort | tail -1)
    local latest_system_metrics=$(find "$ANALYTICS_DIR/metrics" -name "system-metrics_*.json" | sort | tail -1)
    local latest_changes=$(find "$DATA_DIR/changes/summaries" -name "change-summary_*.json" | sort | tail -1 2>/dev/null || echo "")
    
    cat > "$dashboard_file" << EOF
# 📊 Termux Environment Analytics Dashboard

**Generated**: $(date)  
**Dashboard ID**: $TIMESTAMP  
**Analytics Version**: 2.2.0

## 🎯 Executive Summary

### Environment Overview
EOF
    
    if [ -f "$latest_package_metrics" ]; then
        local growth_rate=$(jq -r '.package_trends.growth_rate_percent // 0' "$latest_package_metrics" 2>/dev/null)
        local current_packages=$(jq -r '.package_trends.current_count // 0' "$latest_package_metrics" 2>/dev/null)
        
        cat >> "$dashboard_file" << EOF
- **Total Packages**: $current_packages
- **Growth Rate**: $growth_rate% over analysis period
EOF
    fi
    
    if [ -f "$latest_system_metrics" ]; then
        local storage=$(jq -r '.system_metrics.current_storage // "unknown"' "$latest_system_metrics" 2>/dev/null)
        local git_changes=$(jq -r '.system_metrics.git_changes // 0' "$latest_system_metrics" 2>/dev/null)
        
        cat >> "$dashboard_file" << EOF
- **Storage Usage**: $storage
- **Pending Changes**: $git_changes files
EOF
    fi
    
    cat >> "$dashboard_file" << EOF

### Recent Activity
EOF
    
    if [ -n "$latest_changes" ] && [ -f "$latest_changes" ]; then
        local added_packages=$(jq -r '.package_changes.added // 0' "$latest_changes" 2>/dev/null)
        local removed_packages=$(jq -r '.package_changes.removed // 0' "$latest_changes" 2>/dev/null)
        local significance=$(jq -r '.significance // "UNKNOWN"' "$latest_changes" 2>/dev/null)
        
        cat >> "$dashboard_file" << EOF
- **Recent Package Changes**: +$added_packages, -$removed_packages
- **Change Significance**: $significance
EOF
    else
        echo "- **Recent Changes**: No recent change analysis available" >> "$dashboard_file"
    fi
    
    cat >> "$dashboard_file" << EOF

## 📈 Key Metrics

### Package Management
- **Package Stability**: $(if [ -f "$latest_package_metrics" ]; then jq -r '.package_trends.growth_rate_percent // 0' "$latest_package_metrics" | awk '{if($1>10) print "🚀 Rapid Growth"; else if($1>5) print "📈 Steady Growth"; else if($1>-5) print "➡️ Stable"; else print "📉 Declining"}'; else echo "Unknown"; fi)
- **Management Status**: $(if [ -f "$latest_system_metrics" ]; then jq -r '.system_metrics.git_changes // 0' "$latest_system_metrics" | awk '{if($1==0) print "✅ Clean"; else if($1<5) print "🟡 Minor Changes"; else print "🔴 Many Changes"}'; else echo "Unknown"; fi)

### System Health
- **Resource Usage**: $(if [ -f "$latest_system_metrics" ]; then jq -r '.system_metrics.current_storage // "unknown"' "$latest_system_metrics" | sed 's/[0-9]*M/🟢 Optimal/; s/[0-9][0-9][0-9]M/🟡 Moderate/; s/[0-9][0-9][0-9][0-9]M/🔴 High/'; else echo "Unknown"; fi)
- **Data Collection**: $(if [ -f "$latest_system_metrics" ]; then jq -r '.system_metrics.collection_success // false' "$latest_system_metrics" | sed 's/true/✅ Operational/; s/false/❌ Issues/'; else echo "Unknown"; fi)

## 📊 Available Reports

### Recent Analysis Files
EOF
    
    # List recent analytics files
    echo "#### Package Trends" >> "$dashboard_file"
    find "$ANALYTICS_DIR/trends" -name "package-trends_*.md" | sort -r | head -3 | while read file; do
        echo "- [$(basename "$file")]($(echo "$file" | sed "s|$BASE_DIR/||"))" >> "$dashboard_file"
    done
    
    echo "" >> "$dashboard_file"
    echo "#### System Analysis" >> "$dashboard_file"
    find "$ANALYTICS_DIR/reports" -name "system-analysis_*.md" | sort -r | head -3 | while read file; do
        echo "- [$(basename "$file")]($(echo "$file" | sed "s|$BASE_DIR/||"))" >> "$dashboard_file"
    done
    
    echo "" >> "$dashboard_file"
    echo "#### Change Detection" >> "$dashboard_file"
    find "$DATA_DIR/changes/analysis" -name "change-insights_*.md" | sort -r | head -3 | while read file; do
        echo "- [$(basename "$file")]($(echo "$file" | sed "s|$BASE_DIR/||"))" >> "$dashboard_file"
    done 2>/dev/null || echo "- No change analysis available" >> "$dashboard_file"
    
    cat >> "$dashboard_file" << EOF

## 🎯 Recommendations

### Immediate Actions
EOF
    
    # Generate smart recommendations based on metrics
    if [ -f "$latest_system_metrics" ]; then
        local git_changes=$(jq -r '.system_metrics.git_changes // 0' "$latest_system_metrics" 2>/dev/null)
        if [ "$git_changes" -gt 5 ]; then
            echo "- 🔴 **HIGH PRIORITY**: Commit $git_changes uncommitted changes" >> "$dashboard_file"
        fi
    fi
    
    if [ -f "$latest_package_metrics" ]; then
        local growth_rate=$(jq -r '.package_trends.growth_rate_percent // 0' "$latest_package_metrics" 2>/dev/null)
        if [ "$growth_rate" -gt 20 ]; then
            echo "- 🟡 **REVIEW**: High package growth ($growth_rate%) - audit for unnecessary packages" >> "$dashboard_file"
        fi
    fi
    
    cat >> "$dashboard_file" << EOF

### Maintenance Tasks
- Run fresh data collection: \`./main/scripts/Termux-env/collect-env-data.sh\`
- Update change detection: \`./main/scripts/Termux-env/detect-changes.sh\`
- Review analytics: \`cat $(echo "$dashboard_file" | sed "s|$BASE_DIR/||")\`

---
*Generated by Termux Environment Analytics Engine v2.2.0*
EOF
    
    log "INFO" "Analytics dashboard generated: $dashboard_file"
}

# Generate executive summary
generate_summary() {
    log "INFO" "Generating executive analytics summary..."
    
    local summary_file="$ANALYTICS_DIR/summaries/analytics-summary_${TIMESTAMP}.json"
    local latest_package_metrics=$(find "$ANALYTICS_DIR/metrics" -name "package-metrics_*.json" | sort | tail -1)
    local latest_system_metrics=$(find "$ANALYTICS_DIR/metrics" -name "system-metrics_*.json" | sort | tail -1)
    
    # Create comprehensive JSON summary for automation
    cat > "$summary_file" << EOF
{
    "timestamp": "$(date -Iseconds)",
    "analysis_id": "$TIMESTAMP",
    "analytics_version": "2.2.0",
    "summary": {
        "package_analytics": $(if [ -f "$latest_package_metrics" ]; then cat "$latest_package_metrics" | jq '.package_trends'; else echo 'null'; fi),
        "system_analytics": $(if [ -f "$latest_system_metrics" ]; then cat "$latest_system_metrics" | jq '.system_metrics'; else echo 'null'; fi),
        "dashboard_available": true,
        "recommendations_count": 3,
        "health_status": "operational"
    },
    "files_generated": {
        "dashboard": "dashboards/environment-dashboard_${TIMESTAMP}.md",
        "package_trends": "trends/package-trends_${TIMESTAMP}.md",
        "system_analysis": "reports/system-analysis_${TIMESTAMP}.md"
    }
}
EOF
    
    log "INSIGHT" "Analytics summary completed - comprehensive environment analysis ready"
}

# Main execution function
main() {
    log "INFO" "🚀 Starting Termux Environment Analytics Generation"
    log "INFO" "Timestamp: $TIMESTAMP"
    
    setup_analytics
    analyze_package_trends
    analyze_system_metrics
    generate_analytics_dashboard
    generate_summary
    
    log "INFO" "🎉 Analytics generation completed!"
    log "INFO" "📊 Analytics available in: $ANALYTICS_DIR/"
    
    echo ""
    echo "📈 ANALYTICS SUMMARY"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Display key insights
    local dashboard_file=$(find "$ANALYTICS_DIR/dashboards" -name "environment-dashboard_*.md" | sort | tail -1)
    if [ -f "$dashboard_file" ]; then
        echo "📊 Dashboard: $(basename "$dashboard_file")"
        
        # Extract key metrics for display
        local packages=$(grep "Total Packages" "$dashboard_file" | head -1 | awk -F': ' '{print $2}' | sed 's/\*\*//g' | xargs || echo "Unknown")
        local storage=$(grep "Storage Usage" "$dashboard_file" | head -1 | awk -F': ' '{print $2}' | sed 's/\*\*//g' | xargs || echo "Unknown")
        
        echo "📦 Packages: $packages"
        echo "💾 Storage: $storage"
        echo "📄 Dashboard: $(echo "$dashboard_file" | sed "s|$BASE_DIR/||")"
    fi
    
    echo ""
    echo "📁 Generated Analytics Files:"
    find "$ANALYTICS_DIR" -name "*${TIMESTAMP}*" -type f | head -5 | while read file; do
        echo "  📄 $(basename "$file")"
    done
    
    echo ""
    echo "🔄 Next Steps:"
    echo "1. Review analytics dashboard and reports"
    echo "2. Run: git add main/data/analytics && git commit -m 'Analytics generation: $TIMESTAMP'"
    echo "3. Push to trigger GitHub Actions processing"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi