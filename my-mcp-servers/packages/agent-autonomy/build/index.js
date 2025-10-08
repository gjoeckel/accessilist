#!/usr/bin/env node
"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
const index_js_1 = require("@modelcontextprotocol/sdk/server/index.js");
const stdio_js_1 = require("@modelcontextprotocol/sdk/server/stdio.js");
const types_js_1 = require("@modelcontextprotocol/sdk/types.js");
const child_process_1 = require("child_process");
const util_1 = require("util");
const fs = __importStar(require("fs/promises"));
const path = __importStar(require("path"));
const execAsync = (0, util_1.promisify)(child_process_1.exec);
class WorkflowEngine {
    constructor() {
        this.workflows = new Map();
        this.workingDirectory = process.env.WORKING_DIRECTORY || process.cwd();
    }
    async loadWorkflows() {
        const workflowPath = path.join(this.workingDirectory, '.cursor', 'workflows.json');
        try {
            const data = await fs.readFile(workflowPath, 'utf-8');
            const workflows = JSON.parse(data);
            for (const [name, workflow] of Object.entries(workflows)) {
                this.workflows.set(name, workflow);
            }
            console.error(`✅ Loaded ${this.workflows.size} workflows from ${workflowPath}`);
        }
        catch (error) {
            console.error(`⚠️  No workflows file found at ${workflowPath}`);
            // Create default workflow
            this.workflows.set('example', {
                description: 'Example workflow',
                commands: ['echo "No workflows configured"'],
                auto_approve: true,
                working_directory: this.workingDirectory,
                timeout: 10000,
                on_error: 'stop'
            });
        }
    }
    async executeWorkflow(name) {
        const workflow = this.workflows.get(name);
        if (!workflow) {
            throw new Error(`Workflow '${name}' not found. Available: ${Array.from(this.workflows.keys()).join(', ')}`);
        }
        const results = [];
        const startTime = Date.now();
        for (let i = 0; i < workflow.commands.length; i++) {
            const command = workflow.commands[i];
            const stepResult = await this.executeCommand(command, workflow, i + 1);
            results.push(stepResult);
            if (!stepResult.success && workflow.on_error === 'stop') {
                console.error(`❌ Workflow '${name}' stopped at step ${i + 1} due to error`);
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
    async executeCommand(command, workflow, stepNumber) {
        try {
            console.error(`[${stepNumber}/${workflow.commands.length}] Executing: ${command}`);
            const { stdout, stderr } = await execAsync(command, {
                cwd: workflow.working_directory,
                timeout: workflow.timeout,
                env: { ...process.env, ...workflow.environment }
            });
            return {
                step: stepNumber,
                command,
                success: true,
                stdout: stdout.trim(),
                stderr: stderr.trim()
            };
        }
        catch (error) {
            return {
                step: stepNumber,
                command,
                success: false,
                error: error.message
            };
        }
    }
    listWorkflows() {
        return Array.from(this.workflows.entries()).map(([name, workflow]) => ({
            name,
            command_count: workflow.commands.length,
            auto_approve: workflow.auto_approve,
            description: workflow.description
        }));
    }
}
const workflowEngine = new WorkflowEngine();
const server = new index_js_1.Server({
    name: 'agent-autonomy',
    version: '1.0.1',
}, {
    capabilities: {
        tools: {},
    },
});
// List tools handler
server.setRequestHandler(types_js_1.ListToolsRequestSchema, async () => {
    return {
        tools: [
            {
                name: 'execute_workflow',
                description: 'Execute a predefined workflow by name with autonomous approval',
                inputSchema: {
                    type: 'object',
                    properties: {
                        workflow_name: {
                            type: 'string',
                            description: 'Name of workflow to execute (e.g., "ai-start", "ai-test")',
                        },
                    },
                    required: ['workflow_name'],
                },
            },
            {
                name: 'list_workflows',
                description: 'List all available workflows',
                inputSchema: {
                    type: 'object',
                    properties: {},
                },
            },
            {
                name: 'register_workflow',
                description: 'Register a new workflow at runtime (persisted to .cursor/workflows.json)',
                inputSchema: {
                    type: 'object',
                    properties: {
                        name: {
                            type: 'string',
                            description: 'Unique workflow name',
                        },
                        commands: {
                            type: 'array',
                            items: { type: 'string' },
                            description: 'Commands to execute in sequence',
                        },
                        auto_approve: {
                            type: 'boolean',
                            description: 'Execute without user confirmation',
                        },
                        working_directory: {
                            type: 'string',
                            description: 'Directory to run commands in',
                        },
                    },
                    required: ['name', 'commands'],
                },
            },
            {
                name: 'check_approval',
                description: 'Check if a command would be auto-approved based on workflow patterns',
                inputSchema: {
                    type: 'object',
                    properties: {
                        command: {
                            type: 'string',
                            description: 'Command to check',
                        },
                    },
                    required: ['command'],
                },
            },
        ],
    };
});
// Call tool handler
server.setRequestHandler(types_js_1.CallToolRequestSchema, async (request) => {
    const { name, arguments: args } = request.params;
    try {
        switch (name) {
            case 'execute_workflow': {
                const { workflow_name } = args;
                const result = await workflowEngine.executeWorkflow(workflow_name);
                const output = [
                    `🚀 Executing workflow: ${workflow_name}`,
                    ``,
                    ...result.results.map(r => {
                        const status = r.success ? '✅' : '❌';
                        let output = `[${r.step}/${result.steps_total}] ${status} ${r.command}`;
                        if (r.stdout)
                            output += `\n   Output: ${r.stdout}`;
                        if (r.error)
                            output += `\n   Error: ${r.error}`;
                        return output;
                    }),
                    ``,
                    result.success
                        ? `✅ Workflow completed successfully in ${(result.duration_ms / 1000).toFixed(1)}s`
                        : `❌ Workflow failed after ${result.steps_executed}/${result.steps_total} steps`
                ].join('\n');
                return {
                    content: [
                        {
                            type: 'text',
                            text: output,
                        },
                    ],
                };
            }
            case 'list_workflows': {
                const workflows = workflowEngine.listWorkflows();
                const output = [
                    `📋 Available Workflows (${workflows.length}):`,
                    ``,
                    ...workflows.map(w => `• **${w.name}** - ${w.description}\n  Commands: ${w.command_count}, Auto-approve: ${w.auto_approve ? '✅' : '❌'}`)
                ].join('\n');
                return {
                    content: [
                        {
                            type: 'text',
                            text: output,
                        },
                    ],
                };
            }
            case 'register_workflow': {
                return {
                    content: [
                        {
                            type: 'text',
                            text: 'Workflow registration not yet implemented. Please edit .cursor/workflows.json directly.',
                        },
                    ],
                };
            }
            case 'check_approval': {
                const { command } = args;
                return {
                    content: [
                        {
                            type: 'text',
                            text: `Command "${command}" approval check not yet implemented.`,
                        },
                    ],
                };
            }
            default:
                throw new Error(`Unknown tool: ${name}`);
        }
    }
    catch (error) {
        return {
            content: [
                {
                    type: 'text',
                    text: `Error: ${error instanceof Error ? error.message : String(error)}`,
                },
            ],
            isError: true,
        };
    }
});
async function main() {
    await workflowEngine.loadWorkflows();
    const transport = new stdio_js_1.StdioServerTransport();
    await server.connect(transport);
    console.error('Agent Autonomy MCP Server running on stdio');
}
main().catch((error) => {
    console.error('Fatal error:', error);
    process.exit(1);
});
//# sourceMappingURL=index.js.map