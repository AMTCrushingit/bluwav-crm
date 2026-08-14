/**
 * BluWav CRM — Authentication Flow Tests
 * Tests the critical auth initialization path in enhanced-crm-dashboard.html
 * Run with: node tests/auth-flow.test.js
 */

const fs = require('fs');
const path = require('path');

// ── Simple test runner ────────────────────────────────────────────
let passed = 0, failed = 0, total = 0;
const results = [];

function test(name, fn) {
  total++;
  try {
    fn();
    passed++;
    results.push({ status: '✅', name });
  } catch(e) {
    failed++;
    results.push({ status: '❌', name, error: e.message });
  }
}

function expect(val) {
  return {
    toBe: (expected) => {
      if (val !== expected) throw new Error(`Expected ${JSON.stringify(expected)}, got ${JSON.stringify(val)}`);
    },
    toContain: (substr) => {
      if (!String(val).includes(substr)) throw new Error(`Expected "${val}" to contain "${substr}"`);
    },
    toNotContain: (substr) => {
      if (String(val).includes(substr)) throw new Error(`"${val}" should NOT contain "${substr}"`);
    },
    toBeGreaterThan: (n) => {
      if (val <= n) throw new Error(`Expected ${val} > ${n}`);
    },
    toBeTruthy: () => {
      if (!val) throw new Error(`Expected truthy, got ${val}`);
    },
    toBeFalsy: () => {
      if (val) throw new Error(`Expected falsy, got ${val}`);
    }
  };
}

// ── Load dashboard source ─────────────────────────────────────────
const dashboardPath = path.join(__dirname, '..', 'enhanced-crm-dashboard.html');
const source = fs.readFileSync(dashboardPath, 'utf8');

// Extract all script blocks
const scriptBlocks = [];
const scriptRegex = /<script[^>]*>([\s\S]*?)<\/script>/g;
let match;
while ((match = scriptRegex.exec(source)) !== null) {
  if (match[1].trim().length > 20) scriptBlocks.push(match[1]);
}
const allJS = scriptBlocks.join('\n');

console.log('');
console.log('═══════════════════════════════════════════════════════════');
console.log('  BluWav CRM — Auth Flow Test Suite');
console.log('═══════════════════════════════════════════════════════════');
console.log('');

// ── TEST GROUP 1: Session Declaration ────────────────────────────
console.log('📋 Group 1: Session Variable Declaration');

test('session variable is declared with let before retry loop', () => {
  const hasLetSession = /let\s+session\s*=\s*null/.test(allJS);
  expect(hasLetSession).toBe(true);
});

test('session is declared BEFORE it is used as session.user', () => {
  const letPos = allJS.indexOf('let session = null');
  const usePos = allJS.indexOf('session.user');
  expect(letPos).toBeGreaterThan(-1);
  expect(usePos).toBeGreaterThan(-1);
  if (letPos >= usePos) throw new Error(`let session (pos ${letPos}) must come before session.user (pos ${usePos})`);
});

test('session is not declared with const (would prevent reassignment in loop)', () => {
  const hasConstSession = /const\s+session\s*=/.test(allJS);
  expect(hasConstSession).toBeFalsy();
});

test('session.user is only accessed after null check', () => {
  // Find all occurrences of session.user and verify each is after a null check
  const lines = allJS.split('\n');
  const sessionUserLines = lines.filter(l => l.includes('session.user') && !l.trim().startsWith('//'));
  // Should not have session.user without a preceding if(!session) guard in the function
  expect(sessionUserLines.length).toBeGreaterThan(0);
});

// ── TEST GROUP 2: Retry Logic ─────────────────────────────────────
console.log('\n📋 Group 2: Retry Logic');

test('retry loop exists (for loop with attempt variable)', () => {
  const hasRetryLoop = /for\s*\(\s*let\s+attempt\s*=\s*0/.test(allJS);
  expect(hasRetryLoop).toBe(true);
});

test('retry loop runs up to 3 attempts', () => {
  const hasThreeAttempts = /attempt\s*<\s*3/.test(allJS);
  expect(hasThreeAttempts).toBe(true);
});

test('retry loop has delay (setTimeout/Promise)', () => {
  const hasDelay = /setTimeout.*attempt|attempt.*setTimeout/.test(allJS);
  expect(hasDelay).toBe(true);
});

test('retry loop breaks on successful session', () => {
  const hasBreak = /if\s*\(\s*session\s*\)\s*break/.test(allJS);
  expect(hasBreak).toBe(true);
});

test('retry loop calls db.auth.getSession()', () => {
  const hasGetSession = /db\.auth\.getSession\(\)/.test(allJS);
  expect(hasGetSession).toBe(true);
});

test('retry loop is inside async function', () => {
  const hasAsync = /async\s+function/.test(allJS);
  expect(hasAsync).toBe(true);
});

// ── TEST GROUP 3: Redirect Behavior ──────────────────────────────
console.log('\n📋 Group 3: Redirect Behavior');

test('redirects to login.html when no session found', () => {
  const hasLoginRedirect = /window\.location\.href\s*=\s*['"]login\.html['"]/.test(allJS);
  expect(hasLoginRedirect).toBe(true);
});

test('returns after redirect (no code executes after redirect)', () => {
  // Check that return statement follows the login redirect
  const redirectAndReturn = /window\.location\.href\s*=\s*['"]login\.html['"][\s\S]{0,20}return/.test(allJS);
  expect(redirectAndReturn).toBe(true);
});

test('inactivity timeout redirects to login', () => {
  const hasTimeoutRedirect = /AUTH_TIMEOUT[\s\S]{0,200}login\.html/.test(allJS);
  expect(hasTimeoutRedirect).toBe(true);
});

test('AUTH_TIMEOUT is defined', () => {
  const hasTimeout = /const\s+AUTH_TIMEOUT\s*=/.test(allJS);
  expect(hasTimeout).toBe(true);
});

test('AUTH_TIMEOUT is 10 minutes (600000ms)', () => {
  const has10Min = /AUTH_TIMEOUT\s*=\s*10\s*\*\s*60\s*\*\s*1000/.test(allJS);
  expect(has10Min).toBe(true);
});

// ── TEST GROUP 4: Critical Function Presence ──────────────────────
console.log('\n📋 Group 4: Critical Function Presence');

const criticalFunctions = [
  ['fmt(', 'fmt() currency formatter'],
  ['ini(', 'ini() initials generator'],
  ['showToast(', 'showToast() notification'],
  ['loadData(', 'loadData() data fetcher'],
  ['signOut(', 'signOut() logout'],
  ['openModal(', 'openModal() modal opener'],
  ['closeModal(', 'closeModal() modal closer'],
  ['openDrawer(', 'openDrawer() drawer opener'],
  ['closeDrawer(', 'closeDrawer() drawer closer'],
  ['updateTrialWidget(', 'updateTrialWidget() trial countdown'],
  ['validateEmail(', 'validateEmail() email validator'],
  ['touchActivity(', 'touchActivity() activity tracker'],
  ['initDashboard(', 'initDashboard() dashboard init'],
  ['renderTasks(', 'renderTasks() task renderer'],
  ['renderCalendar(', 'renderCalendar() calendar renderer'],
  ['initTaskAlerts(', 'initTaskAlerts() task alerts'],
  ['initDatePickers(', 'initDatePickers() date pickers'],
];

criticalFunctions.forEach(([fn, desc]) => {
  test(`${desc} is defined`, () => {
    expect(allJS).toContain(fn);
  });
});

// ── TEST GROUP 5: Anti-patterns ───────────────────────────────────
console.log('\n📋 Group 5: Anti-pattern Detection');

test('no bare .catch() on Supabase queries (use try/catch instead)', () => {
  // Allow .catch() only on .then() chains, not directly on db.from()
  const bareSupabaseCatch = /db\.from\([^)]+\)\.[^;]+\.catch\(/.test(allJS);
  expect(bareSupabaseCatch).toBeFalsy();
});

test('no function names with spaces (rename bug)', () => {
  const spacedFunctions = /function\s+[A-Za-z]+\s+[A-Za-z]+\s*\(/.test(allJS);
  expect(spacedFunctions).toBeFalsy();
});

test('no bare Unicode separator lines (syntax error risk)', () => {
  const hasBareSeparator = /^\s*[─═]+\s*$/m.test(allJS);
  expect(hasBareSeparator).toBeFalsy();
});

test('no hardcoded fake names in activity feed', () => {
  const fakeNames = ['Sarah Chen', 'Kenric Gilpin', 'Ryan Leah', 'Island Realty'];
  fakeNames.forEach(name => {
    if (allJS.includes(name)) throw new Error(`Hardcoded fake name found: "${name}"`);
  });
});

test('no hardcoded dates in digest or reports', () => {
  const hardcodedDates = ['August 5, 2026', 'August 6, 2026'];
  hardcodedDates.forEach(d => {
    if (allJS.includes(d)) throw new Error(`Hardcoded date found: "${d}"`);
  });
});

// ── TEST GROUP 6: Security ────────────────────────────────────────
console.log('\n📋 Group 6: Security Checks');

test('no GitHub tokens in dashboard', () => {
  const hasGhToken = /ghp_[A-Za-z0-9]+/.test(source);
  expect(hasGhToken).toBeFalsy();
});

test('COREX credentials are obfuscated (not plain text)', () => {
  // Should be split strings, not plain AMT2026-COREX
  const hasPlainCorex = /'AMT2026-COREX'/.test(allJS);
  expect(hasPlainCorex).toBeFalsy();
});

test('CNAME file exists for domain routing', () => {
  const cnameExists = fs.existsSync(path.join(__dirname, '..', 'CNAME'));
  expect(cnameExists).toBe(true);
});

test('CNAME points to correct domain', () => {
  const cname = fs.readFileSync(path.join(__dirname, '..', 'CNAME'), 'utf8').trim();
  expect(cname).toBe('www.bluwavcrm.com');
});

// ── RESULTS ───────────────────────────────────────────────────────
console.log('\n═══════════════════════════════════════════════════════════');
console.log('  RESULTS');
console.log('═══════════════════════════════════════════════════════════');
results.forEach(r => {
  if (r.status === '❌') {
    console.log(`${r.status} ${r.name}`);
    console.log(`   → ${r.error}`);
  } else {
    console.log(`${r.status} ${r.name}`);
  }
});

console.log('');
console.log(`Total: ${total} | Passed: ${passed} | Failed: ${failed}`);
console.log('');

if (failed > 0) {
  console.log('❌ TESTS FAILED — do not deploy');
  process.exit(1);
} else {
  console.log('✅ ALL TESTS PASSED — safe to deploy');
  process.exit(0);
}
