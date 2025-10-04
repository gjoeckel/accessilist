# 🔍 AccessiList Legacy Analysis & Rebuild Plan

**Date:** 2024-10-03  
**Status:** ✅ **ANALYSIS COMPLETE**  
**Source:** `/Users/a00288946/Desktop/accessilist-legacy`  
**Target:** Rebuild and deploy current version

---

## 📊 **Legacy Structure Analysis**

### **✅ Core Components Found**
- **PHP Backend**: Complete API and page structure
- **JavaScript Modules**: ES6 modules with state management
- **CSS Architecture**: Individual CSS files with PostCSS build pipeline
- **Build System**: npm-based with concat and minification
- **Testing Framework**: Comprehensive test suite
- **Deployment Ready**: Apache + PHP configuration

### **📁 Key Directories**
```
accessilist-legacy/
├── php/                    # Backend API and pages
│   ├── api/               # REST endpoints
│   ├── includes/          # Shared utilities
│   ├── home.php           # Main landing page
│   ├── mychecklist.php    # Checklist interface
│   ├── admin.php          # Admin panel
│   └── reports.php        # Reporting system
├── js/                     # ES6 modules
│   ├── main.js            # Entry point
│   ├── StateManager.js    # State management
│   ├── buildPrinciples.js # Content builder
│   └── [15 other modules]
├── css/                    # Individual CSS files
│   ├── modal.css          # Modal dialogs
│   ├── focus.css          # Focus states
│   ├── landing.css        # Home page
│   ├── admin.css          # Admin interface
│   └── [10 other files]
├── json/                   # Configuration data
├── images/                 # SVG icons and assets
└── tests/                  # Comprehensive test suite
```

---

## 🔧 **Build System Analysis**

### **✅ Package.json Configuration**
```json
{
  "name": "accessilist",
  "version": "1.0.0",
  "scripts": {
    "concat:css": "concat -o global.css css/modal.css css/focus.css css/landing.css css/admin.css css/form-elements.css css/table.css css/section.css css/status.css css/side-panel.css css/header.css css/base.css",
    "minify:css": "npx postcss global.css -o global.css",
    "build:css": "npm-run-all concat:css minify:css"
  },
  "devDependencies": {
    "concat": "^1.0.3",
    "cssnano": "^7.0.6",
    "npm-run-all": "^4.1.5",
    "postcss": "^8.5.3",
    "postcss-cli": "^11.0.1"
  }
}
```

### **🎯 CSS Build Pipeline**
1. **Concatenation**: Individual CSS files → `global.css`
2. **Minification**: PostCSS with cssnano
3. **Build Order**: Defined in `tests/config/build-order.json`
4. **Output**: Single minified `global.css` file

---

## 🚀 **Deployment Configuration**

### **✅ Apache + PHP Setup**
- **Target Path**: `/var/websites/webaim/htdocs/training/online/accessilist/`
- **DocumentRoot**: App root with `.htaccess` routing
- **Writable Paths**: `php/saves/` and `saves/` directories
- **Permissions**: 775 for saves, 644/755 for files/directories

### **🔧 Server Requirements**
- **Apache** with mod_rewrite, mod_headers, mod_alias
- **PHP 7.4+** (targets PHP 8.x)
- **Node.js 18+** for CSS build (optional)
- **SSH/SFTP** access for deployment

---

## 📋 **Current vs Legacy Comparison**

### **✅ What's Already Updated**
- **MCP Integration**: Current version has full MCP autonomy setup
- **Documentation**: Enhanced with AI autonomy features
- **Scripts**: Updated with MCP tool integration
- **Configuration**: Modern MCP server configuration

### **🔄 What Needs Rebuilding**
- **CSS Build Pipeline**: Legacy has PostCSS build system
- **Package.json**: Legacy has proper build scripts
- **Global CSS**: Legacy has concatenated/minified CSS
- **Deployment Scripts**: Legacy has deployment configuration

---

## 🎯 **Rebuild Plan**

### **Phase 1: CSS Build System** ⚡
1. **Copy Package.json**: Restore build scripts from legacy
2. **Install Dependencies**: `npm install` for PostCSS tools
3. **Build CSS**: Run `npm run build:css` to create `global.css`
4. **Verify Output**: Ensure all styles are properly concatenated

### **Phase 2: File Structure Sync** 📁
1. **Compare PHP Files**: Ensure current PHP matches legacy functionality
2. **JavaScript Modules**: Verify all ES6 modules are present
3. **CSS Files**: Ensure all individual CSS files exist
4. **Configuration**: Sync json/ and config/ directories

### **Phase 3: Deployment Setup** 🚀
1. **Deployment Scripts**: Create deployment automation
2. **Server Configuration**: Set up Apache configuration
3. **Permissions**: Configure writable directories
4. **Health Checks**: Implement deployment verification

### **Phase 4: Testing & Validation** ✅
1. **Local Testing**: Verify build process works
2. **Server Testing**: Test deployment on target server
3. **Functionality**: Ensure all features work correctly
4. **Performance**: Validate CSS minification and loading

---

## 🛠 **Immediate Actions Required**

### **1. Restore Build System**
```bash
# Copy package.json from legacy
cp /Users/a00288946/Desktop/accessilist-legacy/package.json ./package.json

# Install dependencies
npm install

# Build CSS
npm run build:css
```

### **2. Sync Critical Files**
- Copy any missing CSS files from legacy
- Ensure JavaScript modules are complete
- Verify PHP API endpoints match legacy

### **3. Create Deployment Script**
- Automated deployment to target server
- Permission configuration
- Health check validation

---

## 📊 **Success Metrics**

| Component | Legacy Status | Current Status | Action Required |
|-----------|---------------|----------------|-----------------|
| **CSS Build** | ✅ PostCSS Pipeline | ❌ Individual Files | 🔄 Restore Build System |
| **Package.json** | ✅ Build Scripts | ❌ Missing Scripts | 🔄 Copy from Legacy |
| **Global CSS** | ✅ Minified | ❌ Not Generated | 🔄 Run Build Process |
| **PHP Backend** | ✅ Complete | ✅ Complete | ✅ No Action |
| **JavaScript** | ✅ ES6 Modules | ✅ ES6 Modules | ✅ No Action |
| **Deployment** | ✅ Configured | ❌ Not Set Up | 🔄 Create Scripts |

---

## 🎉 **Next Steps**

1. **Immediate**: Restore CSS build system from legacy
2. **Short-term**: Sync any missing files and configurations
3. **Medium-term**: Create automated deployment pipeline
4. **Long-term**: Deploy to production server

**The legacy version provides a complete, production-ready foundation that can be quickly rebuilt and deployed!** 🚀