# Fixed battery function - replace in ~/.myprompt/battery.sh

get_battery_status() {
    # Check if termux-api is available and has permissions
    if command -v termux-battery-status >/dev/null 2>&1; then
        local battery_info=$(termux-battery-status 2>/dev/null)
        if [[ $? -eq 0 && -n "$battery_info" ]]; then
            local battery=$(echo "$battery_info" | grep percentage | cut -d: -f2 | tr -d ' ,"')
            if [[ -n "$battery" ]]; then
                local bat_color="%F{green}"
                (( battery < 30 )) && bat_color="%F{red}"
                (( battery < 60 )) && bat_color="%F{yellow}"
                echo " ${bat_color}🔋 ${battery}%%%f"
            fi
        fi
    fi
}

# Alternative battery methods for Android
get_battery_simple() {
    # Method 1: Try different Android paths
    local battery=""
    local paths=(
        "/sys/class/power_supply/battery/capacity"
        "/sys/class/power_supply/BAT0/capacity" 
        "/sys/class/power_supply/BAT1/capacity"
        "/proc/driver/rtc"
    )
    
    for path in "${paths[@]}"; do
        if [[ -r "$path" ]] && battery=$(cat "$path" 2>/dev/null) && [[ "$battery" =~ ^[0-9]+$ ]]; then
            break
        fi
        battery=""
    done
    
    # Method 2: If termux-api fails, try dumpsys (might work)
    if [[ -z "$battery" ]] && command -v dumpsys >/dev/null 2>&1; then
        battery=$(dumpsys battery 2>/dev/null | grep level | cut -d: -f2 | tr -d ' ')
    fi
    
    # Display battery if found
    if [[ -n "$battery" ]] && [[ "$battery" =~ ^[0-9]+$ ]]; then
        local bat_color="%F{green}"
        (( battery < 30 )) && bat_color="%F{red}"
        (( battery < 60 )) && bat_color="%F{yellow}"
        echo " ${bat_color}🔋 ${battery}%%%f"
    fi
}