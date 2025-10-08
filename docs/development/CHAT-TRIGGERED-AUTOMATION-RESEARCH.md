# Chat-Triggered Script Execution in Cursor IDE on macOS

> **Research Document for AccessiList Project**
>
> **Purpose**: Foundational research for implementing autonomous workflow automation
>
> **Related Documents**:
> - [Agent Autonomy Workflow Server](../architecture/agent-autonomy-workflow-server.md) - Technical architecture built from this research
> - [Workflow Automation Guide](WORKFLOW-AUTOMATION.md) - Practical implementation guide
>
> **Date**: October 2025
> **Context**: Research conducted for implementing autonomous "ai-start" workflows in the AccessiList accessibility checklist application

---

**Cursor IDE supports multiple approaches to trigger scripts from chat commands**, with the most direct being custom slash commands, MCP (Model Context Protocol) servers, and the hooks system. For a command like "ai-start" that executes local scripts, **the recommended approach is either custom slash commands combined with hooks, or deploying an MCP shell execution server**. Both methods work natively on macOS Tahoe and require minimal setup—typically under 10 minutes for basic implementation.

This matters because Cursor's architecture, as a VS Code fork with deep AI integration, enables autonomous agent workflows that traditional IDEs cannot match. The extensibility through MCP and custom commands transforms Cursor from a code editor into a programmable AI assistant that executes your development workflows. Unlike VS Code's extension-based approach, Cursor's native MCP support and command system provide standardized, maintainable patterns for automation.

The ecosystem emerged rapidly following Anthropic's November 2024 release of the Model Context Protocol specification. Cursor added native MCP support shortly after, introducing custom commands in beta and the hooks system in version 1.7 (September 2025). This creates three distinct but complementary automation layers: commands for reusable prompts, hooks for event-driven actions, and MCP for external tool integration.

## Three pathways to chat-triggered automation

Cursor provides three primary mechanisms for triggering scripts from chat, each suited to different use cases and technical requirements.

**Custom slash commands** offer the simplest entry point. You create markdown files in `.cursor/commands/` that define reusable AI prompts. When you type `/ai-start` in chat, Cursor's agent reads the command file and executes the instructions, which can include running terminal commands. The agent operates in Composer mode (Cmd+L on macOS), maintaining full project context and the ability to execute shell commands. Commands support both project-specific (`.cursor/commands/`) and global (`~/.cursor/commands/`) scopes, enabling team sharing through version control.

**The hooks system** provides event-driven automation by executing shell scripts at specific lifecycle points—before tool calls, after file edits, when agent sessions stop, or when prompts are submitted. Configured via `.cursor/hooks.json`, hooks receive environment variables like `$CLAUDE_FILE_PATHS` and `$PROMPT`, enabling conditional logic based on agent actions. A hook can detect when you type a specific phrase and trigger corresponding scripts automatically. On macOS, hooks access the native zsh shell and can invoke AppleScript for system integration.

**MCP servers** represent the most powerful but technically involved approach. These are standalone programs exposing tools through a standardized protocol that Cursor's agent can invoke. Multiple production-ready MCP servers already exist for shell command execution, including `mcp-shell-server` (recommended for macOS) and `cli-mcp-server`. You can also build custom MCP tools in under an hour using TypeScript or Python SDKs.

Each approach has tradeoffs. Custom commands are easiest to create but rely on the agent's interpretation. Hooks provide precise control but are beta-stage with potential syntax changes. MCP servers offer enterprise-grade functionality and security through command whitelisting, but require more initial setup.

## Extensions and built-in capabilities for script execution

Cursor IDE maintains broad compatibility with VS Code extensions while adding proprietary features for AI automation. The platform inherits VS Code's extension API, meaning most community extensions install without modification. However, **no existing extensions directly enable chat-command-to-script triggering**—this functionality requires Cursor's native features.

The custom commands system operates through markdown files containing structured prompts. Here's a functional example for triggering project initialization:

Create `.cursor/commands/ai-start.md`:
```markdown
# AI Start - Initialize Development Environment

Execute the project startup script and verify all services are running.

## Steps
1. Run the startup script: `./scripts/start-dev.sh`
2. Verify database connection
3. Check that all services respond to health checks
4. Report status of each component
5. If any service fails, diagnose and fix the issue

## Context
This is a Next.js project with PostgreSQL database and Redis cache.
The startup script should initialize local development environment.
```

Usage is straightforward: type `/ai-start` in Cursor's chat interface, select the command from the dropdown, and the agent executes the instructions with full project awareness. The agent can read files, execute terminal commands, and make edits—essentially performing the same actions a developer would manually.

**VS Code extension compatibility** remains high overall, with 90% of extensions functioning normally. Language servers (Python, Rust, C++), linters (ESLint, Prettier), and development tools (GitLens, Docker) all work seamlessly. Notable exceptions emerged in April 2025 when Microsoft began enforcing marketplace terms more strictly, causing compatibility issues with some Microsoft-owned extensions like C/C++ IntelliSense. Cursor responded by rebuilding key extensions in-house, all installable from the Cursor marketplace.

For script execution specifically, **the Cursor Agent can already run terminal commands natively**—no extensions needed. When operating in Agent mode, Cursor can execute shell commands, run test suites, manage git operations, and control build tools. The agent maintains a terminal session and can chain commands with error handling.

The **YOLO mode** feature deserves attention for automation workflows. Configurable in Settings, it allows the agent to run commands without user approval. You define allow lists (safe commands like test runners) and deny lists (dangerous operations like `rm -rf`). This enables truly autonomous workflows where typing a command triggers an entire development process without interruption.

One limitation worth noting: Cursor Agent cannot directly invoke extension commands as first-class tools. You cannot say "run the Prettier extension" and have it call the extension's API directly. Workarounds include running CLI versions of tools (`npx prettier`), using MCP servers that wrap extension functionality, or employing hooks to auto-run formatters after the agent edits files.

## MCP tools for script execution on macOS

Model Context Protocol provides the most robust, production-ready approach to script execution in Cursor IDE. Multiple MCP servers already exist specifically for command execution, each with different security models and feature sets.

**mcp-shell-server** (by tumf) stands out as the recommended option for macOS. This server prioritizes security through mandatory command whitelisting, requires explicit approval for allowed commands, and includes comprehensive output handling with stdout, stderr, status codes, and execution time tracking. Installation takes under two minutes:

```bash
# Install via pip
pip install mcp-shell-server

# Configure in ~/.cursor/mcp.json
{
  "mcpServers": {
    "shell": {
      "command": "uvx",
      "args": ["mcp-shell-server"],
      "env": {
        "ALLOW_COMMANDS": "ls,cat,pwd,grep,find,git,npm,node,python3"
      }
    }
  }
}
```

After restarting Cursor, the agent gains access to shell execution tools. You can then type "run my ai-start script" and the agent invokes the MCP tool to execute `./ai-start.sh`. The whitelisting system prevents arbitrary command execution—you must explicitly approve each command or script path.

**cli-mcp-server** (by MladenSU) offers enterprise-grade security with additional protections: path traversal prevention, shell operator injection blocking (;, &&, ||), execution timeouts, working directory restrictions, and granular flag whitelisting. Configuration allows precise control:

```json
{
  "mcpServers": {
    "cli-mcp-server": {
      "command": "uvx",
      "args": ["cli-mcp-server"],
      "env": {
        "ALLOWED_DIR": "/Users/yourusername/projects",
        "ALLOWED_COMMANDS": "ls,cat,pwd,./ai-start.sh",
        "ALLOWED_FLAGS": "-l,-a,--help,--version",
        "COMMAND_TIMEOUT": "30",
        "ALLOW_SHELL_OPERATORS": "false"
      }
    }
  }
}
```

This configuration restricts execution to a specific directory, only allows approved commands and flags, enforces timeouts, and blocks shell operator injection. For macOS specifically, **Mac Shell MCP** (by cfdude) provides zsh-specific integration with approval mechanisms tuned for macOS security model.

Alternative implementations include **shell-command-mcp** (NPM package by egoist) using Node.js with simple whitelisting, **run-command-mcp** (by benyue1978) with natural language command interpretation, and **mcp-server-shell** (by odysseus0) offering minimal overhead but no security features—use only in trusted environments.

MCP servers configure through JSON files at two levels: `~/.cursor/mcp.json` for global availability across all projects, or `.cursor/mcp.json` within specific project directories for context-specific tools. Cursor automatically discovers servers on startup, displays available tools in Settings → MCP, and presents tool invocations for approval (unless YOLO mode is enabled).

**Discovery resources** for additional MCP tools include the official MCP Registry at registry.modelcontextprotocol.io (launched September 2025 in preview), MCPCursor.com for Cursor-specific servers, Cursor Directory at cursor.directory/mcp with one-click installation, Glama.ai featuring a web-based MCP Inspector, and Smithery.ai offering one-command deployment via `npx @smithery/cli install`. The GitHub MCP organization at github.com/modelcontextprotocol maintains curated servers and official SDKs.

Security remains paramount when exposing shell access to AI agents. Best practices include always using command whitelisting, restricting working directories to project paths, setting execution timeouts (typically 30 seconds), disabling shell operators unless specifically needed, maintaining manual approval initially before enabling auto-approval, using project-specific configs to limit tool availability, and verifying MCP server sources before installation. Never configure MCP servers with unrestricted command execution or full filesystem access.

## Building custom MCP tools for macOS script execution

Creating custom MCP servers enables tailored automation workflows with complete control over security, functionality, and integration patterns. The Model Context Protocol provides official SDKs for TypeScript and Python, both supporting macOS natively with straightforward development paths.

**TypeScript implementation** requires Node.js 18+ and takes approximately 30 minutes to build a basic script executor:

```typescript
#!/usr/bin/env node
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { z } from 'zod';
import { exec } from 'child_process';
import { promisify } from 'util';

const execAsync = promisify(exec);

const server = new McpServer({
  name: 'custom-script-executor',
  version: '1.0.0'
});

server.registerTool(
  'run-ai-start',
  {
    title: 'Run AI Start Script',
    description: 'Execute the project ai-start script',
    inputSchema: {
      workingDirectory: z.string().optional()
    }
  },
  async ({ workingDirectory }) => {
    try {
      const options = {
        cwd: workingDirectory || process.cwd(),
        shell: '/bin/zsh',
        maxBuffer: 1024 * 1024 * 10
      };

      const { stdout, stderr } = await execAsync('./ai-start.sh', options);

      return {
        content: [{
          type: 'text',
          text: JSON.stringify({ success: true, stdout, stderr }, null, 2)
        }]
      };
    } catch (error: any) {
      return {
        content: [{
          type: 'text',
          text: JSON.stringify({ success: false, error: error.message }, null, 2)
        }],
        isError: true
      };
    }
  }
);

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
}

main();
```

This creates an MCP tool specifically for your ai-start script. **Zod schemas** provide type-safe input validation, the tool handles errors gracefully, and responses format as JSON for consistent parsing. The server uses stdio transport for local development—Cursor spawns the process and communicates through standard input/output.

**Python implementation** using FastMCP offers even simpler syntax with decorator-based registration:

```python
from mcp.server.fastmcp import FastMCP
import subprocess

mcp = FastMCP("Custom Script Executor")

@mcp.tool()
async def run_ai_start(working_directory: str = None) -> dict:
    """Execute the ai-start script in the project directory"""
    try:
        result = subprocess.run(
            ['./ai-start.sh'],
            shell=True,
            executable='/bin/zsh',
            cwd=working_directory,
            capture_output=True,
            text=True,
            timeout=30
        )

        return {
            "success": result.returncode == 0,
            "stdout": result.stdout,
            "stderr": result.stderr
        }
    except Exception as e:
        return {"success": False, "error": str(e)}

if __name__ == "__main__":
    mcp.run()
```

Python's type hints automatically generate schema validation, subprocess module provides robust process management, and FastMCP handles protocol details automatically. Installation requires only `pip install mcp` followed by `uv run server.py`.

**Cursor configuration** for custom servers uses absolute paths in the JSON config:

```json
{
  "mcpServers": {
    "ai-starter": {
      "command": "node",
      "args": ["/Users/yourusername/mcp-servers/ai-start/build/index.js"],
      "env": {
        "PROJECT_ROOT": "/Users/yourusername/projects/current"
      }
    }
  }
}
```

macOS-specific considerations require attention to security and permissions. **File execution permissions** must be set with `chmod +x ai-start.sh` before scripts will run. **Full Disk Access** permissions may be necessary for accessing certain directories—configure this in System Settings → Privacy & Security → Full Disk Access, adding your terminal or the MCP server executable. **TCC (Transparency, Consent, and Control)** on macOS Mojave+ requires explicit approval for inter-application events and file access.

The default shell on macOS Catalina (10.15) and later is **zsh** at `/bin/zsh`. Older systems use bash at `/bin/bash`. Always specify the shell explicitly in your subprocess calls rather than relying on defaults. For AppleScript integration, you can execute system-level automation:

```typescript
const { stdout } = await execAsync(`osascript -e 'display notification "AI Start Complete" with title "Cursor"'`);
```

**Security patterns** for production use include input sanitization (remove shell metacharacters), command allowlisting (only permit specific scripts), path validation (prevent directory traversal), timeout enforcement (prevent hung processes), and environment isolation (use `env -i` for clean environments). Never execute unsanitized user input or allow arbitrary command construction.

**Testing with MCP Inspector** streamlines development. This official tool provides a web interface for interactive testing:

```bash
# Test TypeScript server
npx @modelcontextprotocol/inspector node build/index.js

# Test Python server
npx @modelcontextprotocol/inspector uv run server.py

# With environment variables
PROJECT_ROOT=/path/to/project npx @modelcontextprotocol/inspector node build/index.js
```

The Inspector opens at localhost:5173, showing all registered tools, resources, and prompts. You can invoke tools with custom inputs, inspect request/response messages, and validate error handling—all without configuring Cursor. **Critical for debugging**: STDIO transport prohibits console.log() as it corrupts the protocol stream. Instead, write to log files:

```typescript
import fs from 'fs';
const log = (msg: string) => fs.appendFileSync('/tmp/mcp-debug.log', `${msg}\n`);
```

**Example repositories** provide production-ready templates. The official modelcontextprotocol/typescript-sdk includes example servers (SQLite, calculator, echo), modelcontextprotocol/python-sdk demonstrates weather APIs and database queries, and community templates like hypermodel-labs/mcp-server-template offer minimal boilerplate. For macOS-specific examples, joshrutkowski/applescript-mcp shows system control integration, steipete/macos-automator-mcp demonstrates AppleScript and JXA execution, and jxnl/python-apple-mcp integrates Contacts, Mail, Messages, and Calendar.

Development workflow follows a rapid iteration cycle: build the server (5-10 minutes for basic functionality), test with MCP Inspector (2-3 minutes per iteration), configure in Cursor's mcp.json (1 minute), restart Cursor to load the server (30 seconds), verify in Settings → MCP that server appears with green status, and test in Agent mode by asking the assistant to use your tool. Total time from zero to working custom MCP server: approximately one hour for first implementation, under 30 minutes for subsequent servers once familiar with the pattern.

## Recommended implementation approach

For a production workflow where typing "ai-start" triggers a local script, **combine custom slash commands with MCP shell execution**. This hybrid approach provides the best balance of usability, security, and maintainability.

**Step 1: Install MCP shell server (5 minutes)**
```bash
pip install mcp-shell-server

# Configure ~/.cursor/mcp.json
{
  "mcpServers": {
    "shell": {
      "command": "uvx",
      "args": ["mcp-shell-server"],
      "env": {
        "ALLOW_COMMANDS": "ls,pwd,./scripts/ai-start.sh"
      }
    }
  }
}
```

**Step 2: Create custom command (2 minutes)**

Create `.cursor/commands/ai-start.md`:
```markdown
# AI Start

Initialize the development environment by running the ai-start script.

Execute `./scripts/ai-start.sh` from the project root and verify all services start successfully. Report the status of each component.
```

**Step 3: Create the actual script (variable time)**

Create `scripts/ai-start.sh`:
```bash
#!/bin/zsh
echo "Starting development environment..."
docker-compose up -d
npm run dev &
echo "Environment ready"
```

Then `chmod +x scripts/ai-start.sh`.

**Step 4: Usage**

Restart Cursor, open your project, enter Agent mode (Cmd+L), type `/ai-start`, and the agent executes your script through the MCP server. The workflow is conversational—you can ask "did it work?" or "fix any errors" and the agent continues from context.

**Alternative for simpler needs**: If you don't need MCP's security controls, use a hook that listens for specific prompt patterns:

```json
{
  "version": 1,
  "hooks": {
    "prompt": [
      {
        "command": "if [[ \"$PROMPT\" == *\"ai-start\"* ]]; then ./scripts/ai-start.sh; fi"
      }
    ]
  }
}
```

This executes immediately when you type messages containing "ai-start", but offers less control over execution context and error handling.

## Conclusion

Cursor IDE provides enterprise-grade capabilities for chat-triggered script execution through three complementary systems: custom slash commands for prompt templates, the hooks system for event-driven automation, and MCP servers for standardized tool integration. No traditional VS Code extensions enable this functionality—the capability is native to Cursor's architecture.

For macOS Tahoe users, **mcp-shell-server offers the optimal balance** of security (command whitelisting), ease of setup (pip install), and functionality (comprehensive output handling). Custom MCP development takes under an hour using official TypeScript or Python SDKs, with production-ready examples and testing tools available. The ecosystem continues expanding rapidly with new MCP servers, improved documentation, and growing community resources.

The key insight: treat Cursor's agent not as a chatbot but as a programmable automation engine. Well-designed commands, hooks, and MCP tools transform ad-hoc requests into repeatable workflows that execute with one phrase. This represents a fundamental shift in development environments—from passive editors to active collaborators that understand intent and execute accordingly.

---

## AccessiList Implementation Decision

**Based on this research, the AccessiList project implements a custom MCP workflow server** that combines the best aspects of all three approaches:

### Why a Custom Workflow Server?

1. **Better than slash commands**: Provides actual autonomous execution, not just prompt templates
2. **Better than hooks**: Type-safe, testable, and production-ready (hooks are beta)
3. **Better than YOLO mode**: Explicit workflow definitions provide safety and auditability
4. **Better than basic shell servers**: Workflow orchestration with error handling and chaining

### Implementation

See the following documents for the AccessiList-specific implementation:

- **[Agent Autonomy Workflow Server Architecture](../architecture/agent-autonomy-workflow-server.md)** - Technical design and MCP server implementation
- **[Workflow Automation Guide](WORKFLOW-AUTOMATION.md)** - Setup instructions and workflow creation

### AccessiList Workflows

The custom server enables workflows like:

- **`ai-start`**: Start PHP server, verify endpoints, check database connections
- **`ai-test`**: Run test suite, generate reports, verify accessibility compliance
- **`ai-deploy`**: Build assets, run validation, deploy to staging/production

These workflows execute autonomously without user approval while maintaining security through explicit workflow definitions.
