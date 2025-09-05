# === FILE: ~/.myprompt/exit_code.sh ===
get_exit_code() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        echo " %F{red}✗ $exit_code%f"
    fi
}
