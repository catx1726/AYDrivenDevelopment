# Operations Changelog

| Time | Action | Target | Reason | Commit_ID | Undo_CMD |
| :--- | :----- | :----- | :----- | :-------- | :------- |
| 2026-05-27T12:30+08:00 | refactor | AGENTS.md | Harness Engineering: 精简为地图（117→59行），移出 Mermaid 图和命令细节至 docs/superpowers/ | 51371b7a90f0fdc2bb48073e60100df0bba87c9b | git checkout HEAD -- AGENTS.md && git rm docs/superpowers/lifecycle.md docs/superpowers/tips.md |
| 2026-05-27T12:30+08:00 | add | lefthook.yml + scripts/ | Harness Engineering: 增加 Local Hooks 层（pre-commit 检查 AGENTS.md 大小、禁止破坏性命令、Conventional Commit） | 51371b7a90f0fdc2bb48073e60100df0bba87c9b | git rm lefthook.yml scripts/check-agents-md.* scripts/forbid-destructive.* |
| 2026-05-27T12:30+08:00 | add | scripts/worktree-manager.* | Harness Engineering: Worktree 自动化脚本（sh+ps1），支持 create/list/push/cleanup | 51371b7a90f0fdc2bb48073e60100df0bba87c9b | git rm scripts/worktree-manager.* |
