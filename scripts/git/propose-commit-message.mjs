// Promoted from AssistSupport, which was the only repository whose version
// derived a real scope from the staged paths and named the file it changed,
// instead of always proposing "update N files" against a guessed scope.
//
// Kept from the majority version: the output path, which 49 repositories use.
// Nothing anywhere reads either file, so the name is free, and churn is not.
import { execFileSync } from "node:child_process";
import { writeFileSync } from "node:fs";
import path from "node:path";

const SUBJECT_LIMIT = 72;
const OUT = ".git/CODEX_COMMIT_MSG_PROPOSAL";

const staged = execFileSync(
  "/usr/bin/git",
  ["diff", "--cached", "--name-only", "--diff-filter=ACMR"],
  { encoding: "utf8" },
)
  .split("\n")
  .map((line) => line.trim())
  .filter(Boolean);

if (staged.length === 0) {
  console.error("No staged files.");
  process.exit(1);
}

const lower = staged.map((f) => f.toLowerCase());

// The most common top-level directory, which is a scope the reader can act on.
// A file at the repository root has no directory to name, and using its
// filename would produce chore(package.json): update package.json, so those
// count as "repo". A leading dot is dropped so .github reads as github.
const counts = new Map();
for (const file of staged) {
  const top = file.includes("/") ? file.split("/")[0] : "repo";
  counts.set(top, (counts.get(top) ?? 0) + 1);
}
const scope = [...counts.entries()]
  .sort((a, b) => b[1] - a[1])[0][0]
  .toLowerCase()
  .replace(/^\.+/, "");

// every, not some: staging one Markdown file alongside source is a source
// change with a note attached, not a docs change.
const allDocs = lower.every((f) => f.endsWith(".md"));
// Anchored on path segments and filename markers. Matching the bare substring
// "test" also matches latest.ts and contest.js.
const hasTests = lower.some(
  (f) => f.includes("/tests/") || f.includes(".test.") || f.includes(".spec."),
);
const hasCi = lower.some((f) => f.startsWith(".github/workflows/"));
const hasPerf = lower.some(
  (f) => f.includes("/perf/") || f.includes("lighthouserc"),
);
// Named explicitly rather than matching "lock" anywhere, which also matches
// blocklist.ts, while still covering the ecosystems this portfolio uses.
const LOCKFILES = [
  "package.json",
  "package-lock.json",
  "pnpm-lock.yaml",
  "yarn.lock",
  "cargo.toml",
  "cargo.lock",
  "uv.lock",
  "poetry.lock",
];
const hasDeps = lower.some((f) => LOCKFILES.includes(path.basename(f)));

let type = "feat";
if (allDocs) type = "docs";
else if (hasCi) type = "ci";
else if (hasPerf) type = "perf";
else if (hasTests) type = "test";
else if (hasDeps) type = "chore";

const focus =
  staged.length === 1
    ? `update ${path.basename(staged[0])}`
    : `update ${staged.length} files for ${scope} changes`;

const summary = `${type}(${scope}): ${focus}`.slice(0, SUBJECT_LIMIT);

writeFileSync(OUT, `${summary}\n`);
console.log(summary);
console.log(`written: ${OUT}`);
