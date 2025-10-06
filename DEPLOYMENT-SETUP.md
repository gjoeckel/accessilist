# 🚀 GitHub Actions + Cursor IDE Deployment Setup

## Overview
This guide sets up automated deployment to production using GitHub Actions, integrated with Cursor IDE for seamless AI-assisted development workflows.

## 🔧 **Setup Steps**

### 1. **Configure GitHub Secrets**
Navigate to your repository: `https://github.com/gjoeckel/accessilist/settings/secrets/actions`

Add these secrets:
```
DEPLOY_SSH_KEY      # Private SSH key for server access
DEPLOY_USER         # SSH username (e.g., "user")
DEPLOY_HOST         # Server hostname/IP
DEPLOY_PATH         # Server path (e.g., "/var/www/html")
DEPLOY_URL          # Production URL (e.g., "https://webaim.org/training/online/accessilist")
```

### 2. **Generate SSH Key (if needed)**
```bash
# Generate new SSH key for deployment
ssh-keygen -t ed25519 -C "deploy@accessilist" -f ~/.ssh/deploy_key

# Add public key to server
ssh-copy-id -i ~/.ssh/deploy_key.pub user@your-server.com

# Add private key to GitHub secrets
cat ~/.ssh/deploy_key
```

### 3. **Test GitHub Actions**
```bash
# Test the workflow
gh workflow run deploy.yml

# Monitor workflow status
gh run list --workflow=deploy.yml
```

## 🎯 **Cursor IDE Integration**

### **Available Commands in Cursor**
- `npm run deploy:production` - Deploy to production
- `npm run deploy:preview` - Create deployment preview
- `npm run test:all` - Run all tests
- `npm run validate` - Validate MCP setup

### **GitHub Actions Triggers**
1. **Automatic**: Push to `main`/`master` branch
2. **Manual**: Use Cursor IDE terminal or GitHub UI
3. **Pull Request**: Runs tests only

### **Deployment Flow**
```
Code Push → Tests → Build → Deploy → Health Check → Notify
```

## 📋 **Workflow Features**

### **Testing Phase**
- ✅ Accessibility tests via Puppeteer
- ✅ Performance validation
- ✅ MCP server health checks
- ✅ Build verification

### **Deployment Phase**
- ✅ Automatic backup creation
- ✅ File synchronization via rsync
- ✅ Permission setting
- ✅ Health check validation
- ✅ Automatic rollback on failure

### **Integration Features**
- ✅ Cursor IDE command integration
- ✅ Manual deployment triggers
- ✅ Environment selection (production/staging)
- ✅ Emergency deployment options

## 🔍 **Monitoring & Debugging**

### **Check Deployment Status**
```bash
# View recent deployments
gh run list --workflow=deploy.yml --limit=5

# View specific deployment logs
gh run view <run-id> --log
```

### **Manual Deployment from Cursor**
```bash
# In Cursor IDE terminal
npm run deploy:production

# Or trigger via GitHub CLI
gh workflow run deploy.yml --field environment=production
```

### **Emergency Rollback**
```bash
# Automatic rollback on deployment failure
# Or manual rollback via server
ssh user@server "cd /var/www/html && ls -t *.backup.* | head -1 | xargs -I {} cp -r {}/* ."
```

## 🛡️ **Security Features**

- ✅ SSH key-based authentication
- ✅ Environment-specific secrets
- ✅ Automatic backup before deployment
- ✅ Rollback capability on failure
- ✅ Health check validation

## 📊 **Deployment Environments**

### **Production**
- URL: `https://webaim.org/training/online/accessilist`
- Trigger: Push to `main` branch
- Tests: Full test suite required

### **Staging** (Optional)
- URL: `https://staging.webaim.org/accessilist`
- Trigger: Manual workflow dispatch
- Tests: Simplified test suite

## 🚀 **Next Steps**

1. **Configure GitHub Secrets** (Required)
2. **Test deployment workflow** (Recommended)
3. **Set up staging environment** (Optional)
4. **Configure monitoring alerts** (Optional)

## 📞 **Support**

- **GitHub Actions**: Check workflow logs in repository
- **Cursor IDE**: Use integrated terminal for commands
- **MCP Integration**: Verify with `npm run test:mcp`

---

**Ready to deploy!** 🎉
