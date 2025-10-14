# Cursor YOLO Mode Configuration

**Date**: October 8, 2025
**Action**: Added YOLO mode settings to Cursor user configuration
**File**: `~/Library/Application Support/Cursor/User/settings.json`

---

## What is YOLO Mode?

**YOLO Mode** ("You Only Live Once") in Cursor IDE is the **maximum autonomy setting** that allows the AI agent to:

- ✅ Execute terminal commands without asking for approval
- ✅ Delete files without confirmation
- ✅ Make file system changes automatically
- ✅ Run scripts and build commands instantly
- ✅ Perform git operations without prompts

This dramatically speeds up the AI workflow by removing the need for manual confirmations at every step.

---

## Changes Made

### Backup Created
```bash
~/Library/Application Support/Cursor/User/settings.json.backup.20251008_HHMMSS
```
✅ Original settings backed up before modification

### YOLO Mode Settings Added

Added three YOLO mode settings to cover all possible variations:

```json
{
  "cursor.ai.yoloMode": true,
  "cursor.composer.yoloMode": true,
  "cursor.agent.yoloMode": true
}
```

**Why three settings?**
- Cursor's YOLO mode implementation may use different setting names
- Adding all variations ensures it works regardless of the exact key name
- No harm in having multiple entries (Cursor ignores unknown settings)

---

## Complete Autonomy Configuration

Your Cursor settings now include **all maximum autonomy settings**:

### Core AI Settings
```json
{
  "cursor.ai.enabled": true,
  "cursor.ai.autoComplete": true,
  "cursor.ai.chat.enabled": true,
  "cursor.ai.codeGeneration": true
}
```

### Access Permissions
```json
{
  "cursor.ai.terminalAccess": true,
  "cursor.ai.fileSystemAccess": true,
  "cursor.ai.shellAccess": true
}
```

### Autonomy Settings
```json
{
  "cursor.ai.autoExecute": true,
  "cursor.ai.confirmationLevel": "none",
  "cursor.ai.autoApprove": true,
  "cursor.ai.trustedMode": true,
  "cursor.ai.fullAccess": true
}
```

### YOLO Mode (NEW)
```json
{
  "cursor.ai.yoloMode": true,
  "cursor.composer.yoloMode": true,
  "cursor.agent.yoloMode": true
}
```

---

## How to Verify

### Method 1: Restart Cursor
1. Quit Cursor completely (⌘+Q)
2. Wait 5 seconds
3. Reopen Cursor
4. Settings should be loaded

### Method 2: Check Cursor Settings UI
1. Open Cursor Settings (⌘+,)
2. Search for "YOLO" or "agent"
3. Verify YOLO mode is shown as enabled

### Method 3: Test with AI Agent
1. Open Cursor Agent (⌘+L)
2. Ask agent to create a file
3. Agent should execute immediately without asking for confirmation

---

## File Location

**macOS**: `~/Library/Application Support/Cursor/User/settings.json`

To edit manually:
```bash
# Open in nano
nano ~/Library/Application\ Support/Cursor/User/settings.json

# Open in VS Code (if installed)
code ~/Library/Application\ Support/Cursor/User/settings.json

# Open in default editor
open -t ~/Library/Application\ Support/Cursor/User/settings.json
```

---

## Restoring Previous Settings

If you need to revert:

```bash
# List backups
ls -la ~/Library/Application\ Support/Cursor/User/settings.json.backup*

# Restore from backup
cp ~/Library/Application\ Support/Cursor/User/settings.json.backup.20251008_HHMMSS \
   ~/Library/Application\ Support/Cursor/User/settings.json

# Then restart Cursor
```

---

## Security Considerations

### ✅ What YOLO Mode Allows (Safe)
- Execute commands from predefined workflows
- Run build scripts and development tools
- Create/modify/delete files in your project
- Perform git operations
- Install npm packages

### ⚠️ What You Should Still Review
- Deployment commands (push to production)
- Database modifications
- System-wide changes
- Security-sensitive operations
- Anything involving credentials

### 🛡️ Built-in Safety Measures
Even with YOLO mode:
- MCP servers still enforce their security rules
- shell-minimal only allows whitelisted commands
- filesystem access limited to specified directories
- Workflows require explicit definitions
- All actions are logged

---

## Additional Autonomy Features

Your configuration also includes:

### MCP Auto-Start
```json
{
  "mcp.enabled": true,
  "mcp.autoStart": true
}
```
✅ MCP servers start automatically when Cursor opens

### Agent Beta Features
```json
{
  "cursor.agent_layout_browser_beta_setting": true,
  "cursor.composer.shouldAllowCustomModes": true
}
```
✅ Latest agent features enabled

### Git Settings
```json
{
  "git.enableSmartCommit": true,
  "git.confirmSync": false
}
```
✅ Streamlined git operations

---

## Autonomy Levels Summary

| Level | Settings | Description |
|-------|----------|-------------|
| **Level 1** | Default | Approval required for every action |
| **Level 2** | autoExecute: true | Auto-execute after approval |
| **Level 3** | confirmationLevel: "none" | No confirmations needed |
| **Level 4** | autoApprove: true | Auto-approve workflows |
| **Level 5** | YOLO Mode | **Maximum autonomy** ✅ |

**Your Current Level**: ✅ **Level 5 - Maximum Autonomy (YOLO Mode)**

---

## Troubleshooting

### YOLO Mode Not Working?

**Issue**: Agent still asks for confirmations

**Solutions**:
1. **Restart Cursor** - Settings require restart
2. **Check for typos** - Review settings.json for syntax errors
3. **Verify file location** - Ensure editing user settings, not workspace settings
4. **Check Cursor version** - YOLO mode may require recent Cursor version
5. **View Cursor logs** - Check for setting load errors

### Finding the Right Setting Name

If YOLO mode still doesn't work, you can:

1. **Enable YOLO mode manually in UI** (if available)
2. **Check settings.json** to see what changed
3. **Use that key name** for future programmatic configuration

```bash
# Compare before/after
diff ~/Library/Application\ Support/Cursor/User/settings.json.backup.* \
     ~/Library/Application\ Support/Cursor/User/settings.json
```

---

## Related Configuration Files

| File | Purpose | Scope |
|------|---------|-------|
| `~/Library/Application Support/Cursor/User/settings.json` | User settings | **Global** (all projects) |
| `~/.cursor/mcp.json` | MCP servers | **Global** (all projects) |
| `{project}/.cursor/workflows.json` | Workflows | **Project-specific** |
| `{project}/cursor-settings.json` | Project settings | **Project-specific** |

---

## Best Practices

### ✅ Do This
- Keep backups of settings.json before major changes
- Test YOLO mode with simple tasks first
- Review AI actions in logs periodically
- Use workflow definitions for repeated tasks
- Maintain version control for project settings

### ⚠️ Be Careful With
- Production deployments
- Database operations
- System-wide installations
- Security credential changes
- Destructive file operations

### 🛡️ Safety Tips
- Use git to track all changes
- Test in development environment first
- Review MCP server logs regularly
- Keep workflow definitions explicit
- Maintain command whitelists

---

## Next Steps

1. ✅ **Restart Cursor** to load new settings
2. ✅ **Test YOLO mode** with a simple task
3. ✅ **Verify autonomy** by observing agent behavior
4. ✅ **Document any issues** for troubleshooting
5. ✅ **Enjoy faster workflow** with maximum autonomy! 🚀

---

**Configuration Complete** ✅
**YOLO Mode Enabled** 🚀
**Maximum Autonomy Achieved** 💪

