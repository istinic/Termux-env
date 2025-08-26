#!/bin/bash
# generate-daily-homework.sh - Daily Termux Learning System

set -e

HOMEWORK_DIR="$HOME/main/homework"
TODAY=$(date +"%Y-%m-%d")
DATA_DIR="$HOME/main/data"

mkdir -p "$HOMEWORK_DIR"

# Generate today's homework file
cat > "$HOMEWORK_DIR/homework-${TODAY}.md" << EOF
# Daily Termux Homework - ${TODAY}

## Today's Focus: $(date +"%A")

### Quick Wins (5 minutes)
- [ ] Check system status: \`htop\` (press 'q' to quit)
- [ ] Update packages: \`pkg update\` 
- [ ] Check git repos: \`git status\` in your project directories

### Learning Task (10 minutes)
Pick ONE package you have installed but don't fully understand:

#### This Week's Package: \`git\`
- [ ] Try: \`git log --oneline\` in any repository
- [ ] Try: \`git diff\` to see changes
- [ ] Try: \`git branch\` to see all branches

### File to Read Today (5 minutes)
Read this specific file for practical insights:
\`\`\`
cat $(find "$DATA_DIR" -name "*collection-report*" | tail -1)
\`\`\`

### Practice Command (2 minutes)
Try this useful command combination:
\`\`\`bash
# See which packages take up most space
pkg list-installed | head -10
\`\`\`

### Homework Status
- [ ] Quick wins completed
- [ ] Learning task attempted  
- [ ] File reading done
- [ ] Practice command tried

## Tomorrow's Preview
Next session will focus on text processing with packages you have installed.

---
Generated: $(date)
EOF
