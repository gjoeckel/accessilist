#!/usr/bin/env node
/*
  AccessiList User Stories Generator (Token-Frugal, Non-Interactive)
  - Scans codebase statically with regex/FS, minimal runtime probes
  - Writes structured JSON reports and deterministically updates user-stories.md
  - No model calls; token-frugal by design
*/
"use strict";

const fs = require("fs");
const path = require("path");
const crypto = require("crypto");

const REPO_ROOT = path.resolve(__dirname, "..");
const REPORTS_DIR = path.join(REPO_ROOT, "tests", "reports");
const USER_STORIES_MD = path.join(REPO_ROOT, "user-stories.md");
const INVENTORY_JSON = path.join(REPORTS_DIR, "story_inventory.json");
const FEATURES_STATIC_JSON = path.join(REPORTS_DIR, "features_static.json");
const FEATURES_DYNAMIC_JSON = path.join(REPORTS_DIR, "features_dynamic.json");
const STORIES_GENERATED_JSON = path.join(REPORTS_DIR, "stories_generated.json");
const RUN_LOG = path.join(REPORTS_DIR, "stories_run.log");

function ensureDir(p) {
  fs.mkdirSync(p, { recursive: true });
}

function sha1(content) {
  return crypto.createHash("sha1").update(content).digest("hex");
}

function listFiles(root) {
  const ignoreDirs = new Set([
    ".git",
    "node_modules",
    "tests/screenshots",
    "saves",
    "php/saves",
  ]);
  const files = [];
  (function walk(dir) {
    for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
      if (entry.name.startsWith(".")) continue;
      const full = path.join(dir, entry.name);
      const rel = path.relative(root, full).replace(/\\/g, "/");
      if (entry.isDirectory()) {
        if ([...ignoreDirs].some((p) => rel === p || rel.startsWith(p + "/")))
          continue;
        walk(full);
      } else {
        if (!rel.match(/\.(php|js|css|html)$/i)) continue;
        files.push({ full, rel });
      }
    }
  })(root);
  return files;
}

function readJsonSafe(file) {
  try {
    return JSON.parse(fs.readFileSync(file, "utf8"));
  } catch {
    return null;
  }
}

function writeJson(file, obj) {
  fs.writeFileSync(file, JSON.stringify(obj, null, 2) + "\n", "utf8");
}

function appendLog(msg) {
  const line = `[${new Date().toISOString()}] ${msg}\n`;
  fs.appendFileSync(RUN_LOG, line, "utf8");
}

function inventory(root) {
  const files = listFiles(root);
  const manifest = [];
  for (const f of files) {
    const stat = fs.statSync(f.full);
    const content = fs.readFileSync(f.full);
    manifest.push({
      path: f.rel,
      size: stat.size,
      mtimeMs: stat.mtimeMs,
      sha1: sha1(content),
    });
  }
  return manifest;
}

function diffInventory(prev, next) {
  const prevMap = new Map((prev || []).map((e) => [e.path, e]));
  const changed = [];
  for (const e of next) {
    const p = prevMap.get(e.path);
    if (!p || p.sha1 !== e.sha1) changed.push(e.path);
  }
  return new Set(changed);
}

function grepMatches(content, regex, category, file) {
  const res = [];
  const lines = content.split(/\r?\n/);
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    if (regex.test(line)) {
      res.push({
        file,
        line: i + 1,
        category,
        snippet: line.trim().slice(0, 300),
      });
    }
  }
  return res;
}

function scanStatic(root, changedSet) {
  const files = listFiles(root);
  const results = [];
  for (const f of files) {
    if (changedSet && !changedSet.has(f.rel)) continue;
    const content = fs.readFileSync(f.full, "utf8");
    results.push(
      ...grepMatches(content, /addEventListener\s*\(/, "event-binding", f.rel)
    );
    results.push(
      ...grepMatches(
        content,
        /\bon(click|input|change|submit|keydown|keyup)\b/,
        "inline-event",
        f.rel
      )
    );
    results.push(...grepMatches(content, /fetch\s*\(/, "network-fetch", f.rel));
    results.push(
      ...grepMatches(
        content,
        /XMLHttpRequest|\$.ajax\s*\(/,
        "network-xhr",
        f.rel
      )
    );
    results.push(
      ...grepMatches(content, /localStorage|sessionStorage/, "storage", f.rel)
    );
    results.push(
      ...grepMatches(
        content,
        /window\.location|location\.href/,
        "navigation",
        f.rel
      )
    );
    results.push(
      ...grepMatches(
        content,
        /aria-[a-z-]+\s*=|role=|tabindex=|focus\(|blur\(/,
        "a11y",
        f.rel
      )
    );
    results.push(
      ...grepMatches(
        content,
        /index\.php|home\.php|list\.php|admin\.php/,
        "entrypoints",
        f.rel
      )
    );
    results.push(
      ...grepMatches(
        content,
        /php\/api\/(save|restore|list|delete)\.php/,
        "api-endpoints",
        f.rel
      )
    );
  }
  return results;
}

function synthesizeStories(staticFeatures, dynamicFeatures, commitHash) {
  const has = (cat) =>
    staticFeatures.some((f) => f.category === cat) ||
    dynamicFeatures.some((f) => f.category === cat);
  const stories = [];

  stories.push({
    id: "story-session",
    title: "Automatic Session Creation",
    acceptance: [
      "Session ID extracted or generated; 3-character alphanumeric",
      "URL parameters influence session for all save/restore",
    ],
    evidence: ["storage", "entrypoints", "navigation"].filter(has),
  });

  stories.push({
    id: "story-restore",
    title: "Progressive Data Restoration",
    acceptance: [
      "Restoration waits for DOM availability",
      "Textareas and statuses restored with retries",
      "Side panel and scroll position restored",
    ],
    evidence: ["event-binding", "storage"].filter(has),
  });

  stories.push({
    id: "story-manual-save",
    title: "Manual Save with Feedback",
    acceptance: [
      "Save button triggers immediate save",
      "Busy state visible during save; success message after",
      "API success contract enforced",
    ],
    evidence: ["network-fetch", "api-endpoints", "a11y"].filter(has),
  });

  stories.push({
    id: "story-auto-save",
    title: "Auto-save Gated Behind Manual Save",
    acceptance: [
      "Auto-save disabled until manual save validated",
      "Feature flag controls enablement without UX change",
    ],
    evidence: ["event-binding", "storage"].filter(has),
  });

  stories.push({
    id: "story-report",
    title: "Report Table State Management",
    acceptance: [
      "Report rows persist and re-render",
      "Manual rows add/delete; status changes save",
    ],
    evidence: ["event-binding", "storage"].filter(has),
  });

  stories.push({
    id: "story-status",
    title: "Task Completion Workflow",
    acceptance: [
      "Status cycles pending → in-progress → completed",
      "Completed tasks flow into report with date",
    ],
    evidence: ["event-binding", "a11y"].filter(has),
  });

  stories.push({
    id: "story-persistence",
    title: "Session Data Persistence",
    acceptance: [
      "Saves include textareas, reportRows, statusIcons, sidePanel",
      "Save directory auto-created; session validated",
    ],
    evidence: ["api-endpoints", "network-fetch", "storage"].filter(has),
  });

  stories.push({
    id: "story-errors",
    title: "Error Handling and Recovery",
    acceptance: [
      "Network/API errors surface user-visible messages",
      "Dirty state retained on failure; retries allowed",
    ],
    evidence: ["network-xhr", "network-fetch", "a11y"].filter(has),
  });

  stories.push({
    id: "story-sidepanel",
    title: "Side Panel State Preservation",
    acceptance: [
      "Side panel open/active state persists",
      "Toggles trigger saves; icons match state",
    ],
    evidence: ["event-binding", "storage"].filter(has),
  });

  stories.push({
    id: "story-unsaved",
    title: "Unsaved Changes Protection",
    acceptance: [
      "beforeunload prompt when dirty",
      "Dirty cleared after successful save",
    ],
    evidence: ["event-binding", "network-fetch"].filter(has),
  });

  const metadata = { generatedAt: new Date().toISOString(), commitHash };
  return { stories, metadata };
}

function rewriteUserStories(existingMd, generated) {
  const header = "## **Primary Save/Restore User Stories**";
  const footerHeader = "## **Critical Technical Issues Identified**";
  const startIdx = existingMd.indexOf(header);
  const endIdx = existingMd.indexOf(footerHeader);
  const before = startIdx >= 0 ? existingMd.slice(0, startIdx) : existingMd;
  const after = endIdx >= 0 ? existingMd.slice(endIdx) : "";

  let body = header + "\n\n";
  generated.stories.forEach((s, i) => {
    body += `### **Story ${i + 1}: ${s.title}**\n`;
    body += `**Acceptance Criteria:**\n`;
    s.acceptance.forEach((a) => {
      body += `- ${a}\n`;
    });
    if (s.evidence && s.evidence.length) {
      body += `\nEvidence categories: ${s.evidence.join(", ")}\n`;
    }
    body += "\n";
  });
  body += `\nScan metadata: ${generated.metadata.generatedAt} (commit ${generated.metadata.commitHash})\n`;

  if (startIdx >= 0 && endIdx >= 0) {
    return before + body + after;
  } else if (startIdx >= 0) {
    return before + body;
  } else {
    return existingMd + "\n\n" + body;
  }
}

function getCommitHash() {
  try {
    const { execSync } = require("child_process");
    return execSync("git rev-parse --short HEAD", {
      cwd: REPO_ROOT,
      stdio: ["ignore", "pipe", "ignore"],
    })
      .toString()
      .trim();
  } catch {
    return "unknown";
  }
}

function main() {
  ensureDir(REPORTS_DIR);
  fs.writeFileSync(RUN_LOG, "", "utf8");
  appendLog("Starting user stories generation");

  const prevInventory = readJsonSafe(INVENTORY_JSON);
  const nextInventory = inventory(REPO_ROOT);
  writeJson(INVENTORY_JSON, nextInventory);
  const changed = diffInventory(prevInventory, nextInventory);
  appendLog(`Changed files: ${changed.size}`);

  const staticFeatures = scanStatic(REPO_ROOT, changed.size ? changed : null);
  writeJson(FEATURES_STATIC_JSON, staticFeatures);
  appendLog(`Static features: ${staticFeatures.length}`);

  const dynamicFeatures = readJsonSafe(FEATURES_DYNAMIC_JSON) || [];

  const commitHash = getCommitHash();
  const generated = synthesizeStories(
    staticFeatures,
    dynamicFeatures,
    commitHash
  );
  writeJson(STORIES_GENERATED_JSON, generated);

  const existingMd = fs.readFileSync(USER_STORIES_MD, "utf8");
  const updatedMd = rewriteUserStories(existingMd, generated);
  if (sha1(existingMd) !== sha1(updatedMd)) {
    fs.writeFileSync(USER_STORIES_MD, updatedMd, "utf8");
    appendLog("user-stories.md updated");
  } else {
    appendLog("user-stories.md unchanged");
  }

  appendLog("Done");
}

if (require.main === module) {
  try {
    main();
    process.exit(0);
  } catch (err) {
    appendLog(`Error: ${err && err.stack ? err.stack : String(err)}`);
    process.exit(1);
  }
}
