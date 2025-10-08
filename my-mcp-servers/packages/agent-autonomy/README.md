# Agent Autonomy Workflow Server

Execute predefined workflows with autonomous approval in Cursor IDE.

## Features

- **4 MCP Tools**: Workflow execution, listing, registration, and approval checking
- **Zero Tool Overhead**: Unlimited workflows, fixed 4-tool footprint
- **Security**: Explicit workflow definitions, version-controlled
- **Error Handling**: Configurable stop/continue/retry on errors
- **Observable**: Detailed execution logs and status reporting

## Installation

```bash
npm install -g mcp-agent-autonomy
```

## Configuration

Add to `~/.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "agent-autonomy": {
      "command": "npx",
      "args": ["-y", "mcp-agent-autonomy@1.0.1"],
      "env": {
        "WORKING_DIRECTORY": "/path/to/your/project"
      }
    }
  }
}
```

## Workflow Definition

Create `.cursor/workflows.json` in your project root:

```json
{
  "ai-start": {
    "description": "Start development server",
    "commands": [
      "git status",
      "php -S localhost:8000 -t . router.php > logs/server.log 2>&1 &",
      "sleep 2",
      "curl -s http://localhost:8000 && echo '✅ Server running'"
    ],
    "auto_approve": true,
    "working_directory": "/path/to/project",
    "timeout": 30000,
    "on_error": "stop"
  }
}
```

## Usage

In Cursor chat:
```
"Execute the ai-start workflow"
→ AI uses execute_workflow({ workflow_name: "ai-start" })
→ Commands run autonomously without approval
```

## Tools

### 1. execute_workflow

Execute a workflow by name.

**Input**: `{ workflow_name: string }`
**Output**: Execution results with stdout/stderr for each step

### 2. list_workflows

List all available workflows.

**Output**: Workflow names, descriptions, and command counts

### 3. register_workflow

Register a new workflow (future feature).

### 4. check_approval

Check if a command would be auto-approved (future feature).

## License

ISC

