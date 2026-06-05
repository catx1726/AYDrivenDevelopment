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

| 2026-05-28T16:30+08:00 | add | skills/ + scripts/sync-skills.* | SKILL 目录通用化：创建平台无关 skills/ 目录和同步脚本 | 561ebd4 | git rm -r skills/ scripts/sync-skills.* |
| 2026-05-28T16:30+08:00 | update | docs/superpowers/context-management-strategy.md | 新增中间决策留档机制（第 6 节），修正章节编号 | 561ebd4 | git checkout HEAD~1 -- docs/superpowers/context-management-strategy.md |
| 2026-05-28T16:30+08:00 | update | .markdownlint-cli2.jsonc | 将 skills/ 加入 markdownlint 忽略列表 | 561ebd4 | git checkout HEAD~1 -- .markdownlint-cli2.jsonc |

| 2026-05-28T17:00+08:00 | add | scripts/check-docs-structure.* + lefthook | 机械化架构约束：文档结构检查脚本和 hook | 61dfb3f | git rm scripts/check-docs-structure.* |
| 2026-05-28T17:00+08:00 | add | skills/custom/meta-compliance-checker/ | 合规检查 skill（安全/TDD/日志/文档 checklist + Ratchet） | 61dfb3f | git rm -r skills/custom/meta-compliance-checker/ |
| 2026-05-28T17:00+08:00 | add | .gemini/compliance_log.md | 合规审计日志（Ratchet 记录表） | 61dfb3f | git rm .gemini/compliance_log.md |
| 2026-05-28T17:00+08:00 | update | skills/meta/meta-safe-executor/SKILL.md | ops_changelog 写保护协议（backup + append-only + 行数校验） | 61dfb3f | git checkout HEAD~1 -- skills/meta/meta-safe-executor/SKILL.md |

| 2026-05-29T08:30+08:00 | note | 多项文档与技能 | 补录：从 61dfb3f（2026-05-28T17:00）到 14bf0b8 期间，共 14 项变更未按 meta-safe-executor 协议记录审计日志。核心变更包括：Surgical Workflow 正式规范（a87d1dc+533c484+88d95bd）、project-entry 入口 skill（8c6c3b0）、母库/子库架构清理（137cced+0748601）、.gemini/→.project/ 迁移（91efa99）、skills 同步（14bf0b8）。已建立 lefthook 强制检查防止未来遗漏。 | — | git checkout 61dfb3f -- . |
| 2026-05-29T08:45+08:00 | add | scripts/check-ops-changelog.ps1 | 增加 PowerShell 版本的 ops_changelog 强制检查脚本（与 sh 版本功能一致） | current | git rm scripts/check-ops-changelog.ps1 |

| 2026-05-29T13:45+08:00 | update | README.md | 扩展项目结构树（补充 check-ops-changelog、ai_reviewer.py、.ps1 后缀），新增 Scripts 速查表（what/when/how/why） | current | git checkout HEAD~1 -- README.md

| 2026-05-29T13:50+08:00 | refactor | README.md | 重排章节顺序（快速开始→项目结构→Scripts速查→核心机制→文档地图→FAQ），消除文档地图与项目结构的信息重复，scripts 行指向 Scripts 速查表 | current | git checkout HEAD~1 -- README.md

| 2026-05-29T13:55+08:00 | update | README.md | 调整 Scripts 速查表表头顺序：脚本→是什么→什么时候用→怎么做→为什么（先概念后场景再操作） | current | git checkout HEAD~1 -- README.md

| 2026-05-29T14:00+08:00 | move | docs/standards/surgical-workflow-concept.md → docs/superpowers/ | 语义修正：流程文档不应放在可执行标准目录下 | current | git mv docs/superpowers/surgical-workflow-concept.md docs/standards/ && git checkout HEAD~1 -- AGENTS.md
| 2026-05-29T14:00+08:00 | fix | AGENTS.md | 移除 dangling reference（using-git-worktrees skill 不存在）；更新 surgical-workflow 路径 | current | git checkout HEAD~1 -- AGENTS.md
| 2026-05-29T14:00+08:00 | delete | docs/standards/.DS_Store | 删除 macOS 系统垃圾文件，.gitignore 已追加 .DS_Store | current | git checkout HEAD~1 -- .gitignore && git checkout HEAD -- docs/standards/.DS_Store
| 2026-05-29T14:00+08:00 | add | docs/standards/code-standards-QUICK-REF.md | 从 code-standards submodule（2386行）提取精华，生成快速参考（不修改源数据） | current | git rm docs/standards/code-standards-QUICK-REF.md
| 2026-05-29T14:00+08:00 | update | README.md | 常见问题中补充 CHANGELOG.md 与 ops_changelog.md 的分工说明 | current | git checkout HEAD~1 -- README.md

| 2026-05-29T14:05+08:00 | fix | docs/superpowers/tips.md | 修复 surgical-workflow-concept.md 的引用路径（standards → superpowers） | current | git checkout HEAD~1 -- docs/superpowers/tips.md
| 2026-05-29T14:05+08:00 | refactor | README.md | 优化文档地图：standards 和 skills 行指向 AGENTS.md/project-entry，消除与 AGENTS.md 标准索引的重复 | current | git checkout HEAD~1 -- README.md

| 2026-05-29T14:10+08:00 | update | README.md | 用户重新排版：核心机制前置，文档地图后移，QA 改回多行格式 | current | git checkout HEAD~1 -- README.md
| 2026-05-29T14:10+08:00 | fix | docs/standards/test-driven-development.md + logging-standards.md + api-design-standards.md | 将 dangling reference（链接到不存在的文件）改为纯文本，保留上下文信息 | current | git checkout HEAD~1 -- docs/standards/test-driven-development.md docs/standards/logging-standards.md docs/standards/api-design-standards.md

| 2026-05-29T14:15+08:00 | close | GitHub issues #7 #8 | 清理占位符空 issue（标题和正文均为模板默认值，无实际内容） | — | gh issue reopen 7 8 --repo catx1726/YOU-DRIVE-SOP

| 2026-05-29T14:20+08:00 | add | docs/superpowers/human-guide.md + README.md | 新增人类使用指南（双层结构）：README 轻量导航表 + human-guide.md 详细指南（环境配置/场景示例/纠正话术） | current | git rm docs/superpowers/human-guide.md && git checkout HEAD~1 -- README.md

| 2026-06-03T09:35+08:00 | add | scripts/* (context-guard, generate-handoff, archive-decision, generate-indexes, surgical-check 的 sh+ps1) + docs/superpowers/context-toolchain.md + docs/superpowers/decisions/INDEX.md + docs/superpowers/handoffs/INDEX.md | Context Management Toolchain Phase 1：上下文守护脚本（context-guard/sh+ps1）、handoff/decision 生成与索引脚本（generate-handoff/generate-indexes/archive-decision/sh+ps1）、Surgical Workflow 检查脚本（surgical-check/sh+ps1）、context-toolchain 文档、decisions/handoffs 索引 | current | git rm scripts/archive-decision.* scripts/context-guard.* scripts/generate-handoff.* scripts/generate-indexes.* scripts/surgical-check.* && git rm docs/superpowers/context-toolchain.md docs/superpowers/decisions/INDEX.md docs/superpowers/handoffs/INDEX.md
| 2026-06-03T09:35+08:00 | update | AGENTS.md + surgical-workflow-concept.md + lifecycle.md + check-docs-structure.* | (1) AGENTS.md 精简为执行契约（111→55行），证据呈现与上下文管理细节移入子文档；(2) Surgical Workflow 集成 superpowers brainstorming（轻量级执行+极简 design doc）、Logic MRI 增加需求-代码对齐检查与 Mermaid 歧义暴露；(3) lifecycle.md Mermaid 图同步更新；(4) check-docs-structure 排除 INDEX.md | current | git checkout HEAD~1 -- AGENTS.md docs/superpowers/surgical-workflow-concept.md docs/superpowers/lifecycle.md && git checkout HEAD~1 -- scripts/check-docs-structure.*

| 2026-06-03T09:45+08:00 | update | README.md | 新增「关于 Superpowers」章节：介绍 superpowers 框架、各 AI 工具安装方式、项目内集成指南（skills/ 目录克隆/submodule） | current | git checkout HEAD~1 -- README.md
