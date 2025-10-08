# Workflow Automation Guide

> **Practical Guide for AccessiList Project**
>
> **Purpose**: Step-by-step instructions for setting up and using autonomous AI workflows
> **Audience**: Developers working on AccessiList
> **Prerequisites**: Cursor IDE, Node.js 18+, basic terminal knowledge

## Overview

This guide shows you how to set up autonomous workflows in the AccessiList project using the custom `agent-autonomy` MCP server. Once configured, you can trigger complex development tasks with simple chat commands like "ai-start" without any approval prompts.

### What You'll Accomplish

- ✅ Install and configure the agent-autonomy MCP server
- ✅ Create workflow definitions for common tasks
- ✅ Execute workflows autonomously from Cursor chat
- ✅ Optimize MCP tool count (39 tools total)

### Time Required

- **First-time setup**: 15-20 minutes
- **Adding new workflows**: 5 minutes each
- **Daily usage**: Instant (just type the workflow name)

## Quick Start

### Step 1: Update MCP Configuration (2 minutes)

Edit `~/.cursor/mcp.json` to remove unneeded servers and add agent-autonomy:

```bash
# Open the configuration file
nano ~/.cursor/mcp.json
```

**Remove these servers** (to free up tool slots):
```json
// DELETE these sections:
"sequential-thinking-minimal": { ... },
"everything-minimal": { ... }
```

**Add the agent-autonomy server**:
```json
{
  "mcpServers": {
    "filesystem": { ... },  // Keep existing
    "memory": { ... },      // Keep existing
    "shell-minimal": { ... }, // Keep existing
    "github-minimal": { ... }, // Keep existing
    "puppeteer-minimal": { ... }, // Keep existing
    "agent-autonomy": {
      "command": "npx",
      "args": ["-y", "mcp-agent-autonomy@1.0.1"],
      "env": {
        "WORKING_DIRECTORY": "/Users/a00288946/Desktop/accessilist"
      }
    }
  }
}
```

### Step 2: Create Workflow Configuration (3 minutes)

Create `.cursor/workflows.json` in the AccessiList project root:

```bash
cd /Users/a00288946/Desktop/accessilist
mkdir -p .cursor
nano .cursor/workflows.json
```

Add the `ai-start` workflow:

```json
{
  "ai-start": {
    "description": "Start AccessiList development server",
    "commands": [
      "git status",
      "php -S localhost:8000 -t . router.php > logs/php-server.log 2>&1 &",
      "sleep 2",
      "curl -s http://localhost:8000/php/home.php -o /dev/null && echo '✅ Server running on http://localhost:8000' || echo '❌ Server failed to start'"
    ],
    "auto_approve": true,
    "working_directory": "/Users/a00288946/Desktop/accessilist",
    "timeout": 30000,
    "on_error": "stop"
  }
}
```

### Step 3: Restart Cursor IDE

```bash
# Quit Cursor completely
# CMD+Q (on macOS)

# Wait 5 seconds

# Reopen Cursor
open -a Cursor /Users/a00288946/Desktop/accessilist
```

### Step 4: Test Autonomous Execution

1. Open Cursor IDE with AccessiList project
2. Enter Agent mode (⌘+L)
3. Type: **"Execute the ai-start workflow"**
4. Watch the workflow execute automatically without approval prompts!

Expected output:
```
🚀 Executing workflow: ai-start
[1/4] git status
✅ Output: On branch global-renaming...
[2/4] php -S localhost:8000 -t . router.php > logs/php-server.log 2>&1 &
✅ Output: Started PHP server
[3/4] sleep 2
✅ Output:
[4/4] curl -s http://localhost:8000...
✅ Output: ✅ Server running on http://localhost:8000

Workflow completed successfully in 3.2s
```

## Creating Additional Workflows

### Workflow: `ai-test`

Run the AccessiList test suite:

```json
{
  "ai-test": {
    "description": "Run AccessiList comprehensive tests",
    "commands": [
      "php tests/run_comprehensive_tests.php",
      "echo '✅ Test results available in tests/reports/'"
    ],
    "auto_approve": true,
    "working_directory": "/Users/a00288946/Desktop/accessilist",
    "timeout": 120000,
    "on_error": "continue"
  }
}
```

**Usage**: "Execute the ai-test workflow"

### Workflow: `ai-stop`

Stop the PHP development server:

```json
{
  "ai-stop": {
    "description": "Stop AccessiList development server",
    "commands": [
      "pkill -f 'php -S localhost:8000' || echo 'No server running'",
      "echo '✅ Server stopped'"
    ],
    "auto_approve": true,
    "working_directory": "/Users/a00288946/Desktop/accessilist",
    "timeout": 10000,
    "on_error": "continue"
  }
}
```

**Usage**: "Execute the ai-stop workflow"

### Workflow: `ai-status`

Check project status:

```json
{
  "ai-status": {
    "description": "Check AccessiList project status",
    "commands": [
      "git status --short",
      "curl -s http://localhost:8000/php/home.php -o /dev/null && echo '✅ Server: Running' || echo '❌ Server: Stopped'",
      "php --version | head -n 1",
      "node --version"
    ],
    "auto_approve": true,
    "working_directory": "/Users/a00288946/Desktop/accessilist",
    "timeout": 15000,
    "on_error": "continue"
  }
}
```

**Usage**: "Execute the ai-status workflow"

## Troubleshooting

### Problem: Workflow Not Found

**Error**: `Workflow 'ai-start' not found`

**Solutions**:
1. Check `.cursor/workflows.json` exists in project root
2. Verify workflow name is spelled correctly
3. Restart Cursor to reload workflow definitions

### Problem: Commands Require Approval

**Error**: Commands still ask for approval

**Solutions**:
1. Verify `auto_approve: true` in workflow definition
2. Check MCP server is running: `Settings → MCP → agent-autonomy` should show green status
3. Restart Cursor after configuration changes

### Problem: Tool Count Still Over Limit

**Error**: "Too many MCP tools"

**Solutions**:
1. Verify you removed `sequential-thinking-minimal` and `everything-minimal`
2. Check tool count: `Settings → MCP` - should show 39 tools total
3. Restart Cursor after removing servers

### Problem: Workflow Fails Silently

**Debugging**:
1. Check `logs/workflow-audit.log` for execution details
2. Run commands manually to test:
   ```bash
   cd /Users/a00288946/Desktop/accessilist
   php -S localhost:8000 -t . router.php
   ```
3. Verify working directory path is correct
4. Check timeout is sufficient for long-running commands

### Problem: MCP Server Not Starting

**Error**: agent-autonomy server shows red in Settings → MCP

**Solutions**:
1. Check Node.js version: `node --version` (need 18+)
2. Clear npm cache: `npm cache clean --force`
3. Reinstall package: `npm install -g mcp-agent-autonomy`
4. Check logs: Look for errors in Cursor's developer console

## Best Practices

### 1. Workflow Naming

- Use `ai-` prefix for consistency (e.g., `ai-start`, `ai-test`, `ai-deploy`)
- Keep names short and descriptive
- Use kebab-case for multi-word names

### 2. Command Design

- **Idempotent**: Running twice should be safe
- **Verbose**: Include echo statements for status updates
- **Fail-safe**: Use `||` for error handling
- **Background tasks**: Redirect logs (`> logs/server.log 2>&1 &`)

### 3. Error Handling

- **Development workflows**: Use `on_error: "continue"` (don't stop on minor errors)
- **Production workflows**: Use `on_error: "stop"` (halt on any error)
- **Deployment workflows**: Set `auto_approve: false` (require confirmation)

### 4. Timeouts

- **Quick commands** (< 5s): 10000ms
- **Normal commands** (< 30s): 30000ms
- **Tests** (< 2min): 120000ms
- **Builds/deploys** (< 5min): 300000ms

### 5. Security

- **Never include secrets** in workflow definitions
- **Use environment variables** for sensitive data
- **Version control** `.cursor/workflows.json` for team sharing
- **Review changes** to workflows before committing

## Advanced Usage

### Conditional Workflow Execution

Use shell conditionals in commands:

```json
{
  "commands": [
    "[ -f package-lock.json ] && npm ci || echo 'No package-lock.json'",
    "[ -d node_modules ] || npm install"
  ]
}
```

### Environment-Specific Workflows

Create separate workflows for different environments:

```json
{
  "ai-start-dev": {
    "commands": ["php -S localhost:8000 ..."],
    "environment": { "ENV": "development" }
  },
  "ai-start-prod": {
    "commands": ["php -S localhost:8080 ..."],
    "environment": { "ENV": "production" }
  }
}
```

### Workflow Composition

Chain workflows together:

```json
{
  "ai-full-start": {
    "description": "Complete startup sequence",
    "commands": [
      "# First, stop any running servers",
      "pkill -f 'php -S localhost:8000' || true",
      "# Clean up",
      "rm -f logs/*.log",
      "# Start fresh",
      "php -S localhost:8000 -t . router.php > logs/php-server.log 2>&1 &",
      "sleep 2",
      "# Verify",
      "curl -s http://localhost:8000/php/home.php -o /dev/null && echo '✅ Ready' || echo '❌ Failed'"
    ]
  }
}
```

## Common Workflows for AccessiList

### Full `.cursor/workflows.json` Example

```json
{
  "ai-start": {
    "description": "Start development server",
    "commands": [
      "git status",
      "php -S localhost:8000 -t . router.php > logs/php-server.log 2>&1 &",
      "sleep 2",
      "curl -s http://localhost:8000/php/home.php -o /dev/null && echo '✅ Server running' || echo '❌ Failed'"
    ],
    "auto_approve": true,
    "working_directory": "/Users/a00288946/Desktop/accessilist",
    "timeout": 30000,
    "on_error": "stop"
  },
  "ai-stop": {
    "description": "Stop development server",
    "commands": [
      "pkill -f 'php -S localhost:8000' || echo 'No server running'",
      "echo '✅ Server stopped'"
    ],
    "auto_approve": true,
    "working_directory": "/Users/a00288946/Desktop/accessilist",
    "timeout": 10000,
    "on_error": "continue"
  },
  "ai-test": {
    "description": "Run test suite",
    "commands": [
      "php tests/run_comprehensive_tests.php",
      "echo '✅ Tests complete'"
    ],
    "auto_approve": true,
    "working_directory": "/Users/a00288946/Desktop/accessilist",
    "timeout": 120000,
    "on_error": "continue"
  },
  "ai-status": {
    "description": "Check project status",
    "commands": [
      "git status --short",
      "curl -s http://localhost:8000/php/home.php -o /dev/null && echo '✅ Server: Running' || echo '❌ Server: Stopped'",
      "php --version | head -n 1"
    ],
    "auto_approve": true,
    "working_directory": "/Users/a00288946/Desktop/accessilist",
    "timeout": 15000,
    "on_error": "continue"
  }
}
```

## Related Documentation

- **[Agent Autonomy Workflow Server Architecture](../architecture/agent-autonomy-workflow-server.md)** - Technical design and implementation details
- **[Chat-Triggered Automation Research](CHAT-TRIGGERED-AUTOMATION-RESEARCH.md)** - Research foundation for this approach
- **[MCP Tool Strategy](../../my-mcp-servers/README.md)** - Overall MCP server configuration

## Next Steps

1. ✅ Follow the Quick Start to set up your first workflow
2. ✅ Test the `ai-start` workflow
3. ✅ Add additional workflows for your common tasks
4. ✅ Share workflows with your team via Git

---

**Questions or Issues?**
- Check the Troubleshooting section above
- Review the Architecture document for technical details
- Examine `logs/workflow-audit.log` for execution details

**Happy automating!** 🚀

---

## Advanced: RAG Workflows for Code Analysis

### Overview

RAG (Retrieval-Augmented Generation) workflows enable semantic code analysis using embeddings and vector similarity. These workflows don't consume MCP tool slots - they're implemented as scripts called by workflows.

### Available RAG Workflows

| Workflow | Difficulty | Time | Value | Status |
|----------|-----------|------|-------|--------|
| ai-summarize-code | ⭐ (Easy) | 1h | High | Future |
| ai-impact-analysis | ⭐⭐ (Medium) | 2-3h | High | Future |
| ai-find-duplicates | ⭐⭐⭐ (Medium) | 3-4h | Medium | Future |
| ai-generate-docs | ⭐⭐⭐ (Medium) | 4-5h | Medium | Future |
| ai-analyze-architecture | ⭐⭐⭐⭐ (Hard) | 6-8h | High | Future |

### RAG Use Cases

**1. Global Code Pattern Detection**
- Find semantically similar code across the codebase
- Detect authentication/validation patterns regardless of naming

**2. Architecture Understanding**
- Map data flows through the application
- Understand component relationships

**3. Enhanced DRY Analysis**
- Detect semantic duplicates (not just exact matches)
- Find functions that do the same thing differently

**4. Cross-File Impact Analysis**
- Identify what breaks when you change something
- Find indirect dependencies

**5. Documentation Generation**
- Auto-generate API docs from code
- Create architecture diagrams

### Implementation Requirements

**Dependencies**:
```bash
npm install openai cosine-similarity @babel/parser @babel/traverse
```

**Environment Setup**:
```bash
export OPENAI_API_KEY="sk-..."
mkdir -p analysis
```

### Example: ai-summarize-code

**Workflow Definition**:
```json
{
  "ai-summarize-code": {
    "description": "Generate AI summary of code file",
    "commands": [
      "node scripts/code-summarizer.js $1",
      "echo '✅ Summary saved to analysis/'"
    ],
    "auto_approve": true,
    "timeout": 30000
  }
}
```

**Usage**:
```
In Cursor chat: "Summarize the StateManager.js file"
→ execute_workflow("ai-summarize-code")
```

### RAG vs Memory MCP Server

- **Memory MCP** (Knowledge Graph): Stores structured facts (entities, relations)
  - Good for: User preferences, project decisions, session context

- **RAG** (Vector Database): Stores semantic embeddings of code/docs
  - Good for: Finding similar code, understanding patterns, global analysis

They complement each other! Memory = facts, RAG = semantic understanding.

### Future Enhancements

RAG workflows can be added later without consuming additional MCP tool slots. Start with session management workflows, add RAG capabilities as needed.


