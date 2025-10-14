# Event Handler Conflict Analysis Report

**Generated:** $(date -u '+%Y-%m-%d %H:%M:%S UTC')

## Executive Summary

This report identifies all event handlers in the JavaScript codebase and flags potential conflicts where multiple handlers may be attached to the same elements.

---

## Analysis Results


### Event Types Summary

- **click**: 14 handlers
- **keydown**: 4 handlers
- **input**: 2 handlers
- **resize**: 1 handlers
- **DOMContentLoaded**: 4 handlers
- **contentBuilt**: 3 handlers
- **beforeunload**: 2 handlers

---

## Detailed Event Handler Breakdown

### 1. Global Event Delegation (Potential Conflict Points)

Global event delegation catches events at the document/window level and can conflict with direct element listeners.

**Files with global delegation:**

- **StateEvents.js:35** - `    document.addEventListener('click', (e) => {`
- **StateEvents.js:76** - `    document.addEventListener('input', (e) => {`
- **StateEvents.js:461** - `  document.addEventListener('DOMContentLoaded', () => {`
- **StateManager.js:91** - `    document.addEventListener('contentBuilt', () => {`
- **StateManager.js:332** - `    document.addEventListener('contentBuilt', () => {`
- **StateManager.js:966** - `    window.addEventListener('beforeunload', (event) => {`
- **StateManager.js:1057** - `    document.addEventListener('input', (event) => {`
- **StateManager.js:1066** - `    document.addEventListener('click', (event) => {`
- **StateManager.js:1092** - `    window.addEventListener('beforeunload', (event) => {`
- **StateManager.js:1219** - `  document.addEventListener('DOMContentLoaded', () => {`
- **StatusManager.js:17** - `      document.addEventListener('DOMContentLoaded', () => this.initContainer());`
- **main.js:165** - `// document.addEventListener('DOMContentLoaded', () => {`
- **main.js:171** - `document.addEventListener('contentBuilt', () => {`
- **scroll.js:208** - `window.addEventListener('resize', () => {`
- **simple-modal.js:93** - `    document.addEventListener('keydown', this.escapeHandler);`

---

### 2. Direct Element Listeners (Potential Duplicates)

Direct element listeners can conflict with global delegation if both handle the same event on the same element.

**Common Patterns:**

- **.filter-button** - Found in direct listeners

---

### 3. HIGH RISK: Potential Conflict Analysis

