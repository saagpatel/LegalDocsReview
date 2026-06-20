// codex-os-managed
export default {
  extends: ["@commitlint/config-conventional"],
  rules: {
    "type-enum": [2, "always", ["feat", "fix", "refactor", "perf", "docs", "test", "build", "ci", "chore", "revert"]],
    "header-max-length": [2, "always", 100],
    "subject-empty": [2, "never"],
    "subject-full-stop": [2, "never", "."],
  },
};
