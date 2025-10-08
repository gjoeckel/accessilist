# Agent Autonomy Workflow Server

> **Technical Architecture Document**
>
> **Project**: AccessiList - Accessibility Checklist Application
> **Purpose**: Enable autonomous AI agent workflows without user approval
> **Status**: Design Phase
> **Last Updated**: October 8, 2025

## Overview

The Agent Autonomy Workflow Server is a custom MCP (Model Context Protocol) server that enables predefined workflow execution with autonomous approval. This solves the "first command approval" problem in Cursor IDE by providing a structured, secure way to execute multi-step development workflows.

### Problem Statement

**Current State**: Terminal commands via `run_terminal_cmd` require user approval, breaking autonomous agent workflows.

**Research Finding**: Multiple approaches exist (slash commands, hooks, YOLO mode, shell MCP servers), but each has limitations:
- Slash commands: Prompt templates only, no true autonomy
- Hooks: Beta status, fragile, hard to debug
- YOLO mode: Too permissive, security concerns
- Basic shell servers: Still require per-command approval

**Solution**: Custom MCP workflow server with explicit workflow definitions that execute autonomously.

### Design Principles

1. **Security through Explicit Definition**: Workflows are predefined and version-controlled
2. **Autonomous Execution**: No user approval required for registered workflows
3. **Error Resilience**: Built-in error handling, retries, and rollback
4. **Observability**: Comprehensive logging and status reporting
5. **Composability**: Workflows can call other workflows

## Architecture

### System Components

```
┌─────────────────────────────────────────────────────────────┐
│                      Cursor IDE                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │           AI Agent (Claude)                         │   │
│  │  "Execute the ai-start workflow"                    │   │
│  └────────────────────┬────────────────────────────────┘   │
│                       │ MCP Protocol                        │
│                       ▼                                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │      Agent Autonomy Workflow Server (MCP)           │   │
│  │  ┌──────────────────────────────────────────────┐   │   │
│  │  │  Tool: execute_workflow                      │   │   │
│  │  │  Tool: register_workflow                     │   │   │
│  │  │  Tool: list_workflows                        │   │   │
│  │  │  Tool: check_approval                        │   │   │
│  │  └──────────────────────────────────────────────┘   │   │
│  │                                                      │   │
│  │  ┌──────────────────────────────────────────────┐   │   │
│  │  │  Workflow Engine                             │   │   │
│  │  │  - Load workflows from .cursor/workflows.json│   │   │
│  │  │  - Execute command sequences                 │   │   │
│  │  │  - Handle errors & retries                   │   │   │
│  │  │  - Report status                             │   │   │
│  │  └──────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                       │
                       │ Shell Execution
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                  macOS System (zsh)                         │
│  - Start PHP server                                         │
│  - Run git commands                                         │
│  - Execute test suites                                      │
│  - Deploy applications                                      │
└─────────────────────────────────────────────────────────────┘
```

### MCP Server Implementation

**Language**: TypeScript
**Runtime**: Node.js 18+
**Transport**: stdio (standard input/output)
**Protocol**: MCP 1.0

**Package Structure**:
```
my-mcp-servers/packages/agent-autonomy/
├── src/
│   ├── index.ts              # MCP server entry point
│   ├── workflow-engine.ts    # Workflow execution logic
│   ├── types.ts              # TypeScript interfaces
│   └── utils.ts              # Helper functions
├── package.json
├── tsconfig.json
└── README.md
```

## MCP Tools Specification

### Tool 1: `execute_workflow`

Execute a predefined workflow by name with autonomous approval.

**Input Schema**:
```typescript
{
  workflow_name: string;  // Name of workflow to execute (e.g., "ai-start")
}
```

**Output**:
```typescript
{
  success: boolean;
  workflow: string;
  steps_executed: number;
  steps_total: number;
  results: Array<{
    step: number;
    command: string;
    success: boolean;
    stdout?: string;
    stderr?: string;
    error?: string;
  }>;
  duration_ms: number;
}
```

**Example Usage**:
```
AI Agent: "Execute the ai-start workflow"
→ MCP call: execute_workflow({ workflow_name: "ai-start" })
→ Executes all commands in ai-start workflow
→ Returns status for each step
```

### Tool 2: `register_workflow`

Register a new workflow at runtime (persisted to `.cursor/workflows.json`).

**Input Schema**:
```typescript
{
  name: string;
  commands: string[];
  auto_approve: boolean;
  working_directory: string;
  timeout?: number;
  on_error?: "continue" | "stop" | "retry";
  environment?: Record<string, string>;
}
```

### Tool 3: `list_workflows`

List all available workflows.

**Output**:
```typescript
{
  workflows: Array<{
    name: string;
    command_count: number;
    auto_approve: boolean;
    description?: string;
  }>;
}
```

### Tool 4: `check_approval`

Check if a command would be auto-approved based on workflow patterns.

**Input Schema**:
```typescript
{
  command: string;
}
```

**Output**:
```typescript
{
  approved: boolean;
  reason: string;
  matching_workflow?: string;
}
```

## Workflow Configuration

### Workflow Definition Schema

Workflows are defined in `.cursor/workflows.json` at the project root:

```typescript
interface Workflow {
  name: string;                    // Unique workflow identifier
  description?: string;            // Human-readable description
  commands: string[];              // Commands to execute in sequence
  auto_approve: boolean;           // Execute without user confirmation
  working_directory: string;       // Directory to run commands in
  timeout: number;                 // Timeout per command (milliseconds)
  on_error: "continue" | "stop" | "retry";  // Error handling strategy
  environment?: Record<string, string>;      // Additional env variables
}
```

### AccessiList Workflow Definitions

#### Workflow: `ai-start`

Start the AccessiList development environment.

```json
{
  "ai-start": {
    "description": "Start AccessiList development server",
    "commands": [
      "git status",
      "php -S localhost:8000 -t . router.php > logs/php-server.log 2>&1 &",
      "sleep 2",
      "curl -s http://localhost:8000/php/home.php -o /dev/null && echo '✅ Server running' || echo '❌ Server failed'"
    ],
    "auto_approve": true,
    "working_directory": "/Users/a00288946/Desktop/accessilist",
    "timeout": 30000,
    "on_error": "stop"
  }
}
```

#### Workflow: `ai-test`

Run AccessiList test suite and generate reports.

```json
{
  "ai-test": {
    "description": "Run AccessiList test suite",
    "commands": [
      "php tests/run_comprehensive_tests.php",
      "echo 'Test results available in tests/reports/'"
    ],
    "auto_approve": true,
    "working_directory": "/Users/a00288946/Desktop/accessilist",
    "timeout": 120000,
    "on_error": "continue"
  }
}
```

#### Workflow: `ai-deploy`

Build and deploy AccessiList (requires validation).

```json
{
  "ai-deploy": {
    "description": "Deploy AccessiList to production",
    "commands": [
      "npm run build",
      "php tests/run_comprehensive_tests.php",
      "git push origin main"
    ],
    "auto_approve": false,  // Requires user approval for deploy
    "working_directory": "/Users/a00288946/Desktop/accessilist",
    "timeout": 300000,
    "on_error": "stop"
  }
}
```

## Implementation Details

### Workflow Engine Core Logic

```typescript
class WorkflowEngine {
  private workflows: Map<string, Workflow> = new Map();

  async loadWorkflows(): Promise<void> {
    const workflowPath = path.join(
      process.env.WORKING_DIRECTORY || process.cwd(),
      '.cursor',
      'workflows.json'
    );

    const data = await fs.readFile(workflowPath, 'utf-8');
    const workflows = JSON.parse(data);

    for (const [name, workflow] of Object.entries(workflows)) {
      this.workflows.set(name, workflow as Workflow);
    }
  }

  async executeWorkflow(name: string): Promise<WorkflowResult> {
    const workflow = this.workflows.get(name);
    if (!workflow) {
      throw new Error(`Workflow '${name}' not found`);
    }

    const results: StepResult[] = [];
    const startTime = Date.now();

    for (let i = 0; i < workflow.commands.length; i++) {
      const command = workflow.commands[i];
      const stepResult = await this.executeCommand(command, workflow);
      results.push(stepResult);

      if (!stepResult.success && workflow.on_error === 'stop') {
        break;
      }
    }

    return {
      success: results.every(r => r.success),
      workflow: name,
      steps_executed: results.length,
      steps_total: workflow.commands.length,
      results,
      duration_ms: Date.now() - startTime
    };
  }

  private async executeCommand(
    command: string,
    workflow: Workflow
  ): Promise<StepResult> {
    try {
      const { stdout, stderr } = await execAsync(command, {
        cwd: workflow.working_directory,
        timeout: workflow.timeout,
        env: { ...process.env, ...workflow.environment }
      });

      return {
        step: i + 1,
        command,
        success: true,
        stdout,
        stderr
      };
    } catch (error) {
      return {
        step: i + 1,
        command,
        success: false,
        error: error.message
      };
    }
  }
}
```

## Security Considerations

### 1. Explicit Workflow Definitions

**Risk**: Arbitrary command execution
**Mitigation**: Only predefined workflows in `.cursor/workflows.json` can execute
**Enforcement**: Workflow engine validates workflow existence before execution

### 2. Command Whitelisting

**Risk**: Malicious commands in workflow definitions
**Mitigation**: Workflows are version-controlled and reviewed
**Best Practice**: Use Git hooks to validate workflow changes

### 3. Timeout Protection

**Risk**: Hung processes consuming resources
**Mitigation**: All commands have configurable timeouts (default 30s)
**Implementation**: `execAsync` with timeout parameter

### 4. Environment Isolation

**Risk**: Environment variable leakage
**Mitigation**: Explicit environment variable passing only
**Implementation**: No automatic environment inheritance

### 5. Error Boundary

**Risk**: Cascade failures
**Mitigation**: Configurable error handling (stop/continue/retry)
**Implementation**: Workflow engine respects `on_error` setting

### 6. Audit Logging

**Risk**: Untracked workflow executions
**Mitigation**: All executions logged with timestamps and results
**Implementation**: Structured logs to `logs/workflow-audit.log`

## Deployment

### MCP Configuration

Add to `~/.cursor/mcp.json`:

```json
{
  "mcpServers": {
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

### Package Publishing

The `agent-autonomy` package is published to npm as:
- **Package Name**: `mcp-agent-autonomy`
- **Repository**: `https://github.com/gjoeckel/my-mcp-servers`
- **Directory**: `packages/agent-autonomy`

### Tool Count Impact

**Before**: 43 tools (over limit)
**Remove**: `sequential-thinking-minimal` (4 tools), `everything-minimal` (4 tools)
**Add**: `agent-autonomy` (4 tools)
**Result**: 39 tools ✅

## Testing Strategy

### Unit Testing

Test individual workflow execution functions:

```bash
cd my-mcp-servers/packages/agent-autonomy
npm test
```

### Integration Testing with MCP Inspector

```bash
# Start MCP Inspector
npx @modelcontextprotocol/inspector npx mcp-agent-autonomy

# Test workflow execution
# 1. Open http://localhost:5173
# 2. Call execute_workflow with workflow_name: "ai-start"
# 3. Verify commands execute in sequence
# 4. Check output contains success status
```

### End-to-End Testing in Cursor

1. Install package: `npm install -g mcp-agent-autonomy`
2. Configure in `~/.cursor/mcp.json`
3. Restart Cursor IDE
4. In Agent mode, type: "Execute the ai-start workflow"
5. Verify workflow runs without approval prompt
6. Check `logs/workflow-audit.log` for execution record

## Performance Considerations

### Workflow Caching

- Workflows loaded once on server startup
- Reload triggered when `.cursor/workflows.json` changes
- File system watcher for hot-reload capability

### Execution Optimization

- Commands execute sequentially (not parallel) for predictability
- `stdout`/`stderr` buffering to prevent memory issues
- Configurable timeouts prevent hung processes

### Resource Limits

- Max 10 simultaneous workflow executions
- Max 100 commands per workflow
- Max 10MB output per command

## Related Documentation

- **[Chat-Triggered Automation Research](../development/CHAT-TRIGGERED-AUTOMATION-RESEARCH.md)** - Foundational research for this implementation
- **[Workflow Automation Guide](../development/WORKFLOW-AUTOMATION.md)** - Practical setup and usage guide
- **[MCP Tool Strategy](../../my-mcp-servers/README.md)** - Overall MCP server architecture

## Implementation Checklist

- [ ] Create TypeScript package in `my-mcp-servers/packages/agent-autonomy/`
- [ ] Implement MCP server with 4 tools
- [ ] Build and test with MCP Inspector
- [ ] Publish to npm as `mcp-agent-autonomy`
- [ ] Update `~/.cursor/mcp.json` configuration
- [ ] Remove `sequential-thinking-minimal` and `everything-minimal`
- [ ] Create `.cursor/workflows.json` with `ai-start` workflow
- [ ] Test autonomous execution in Cursor IDE
- [ ] Verify 39 total tool count
- [ ] Document in changelog

## References

- **MCP Protocol**: https://modelcontextprotocol.io/
- **MCP TypeScript SDK**: https://github.com/modelcontextprotocol/typescript-sdk
- **Cursor IDE Documentation**: https://docs.cursor.com/
- **AccessiList Repository**: https://github.com/gjoeckel/my-mcp-servers

---

**Status**: Ready for implementation
**Next Steps**: Create package structure and implement MCP server


