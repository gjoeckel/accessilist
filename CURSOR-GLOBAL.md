# Cursor IDE Global Configuration Files

This document outlines the locations and details of global configuration files for Cursor IDE on Windows 11 and macOS.

---

## Windows 11 Configuration

### User: A00288946

#### Primary Configuration Locations

**1. Main Settings File**
- **Path**: `C:\Users\A00288946\AppData\Roaming\Cursor\User\settings.json`
- **Description**: Primary global settings file containing all IDE preferences
- **Contains**:
  - YOLO mode settings (AI autonomy)
  - Terminal configuration
  - Editor preferences
  - AI/MCP settings
  - File handling preferences

**2. Keybindings File**
- **Path**: `C:\Users\A00288946\AppData\Roaming\Cursor\User\keybindings.json`
- **Description**: Custom keyboard shortcuts and key mappings

**3. Snippets Directory**
- **Path**: `C:\Users\A00288946\AppData\Roaming\Cursor\User\snippets\`
- **Description**: Custom code snippets for various languages

**4. Global Storage**
- **Path**: `C:\Users\A00288946\AppData\Roaming\Cursor\User\globalStorage\`
- **Description**: Extension data and global state storage

**5. Workspace Storage**
- **Path**: `C:\Users\A00288946\AppData\Roaming\Cursor\User\workspaceStorage\`
- **Description**: Workspace-specific settings and state

**6. History**
- **Path**: `C:\Users\A00288946\AppData\Roaming\Cursor\User\History\`
- **Description**: File history and recent files tracking

#### Additional Configuration Locations

**7. Local Application Data**
- **Path**: `C:\Users\A00288946\AppData\Local\Cursor\`
- **Contains**:
  - Cache files
  - GPU cache
  - Code cache
  - Crash reports

**8. Roaming Configuration Root**
- **Path**: `C:\Users\A00288946\AppData\Roaming\Cursor\`
- **Contains**:
  - `Preferences` - UI preferences
  - `Local State` - Application state
  - `Network\` - Network-related settings
  - `logs\` - Application logs
  - `Backups\` - Settings backups
  - `CachedData\` - Cached IDE data

**9. CLI Configuration** (if used)
- **Path**: `C:\Users\A00288946\.cursor\cli-config.json`
- **Description**: Cursor Agent CLI configuration

#### Environment Variables

- `%USERPROFILE%` = `C:\Users\A00288946`
- `%APPDATA%` = `C:\Users\A00288946\AppData\Roaming`
- `%LOCALAPPDATA%` = `C:\Users\A00288946\AppData\Local`

---

## macOS Configuration

### Standard macOS Installation Locations

#### Primary Configuration Locations

**1. Main Settings File**
- **Path**: `~/Library/Application Support/Cursor/User/settings.json`
- **Description**: Primary global settings file (equivalent to Windows settings.json)

**2. Keybindings File**
- **Path**: `~/Library/Application Support/Cursor/User/keybindings.json`
- **Description**: Custom keyboard shortcuts and key mappings

**3. Snippets Directory**
- **Path**: `~/Library/Application Support/Cursor/User/snippets/`
- **Description**: Custom code snippets for various languages

**4. Global Storage**
- **Path**: `~/Library/Application Support/Cursor/User/globalStorage/`
- **Description**: Extension data and global state storage

**5. Workspace Storage**
- **Path**: `~/Library/Application Support/Cursor/User/workspaceStorage/`
- **Description**: Workspace-specific settings and state

**6. History**
- **Path**: `~/Library/Application Support/Cursor/User/History/`
- **Description**: File history and recent files tracking

#### Additional Configuration Locations

**7. Application Support Root**
- **Path**: `~/Library/Application Support/Cursor/`
- **Contains**:
  - `Preferences` - UI preferences
  - `Local Storage/` - Local state data
  - `Network/` - Network-related settings
  - `logs/` - Application logs
  - `Backups/` - Settings backups
  - `CachedData/` - Cached IDE data

**8. Cache Files**
- **Path**: `~/Library/Caches/Cursor/`
- **Contains**:
  - Cache files
  - GPU cache
  - Code cache

**9. Logs**
- **Path**: `~/Library/Logs/Cursor/`
- **Description**: Application logs and crash reports

**10. CLI Configuration** (if used)
- **Path**: `~/.cursor/cli-config.json`
- **Description**: Cursor Agent CLI configuration

#### Environment Variables

- `~` = `/Users/[username]`
- Home directory: `/Users/[username]`

#### Accessing Library Folder on macOS

The `~/Library` folder is hidden by default in macOS Finder. To access it:

1. **Via Finder**:
   - Open Finder
   - Click "Go" in menu bar
   - Hold down the `Option` key
   - Click "Library" (appears when Option is held)

2. **Via Terminal**:
   ```bash
   cd ~/Library/Application\ Support/Cursor/
   ```

3. **Make Library Permanently Visible**:
   ```bash
   chflags nohidden ~/Library/
   ```

---

## Creating and Managing Global Configuration Files

### Windows 11

#### Creating settings.json

1. Navigate to `%APPDATA%\Cursor\User\`
2. Create or edit `settings.json` using any text editor
3. Ensure valid JSON format

**Example settings.json structure**:
```json
{
    "cursor.ai.yoloMode": true,
    "terminal.integrated.defaultProfile.windows": "Git Bash",
    "editor.fontSize": 14,
    "files.autoSave": "afterDelay"
}
```

#### Creating keybindings.json

1. Navigate to `%APPDATA%\Cursor\User\`
2. Create or edit `keybindings.json`
3. Define custom keybindings

**Example keybindings.json**:
```json
[
    {
        "key": "ctrl+shift+t",
        "command": "workbench.action.terminal.new"
    }
]
```

### macOS

#### Creating settings.json

1. Open Terminal
2. Navigate to configuration directory:
   ```bash
   cd ~/Library/Application\ Support/Cursor/User/
   ```
3. Create or edit settings.json:
   ```bash
   nano settings.json
   ```
4. Ensure valid JSON format

**Example settings.json structure**:
```json
{
    "cursor.ai.yoloMode": true,
    "terminal.integrated.defaultProfile.osx": "zsh",
    "editor.fontSize": 14,
    "files.autoSave": "afterDelay"
}
```

#### Creating keybindings.json

1. Navigate to configuration directory:
   ```bash
   cd ~/Library/Application\ Support/Cursor/User/
   ```
2. Create or edit keybindings.json:
   ```bash
   nano keybindings.json
   ```

**Example keybindings.json**:
```json
[
    {
        "key": "cmd+shift+t",
        "command": "workbench.action.terminal.new"
    }
]
```

---

## Platform-Specific Differences

### Key Differences Between Windows 11 and macOS

| Feature | Windows 11 | macOS |
|---------|-----------|--------|
| **Settings Location** | `%APPDATA%\Roaming\Cursor\User\` | `~/Library/Application Support/Cursor/User/` |
| **Cache Location** | `%LOCALAPPDATA%\Cursor\` | `~/Library/Caches/Cursor/` |
| **Logs Location** | `%APPDATA%\Roaming\Cursor\logs\` | `~/Library/Logs/Cursor/` |
| **CLI Config** | `C:\Users\[user]\.cursor\` | `~/.cursor/` |
| **Default Terminal** | PowerShell or Git Bash | zsh or bash |
| **Path Separator** | `\` (backslash) | `/` (forward slash) |
| **Home Directory** | `C:\Users\[username]` | `/Users/[username]` |
| **Hidden Files** | Controlled by File Explorer settings | Prefix with `.` or in Library |

### Terminal Configuration Differences

**Windows 11**:
```json
"terminal.integrated.defaultProfile.windows": "Git Bash",
"terminal.integrated.profiles.windows": {
    "Git Bash": {
        "path": "C:\\Program Files\\Git\\bin\\bash.exe"
    }
}
```

**macOS**:
```json
"terminal.integrated.defaultProfile.osx": "zsh",
"terminal.integrated.profiles.osx": {
    "zsh": {
        "path": "/bin/zsh"
    }
}
```

---

## Best Practices

### Backup and Sync

1. **Regular Backups**:
   - Windows: Copy `%APPDATA%\Roaming\Cursor\User\` to backup location
   - macOS: Copy `~/Library/Application Support/Cursor/User/` to backup location

2. **Version Control**:
   - Store `settings.json` and `keybindings.json` in a Git repository
   - Exclude machine-specific paths and tokens

3. **Settings Sync**:
   - Use Cursor's built-in Settings Sync feature if available
   - Manually sync via cloud storage (Dropbox, iCloud, etc.)

### Security Considerations

1. **Sensitive Data**:
   - Never commit API keys or tokens in settings files
   - Use environment variables for sensitive configuration
   - Review `settings.json` before sharing

2. **Permissions**:
   - Windows: Check folder permissions in Properties
   - macOS: Use `chmod` and `chown` for proper access control

### Troubleshooting

1. **Invalid JSON**:
   - Use a JSON validator (e.g., jsonlint.com)
   - Check for trailing commas and missing quotes

2. **Settings Not Applied**:
   - Restart Cursor IDE
   - Check for conflicting workspace settings
   - Review error logs

3. **Finding Logs**:
   - Windows: `%APPDATA%\Roaming\Cursor\logs\`
   - macOS: `~/Library/Logs/Cursor/`

---

## Quick Reference Commands

### Windows 11 (PowerShell)

```powershell
# Open settings directory
explorer "$env:APPDATA\Cursor\User"

# Edit settings.json
notepad "$env:APPDATA\Cursor\User\settings.json"

# View logs
Get-ChildItem "$env:APPDATA\Cursor\logs" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
```

### Windows 11 (Git Bash)

```bash
# Open settings directory
cd $APPDATA/Cursor/User

# Edit settings.json
nano $APPDATA/Cursor/User/settings.json

# View latest log
ls -lt $APPDATA/Cursor/logs/ | head -2
```

### macOS (Terminal)

```bash
# Open settings directory
cd ~/Library/Application\ Support/Cursor/User/

# Edit settings.json
nano ~/Library/Application\ Support/Cursor/User/settings.json

# View latest log
ls -lt ~/Library/Logs/Cursor/ | head -2

# Open in Finder
open ~/Library/Application\ Support/Cursor/
```

---

## Current Configuration Summary (A00288946 - Windows 11)

### Verified Configuration Files

✅ **settings.json** - Located and contains:
- YOLO mode enabled (full AI autonomy)
- Git Bash as default terminal
- MCP enabled
- Auto-execute enabled
- Full filesystem/terminal access

✅ **keybindings.json** - Located

✅ **snippets/** - Directory exists

✅ **globalStorage/** - Directory exists

✅ **workspaceStorage/** - Directory exists

---

## Additional Resources

- **Official Cursor Documentation**: https://docs.cursor.com
- **Cursor Forum**: https://forum.cursor.com
- **VS Code Settings Reference**: https://code.visualstudio.com/docs/getstarted/settings
  (Cursor is based on VS Code and shares many settings)

---

**Document Created**: October 14, 2025
**Last Updated**: October 14, 2025
**Platform**: Windows 11 & macOS
**Cursor Version Referenced**: 1.7.39+

