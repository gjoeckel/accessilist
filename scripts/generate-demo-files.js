#!/usr/bin/env node

/**
 * Generate Demo Save Files
 * Creates realistic demo data for each checklist type with:
 * - 5% Completed tasks
 * - 70% In Progress tasks
 * - 25% Pending tasks
 * - 1 manual row per checkpoint
 */

const fs = require('fs');
const path = require('path');

// Demo file configuration
const DEMO_FILES = [
  { key: 'WRD', typeSlug: 'word', typeName: 'Word', taskCount: 25, checkpoints: 4 },
  { key: 'PPT', typeSlug: 'powerpoint', typeName: 'PowerPoint', taskCount: 26, checkpoints: 4 },
  { key: 'XLS', typeSlug: 'excel', typeName: 'Excel', taskCount: 28, checkpoints: 4 },
  { key: 'DOC', typeSlug: 'docs', typeName: 'Google Docs', taskCount: 24, checkpoints: 4 },
  { key: 'SLD', typeSlug: 'slides', typeName: 'Google Slides', taskCount: 25, checkpoints: 4 },
  { key: 'CAM', typeSlug: 'camtasia', typeName: 'Camtasia', taskCount: 11, checkpoints: 3 },
  { key: 'DJO', typeSlug: 'dojo', typeName: 'Dojo', taskCount: 19, checkpoints: 4 }
];

const PROJECT_DIR = path.resolve(__dirname, '..');
const SAVES_DIR = path.join(PROJECT_DIR, 'saves');
const JSON_DIR = path.join(PROJECT_DIR, 'json');

/**
 * Load JSON template to get task structure
 */
function loadTemplate(typeSlug) {
  const templatePath = path.join(JSON_DIR, `${typeSlug}.json`);
  const content = fs.readFileSync(templatePath, 'utf8');
  return JSON.parse(content);
}

/**
 * Get all task IDs from template
 */
function getTaskIds(template) {
  const taskIds = [];

  Object.keys(template).forEach(key => {
    if (key.startsWith('checkpoint-')) {
      const checkpoint = template[key];
      if (checkpoint.table && Array.isArray(checkpoint.table)) {
        checkpoint.table.forEach(task => {
          taskIds.push(task.id);
        });
      }
    }
  });

  return taskIds;
}

/**
 * Distribute statuses: 5% completed, 70% in-progress, 25% pending
 */
function distributeStatuses(taskIds) {
  const total = taskIds.length;
  const completedCount = Math.ceil(total * 0.05); // 5%
  const inProgressCount = Math.floor(total * 0.70); // 70%
  const pendingCount = total - completedCount - inProgressCount; // Remaining 25%

  console.log(`  Total tasks: ${total}`);
  console.log(`  Completed: ${completedCount} (${Math.round(completedCount/total*100)}%)`);
  console.log(`  In Progress: ${inProgressCount} (${Math.round(inProgressCount/total*100)}%)`);
  console.log(`  Pending: ${pendingCount} (${Math.round(pendingCount/total*100)}%)`);

  const statuses = {};

  // First N tasks = completed
  for (let i = 0; i < completedCount; i++) {
    statuses[taskIds[i]] = 'completed';
  }

  // Next N tasks = in-progress
  for (let i = completedCount; i < completedCount + inProgressCount; i++) {
    statuses[taskIds[i]] = 'in-progress';
  }

  // Remaining tasks = pending
  for (let i = completedCount + inProgressCount; i < total; i++) {
    statuses[taskIds[i]] = 'pending';
  }

  return statuses;
}

/**
 * Create demo save file for a checklist type
 */
function createDemoFile(config) {
  console.log(`\nCreating ${config.key}.json (${config.typeName})...`);

  // Load template
  const template = loadTemplate(config.typeSlug);
  const taskIds = getTaskIds(template);

  // Distribute statuses
  const statusDistribution = distributeStatuses(taskIds);

  // Build state object
  const state = {
    sidePanel: {
      expanded: true,
      activeSection: 'checkpoint-1'
    },
    notes: {},
    statusButtons: {},
    restartButtons: {},
    principleRows: {}
  };

  // Initialize checkpoint arrays
  for (let i = 1; i <= config.checkpoints; i++) {
    state.principleRows[`checklist-${i}`] = [];
  }

  // Add notes and status for each task
  taskIds.forEach(taskId => {
    const status = statusDistribution[taskId];
    const statusKey = `status-${taskId}`;
    const textareaKey = `textarea-${taskId}`;
    const restartKey = `restart-${taskId}`;

    // Set status
    state.statusButtons[statusKey] = status;

    // Set restart button (visible for completed tasks)
    state.restartButtons[restartKey] = (status === 'completed');

    // Add notes for completed and in-progress tasks
    if (status === 'completed') {
      state.notes[textareaKey] = `Completed task ${taskId} - all requirements met!`;
    } else if (status === 'in-progress') {
      state.notes[textareaKey] = `Working on task ${taskId}...`;
    } else {
      // Pending tasks have empty notes
      state.notes[textareaKey] = '';
    }
  });

  // Add manual row to each checkpoint
  for (let i = 1; i <= config.checkpoints; i++) {
    const checkpointKey = `checklist-${i}`;
    state.principleRows[checkpointKey].push({
      task: "Hey! I added this!",
      notes: "Great job!",
      status: "completed",
      timestamp: Date.now()
    });
  }

  // Create save file structure
  const saveFile = {
    sessionKey: config.key,
    timestamp: Date.now(),
    typeSlug: config.typeSlug,
    state: state,
    metadata: {
      version: '1.0',
      created: Date.now(),
      lastModified: Date.now()
    }
  };

  // Write file
  const filePath = path.join(SAVES_DIR, `${config.key}.json`);
  fs.writeFileSync(filePath, JSON.stringify(saveFile, null, 2), 'utf8');

  console.log(`  ✅ Created: ${config.key}.json`);
  console.log(`  Location: saves/${config.key}.json`);
}

/**
 * Main execution
 */
function main() {
  console.log('╔════════════════════════════════════════════════════════╗');
  console.log('║         Generating Demo Save Files                    ║');
  console.log('╚════════════════════════════════════════════════════════╝');
  console.log('');

  // Ensure saves directory exists
  if (!fs.existsSync(SAVES_DIR)) {
    fs.mkdirSync(SAVES_DIR, { recursive: true });
  }

  // Create each demo file
  DEMO_FILES.forEach(config => {
    createDemoFile(config);
  });

  console.log('');
  console.log('╔════════════════════════════════════════════════════════╗');
  console.log('║  ✅ ALL 7 DEMO FILES CREATED SUCCESSFULLY! ✅          ║');
  console.log('╚════════════════════════════════════════════════════════╝');
  console.log('');
  console.log('Demo files created:');
  DEMO_FILES.forEach(config => {
    console.log(`  • ${config.key}.json - ${config.typeName} (${config.taskCount} tasks)`);
  });
  console.log('');
  console.log('Next steps:');
  console.log('  1. Test locally: http://localhost:8000/training/online/accessilist/reports');
  console.log('  2. Upload to production: ./scripts/deployment/upload-demo-files.sh');
  console.log('');
}

// Run
main();

