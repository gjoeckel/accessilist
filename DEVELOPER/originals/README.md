# AccessiList Puppeteer Test Suite

Comprehensive end-to-end testing suite for AccessiList using Playwright/Puppeteer with real browser automation.

## 🎯 **Test Coverage**

### **Critical Path Tests** (`critical-path-tests.js`)
- ✅ Home to Checklist Journey
- ✅ Checklist Item Interactions
- ✅ Save and Restore Functionality
- ✅ Report Generation
- ✅ Admin Management
- ✅ API Health Check

### **Checklist Functionality Tests** (`checklist-functionality-tests.js`)
- ✅ All Checklist Types (Word, Excel, PowerPoint, Slides, Docs, Camtasia, Dojo)
- ✅ Item Click Interactions
- ✅ Status Button Functionality
- ✅ Notes Input/Output
- ✅ Add Row Functionality
- ✅ Save/Restore Operations
- ✅ Navigation Testing

### **API Integration Tests** (`api-integration-tests.js`)
- ✅ Health Check Endpoint
- ✅ List All Checklists
- ✅ Instantiate New Checklist
- ✅ Save Checklist Data
- ✅ Restore Saved Data
- ✅ Delete Checklist
- ✅ Error Handling & Validation
- ✅ Performance Testing

### **Frontend Tests** (`frontend_tests.js`)
- ✅ Form Submissions
- ✅ Dynamic Content Updates
- ✅ Responsive Design (Mobile, Tablet, Desktop)
- ✅ JavaScript Functionality

### **Accessibility Tests** (`accessibility_tests.js`)
- ✅ WCAG 2.1 AA Compliance
- ✅ Keyboard Navigation
- ✅ Color Contrast
- ✅ Screen Reader Compatibility
- ✅ Motion and Animation
- ✅ Error Handling and Feedback

### **Performance Tests** (`performance_tests.js`)
- ✅ Core Web Vitals (LCP, FID, CLS)
- ✅ Page Load Performance
- ✅ Resource Optimization
- ✅ Mobile Performance

## 🚀 **Running Tests**

### **Run All Tests**
```bash
npm test
# or
npm run test:headless
```

### **Run Individual Test Suites**
```bash
npm run test:critical      # Critical path tests
npm run test:checklist     # Checklist functionality
npm run test:api          # API integration
npm run test:frontend     # Frontend tests
npm run test:accessibility # Accessibility tests
npm run test:performance  # Performance tests
```

### **Run with Visual Browser**
```bash
npm run test:headed
```

### **Run Specific Test File**
```bash
node tests/puppeteer/critical-path-tests.js
node tests/puppeteer/checklist-functionality-tests.js
node tests/puppeteer/api-integration-tests.js
```

## ⚙️ **Configuration**

### **Test Configuration** (`test-config.js`)
- Base URL: `http://localhost:8000`
- Browser settings (headless/headed, viewport, timeouts)
- Test data and checklist types
- API endpoints and page URLs
- CSS selectors for elements
- Performance thresholds

### **Environment Variables**
```bash
HEADLESS=true          # Run in headless mode (default)
HEADLESS=false         # Run with visible browser
SLOW_MO=100           # Slow down actions by 100ms
DEVTOOLS=true         # Open browser devtools
```

## 📊 **Test Reports**

### **Report Locations**
- `tests/reports/` - JSON test reports
- `tests/screenshots/` - Screenshots for visual verification
- `tests/reports/master-test-report.json` - Master test summary

### **Report Structure**
```json
{
  "timestamp": "2025-10-02T20:37:45.859Z",
  "testName": "critical-path-tests",
  "summary": {
    "total": 6,
    "passed": 5,
    "failed": 1,
    "successRate": "83.33%"
  },
  "results": [...],
  "screenshots": [...]
}
```

## 🔧 **Test Utilities** (`test-utils.js`)

### **Common Functions**
- `screenshot(name)` - Take and save screenshots
- `waitForElement(selector)` - Wait for elements to appear
- `navigateToPage(path)` - Navigate and wait for loading
- `clickAndWait(selector)` - Click and wait for results
- `apiCall(endpoint, method, data)` - Make API calls
- `assertElementVisible(selector)` - Assert element visibility
- `generateSessionKey()` - Create unique test session keys

### **Test Data Management**
- `createTestData(sessionKey, type)` - Generate test data
- `cleanupTestData(sessionKey)` - Clean up after tests
- `generateTestReport(name, results)` - Create test reports

## 🎭 **Real Browser Automation**

### **What Makes This Different**
- **Real DOM Interactions** - Actual clicks, typing, navigation
- **Real API Calls** - HTTP requests to actual endpoints
- **Real Screenshots** - Visual verification of UI state
- **Real Performance** - Actual timing measurements
- **Real Error Handling** - Genuine error scenarios

### **Browser Features Used**
- Page navigation and loading
- Element selection and interaction
- Form filling and submission
- Screenshot capture
- Network request interception
- JavaScript execution
- Viewport manipulation

## 🏗️ **Test Architecture**

### **Modular Design**
```
tests/puppeteer/
├── test-config.js           # Centralized configuration
├── test-utils.js            # Common utilities
├── critical-path-tests.js   # Critical user journeys
├── checklist-functionality-tests.js # Checklist features
├── api-integration-tests.js # API endpoints
├── frontend_tests.js        # Frontend functionality
├── accessibility_tests.js   # WCAG compliance
├── performance_tests.js     # Performance metrics
├── run-all-tests.js         # Master test runner
└── README.md               # This documentation
```

### **Test Flow**
1. **Setup** - Launch browser, create page, initialize utilities
2. **Execute** - Run test scenarios with real interactions
3. **Verify** - Assert expected outcomes and capture evidence
4. **Cleanup** - Close browser, clean test data, generate reports

## 🚨 **Error Handling**

### **Robust Error Management**
- Graceful cleanup on test failures
- Screenshot capture on errors
- Detailed error messages with context
- Test data cleanup even on failures
- Comprehensive error reporting

### **Common Issues & Solutions**
- **Server not running** - Ensure `php -S localhost:8000` is active
- **Element not found** - Check selectors in `test-config.js`
- **Timeout errors** - Adjust timeouts in configuration
- **API failures** - Verify server endpoints are working

## 🔄 **CI/CD Integration**

### **GitHub Actions Example**
```yaml
- name: Run Puppeteer Tests
  run: |
    php -S localhost:8000 -t . &
    npm test
    kill %1
```

### **Docker Integration**
```dockerfile
FROM node:18
RUN npx playwright install chromium
COPY . /app
WORKDIR /app
CMD ["npm", "test"]
```

## 📈 **Performance Benchmarks**

### **Expected Performance**
- **API Health Check**: < 1000ms
- **Page Load**: < 2000ms
- **Critical Path**: < 30000ms
- **Full Test Suite**: < 300000ms (5 minutes)

### **Core Web Vitals Targets**
- **LCP (Largest Contentful Paint)**: < 2500ms
- **FID (First Input Delay)**: < 100ms
- **CLS (Cumulative Layout Shift)**: < 0.1

## 🎯 **Best Practices**

### **Test Writing**
- Use descriptive test names
- Take screenshots at key points
- Clean up test data after each test
- Use realistic test data
- Test both success and failure scenarios

### **Maintenance**
- Keep selectors up to date
- Update test data when UI changes
- Monitor test performance
- Review and update thresholds
- Document new test scenarios

---

**Ready for production use with comprehensive coverage of all AccessiList functionality!** 🚀
