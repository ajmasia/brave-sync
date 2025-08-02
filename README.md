# 🦁 Brave Sync (Local)

A simple, private and scriptable way to **backup and restore Brave browser data** (bookmarks, extensions, preferences, etc.) using your own local storage or a Nextcloud folder — no Brave Sync, no cloud dependencies.

---

## ✅ Features

- 🔐 100% local: no Brave account or sync chain needed
- 📑 Backup and restore:
  - Bookmarks
  - Extensions
  - Custom search engines
  - Preferences
  - History
- 💾 Integrates easily with Nextcloud or any synced folder
- 🔄 Session-aware: closes Brave before syncing, optionally reopens it
- 🖱️ .desktop launchers for GUI execution
- 🔧 Easily installable and updatable via `install.sh` or Git

---

## 📦 Installation

### 📁 Option 1: Git-based

```bash
curl -sL https://raw.githubusercontent.com/ajmasia/brave-sync/main/install.sh | bash
# or
wget -qO- https://raw.githubusercontent.com/YOUR-USERNAME/brave-sync/main/install.sh | bash
```

## TODO

- [x] Divide variables for install process and scriptable process
- [x] Add uninstall and update as cli commands
