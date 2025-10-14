#!/bin/bash

# SRD Development Environment Setup
# Simple, Reliable, DRY Development Focus

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🎯 Setting up SRD Development Environment${NC}"
echo -e "${BLUE}Simple, Reliable, DRY Development Focus${NC}"
echo ""

# Create SRD development directory structure
echo -e "${BLUE}📁 Creating SRD development structure...${NC}"
mkdir -p ~/Developer/srd-templates/{configs,scripts,examples}
mkdir -p ~/Developer/srd-templates/configs/{eslint,prettier,jest}
mkdir -p ~/Developer/srd-templates/scripts/{analysis,testing,quality}

echo -e "${GREEN}✅ SRD directory structure created${NC}"

# Copy SRD configuration files
echo -e "${BLUE}⚙️  Setting up SRD configuration files...${NC}"

# Copy ESLint config
cp /Users/a00288946/Desktop/template/.eslintrc.srd.js ~/Developer/srd-templates/configs/eslint/
echo -e "${GREEN}✅ ESLint SRD config copied${NC}"

# Copy Prettier config
cp /Users/a00288946/Desktop/template/.prettierrc.srd ~/Developer/srd-templates/configs/prettier/
echo -e "${GREEN}✅ Prettier SRD config copied${NC}"

# Copy Jest config
cp /Users/a00288946/Desktop/template/jest.config.srd.js ~/Developer/srd-templates/configs/jest/
echo -e "${GREEN}✅ Jest SRD config copied${NC}"

# Create SRD package.json template
echo -e "${BLUE}📦 Creating SRD package.json template...${NC}"
cat > ~/Developer/srd-templates/package.json.template << 'EOF'
{
  "name": "srd-project",
  "version": "1.0.0",
  "description": "Simple, Reliable, DRY Development Project",
  "main": "index.js",
  "scripts": {
    "lint": "eslint src/ --ext .js,.ts,.tsx",
    "lint:fix": "eslint src/ --ext .js,.ts,.tsx --fix",
    "format": "prettier --write src/",
    "format:check": "prettier --check src/",
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "analyze:complexity": "complexity-report src/",
    "analyze:duplicates": "jscpd src/ --min-lines 5 --min-tokens 50",
    "analyze:deps": "madge --circular src/",
    "analyze:bundle": "webpack-bundle-analyzer dist/static/js/*.js",
    "srd:check": "npm run lint && npm run format:check && npm run test && npm run analyze:complexity",
    "srd:analyze": "npm run analyze:complexity && npm run analyze:duplicates && npm run analyze:deps",
    "srd:setup": "npm run lint:fix && npm run format && npm run test"
  },
  "devDependencies": {
    "eslint": "^8.0.0",
    "prettier": "^3.0.0",
    "@typescript-eslint/parser": "^6.0.0",
    "@typescript-eslint/eslint-plugin": "^6.0.0",
    "eslint-plugin-simple-import-sort": "^10.0.0",
    "eslint-plugin-unused-imports": "^3.0.0",
    "jest": "^29.0.0",
    "@testing-library/jest-dom": "^6.0.0",
    "jscpd": "^3.0.0",
    "complexity-report": "^2.0.0",
    "madge": "^7.0.0"
  },
  "keywords": ["srd", "simple", "reliable", "dry", "development"],
  "author": "SRD Developer",
  "license": "MIT"
}
EOF

echo -e "${GREEN}✅ SRD package.json template created${NC}"

# Create SRD analysis scripts
echo -e "${BLUE}📊 Creating SRD analysis scripts...${NC}"

# Complexity analysis script
cat > ~/Developer/srd-templates/scripts/analysis/complexity-check.sh << 'EOF'
#!/bin/bash

echo "🔍 SRD Complexity Analysis"
echo "=========================="

# Check if complexity-report is available
if command -v complexity-report &> /dev/null; then
    echo "📊 Running complexity analysis..."
    complexity-report src/ --format json > complexity-report.json
    echo "✅ Complexity report generated: complexity-report.json"

    # Check for high complexity functions
    echo "⚠️  High complexity functions (>10):"
    grep -E '"complexity": [0-9]{2,}' complexity-report.json || echo "None found"
else
    echo "❌ complexity-report not installed. Run: npm install -g complexity-report"
fi
EOF

chmod +x ~/Developer/srd-templates/scripts/analysis/complexity-check.sh

# Duplication analysis script
cat > ~/Developer/srd-templates/scripts/analysis/duplication-check.sh << 'EOF'
#!/bin/bash

echo "🔍 SRD Duplication Analysis"
echo "==========================="

# Check if jscpd is available
if command -v jscpd &> /dev/null; then
    echo "📊 Running duplication analysis..."
    jscpd src/ --min-lines 5 --min-tokens 50 --reporters json > duplication-report.json
    echo "✅ Duplication report generated: duplication-report.json"

    # Check for high duplication
    echo "⚠️  Duplication summary:"
    grep -E '"percentage": [0-9]+' duplication-report.json || echo "No significant duplication found"
else
    echo "❌ jscpd not installed. Run: npm install -g jscpd"
fi
EOF

chmod +x ~/Developer/srd-templates/scripts/analysis/duplication-check.sh

# Dependency analysis script
cat > ~/Developer/srd-templates/scripts/analysis/dependency-check.sh << 'EOF'
#!/bin/bash

echo "🔍 SRD Dependency Analysis"
echo "=========================="

# Check if madge is available
if command -v madge &> /dev/null; then
    echo "📊 Running dependency analysis..."

    # Check for circular dependencies
    echo "🔄 Checking for circular dependencies..."
    madge --circular src/ || echo "No circular dependencies found"

    # Generate dependency graph
    echo "📈 Generating dependency graph..."
    madge --image dependency-graph.png src/
    echo "✅ Dependency graph generated: dependency-graph.png"
else
    echo "❌ madge not installed. Run: npm install -g madge"
fi
EOF

chmod +x ~/Developer/srd-templates/scripts/analysis/dependency-check.sh

# Master SRD analysis script
cat > ~/Developer/srd-templates/scripts/srd-analyze.sh << 'EOF'
#!/bin/bash

echo "🎯 SRD Complete Analysis"
echo "======================="
echo "Simple, Reliable, DRY Development Analysis"
echo ""

# Run all analysis scripts
echo "🔍 Running complexity analysis..."
~/Developer/srd-templates/scripts/analysis/complexity-check.sh

echo ""
echo "🔍 Running duplication analysis..."
~/Developer/srd-templates/scripts/analysis/duplication-check.sh

echo ""
echo "🔍 Running dependency analysis..."
~/Developer/srd-templates/scripts/analysis/dependency-check.sh

echo ""
echo "🎯 SRD Analysis Complete!"
echo "Check the generated reports for insights."
EOF

chmod +x ~/Developer/srd-templates/scripts/srd-analyze.sh

echo -e "${GREEN}✅ SRD analysis scripts created${NC}"

# Create SRD code review checklist
echo -e "${BLUE}📋 Creating SRD code review checklist...${NC}"
cat > ~/Developer/srd-templates/SRD-CODE-REVIEW.md << 'EOF'
# SRD Code Review Checklist
## Simple, Reliable, DRY Development

### 🎯 **Simple**
- [ ] Code is easy to understand at first glance
- [ ] Functions have single responsibility
- [ ] No unnecessary complexity or over-engineering
- [ ] Clear variable and function names
- [ ] Cyclomatic complexity < 10
- [ ] Function length < 50 lines
- [ ] Max 4 function parameters
- [ ] Max 4 nesting levels

### 🔒 **Reliable**
- [ ] All tests pass
- [ ] Error handling is present
- [ ] No console.log or debugger statements
- [ ] Type safety (if using TypeScript)
- [ ] No unused variables or imports
- [ ] Consistent code formatting
- [ ] No implicit type coercion
- [ ] Proper error boundaries

### 🔄 **DRY**
- [ ] No code duplication
- [ ] Reusable functions and components
- [ ] Shared utilities and constants
- [ ] Consistent patterns throughout codebase
- [ ] No duplicate imports
- [ ] Shared configuration files
- [ ] Common error handling patterns
- [ ] Reusable test utilities

### 📊 **Quality Metrics**
- [ ] Test coverage > 80%
- [ ] Code duplication < 5%
- [ ] No circular dependencies
- [ ] Bundle size optimized
- [ ] Performance benchmarks met
- [ ] Security vulnerabilities addressed
- [ ] Documentation updated
- [ ] Code follows team conventions

### 🚀 **Deployment Readiness**
- [ ] All SRD checks pass
- [ ] Production build successful
- [ ] Environment variables configured
- [ ] Monitoring and logging in place
- [ ] Error tracking configured
- [ ] Performance monitoring active
- [ ] Security headers configured
- [ ] Backup and recovery tested
EOF

echo -e "${GREEN}✅ SRD code review checklist created${NC}"

# Create SRD development guide
echo -e "${BLUE}📚 Creating SRD development guide...${NC}"
cat > ~/Developer/srd-templates/SRD-DEVELOPMENT-GUIDE.md << 'EOF'
# SRD Development Guide
## Simple, Reliable, DRY Development

### 🎯 **Core Principles**

#### **Simple**
- Write code that is easy to understand
- Avoid unnecessary complexity
- Use clear, descriptive names
- Keep functions small and focused
- Prefer composition over inheritance

#### **Reliable**
- Write comprehensive tests
- Handle errors gracefully
- Use type safety when possible
- Follow consistent patterns
- Monitor and log appropriately

#### **DRY (Don't Repeat Yourself)**
- Extract common functionality
- Use shared utilities and components
- Maintain consistent configurations
- Avoid code duplication
- Create reusable patterns

### 🛠️ **Development Workflow**

1. **Plan**: Define simple, clear requirements
2. **Design**: Create simple, reusable components
3. **Code**: Write simple, reliable, DRY code
4. **Test**: Ensure reliability through testing
5. **Review**: Check against SRD principles
6. **Refactor**: Improve simplicity and reusability
7. **Deploy**: Ensure reliable deployment

### 📊 **Quality Gates**

- **Linting**: ESLint with SRD rules
- **Formatting**: Prettier for consistency
- **Testing**: Jest with 80% coverage
- **Analysis**: Complexity and duplication checks
- **Review**: SRD checklist compliance

### 🎯 **Success Metrics**

- **Simplicity**: Low cyclomatic complexity
- **Reliability**: High test coverage, low error rates
- **DRY**: Low code duplication, high reusability
EOF

echo -e "${GREEN}✅ SRD development guide created${NC}"

# Final summary
echo ""
echo -e "${BLUE}🎉 SRD Development Environment Setup Complete!${NC}"
echo ""
echo -e "${GREEN}✅ What's been created:${NC}"
echo "   • SRD configuration files (ESLint, Prettier, Jest)"
echo "   • SRD analysis scripts (complexity, duplication, dependencies)"
echo "   • SRD package.json template"
echo "   • SRD code review checklist"
echo "   • SRD development guide"
echo ""
echo -e "${YELLOW}🚀 Next Steps:${NC}"
echo "   1. Use SRD templates for new projects"
echo "   2. Run SRD analysis: ~/Developer/srd-templates/scripts/srd-analyze.sh"
echo "   3. Follow SRD code review checklist"
echo "   4. Integrate SRD principles into your workflow"
echo ""
echo -e "${BLUE}💡 SRD Tools Available:${NC}"
echo "   • ESLint with SRD rules"
echo "   • Prettier for consistent formatting"
echo "   • Jest for reliable testing"
echo "   • Complexity analysis tools"
echo "   • Duplication detection"
echo "   • Dependency analysis"
echo ""
echo -e "${GREEN}🎯 Ready for SRD Development!${NC}"


