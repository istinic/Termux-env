# === FILE: ~/.myprompt/timing.sh ===
# Command execution time tracker
preexec() {
    _cmd_start_time=$SECONDS
}

precmd() {
    if [[ $_cmd_start_time ]]; then
        local elapsed=$(($SECONDS - $_cmd_start_time))
        if (( elapsed > 3 )); then
            _cmd_duration=" %F{yellow}⏱ ${elapsed}s%f"
        else
            _cmd_duration=""
        fi
        unset _cmd_start_time
    fi
}

