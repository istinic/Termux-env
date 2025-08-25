#!/data/data/com.termux/files/usr/bin/bash
# Stop Termux SSH server
pkill sshd && echo "🛑 SSH server stopped" || echo "⚠️ SSH server not running"