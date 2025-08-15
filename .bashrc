export PATH=$PATH:$HOME/main/scripts

# The bellow command clean up duplicates
export PATH=$(echo "$PATH" | tr ':' '\n' | awk '!seen[$0]++' | tr '\n' ':' | sed 's/:$//')
