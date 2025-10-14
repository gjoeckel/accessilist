# Deployment Process Optimization Proposal

**Date**: October 8, 2025
**Purpose**: Align deployment with new autonomous configuration and MCP tools

---

## Current Deployment Process Analysis

### **Current Method** (github-push-gate.sh)

**Workflow:**
```
1. Manual: ./scripts/github-push-gate.sh secure-push 'push to github'
2. Script validates token
3. Git push to GitHub
4. rsync deploy to AWS production server
5. Verify production site responds (200 OK)
```

**Strengths:**
- ✅ Security gate (requires token)
- ✅ Automated rsync deployment
- ✅ Health check verification
- ✅ Single command execution

**Weaknesses:**
- ❌ No pre-deployment testing
- ❌ No production-mirror validation
- ❌ No MCP tool integration
- ❌ No agent-autonomy workflow support
- ❌ Manual token entry required
- ❌ No automated rollback on failure
- ❌ Doesn't leverage new testing infrastructure

---

## Proposed Optimized Deployment Process

### **New Autonomous Deployment Workflow**

Leverages:
- ✅ New production-mirror testing (42 tests)
- ✅ Agent-autonomy MCP workflows
- ✅ YOLO mode for autonomous execution
- ✅ GitHub MCP tools for repository operations
- ✅ Existing push gate security

**Proposed Workflow:**
```
1. Pre-Deploy: Run production-mirror tests (42 tests)
   └─ If tests fail → STOP

2. Pre-Deploy: Verify git status clean
   └─ If uncommitted changes → Ask to commit or stash

3. Deploy: Push to GitHub (with security gate)
   └─ Requires token: "push to github"

4. Deploy: rsync to AWS production
   └─ With backup of production saves/

5. Post-Deploy: Health check production site
   └─ Test: /home, /reports, /php/api/health

6. Post-Deploy: Verify production paths
   └─ Curl check for correct base paths

7. Success: Log deployment
   └─ Update changelog with deployment timestamp
```

---

## Proposed New Scripts

### Script 1: `scripts/deploy-autonomous.sh`

**Purpose**: Single autonomous deployment command

```bash
#!/bin/bash
# Autonomous Deployment Script
# Integrates testing, push gate, and deployment in one flow

WORKFLOW:
1. Check git status (must be clean or committed)
2. Run production-mirror tests (./scripts/test-production-mirror.sh)
3. If tests pass → Continue
4. Execute push gate (./scripts/github-push-gate.sh secure-push 'push to github')
5. Verify production health
6. Update deployment log
```

**Benefits:**
- Single command deployment
- Automatic testing before deploy
- Integrated security gate
- Health verification
- Deployment logging

---

### Script 2: `scripts/pre-deploy-check.sh`

**Purpose**: Pre-flight validation

```bash
#!/bin/bash
# Pre-Deployment Validation

CHECKS:
1. Git status (committed/clean?)
2. Production-mirror tests (42 tests pass?)
3. .env configuration (production mode?)
4. Required files present?
5. MCP servers healthy?
```

**Benefits:**
- Catches issues before deployment
- Reduces deployment failures
- Clear go/no-go decision

---

### Script 3: `scripts/post-deploy-verify.sh`

**Purpose**: Production validation after deployment

```bash
#!/bin/bash
# Post-Deployment Verification

CHECKS:
1. Production site responds (200)
2. /home page loads
3. /reports page loads
4. /php/api/health returns OK
5. /php/api/list returns valid JSON
6. Base paths correct in HTML
7. JavaScript ENV configured
```

**Benefits:**
- Immediate deployment validation
- Quick rollback decision
- Confidence in live deployment

---

## Integration with MCP Agent-Autonomy

### Workflow Definition

Create `.cursor/workflows.json` entry:

```json
{
  "deploy-production": {
    "name": "Deploy to Production",
    "description": "Full deployment workflow with testing and validation",
    "commands": [
      "cd $WORKING_DIRECTORY",
      "./scripts/pre-deploy-check.sh",
      "./scripts/deploy-autonomous.sh",
      "./scripts/post-deploy-verify.sh"
    ],
    "working_directory": "/Users/a00288946/Desktop/accessilist",
    "timeout": 300,
    "auto_approve": false,
    "on_error": "stop"
  }
}
```

**Usage:**
```javascript
// AI agent can execute:
mcp_agent-autonomy_execute_workflow({ workflow_name: "deploy-production" })
```

**Benefits:**
- One command deployment from AI
- Automated testing + deploy + verify
- Requires manual approval (auto_approve: false)
- Stops on any error

---

## Proposed npm Scripts

Add to `package.json`:

```json
{
  "scripts": {
    "predeploy": "./scripts/pre-deploy-check.sh",
    "deploy": "./scripts/deploy-autonomous.sh",
    "postdeploy": "./scripts/post-deploy-verify.sh",
    "deploy:full": "npm run predeploy && npm run deploy && npm run postdeploy",
    "deploy:test": "./scripts/test-production-mirror.sh",
    "deploy:status": "./scripts/github-push-gate.sh status"
  }
}
```

**Usage:**
```bash
npm run deploy:full    # Complete deployment with all checks
npm run deploy:test    # Just run tests
npm run deploy:status  # Check push gate status
```

---

## Enhanced Security with MCP Tools

### Using GitHub MCP for Deployment

**Current**: Manual git push via terminal
**Proposed**: GitHub MCP tools for repository operations

```javascript
// Push using GitHub MCP (when available)
mcp_github-minimal_push_files({
  owner: "gjoeckel",
  repo: "accessilist",
  ref: "refs/heads/main",
  message: "Deploy: [description]"
})
```

**Benefits:**
- Integrated with MCP ecosystem
- Better error handling
- Consistent with autonomous workflows
- Logged via MCP tools

---

## Testing Integration

### Before Deployment
```bash
# Run production-mirror tests
./scripts/test-production-mirror.sh

Expected: 42/42 tests pass (100%)
If fails: STOP deployment, review failures
```

### After Deployment
```bash
# Verify production with subset of tests
# Test critical paths only (faster feedback)

Critical Tests (6):
1. /home responds (200)
2. /reports responds (200)
3. /php/api/health (200)
4. /php/api/list (200)
5. Base path correct in HTML
6. ENV config present
```

---

## Rollback Strategy

### Current
- Manual SSH to server
- Restore from backup

### Proposed Enhanced
```bash
#!/bin/bash
# scripts/rollback-production.sh

WORKFLOW:
1. Verify backup exists on production
2. Stop production (optional maintenance mode)
3. Restore files from backup
4. Restore saves/ directory
5. Health check
6. Verify rollback successful
```

**MCP Integration:**
```javascript
// Emergency rollback via agent-autonomy
mcp_agent-autonomy_execute_workflow({
  workflow_name: "rollback-production"
})
```

---

## Proposed File Structure

```
scripts/
├── deployment/
│   ├── deploy-autonomous.sh        # Main deployment script
│   ├── pre-deploy-check.sh        # Pre-flight validation
│   ├── post-deploy-verify.sh      # Production verification
│   ├── rollback-production.sh     # Emergency rollback
│   └── deployment-log.sh          # Deployment history tracking
├── github-push-gate.sh            # Keep existing (used by deploy-autonomous)
└── test-production-mirror.sh      # Keep existing (used in pre-deploy)
```

---

## Comparison: Current vs Proposed

| Aspect | Current | Proposed | Improvement |
|--------|---------|----------|-------------|
| **Pre-Deploy Testing** | None | 42 automated tests | ✅ 100% coverage |
| **Deployment Command** | Manual script | `npm run deploy:full` or workflow | ✅ Simpler |
| **Health Checks** | Basic curl | 6 critical tests | ✅ Comprehensive |
| **Rollback** | Manual | Automated script | ✅ Faster recovery |
| **MCP Integration** | None | Agent-autonomy workflows | ✅ Autonomous |
| **Security** | Token gate | Token gate + tests | ✅ Enhanced |
| **Logging** | Basic | Comprehensive + changelog | ✅ Better audit |
| **Error Handling** | Stop on error | Rollback on failure | ✅ Self-healing |

---

## Implementation Plan

### Phase 1: Core Scripts (Immediate)
1. Create `scripts/deployment/` directory
2. Create `pre-deploy-check.sh`
3. Create `deploy-autonomous.sh`
4. Create `post-deploy-verify.sh`
5. Add npm scripts to package.json

**Estimated Time**: 30-45 minutes
**Benefits**: Automated deployment with testing

### Phase 2: MCP Integration (Follow-up)
1. Create agent-autonomy workflow definition
2. Add rollback workflow
3. Integrate GitHub MCP tools
4. Add deployment logging workflow

**Estimated Time**: 20-30 minutes
**Benefits**: Full MCP integration, one-command deploy

### Phase 3: Enhanced Features (Optional)
1. Staging environment setup
2. Blue-green deployment
3. Automated changelog generation on deploy
4. Slack/email notifications

**Estimated Time**: 60+ minutes
**Benefits**: Enterprise-grade deployment

---

## Quick Start Implementation

### Minimal Viable Deployment (Phase 1)

**Step 1**: Create pre-deploy check
```bash
# scripts/deployment/pre-deploy-check.sh
- Check git status
- Run test-production-mirror.sh
- Exit 1 if tests fail
```

**Step 2**: Create deploy script
```bash
# scripts/deployment/deploy-autonomous.sh
- Call github-push-gate.sh with token
- Monitor deployment
- Return exit code
```

**Step 3**: Create post-deploy verify
```bash
# scripts/deployment/post-deploy-verify.sh
- Test 6 critical production URLs
- Verify response codes
- Check content
```

**Step 4**: Add npm script
```json
"deploy:full": "npm run predeploy && npm run deploy && npm run postdeploy"
```

**Result**: Full deployment in one command with comprehensive validation

---

## Recommendation

### Immediate Action (5-10 minutes)
✅ **Implement Phase 1** - Core deployment scripts

**Why:**
- Uses existing testing infrastructure (already working)
- Minimal code changes required
- Immediate value (safe deployments)
- Foundation for future enhancements

### After Manual Testing
✅ **Test new deployment flow** on current changes

**Why:**
- Validate the new process works
- Ensure production-mirror tests catch issues
- Confirm deployment succeeds

### Future Enhancement
✅ **Add Phase 2** when time permits

**Why:**
- Full MCP integration
- Agent-autonomy workflows
- One-command deployments via AI

---

## Approval Request

**Proceed with Phase 1 implementation?**

Will create:
1. `scripts/deployment/pre-deploy-check.sh` (~80 lines)
2. `scripts/deployment/deploy-autonomous.sh` (~120 lines)
3. `scripts/deployment/post-deploy-verify.sh` (~100 lines)
4. Update `package.json` scripts
5. Create deployment workflow documentation

**Estimated time**: 30 minutes
**Risk**: Low (uses existing scripts)
**Benefit**: Comprehensive automated deployment

**Awaiting approval to proceed...**

