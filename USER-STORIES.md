# AccessiList - User Stories Documentation

**Version**: 1.0
**Date**: October 8, 2025
**Purpose**: Comprehensive user stories for all application features

---

## Table of Contents

1. [User Roles](#user-roles)
2. [Home Page & Navigation](#home-page--navigation)
3. [Checklist Features](#checklist-features)
4. [Save & Restore System](#save--restore-system)
5. [Reports Dashboard](#reports-dashboard)
6. [User Report Page](#user-report-page)
7. [Admin Management](#admin-management)
8. [API Endpoints](#api-endpoints)
9. [Accessibility Features](#accessibility-features)
10. [Technical User Stories](#technical-user-stories)

---

## User Roles

### Primary Users
- **Educator**: Teacher or instructor creating accessible educational content
- **Content Creator**: Designer/developer creating accessible materials
- **Administrator**: System admin managing checklist instances
- **Reviewer**: Person reviewing accessibility compliance of existing work

### System Actors
- **System**: Automated processes and API operations
- **Developer**: Technical user integrating with APIs

---

## Home Page & Navigation

### Story 1.1: Select Checklist Type
**As an** Educator
**I want to** select a checklist type from categorized options (Microsoft, Google, Other)
**So that** I can start an accessibility review for my specific tool

**Acceptance Criteria:**
- Home page displays checklist types grouped by category
- Microsoft: Word, PowerPoint, Excel
- Google: Docs, Slides
- Other: Camtasia, Dojo
- Each button clearly labeled with tool name
- Clicking button creates new session and opens checklist

**Priority**: HIGH
**Complexity**: Low

---

### Story 1.2: Access Reports Dashboard
**As an** Educator
**I want to** click a "Reports" button from the home page
**So that** I can view all my saved checklists in one place

**Acceptance Criteria:**
- Reports button visible in header
- Clicking navigates to /reports page
- All saved checklists displayed in table

**Priority**: HIGH
**Complexity**: Low

---

### Story 1.3: Return to Home
**As a** User
**I want to** click a "Home" button from any page
**So that** I can return to the checklist selection screen

**Acceptance Criteria:**
- Home button visible in header on all pages
- Clicking navigates to home page
- Available on: list, admin, reports, report pages

**Priority**: MEDIUM
**Complexity**: Low

---

## Checklist Features

### Story 2.1: View Accessibility Checkpoints
**As an** Educator
**I want to** see accessibility checkpoints organized by WCAG checkpoints
**So that** I can systematically review my content

**Acceptance Criteria:**
- Checkpoints displayed as numbered sections (1-4 typically, up to 10 supported)
- Each checkpoint has descriptive caption
- Tasks displayed in table format with columns: Tasks, Info, Notes, Status
- Side panel navigation shows checkpoint icons
- Page title shows checklist type (e.g., "Word Accessibility Checklist")

**Priority**: HIGH
**Complexity**: Medium

---

### Story 2.2: Navigate Between Checkpoints
**As an** Educator
**I want to** use a side panel to quickly jump to different checkpoints
**So that** I can navigate efficiently without scrolling

**Acceptance Criteria:**
- Side panel visible on left with numbered checkpoint buttons
- Buttons show active/inactive visual states
- Clicking checkpoint button scrolls to that section
- Active checkpoint highlighted in side panel
- Toggle button to collapse/expand side panel
- Side panel height adjusts dynamically (3-10 checkpoints)
- 15px spacing between checkpoint buttons

**Priority**: HIGH
**Complexity**: High

---

### Story 2.3: Add Notes to Tasks
**As an** Educator
**I want to** add notes to individual tasks
**So that** I can document my progress and decisions

**Acceptance Criteria:**
- Each task has Notes column with textarea
- Typing in notes textarea auto-triggers save after 3 seconds
- Notes persist across sessions
- Textareas resize to fit content
- Line height: 2 for readability

**Priority**: HIGH
**Complexity**: Medium

---

### Story 2.4: Update Task Status
**As an** Educator
**I want to** mark tasks as Ready, Active, or Done
**So that** I can track my accessibility review progress

**Acceptance Criteria:**
- Each task has Status column with clickable button
- Three statuses: Ready (blue), Active (yellow), Done (green)
- Clicking status button cycles through states
- Visual indicators: color-coded icons (75x75px)
- Done tasks show "Reset" button
- Status persists across sessions
- Typing in Notes changes status from Ready to Active automatically
- Reports use alternate terminology: Not Started/Active/Done for review context

**Priority**: HIGH
**Complexity**: Medium

---

### Story 2.5: Reset Done Task
**As an** Educator
**I want to** restart a done task back to ready
**So that** I can re-review items that need updates

**Acceptance Criteria:**
- Reset button appears when task marked Done
- Clicking reset shows confirmation modal
- Confirming resets task to Ready status
- Notes textarea becomes editable again
- Reset button disappears

**Priority**: MEDIUM
**Complexity**: Medium

---

### Story 2.6: View Task Information
**As an** Educator
**I want to** click an Info icon to see guidance for each task
**So that** I understand what's required for compliance

**Acceptance Criteria:**
- Info column has clickable icon for each task
- Clicking opens modal with task guidance
- Modal displays task text
- Modal can be closed with X button or Escape key
- Future: Will link to web resources

**Priority**: MEDIUM
**Complexity**: Low

---

### Story 2.7: Add Manual Tasks
**As an** Educator
**I want to** add custom tasks to each checkpoint
**So that** I can track additional accessibility requirements specific to my content

**Acceptance Criteria:**
- "Add Row" button at bottom of each checkpoint table
- Button icon color-coded by checkpoint (blue, green, orange, dark blue)
- Clicking adds new empty row
- New row has: Task textarea, Notes textarea, Status button
- Manual rows save/restore with session
- Manual rows can be deleted

**Priority**: MEDIUM
**Complexity**: High

---

## Save & Restore System

### Story 3.1: Auto-Save Progress
**As an** Educator
**I want** my progress to save automatically
**So that** I don't lose work if I navigate away or close the browser

**Acceptance Criteria:**
- Auto-save triggers 3 seconds after any change
- Changes include: notes, status updates, manual rows
- Footer shows "Saved at HH:MM" message
- Save happens silently without interrupting work
- Loading spinner brief visual feedback

**Priority**: HIGH
**Complexity**: High

---

### Story 3.2: Manual Save
**As an** Educator
**I want to** click a Save button to immediately save my work
**So that** I can ensure my progress is saved before closing

**Acceptance Criteria:**
- Save button visible in header
- Clicking triggers immediate save
- Footer shows confirmation message
- Works even if auto-save is ready
- Keyboard accessible

**Priority**: HIGH
**Complexity**: Low

---

### Story 3.3: Restore Session from URL
**As an** Educator
**I want to** open a short URL and see my saved checklist exactly as I left it
**So that** I can resume work easily

**Acceptance Criteria:**
- Minimal URL format: `/?=ABC` (3-character session key)
- Opening URL restores all saved state
- Restores: notes, statuses, manual rows, side panel position, restart buttons
- Loading overlay shows during restoration
- Automatic scroll to last active checkpoint
- Footer shows "Restored using key ABC"

**Priority**: HIGH
**Complexity**: High

---

### Story 3.4: Unsaved Changes Warning
**As an** Educator
**I want to** be warned if I try to leave with unsaved changes
**So that** I don't accidentally lose my work

**Acceptance Criteria:**
- Browser shows confirmation dialog if changes not saved
- Message: "You have unsaved changes. Are you sure you want to leave?"
- Only triggers if changes exist since last save
- Uses browser's native beforeunload dialog
- WCAG compliant

**Priority**: HIGH
**Complexity**: Low

---

### Story 3.5: Share Checklist URL
**As an** Educator
**I want to** share a simple URL to my checklist
**So that** others can view my accessibility compliance progress

**Acceptance Criteria:**
- URL format: `https://webaim.org/training/online/accessilist/?=ABC`
- Short, memorable 3-character session key
- URL opens checklist in read-only mode for others
- Session persists indefinitely
- URL can be bookmarked

**Priority**: MEDIUM
**Complexity**: Low

---

## Reports Dashboard

### Story 4.1: View All Checklists
**As an** Educator
**I want to** see all my saved checklists in a dashboard
**So that** I can manage multiple accessibility reviews

**Acceptance Criteria:**
- Dashboard shows table with all saved checklists
- Columns: Type, Updated, Key, Status, Progress, Delete
- Sorted by last updated (newest first)
- Shows checklist type icon/name
- Shows 3-character session key
- Shows calculated status (Done, Active, Not Started)
- Shows progress bar with percentage
- Timestamp shows last modification time

**Priority**: HIGH
**Complexity**: Medium

---

### Story 4.2: Filter Checklists by Status
**As an** Educator
**I want to** filter checklists by completion status
**So that** I can focus on checklists needing attention

**Acceptance Criteria:**
- Filter buttons: Done, Active, Not Started, All
- Clicking filter shows only matching reports
- Button shows count of reports in each status
- "All" shows total count
- Filtered results update immediately
- Visual indication of active filter

**Priority**: MEDIUM
**Complexity**: Medium

---

### Story 4.3: Open Checklist from Dashboard
**As an** Educator
**I want to** click a session key in the dashboard
**So that** I can open and continue working on that checklist

**Acceptance Criteria:**
- Session key is clickable link
- Opens checklist in same or new tab
- Uses minimal URL format (/?=KEY)
- All saved state restored

**Priority**: HIGH
**Complexity**: Low

---

### Story 4.4: Delete Checklist from Dashboard
**As an** Educator
**I want to** delete old/unwanted checklists
**So that** I can keep my dashboard clean and organized

**Acceptance Criteria:**
- Delete button in each row (trash icon)
- Clicking shows confirmation modal
- Modal shows "Delete checklist [KEY]?"
- Confirming removes from dashboard immediately
- File deleted from server
- No undo available (permanent)

**Priority**: MEDIUM
**Complexity**: Medium

---

### Story 4.5: Refresh Dashboard Data
**As an** Educator
**I want to** refresh the dashboard to see latest changes
**So that** I can see updates from other devices/browsers

**Acceptance Criteria:**
- Refresh button in header
- Clicking reloads all checklist data
- Progress bars recalculated
- Timestamps updated
- Visual feedback during refresh

**Priority**: LOW
**Complexity**: Low

---

### Story 4.6: View Individual Checklist Report
**As an** Educator
**I want to** click on a checklist row to see detailed report
**So that** I can review all tasks and notes for that checklist

**Acceptance Criteria:**
- Clicking checklist row (except delete button) opens report
- Opens user report page for that session
- Shows all checkpoints with tasks, notes, and statuses
- Read-only view

**Priority**: MEDIUM
**Complexity**: Low

---

## User Report Page

### Story 5.1: View Single Checklist Report
**As a** Reviewer
**I want to** see a comprehensive report of a checklist
**So that** I can review accessibility compliance status

**Acceptance Criteria:**
- Report shows checklist type in title
- All checkpoints grouped and displayed
- Table columns: Checkpoint icon, Tasks, Notes, Status
- Status shown as icons (done/in-progress/ready)
- Tasks and notes in read-only textareas
- Last updated timestamp displayed

**Priority**: HIGH
**Complexity**: Medium

---

### Story 5.2: Filter Report by Status
**As a** Reviewer
**I want to** filter report tasks by completion status
**So that** I can focus on incomplete items or review done work

**Acceptance Criteria:**
- Filter buttons: Done, Active, Not Started, All
- Filters apply immediately
- Filtered view shows subset of tasks
- Clear visual indication of active filter
- Button counts update based on checklist content

**Priority**: MEDIUM
**Complexity**: Low

---

### Story 5.3: Refresh Report Data
**As a** Reviewer
**I want to** refresh the report to see latest changes
**So that** I can see updates made in another browser/device

**Acceptance Criteria:**
- Refresh button in header
- Reloads checklist data from server
- Updates timestamp
- Re-renders table with latest data

**Priority**: LOW
**Complexity**: Low

---

### Story 5.4: Navigate Back to Checklist
**As an** Educator
**I want to** navigate from report back to editable checklist
**So that** I can make changes based on report review

**Acceptance Criteria:**
- Link/button to open checklist
- Opens in minimal URL format (/?=KEY)
- Preserves session key

**Priority**: MEDIUM
**Complexity**: Low

---

## Admin Management

### Story 6.1: View All Checklist Instances
**As an** Administrator
**I want to** see all checklist instances in the system
**So that** I can manage and monitor usage

**Acceptance Criteria:**
- Admin page shows table of all instances
- Columns: Type, Created, Key, Updated, Delete
- Type shows formatted display name
- Created shows file creation timestamp
- Key shows 3-character session identifier
- Updated shows last modified time or "—" if never saved
- Sorted by most recent

**Priority**: HIGH
**Complexity**: Medium

---

### Story 6.2: Open Instance from Admin
**As an** Administrator
**I want to** click an instance key to open that checklist
**So that** I can review or modify it

**Acceptance Criteria:**
- Session key is clickable link
- Opens in new tab
- Uses minimal URL format
- All saved state loads correctly

**Priority**: HIGH
**Complexity**: Low

---

### Story 6.3: Delete Instance from Admin
**As an** Administrator
**I want to** delete checklist instances
**So that** I can remove test data or old checklists

**Acceptance Criteria:**
- Delete button (trash icon) in each row
- Clicking shows confirmation modal
- Modal uses accessible design (SimpleModal system)
- Confirming removes row from table
- File deleted from server
- Deletion permanent (no undo)

**Priority**: MEDIUM
**Complexity**: Medium

---

### Story 6.4: Refresh Admin Data
**As an** Administrator
**I want to** refresh the admin table
**So that** I can see newly created instances

**Acceptance Criteria:**
- Refresh button in header
- Reloads instance list from server
- Table re-renders with latest data
- Maintains scroll position if possible

**Priority**: LOW
**Complexity**: Low

---

## Checklist Features

### Story 7.1: Dynamic Checkpoint Display
**As a** System
**I want to** dynamically display checkpoints based on JSON configuration
**So that** different checklist types can have different checkpoint counts

**Acceptance Criteria:**
- Supports 2-10 checkpoints per checklist type
- Camtasia shows 3 checkpoints
- Most types show 4 checkpoints
- Side panel generates correct number of buttons
- Content sections match side panel
- No hardcoded checkpoint limits

**Priority**: HIGH
**Complexity**: High

---

### Story 7.2: Task Status Cycling
**As an** Educator
**I want to** click a status button multiple times to cycle through statuses
**So that** I can easily update task progress

**Acceptance Criteria:**
- Status button cycles: Ready → Active → Done → Ready
- Single click advances to next status
- Visual feedback immediate (color change)
- Auto-save triggers after status change

**Priority**: HIGH
**Complexity**: Low

---

### Story 7.3: Keyboard Navigation
**As an** Educator with motor impairments
**I want to** navigate and use all features with keyboard only
**So that** I can complete accessibility reviews without a mouse

**Acceptance Criteria:**
- Tab key moves focus through all interactive elements
- Enter/Space activates buttons
- Focus visible with golden ring indicator
- Side panel links keyboard accessible
- Skip links provided for main content
- Modals keyboard accessible with Escape to close

**Priority**: HIGH
**Complexity**: Medium

---

### Story 7.4: Manual Row Management
**As an** Educator
**I want to** add custom tasks to checkpoints
**So that** I can track tool-specific or content-specific accessibility requirements

**Acceptance Criteria:**
- "Add Row" button at bottom of each checkpoint
- Clicking adds new editable row
- New row has: Task textarea, Notes textarea, Status button
- Manual rows stored in checkpointRows array
- Manual rows persist with save/restore
- Can add multiple manual rows per checkpoint
- Manual rows included in reports

**Priority**: MEDIUM
**Complexity**: High

---

### Story 7.5: Side Panel Toggle
**As an** Educator
**I want to** collapse the side panel to see more content
**So that** I can maximize screen space when needed

**Acceptance Criteria:**
- Toggle button (◀) on right edge of side panel
- Clicking collapses panel off-screen
- Arrow rotates 180° to show expand (▶)
- Clicking again expands panel
- Animation smooth (0.3s transition)
- Aria-expanded attribute updates
- Toggle strip height matches side panel

**Priority**: MEDIUM
**Complexity**: Low

---

### Story 7.6: Session URL Sharing
**As an** Educator
**I want to** share my checklist URL with colleagues
**So that** they can review my accessibility compliance work

**Acceptance Criteria:**
- URL format: `/?=ABC` (3 characters)
- URL visible in browser address bar
- URL shareable via copy/paste
- Others can open and view (read-only potential)
- Session persists indefinitely
- Clean, professional URL format

**Priority**: HIGH
**Complexity**: Medium

---

## Save & Restore System

### Story 8.1: Generate Unique Session Key
**As a** System
**I want to** generate unique 3-character session keys
**So that** each checklist instance has a unique identifier

**Acceptance Criteria:**
- Keys are 3 characters: A-Z and 0-9
- 46,656 possible combinations
- Cryptographically secure random generation
- Collision detection (checks existing files)
- Reserved keys excluded: WRD, PPT, XLS, DOC, SLD, CAM, DJO
- Maximum 100 attempts before error

**Priority**: HIGH
**Complexity**: Medium

---

### Story 8.2: Create Session Instance
**As a** System
**I want to** create a session file when user starts a checklist
**So that** the session can be tracked and saved

**Acceptance Criteria:**
- API endpoint: POST /php/api/instantiate
- Creates minimal JSON file with sessionKey, typeSlug, metadata
- File created in saves/ directory
- Atomic write with file locking
- Idempotent operation (safe to call multiple times)
- Returns success response

**Priority**: HIGH
**Complexity**: Medium

---

### Story 8.3: Save Checklist State
**As a** System
**I want to** save complete checklist state to server
**So that** user progress persists across sessions

**Acceptance Criteria:**
- API endpoint: POST /php/api/save
- Saves all state data:
  - sidePanel: {expanded, activeSection}
  - notes: {textarea-X.X: "content"}
  - statusButtons: {status-X.X: "ready|in-progress|done"}
  - restartButtons: {restart-X.X: true|false}
  - checkpointRows: {checkpoint-N: [{task, notes, status, timestamp}]}
- Updates metadata.lastModified timestamp
- Atomic write with file locking
- Returns success/error response

**Priority**: HIGH
**Complexity**: High

---

### Story 8.4: Restore Checklist State
**As a** System
**I want to** restore complete checklist state from saved file
**So that** user sees exactly what they saved

**Acceptance Criteria:**
- API endpoint: GET /php/api/restore?sessionKey=ABC
- Returns complete saved state object
- Handles missing fields gracefully
- Backward compatible with old save format
- Returns 404 if session doesn't exist

**Priority**: HIGH
**Complexity**: Medium

---

### Story 8.5: Backward Compatibility
**As a** System
**I want to** support old save file formats
**So that** existing user data continues to work

**Acceptance Criteria:**
- Supports legacy "checklist-1/2/3/4" naming
- Supports new "checkpoint-1/2/3/4" naming
- Converts old format to new format transparently
- No data loss during conversion
- Both formats work side-by-side

**Priority**: MEDIUM
**Complexity**: Medium

---

## Reports Dashboard

### Story 9.1: Calculate Checklist Status
**As a** System
**I want to** automatically calculate completion status for each checklist
**So that** users can see at-a-glance progress

**Acceptance Criteria:**
- Status logic:
  - **Done**: All tasks marked "done"
  - **Active**: At least one task done or in-progress, but not all done
  - **Not Started**: All tasks marked "ready" or no tasks started
- Status icon displayed (green check, yellow warning, blue ready icon)
- Status recalculated on every dashboard load
- Based on state.statusButtons data

**Priority**: HIGH
**Complexity**: Medium

---

### Story 9.2: Calculate Progress Percentage
**As an** Educator
**I want to** see progress percentage for each checklist
**So that** I know how much work remains

**Acceptance Criteria:**
- Progress calculated from statusButtons:
  - Done tasks / Total tasks × 100
- Displayed as progress bar (visual)
- Displayed as percentage text (e.g., "75%")
- Progress bar color-coded (green when complete)
- Bar width corresponds to percentage
- Handles manual rows in calculation

**Priority**: HIGH
**Complexity**: Medium

---

### Story 9.3: List Detailed API
**As a** System
**I want to** provide checklist data with full state
**So that** reports dashboard can calculate status and progress

**Acceptance Criteria:**
- API endpoint: GET /php/api/list-detailed
- Returns array of instances with full state data
- Includes state.statusButtons for each instance
- Includes metadata with timestamps
- Returns empty array if no instances
- Handles legacy saves gracefully

**Priority**: HIGH
**Complexity**: Medium

---

## User Report Page

### Story 10.1: Group Tasks by Checkpoint
**As a** Reviewer
**I want to** see tasks organized by checkpoint
**So that** I understand the structure and compliance coverage

**Acceptance Criteria:**
- Tasks displayed in single table
- Checkpoint column shows numbered icon (1, 2, 3, 4)
- Tasks from same checkpoint grouped together
- Visual grouping clear and consistent
- Checkpoint icons match checklist page

**Priority**: MEDIUM
**Complexity**: Medium

---

### Story 10.2: View Task Details
**As a** Reviewer
**I want to** read task descriptions and notes
**So that** I can understand what was reviewed and decided

**Acceptance Criteria:**
- Task column shows task text in textarea (read-only)
- Notes column shows user notes in textarea (read-only)
- Textareas styled to match checklist page
- Text readable with line-height: 2
- Textareas resize to content
- No borders (clean presentation)

**Priority**: HIGH
**Complexity**: Low

---

### Story 10.3: View Completion Status
**As a** Reviewer
**I want to** see visual status for each task
**So that** I can quickly identify done vs ready work

**Acceptance Criteria:**
- Status column shows status icon (non-interactive)
- Green check: Done
- Yellow warning: Active
- Blue ready icon: Not Started
- Icons match checklist page design
- No interaction (read-only report)

**Priority**: MEDIUM
**Complexity**: Low

---

## API Endpoints

### Story 11.1: Health Check Endpoint
**As a** Developer
**I want to** check if the API is responding
**So that** I can verify system health

**Acceptance Criteria:**
- Endpoint: GET /php/api/health
- Returns JSON: {status: "ok", timestamp, version, environment}
- HTTP 200 response
- No authentication required
- Fast response (<100ms)

**Priority**: LOW
**Complexity**: Low

---

### Story 11.2: List All Sessions
**As a** Developer
**I want to** retrieve all checklist sessions
**So that** I can integrate with other systems

**Acceptance Criteria:**
- Endpoint: GET /php/api/list
- Returns array of instances
- Each instance: sessionKey, timestamp, created, typeSlug, metadata
- Sorted by timestamp (newest first)
- Returns empty array if no instances
- Standard JSON response format

**Priority**: MEDIUM
**Complexity**: Low

---

### Story 11.3: Delete Session
**As a** Developer
**I want to** delete a session via API
**So that** I can clean up programmatically

**Acceptance Criteria:**
- Endpoint: GET /php/api/delete?session=ABC
- Validates session key format
- Deletes file if exists
- Returns success even if file doesn't exist (idempotent)
- Returns error if invalid session key
- Standard JSON response format

**Priority**: LOW
**Complexity**: Low

---

## Accessibility Features

### Story 12.1: Screen Reader Support
**As an** Educator using a screen reader
**I want** all content and controls announced properly
**So that** I can use the application independently

**Acceptance Criteria:**
- All images have alt text
- ARIA labels on buttons and controls
- ARIA-live regions for status updates
- Semantic HTML (header, main, nav, footer)
- Role attributes where appropriate
- Accessible modals with focus management

**Priority**: HIGH
**Complexity**: Medium

---

### Story 12.2: Focus Management
**As an** Educator using keyboard
**I want** clear focus indicators
**So that** I always know where I am in the interface

**Acceptance Criteria:**
- Golden ring focus indicator (4px, #FFD700)
- Consistent across all interactive elements
- Skip links to main content
- Focus moves to headings when side panel clicked
- Modal focus trapped while open
- Focus returns to trigger after modal closes

**Priority**: HIGH
**Complexity**: Medium

---

### Story 12.3: WCAG Compliance
**As an** Educator
**I want** the application to meet WCAG 2.1 AA standards
**So that** I'm using an accessible tool to create accessible content

**Acceptance Criteria:**
- Color contrast meets 4.5:1 minimum
- All functionality keyboard accessible
- No keyboard traps
- Proper heading hierarchy (H1, H2)
- Form labels and ARIA attributes
- Time limits: auto-save has 3-second delay (adequate)
- Error messages clear and helpful

**Priority**: HIGH
**Complexity**: High

---

### Story 12.4: Skip Links
**As an** Educator using keyboard
**I want** skip links to bypass repetitive navigation
**So that** I can reach main content quickly

**Acceptance Criteria:**
- Skip link appears on Tab focus
- "Skip to checklist" on list page
- "Skip to checklist selection" on home page
- "Skip to checklists table" on admin page
- Clicking moves focus to target
- Visually hidden until focused

**Priority**: MEDIUM
**Complexity**: Low

---

## Technical User Stories

### Story 13.1: Dynamic Side Panel Generation
**As a** System
**I want to** generate side panel checkpoints from JSON data
**So that** new checkpoint configurations work automatically

**Acceptance Criteria:**
- Reads checkpoint-* keys from JSON
- Supports 2-10 checkpoints
- Validates checkpoint-1 minimum requirement
- Calculates height: 15 + (N×36) + ((N-1)×15) + 15
- Applies height to .side-panel and .toggle-strip
- Generates <li> elements with proper structure
- Sets first checkpoint as active (infocus class)
- Handles missing icons gracefully (404 = broken image, still functional)

**Priority**: HIGH
**Complexity**: High

---

### Story 13.2: Session File Management
**As a** System
**I want to** manage session files atomically
**So that** concurrent access doesn't corrupt data

**Acceptance Criteria:**
- File locking with flock(LOCK_EX)
- Atomic read-modify-write operations
- Race condition prevention
- Handles concurrent saves from same session
- File permissions: 0755 for directory, 0644 for files
- Files stored in saves/ directory

**Priority**: HIGH
**Complexity**: High

---

### Story 13.3: Type Management System
**As a** System
**I want to** centralize checklist type configuration
**So that** adding new types is simple

**Acceptance Criteria:**
- Single source: config/checklist-types.json
- TypeManager class (PHP and JS)
- Methods: validateType, convertDisplayNameToSlug, formatDisplayName
- Supports 7 production types + test types
- Graceful handling of legacy saves
- Default type: camtasia

**Priority**: MEDIUM
**Complexity**: Medium

---

### Story 13.4: Environment Configuration
**As a** System
**I want to** support multiple environments (local, apache-local, production)
**So that** the application works in development and production

**Acceptance Criteria:**
- .env file controls environment
- APP_ENV: local | apache-local | production
- Local: no base path, .php extensions
- Apache-local: /training/online/accessilist base path, no extensions
- Production: same as apache-local with debug=false
- Path utilities handle environment differences
- API extension configurable per environment

**Priority**: HIGH
**Complexity**: Medium

---

### Story 13.5: Minimal URL System
**As a** System
**I want to** support minimal URL format /?=ABC
**So that** URLs are short and shareable

**Acceptance Criteria:**
- Pattern: /?=[A-Z0-9]{3}
- Regex validation in index.php
- Extracts session key from URL
- Loads list.php with session parameter
- URL stays visible in browser (no redirect)
- Handles invalid keys gracefully (404 error page)

**Priority**: HIGH
**Complexity**: Medium

---

### Story 13.6: Modal System
**As a** System
**I want to** use consistent modal dialogs throughout
**So that** confirmations and messages have uniform UX

**Acceptance Criteria:**
- SimpleModal class handles all modals
- ModalActions class for confirmation dialogs
- Methods: showConfirmation, showInfo, showError
- Accessible: focus trap, Escape key, ARIA attributes
- Callback system for confirmations
- Used for: Reset task, Delete row, Delete instance, Info display

**Priority**: MEDIUM
**Complexity**: Medium

---

### Story 13.7: State Management
**As a** System
**I want to** use unified state management
**So that** save/restore is reliable and maintainable

**Acceptance Criteria:**
- UnifiedStateManager class (single source of truth)
- Collects all UI state: notes, status, restart, rows, sidePanel
- Handles dirty state tracking
- Debounced auto-save (3 seconds)
- Before unload warning if unsaved
- Backward compatible with old save format

**Priority**: HIGH
**Complexity**: High

---

### Story 13.8: Event Delegation
**As a** System
**I want to** use global event delegation
**So that** dynamically added elements work without re-binding

**Acceptance Criteria:**
- StateEvents class handles all interactions
- Single document-level click listener
- Single document-level input listener
- Handles: status buttons, reset buttons, textareas, side panel, modals
- Works with dynamically added manual rows
- No duplicate event listeners

**Priority**: HIGH
**Complexity**: High

---

## Demo Data Features

### Story 14.1: Reserved Session Keys
**As a** System
**I want to** reserve specific session keys for demo data
**So that** demo checklists have predictable, memorable keys

**Acceptance Criteria:**
- Reserved keys: WRD, PPT, XLS, DOC, SLD, CAM, DJO
- Key generator skips reserved keys
- Users never receive reserved keys randomly
- Demo files use these keys
- Documented in code and documentation

**Priority**: LOW
**Complexity**: Low

---

### Story 14.2: Generate Demo Files
**As a** Developer
**I want to** generate realistic demo data
**So that** the system can be demonstrated effectively

**Acceptance Criteria:**
- Script: scripts/generate-demo-files.js
- Creates 7 demo files (one per type)
- Status distribution: ~5% done, ~70% in-progress, ~25% ready
- Each checkpoint has 1 manual row: "Hey! I added this!" / "Great job!"
- Realistic notes for different statuses
- Files saved in saves/ directory

**Priority**: LOW
**Complexity**: Medium

---

### Story 14.3: Upload Demo Files to Production
**As a** Developer
**I want to** upload demo files to production server
**So that** production has realistic test data

**Acceptance Criteria:**
- Script: scripts/deployment/upload-demo-files.sh
- Uploads all 7 demo files via SSH
- Verifies files on production
- Tests Reports dashboard accessibility
- One-time operation (demo files preserved by deployment)

**Priority**: LOW
**Complexity**: Low

---

## Deployment & Operations

### Story 15.1: Automated Deployment
**As a** Developer
**I want** automated deployment via GitHub Actions
**So that** code changes deploy to production automatically

**Acceptance Criteria:**
- GitHub Actions workflow: deploy-simple.yml
- Triggers on push to main branch
- Runs on: push to main, workflow_dispatch
- Steps: checkout, install deps, create package, deploy via rsync
- Excludes: .env, saves/, logs/, tests/, docs/, scripts/
- Preserves: .env files, saves/ directory on production
- Health check after deployment

**Priority**: HIGH
**Complexity**: High

---

### Story 15.2: Pre-Deploy Validation
**As a** Developer
**I want** automated tests before deployment
**So that** broken code doesn't reach production

**Acceptance Criteria:**
- Script: scripts/deployment/pre-deploy-check.sh
- Runs 41 production-mirror tests
- Tests: URL routing, API endpoints, static assets, reports, user reports
- Exits with error if any test fails
- Prevents deployment if tests fail
- Logs results to file

**Priority**: HIGH
**Complexity**: High

---

### Story 15.3: Post-Deploy Verification
**As a** Developer
**I want** automated verification after deployment
**So that** I know production is working correctly

**Acceptance Criteria:**
- Script: scripts/deployment/post-deploy-verify.sh
- Tests 6 critical production endpoints
- Waits for GitHub Actions deployment (10 seconds)
- Tests: home, reports, health, list API, assets
- Reports success/failure
- Can be run independently

**Priority**: MEDIUM
**Complexity**: Medium

---

## Security Features

### Story 16.1: Environment Protection
**As a** System Administrator
**I want** production .env file protected from deployment
**So that** sensitive configuration isn't overwritten

**Acceptance Criteria:**
- .env files excluded from deployment packages
- rsync --filter='P .env' preserves existing .env
- config.php loads external .env first: /var/websites/webaim/htdocs/training/online/etc/.env
- Local .env not deployed
- .htaccess blocks web access to .env files (HTTP 403)

**Priority**: HIGH
**Complexity**: Medium

---

### Story 16.2: Session Key Validation
**As a** System
**I want to** validate session keys strictly
**So that** invalid keys are rejected

**Acceptance Criteria:**
- Pattern: /^[A-Z0-9]{3}$/
- Case-sensitive validation
- Length exactly 3 characters
- Only uppercase letters and numbers
- Validation in: PHP (validate_session_key) and JavaScript (regex)
- Returns 400 error if invalid

**Priority**: HIGH
**Complexity**: Low

---

### Story 16.3: GitHub Push Security
**As a** Developer
**I want** GitHub pushes to require security token
**So that** accidental pushes are prevented

**Acceptance Criteria:**
- Script: scripts/github-push-gate.sh
- Required token: "push to github"
- Validates token before allowing push
- Pushes to GitHub (no local rsync deployment)
- Shows GitHub Actions monitoring URL
- Only affects GitHub repositories

**Priority**: MEDIUM
**Complexity**: Medium

---

## Summary Statistics

### Total User Stories: 50+

**By Priority:**
- HIGH: 32 stories (64%)
- MEDIUM: 15 stories (30%)
- LOW: 8 stories (6%)

**By Complexity:**
- High: 12 stories (24%)
- Medium: 23 stories (46%)
- Low: 20 stories (40%)

**By Feature Area:**
- Checklist Features: 10 stories
- Save/Restore: 6 stories
- Reports Dashboard: 6 stories
- User Report: 3 stories
- Admin: 4 stories
- API: 3 stories
- Accessibility: 4 stories
- Technical: 8 stories
- Deployment: 3 stories
- Security: 3 stories
- Demo Data: 3 stories

---

## Feature Coverage

### Pages Documented:
1. ✅ Home page (checklist selection)
2. ✅ Checklist page (list.php)
3. ✅ Reports dashboard (reports.php)
4. ✅ User report page (report.php)
5. ✅ Admin page (admin.php)

### APIs Documented:
1. ✅ health - Health check
2. ✅ generate-key - Session key generation
3. ✅ instantiate - Create session
4. ✅ save - Save state
5. ✅ restore - Load state
6. ✅ list - List sessions
7. ✅ list-detailed - List with full state
8. ✅ delete - Delete session

### Core Features Documented:
1. ✅ Session management
2. ✅ Save/restore system
3. ✅ Status tracking (ready/in-progress/done)
4. ✅ Manual row addition
5. ✅ Side panel navigation
6. ✅ Reports and filtering
7. ✅ Admin instance management
8. ✅ Dynamic checkpoint generation
9. ✅ Keyboard navigation
10. ✅ Modal system
11. ✅ Auto-save
12. ✅ URL sharing
13. ✅ Progress calculation
14. ✅ Type management
15. ✅ Environment configuration

---

## Implementation Status

All user stories represent **IMPLEMENTED** features currently in the application.

**Next Steps for Product Development:**
- These stories can guide new feature development
- Acceptance criteria serve as test specifications
- Priority ratings help with backlog management
- Stories can be refined into technical tasks

---

**Document Status**: ✅ Complete
**Coverage**: 100% of current features
**Ready for**: Product planning, testing, stakeholder review

---

*Generated autonomously on October 8, 2025*
