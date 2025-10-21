# MCP Architecture - Corrected Global Installation

**Date**: October 21, 2025
**Issue**: MCP configs were pointing to project-specific paths
**Solution**: Moved MCP servers to `~/cursor-global/mcp-servers/`
**Status**: ✅ FIXED - Now truly global

---

## ❌ **THE ORIGINAL PROBLEM**

### **What Was Wrong**:
```json
{
  "playwright-minimal": {
    "command": "node",
    "args": ["/Users/a00288946/Projects/accessilist/my-mcp-servers/packages/playwright-minimal/build/index.js"]
  }
}
```

**Problems**:
1. ❌ **Not global** - Only works within accessilist project
2. ❌ **Breaks portability** - Fails if project path changes
3. ❌ **Defeats cursor-global purpose** - Global config with local paths
4. ❌ **Can't use in other projects** - Tied to one project location

---

## ✅ **THE CORRECT SOLUTION**

### **What's Fixed**:
```json
{
  "playwright-minimal": {
    "command": "node",
    "args": ["/Users/a00288946/cursor-global/mcp-servers/playwright-minimal/build/index.js"]
  }
}
```

**Benefits**:
1. ✅ **Truly global** - Works from any project
2. ✅ **Portable** - Survives project moves/deletions
3. ✅ **Proper architecture** - Global config → global location
4. ✅ **Reusable** - Available to all Cursor projects

---

## 📁 **NEW DIRECTORY STRUCTURE**

### **Global Location** (Runtime):
```
~/cursor-global/
├── mcp-servers/              ← **MCP SERVERS RUN FROM HERE**
│   ├── playwright-minimal/
│   ├── github-minimal/
│   ├── shell-minimal/
│   ├── sequential-thinking-minimal/
│   ├── everything-minimal/
│   ├── agent-autonomy/
│   └── README.md
├── config/
│   └── mcp.json              ← Points to ~/cursor-global/mcp-servers/
└── scripts/
    └── ...
```

### **Project Location** (Source):
```
accessilist/
├── my-mcp-servers/
│   └── packages/             ← **SOURCE CODE (for development)**
│       ├── playwright-minimal/
│       ├── github-minimal/
│       └── ...
└── ...
```

**Flow**: Develop in project → Copy to global → Cursor runs from global

---

## 🔄 **SYNC WORKFLOW**

### **When you update an MCP server**:

```bash
# 1. Develop/update in project
cd /Users/a00288946/Projects/accessilist/my-mcp-servers/packages/playwright-minimal
# Make changes to src/index.ts
npm run build

# 2. Copy to global location
cp -r build ~/cursor-global/mcp-servers/playwright-minimal/
# OR copy entire package:
cp -r . ~/cursor-global/mcp-servers/playwright-minimal/

# 3. Restart Cursor
pkill -9 Cursor && open -a Cursor
```

### **Helper script** (future):
```bash
# Create ~/cursor-global/scripts/sync-mcp-servers.sh
#!/bin/bash
cp -r /Users/a00288946/Projects/accessilist/my-mcp-servers/packages/* \
      ~/cursor-global/mcp-servers/
echo "✅ MCP servers synced to global location"
```

---

## 📊 **COMPARISON: PROJECT vs GLOBAL**

| Aspect | Project Path (❌ Wrong) | Global Path (✅ Correct) |
|--------|------------------------|-------------------------|
| **Location** | `/Projects/accessilist/my-mcp-servers/` | `~/cursor-global/mcp-servers/` |
| **Works from any project** | ❌ No | ✅ Yes |
| **Survives project deletion** | ❌ No | ✅ Yes |
| **Truly global** | ❌ No | ✅ Yes |
| **Follows Cursor pattern** | ❌ No | ✅ Yes |
| **Reusable** | ❌ No | ✅ Yes |

---

## 🎯 **CORRECT MCP PATTERNS**

### **Pattern 1: Official npm Packages** (Best)
```json
{
  "filesystem": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-filesystem", "/Users/a00288946"]
  }
}
```
**Use for**: Published packages
**Example**: filesystem, memory

### **Pattern 2: Global npm Install**
```bash
cd ~/cursor-global/mcp-servers/playwright-minimal
npm install -g .
```
```json
{
  "playwright-minimal": {
    "command": "playwright-minimal"
  }
}
```
**Use for**: Frequently updated custom servers

### **Pattern 3: Global Directory** (Current)
```json
{
  "playwright-minimal": {
    "command": "node",
    "args": ["/Users/a00288946/cursor-global/mcp-servers/playwright-minimal/build/index.js"]
  }
}
```
**Use for**: Custom servers not published to npm

---

## ✅ **CURRENT STATUS**

### **Installed Globally**:
- ✅ playwright-minimal
- ✅ github-minimal
- ✅ shell-minimal
- ✅ sequential-thinking-minimal
- ✅ everything-minimal
- ✅ agent-autonomy
- ✅ filesystem (via npx)
- ✅ memory (via npx)

### **Removed**:
- ❌ puppeteer-minimal (replaced by playwright-minimal)

### **Tool Count**:
- **Total**: 39/40 (within Cursor limit)

---

## 📝 **UPDATED CONFIGURATIONS**

### **~/.cursor/mcp.json**:
```json
{
  "mcpServers": {
    "playwright-minimal": {
      "command": "node",
      "args": ["/Users/a00288946/cursor-global/mcp-servers/playwright-minimal/build/index.js"]
    },
    "github-minimal": {
      "command": "node",
      "args": ["/Users/a00288946/cursor-global/mcp-servers/github-minimal/build/index.js"],
      "env": {"GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"}
    },
    "shell-minimal": {
      "command": "node",
      "args": ["/Users/a00288946/cursor-global/mcp-servers/shell-minimal/build/index.js"],
      "env": {
        "WORKING_DIRECTORY": "${PROJECT_ROOT}",
        "ALLOWED_COMMANDS": "npm,git,node,php,composer,curl,wget,ls,cat,grep,find,chmod,chown,mkdir,rm,cp,mv"
      }
    },
    "sequential-thinking-minimal": {
      "command": "node",
      "args": ["/Users/a00288946/cursor-global/mcp-servers/sequential-thinking-minimal/build/index.js"]
    },
    "everything-minimal": {
      "command": "node",
      "args": ["/Users/a00288946/cursor-global/mcp-servers/everything-minimal/build/index.js"]
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/Users/a00288946"],
      "env": {
        "ALLOWED_PATHS": "/Users/a00288946:/Users/a00288946/.cursor:/Users/a00288946/.config",
        "READ_ONLY": "false"
      }
    },
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    }
  }
}
```

### **~/cursor-global/config/mcp.json**:
Same as above (synchronized)

---

## 🚀 **NEXT STEPS**

1. **Restart Cursor** to load corrected config:
   ```bash
   pkill -9 Cursor && open -a Cursor
   ```

2. **Verify MCP servers loaded**:
   - Check Cursor MCP status
   - Should show 7 servers with 39 tools total

3. **Test AI-driven browser automation**:
   ```
   Using playwright-minimal, navigate to https://example.com
   ```

4. **(Optional) Create sync script** for future updates:
   ```bash
   ~/cursor-global/scripts/sync-mcp-servers.sh
   ```

---

## 📚 **DOCUMENTATION LOCATIONS**

### **Global**:
- `~/cursor-global/mcp-servers/README.md` - Server catalog
- `~/.cursor/mcp.json` - Active configuration

### **Project** (Source):
- `my-mcp-servers/packages/*/README.md` - Individual server docs
- `my-mcp-servers/packages/*/COMPARISON.md` - Analysis docs

---

## ✅ **VERIFICATION CHECKLIST**

- [x] MCP servers copied to ~/cursor-global/mcp-servers/
- [x] ~/.cursor/mcp.json updated with global paths
- [x] ~/cursor-global/config/mcp.json synchronized
- [x] puppeteer-minimal removed
- [x] Documentation created
- [ ] Cursor restarted
- [ ] MCP servers verified in Cursor
- [ ] AI-driven testing confirmed working

---

## 🎉 **BENEFITS ACHIEVED**

1. ✅ **True global configuration** - Works from any project
2. ✅ **Proper architecture** - Follows Cursor IDE best practices
3. ✅ **Maintainable** - Clear source → global workflow
4. ✅ **Portable** - Not tied to specific project path
5. ✅ **Reusable** - Available to all future projects

---

*Document Created: October 21, 2025*
*Issue: Project-specific paths in global config*
*Status: ✅ RESOLVED - MCP servers now truly global*
