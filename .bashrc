export PATH=$PATH:$HOME/main/scripts
export PATH=$PATH:$HOME/global_packages

# The bellow command clean up duplicates
export PATH=$(echo "$PATH" | tr ':' '\n' | awk '!seen[$0]++' | tr '\n' ':' | sed 's/:$//')
