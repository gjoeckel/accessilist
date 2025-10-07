### AccessiList

An accessibility checklist app built with PHP and vanilla JavaScript (ES modules), using individual CSS files for maintainability. The project emphasizes MCP-first workflows and SRD principles: Simple, Reliable, DRY.

### Requirements

- PHP 8.x CLI
- Google Chrome (for Chrome MCP)
- Git Bash on Windows (mandatory for scripts)

### Quick Start

#### 1. Environment Setup

This project uses `.env` file for environment configuration (SRD approach):

```bash
# Copy environment template
cp .env.example .env

# .env will have APP_ENV=local by default
# No changes needed for local development
```

The `.env` file controls:
- Environment (local, production, staging)
- Base paths for assets and URLs
- API endpoint extensions
- Debug mode

See **[SRD-ENVIRONMENT-PROPOSAL.md](SRD-ENVIRONMENT-PROPOSAL.md)** for full details.

#### 2. Start Local Server (Git Bash)

**Option A: With Clean URL Support (Recommended)**
```bash
# Start with router.php for clean URL testing
php -S localhost:8000 router.php
```

**Option B: Standard PHP Server**
```bash
./tests/start_server.sh
```

**What's the Difference?**
- `router.php`: Supports clean URLs (`/home`, `/admin`) - **Recommended for testing**
- `start_server.sh`: Standard PHP server - Clean URLs won't work

#### 3. Minimal Verification (Constrained Agents)

- Prefer MCP tools. If Chrome MCP is available, navigate to `http://localhost:8000/index.php` and confirm it loads; optionally request a simple health URL if one is provided.
- Fallback: curl `http://localhost:8000/index.php` and expect HTTP 200.

#### 4. Docker (Recommended parity testing)

```bash
npm run docker:up           # start containerized Apache+PHP (port 8080)
npm run docker:logs         # tail logs
npm run docker:rebuild      # rebuild and restart
npm run docker:down         # stop and remove
```

Ports and config:

```7:16:docker-compose.yml
  web:
    ports:
      - "127.0.0.1:8080:80"
    command: >
      bash -lc "a2enmod rewrite && \
                sed -ri 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf && \
                apache2-foreground"
```

### Entrypoints and Pages

- `index.php` redirects to the main UI:

```1:3:index.php
<?php
header('Location: php/home.php');
exit;
```

- Primary pages: `php/home.php`, `php/mychecklist.php`, `php/admin.php`

### API Endpoints (PHP)

- `POST /php/api/save.php` – Save session data
- `GET /php/api/restore.php?sessionKey=XXX` – Restore session data
- `GET /php/api/list.php` – List saved sessions
- `POST /php/api/delete.php?sessionKey=XXX` – Delete saved data

Endpoints use shared helpers in `php/includes/api-utils.php` and typically return a standardized JSON envelope with a `data` field.

### JavaScript Modules

ES modules orchestrate UI behavior and checklist logic (imports from `main.js`):

```11:14:js/main.js
import { buildContent } from './buildPrinciples.js';
import { buildReportsSection } from './buildReport.js';
import { initializeAddRowButton } from './addRow.js';
```

Path utilities and configuration live in `js/path-utils.js` and `js/simple-path-config.js`.

### CSS Architecture

CSS is organized into individual files for maintainability and follows the Single Responsibility Principle:

- `css/modal.css` - Modal dialog styles
- `css/focus.css` - Focus and hover states
- `css/landing.css` - Home page and button styles
- `css/admin.css` - Admin interface styles
- `css/form-elements.css` - Form input and textarea styles
- `css/table.css` - Table and interactive element styles
- `css/section.css` - Section layout and theming
- `css/status.css` - Status messages and footer
- `css/side-panel.css` - Navigation panel styles
- `css/header.css` - Header and navigation buttons
- `css/base.css` - Base styles and CSS variables

All PHP files include these CSS files individually in the correct order for proper cascading.

### Testing (MCP-first)

- **Clean URL Testing (Recommended)**:
  - Start server with `php -S localhost:8000 router.php`
  - Test clean URLs: `http://localhost:8000/home`, `http://localhost:8000/admin`
  - `router.php` mimics Apache .htaccess for local testing

- Minimal (preferred default for constrained agents):
  - Start server with `./tests/start_server.sh`
  - Use Chrome MCP to navigate to base URL and perform a simple health check if available; otherwise verify HTTP 200 for `/index.php`

- Comprehensive (on demand):
  - `php tests/run_comprehensive_tests.php`
  - `php tests/chrome-mcp/run_chrome_mcp_tests.php`
  - Startup tokens: `./scripts/startup-runbook.sh [quick|new|full]`

### Configuration

- Default base URL is `http://localhost:8000`:

```7:11:tests/start_server.sh
# Configuration
PORT=8000
HOST=localhost
BASE_URL="http://${HOST}:${PORT}"
```

### Conventions

- Use Git Bash on Windows for all script execution
- Prefer MCP tools (Chrome DevTools, Filesystem, Memory, GitHub) for testing and operations
- Keep code SRD: Simple, Reliable, DRY

### Troubleshooting

- Ensure port 8000 is free before starting the server
- If ES modules fail to load (e.g., `Unexpected token 'export'`), confirm `<script type="module">` usage where applicable
- Verify Chrome remote debugging if using Chrome MCP
# Deployment exclusion test
# Test 1759867669
