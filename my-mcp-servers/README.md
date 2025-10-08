# My Custom MCP Servers

**Repository**: [https://github.com/gjoeckel/my-mcp-servers](https://github.com/gjoeckel/my-mcp-servers)
**Purpose**: Custom MCP servers with minimal tool sets for 39-tool limit compliance
**Target**: Exactly 39 tools across 6 servers for optimal AI autonomous operation

---

## 🎯 **STRATEGY OVERVIEW**

This repository contains custom forks of official MCP servers, reduced to only essential tools to stay within the 39-tool limit while maintaining full functionality.

### **39-Tool Configuration** (Current)
```
✅ OFFICIAL SERVERS:
├── filesystem: 15 tools (all essential)
└── memory: 8 tools (all essential)

✅ CUSTOM SERVERS (Minimal implementations):
├── shell-minimal: 4 tools (custom implementation)
├── github-minimal: 4 tools (reduced from 20+ tools)
├── puppeteer-minimal: 4 tools (reduced from 12+ tools)
└── agent-autonomy: 4 tools (workflow automation)

TOTAL: 15 + 8 + 4 + 4 + 4 + 4 = 39 tools ✅
```

---

## 📦 **PACKAGES**

### **GitHub Minimal** (`packages/github-minimal/`)
**Original**: `@modelcontextprotocol/server-github` (20+ tools)
**Custom**: 4 essential tools only

**Tools Included**:
- `get_file_contents` - Read repository files
- `create_or_update_file` - Manage repository files
- `push_files` - Deploy code changes
- `search_repositories` - Find relevant repos

**Tools Removed** (16+ tools):
- `list_commits`, `create_pull_request`, `fork_repository`
- `get_issue`, `create_issue`, `update_issue`, `list_issues`
- `get_pull_request`, `merge_pull_request`, `close_pull_request`
- `get_workflow`, `trigger_workflow`, `get_deployment`
- `get_release`, `create_release`, `list_releases`
- And more...

### **Shell Minimal** (`packages/shell-minimal/`)
**Original**: Custom implementation (no official server exists)
**Custom**: 4 essential tools only

**Tools Included**:
- `execute_command` - Run terminal commands
- `list_processes` - Check running processes
- `kill_process` - Stop processes
- `get_environment` - Check environment variables

### **Agent Autonomy** (`packages/agent-autonomy/`)
**Original**: Custom implementation for workflow automation
**Custom**: 4 workflow tools only
**Published**: npm package `mcp-agent-autonomy@1.0.1`

**Tools Included**:
- `execute_workflow` - Execute predefined workflows autonomously
- `list_workflows` - List all available workflows
- `register_workflow` - Register new workflows at runtime
- `check_approval` - Check command approval status

**Key Features**:
- Autonomous execution without approval prompts
- Workflow definitions in `.cursor/workflows.json`
- Multi-step command orchestration
- Error handling and logging
- Zero additional tool overhead for unlimited workflows

### **Puppeteer Minimal** (`packages/puppeteer-minimal/`)
**Original**: `@modelcontextprotocol/server-puppeteer` (12+ tools)
**Custom**: 4 essential tools only

**Tools Included**:
- `navigate` - Navigate to URLs
- `screenshot` - Capture visual state
- `evaluate` - Execute JavaScript
- `click` - Interact with elements

**Tools Removed** (8+ tools):
- `fill`, `select`, `hover`, `wait`, `scroll`, `type`, `press_key`
- `get_text`, `get_attribute`
- And more...

---

## 🚀 **QUICK START**

### **Installation**
```bash
# Clone the repository
git clone https://github.com/gjoeckel/my-mcp-servers.git
cd my-mcp-servers

# Install all packages
npm run install-all

# Build all packages
npm run build-all

# Link all packages globally
npm run link-all
```

### **Usage in Cursor IDE**

#### **Option 1: Local Development (Recommended)**
Clone the repository and use local builds:
```bash
# Clone the repository
git clone https://github.com/gjoeckel/my-mcp-servers.git
cd my-mcp-servers

# Install dependencies and build
npm run install-all
npm run build-all
```

Update your `.cursor/mcp.json`:
```json
{
  "mcpServers": {
    "github-minimal": {
      "command": "node",
      "args": ["/path/to/my-mcp-servers/packages/github-minimal/build/index.js"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
      }
    },
    "shell-minimal": {
      "command": "node",
      "args": ["/path/to/my-mcp-servers/packages/shell-minimal/build/index.js"],
      "env": {
        "WORKING_DIRECTORY": "/path/to/your/project",
        "ALLOWED_COMMANDS": "npm,git,node,php,composer,curl,wget,ls,cat,grep,find,chmod,chown,mkdir,rm,cp,mv"
      }
    },
    "puppeteer-minimal": {
      "command": "node",
      "args": ["/path/to/my-mcp-servers/packages/puppeteer-minimal/build/index.js"]
    },
    "agent-autonomy": {
      "command": "node",
      "args": ["/path/to/my-mcp-servers/packages/agent-autonomy/build/index.js"],
      "env": {
        "WORKING_DIRECTORY": "/path/to/your/project"
      }
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/your/project"],
      "env": {
        "ALLOWED_PATHS": "/path/to/your/project:/Users/yourusername/.cursor",
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

#### **Option 2: Published Packages (Future)**
When packages are published to npm:
```json
{
  "mcpServers": {
    "github-minimal": {
      "command": "npx",
      "args": ["-y", "@gjoeckel/mcp-github-minimal"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
      }
    },
    "shell-minimal": {
      "command": "npx",
      "args": ["-y", "@gjoeckel/mcp-shell-minimal"],
      "env": {
        "WORKING_DIRECTORY": "/path/to/your/project",
        "ALLOWED_COMMANDS": "npm,git,node,php,composer,curl,wget,ls,cat,grep,find,chmod,chown,mkdir,rm,cp,mv"
      }
    },
    "puppeteer-minimal": {
      "command": "npx",
      "args": ["-y", "@gjoeckel/mcp-puppeteer-minimal"]
    },
    "agent-autonomy": {
      "command": "npx",
      "args": ["-y", "mcp-agent-autonomy@1.0.1"],
      "env": {
        "WORKING_DIRECTORY": "/path/to/your/project"
      }
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/your/project"]
    },
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    }
  }
}
```

---

## 🔧 **DEVELOPMENT**

### **Project Structure**
```
my-mcp-servers/
├── packages/
│   ├── shell-minimal/           # Custom shell server (4 tools)
│   ├── github-minimal/          # Forked GitHub server (4 tools)
│   ├── puppeteer-minimal/       # Forked Puppeteer server (4 tools)
│   ├── agent-autonomy/          # Workflow automation (4 tools) - Published to npm
│   ├── sequential-thinking-minimal/  # DEPRECATED - Not in current config
│   └── everything-minimal/      # DEPRECATED - Not in current config
├── scripts/
│   ├── build-all.sh            # Build all packages
│   ├── link-all.sh             # Link all packages globally
│   └── test-all.sh             # Test all packages
├── package.json                # Root package configuration
└── README.md                   # This file
```

### **Available Scripts**
```bash
# Development
npm run build-all              # Build all packages
npm run link-all               # Link all packages globally
npm run test-all               # Test all packages
npm run clean-all              # Clean all build directories

# Individual package commands
cd packages/github-minimal && npm run build
cd packages/shell-minimal && npm run build
cd packages/puppeteer-minimal && npm run build
```

### **Adding New Tools**
1. Edit the `tools` array in the package's main file
2. Add the corresponding handler in the `CallToolRequestSchema` handler
3. Build and test the package
4. Update documentation

### **Updating from Upstream**
```bash
# For forked packages (github-minimal, puppeteer-minimal)
cd packages/github-minimal
git remote add upstream https://github.com/modelcontextprotocol/servers.git
git fetch upstream
git merge upstream/main

# Reapply your tool filtering changes
# Test to ensure functionality is preserved
```

---

## 📊 **TOOL COUNT VERIFICATION**

### **Current Tool Distribution**
| Server | Original Tools | Custom Tools | Reduction | Status |
|--------|----------------|--------------|-----------|---------|
| Filesystem | 15 | 15 | 0% | ✅ Official |
| Memory | 8 | 8 | 0% | ✅ Official |
| Shell Minimal | Custom | 4 | N/A | ✅ Custom |
| GitHub Minimal | 20+ | 4 | 80% | ✅ Custom |
| Puppeteer Minimal | 12+ | 4 | 67% | ✅ Custom |
| Agent Autonomy | Custom | 4 | N/A | ✅ Published |
| **TOTAL** | **55+** | **39** | **29%** | ✅ **OPTIMIZED** |

### **Deprecated Servers** (Not in current configuration)
| Server | Status | Reason |
|--------|--------|--------|
| Sequential Thinking Minimal | ❌ Removed | Freed tool slots for agent-autonomy |
| Everything Minimal | ❌ Removed | Freed tool slots for agent-autonomy |

### **Verification Commands**
```bash
# Check tool count in Cursor IDE
# The AI should have exactly 39 tools available

# Manual verification
npm run verify-tool-count

# Health check
npm run health-check
```

---

## 🎯 **BENEFITS**

### **Performance**
- ✅ **Faster Response**: Fewer tools = faster tool discovery
- ✅ **Lower Memory**: Reduced tool registration overhead
- ✅ **Better Reliability**: Less chance of tool conflicts

### **Maintenance**
- ✅ **Focused Tools**: Only essential functionality
- ✅ **Clear Purpose**: Each tool has specific use case
- ✅ **Easy Updates**: Can pull upstream bug fixes

### **Compliance**
- ✅ **39-Tool Configuration**: Optimized configuration under 40-tool limit
- ✅ **No Bloat**: No unused or rarely-used tools
- ✅ **Full Functionality**: All essential operations preserved
- ✅ **Workflow Automation**: Unlimited workflows via agent-autonomy (4 tools)

---

## 🤝 **CONTRIBUTING**

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

### **Guidelines**
- Maintain the 39-tool configuration (under 40-tool limit)
- Document any new tools
- Test with Cursor IDE integration
- Keep tool descriptions clear and concise
- Consider workflow-based features (agent-autonomy) for scalability

---

## 📄 **LICENSE**

ISC License - See individual package licenses for details.

---

## 🔗 **LINKS**

- **Repository**: [https://github.com/gjoeckel/my-mcp-servers](https://github.com/gjoeckel/my-mcp-servers)
- **Original MCP Servers**: [https://github.com/modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers)
- **MCP Documentation**: [https://modelcontextprotocol.io/](https://modelcontextprotocol.io/)

---

*This repository provides optimized MCP servers for AI autonomous operation within the 39-tool configuration (under 40-tool limit) while maintaining full essential functionality and workflow automation capabilities.*
