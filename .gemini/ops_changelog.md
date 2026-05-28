# Operations Changelog

| Time | Action | Target | Reason | Commit_ID | Undo_CMD |
| :--- | :----- | :----- | :----- | :-------- | :------- |
| 2026-05-27T12:30+08:00 | refactor | AGENTS.md | Harness Engineering: 精简为地图（117→59行），移出 Mermaid 图和命令细节至 docs/superpowers/ | 51371b7a90f0fdc2bb48073e60100df0bba87c9b | git checkout HEAD -- AGENTS.md && git rm docs/superpowers/lifecycle.md docs/superpowers/tips.md |
| 2026-05-27T12:30+08:00 | add | lefthook.yml + scripts/ | Harness Engineering: 增加 Local Hooks 层（pre-commit 检查 AGENTS.md 大小、禁止破坏性命令、Conventional Commit） | 51371b7a90f0fdc2bb48073e60100df0bba87c9b | git rm lefthook.yml scripts/check-agents-md.* scripts/forbid-destructive.* |
| 2026-05-27T12:30+08:00 | add | scripts/worktree-manager.* | Harness Engineering: Worktree 自动化脚本（sh+ps1），支持 create/list/push/cleanup | 51371b7a90f0fdc2bb48073e60100df0bba87c9b | git rm scripts/worktree-manager.* |
| 2026-05-27T16:30+08:00 | add | GETTING_STARTED.md + setup-dev.* | 修复 Local Hooks onboarding 断层：新增人类 onboarding 文档和一键安装脚本 | TBD | git rm GETTING_STARTED.md scripts/setup-dev.* |

| 2026-05-28T14:00+08:00 | add | .gemini/skills/meta-runtime-evaluator/ | Harness Engineering: 创建 Layer 3 独立运行时验证 skill | 6eab2ee | git rm -r .gemini/skills/meta-runtime-evaluator/ |
| 2026-05-28T14:00+08:00 | add | docs/superpowers/handoffs/generator-evaluator-research-2026-05-28.md | Harness Engineering: Generator/Evaluator 分离调研报告 | 6eab2ee | git rm docs/superpowers/handoffs/generator-evaluator-research-2026-05-28.md |
| 2026-05-28T14:00+08:00 | update | docs/superpowers/handoffs/harness-engineering-research-2026-05-27.md | Harness Engineering: 修正 Superpowers 角色描述 | 6eab2ee | git checkout HEAD~1 -- docs/superpowers/handoffs/harness-engineering-research-2026-05-27.md |

| 2026-05-28T15:30+08:00 | add | docs/superpowers/context-management-strategy.md | Harness Engineering: 制定上下文管理策略（Compaction/Offloading/Reset） | 91167e8 | git rm docs/superpowers/context-management-strategy.md |

| 2026-05-28T16:00+08:00 | update | AGENTS.md, lifecycle.md, tips.md | 更新引导文档：三层验证架构 + 上下文管理策略 | 20ce0e0 | git checkout HEAD~1 -- AGENTS.md docs/superpowers/lifecycle.md docs/superpowers/tips.md |
