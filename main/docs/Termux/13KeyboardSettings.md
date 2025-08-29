# Keyboard Settings

This guide explains how to customize and use keyboard shortcuts in Termux.


---

1. Levels of Keyboard Configuration

🔑 1.1 Termux Properties (~/.termux/termux.properties)

Defines the extra-keys row (the on-screen buttons above your Android keyboard).

Lets you choose which keys are visible: ESC, CTRL, TAB, F1–F10, PGUP, PGDN, etc.

Example:

extra-keys = [ \
  [ESC, TAB, CTRL, ALT, LEFT, RIGHT], \
  [F1, F2, F3, F4, F5, F6] \
]

After editing:

termux-reload-settings


📘 1.2 Readline Input (~/.inputrc)

Controls how keys behave inside Bash and other Readline-based apps (Python REPL, MySQL, etc.).

You can bind function keys, Ctrl-combos, Alt-combos to commands.

Example:

# Bind F1 to show command history
"\eOP": "history\n"

Keycodes (\eOP, \eOQ, …) map to F1, F2, etc.


📝 1.3 Program-specific configs

Editors like Nano, Vim, Neovim, Emacs, htop have their own shortcut settings.

These configs do not depend on .inputrc.

Examples:

~/.nanorc for Nano

~/.vimrc for Vim

~/.config/htop/htoprc for htop

---

2. Common Usage of Function Keys (Windows vs Linux vs Termux)

Key	Windows Usage	Bash / Linux Usage	Termux Potential

F1	Help	Man pages / Help	man / help
F2	Rename	Varies	Git status
F3	Search	Search in Nano	grep shortcut
F4	Close Window	Exit in some apps	exit shortcut
F5	Refresh	Rerun last cmd	!! binding
F6	Move cursor	Switch TTY	htop shortcut
F7	Spellcheck (WinWord)	Command history	history
F8	Boot menu (BIOS)	Search history	Git add
F9	Build (IDEs)	Shell expansion	Git commit
F10	Menu bar	Shifted functions	Git push

---

3. Example: Git-focused F-keys

In .termux/termux.properties:

extra-keys = [ \
  [F1, F2, F3, F4, F5], \
  [F6, F7, F8, F9, F10] \
]

In .inputrc:

# Git shortcuts
"\eOP": "git status\n"     # F1
"\eOQ": "git add .\n"      # F2
"\eOR": "git commit -m ''\C-b" # F3 (cursor moves back to inside quotes)
"\eOS": "git push\n"       # F4
"\e[15~": "git pull\n"     # F5

---

4. Other Common Bash Shortcuts

ls -l
cd ..
clear
nano
python
htop
exit

These can also be mapped to F-keys.

---

5. Switching Between Keyboard Layouts

You can create multiple Termux key layouts:

Example directory: ~/.termux/keys/

git.keys
bash.keys
minimal.keys

Then copy/symlink the one you need to ~/.termux/termux.properties:

cp ~/.termux/keys/git.keys ~/.termux/termux.properties
termux-reload-settings

---

6. Tips

You can use ALT+letter and CTRL+letter combos on the extra-keys row.

F-keys are very useful for repetitive Git workflows.

.inputrc allows deep customization, but only for Readline-aware apps (not Vim/Nano).