Here are the basic `tmux` commands you need as a first-time user:

### **Starting & Exiting**
- **Start tmux**: `tmux`
- **Start with a session name**: `tmux new -s mysession`
- **Detach from a session**: `Ctrl+b d`
- **Reattach to a session**: `tmux attach -t mysession`
- **List all sessions**: `tmux list-sessions`
- **Kill a session**: `tmux kill-session -t mysession`
- **Kill all sessions**: `tmux kill-server`
- **Exit tmux**: `Ctrl+d` (inside a session) or `exit`

### **Windows (Like Tabs)**
- **Create a new window**: `Ctrl+b c`
- **Switch to the next window**: `Ctrl+b n`
- **Switch to the previous window**: `Ctrl+b p`
- **List all windows**: `Ctrl+b w`
- **Rename a window**: `Ctrl+b ,`
- **Close a window**: `Ctrl+b &`

### **Panes (Like Splits)**
- **Split horizontally**: `Ctrl+b %`
- **Split vertically**: `Ctrl+b "`
- **Switch between panes**: `Ctrl+b o` (or use arrow keys `Ctrl+b ← → ↑ ↓`)
- **Resize panes**: `Ctrl+b` then `Alt+Arrow keys`
- **Close a pane**: `Ctrl+b x`

### **Miscellaneous**
- **Scroll in history mode**: `Ctrl+b [` then use arrow keys, exit with `q`
- **Synchronize input across panes**: `Ctrl+b :setw synchronize-panes on` (off: `off`)
- **Reload config file**: `Ctrl+b :source-file ~/.tmux.conf`
- **Show all key bindings**: `Ctrl+b ?`

That's enough to get you started! 🚀 Let me know if you need anything else.
