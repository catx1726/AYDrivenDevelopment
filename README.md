# Base AI-Driven Template

面向 AI 辅助开发的工程化 SOP 模板，让 AI 编码**可控、可积累、可验证**。

## 为什么需要它

AI 写代码很快，但会失控（危险操作、范围膨胀）、会遗忘（上下文腐烂）、会重复犯错。本模板把工程纪律做成环境规则——你只管在关键点拍板，其余交给流程：

| 关键字 | 解决什么问题 | 靠什么 |
|--------|-------------|--------|
| **复利** | 同样的错不犯第二次，经验沉淀为资产 | 决策即时归档（decisions）、错误变规则（Ratchet）、任务提纯（meta-distiller）、棘手问题沉淀（playbooks） |
| **控制** | AI 不越权，结论必须有证据 | 人机暂停点（Spec/Plan/合并确认）、本地钩子拦截（破坏性命令/提交规范/审计强制）、三层验证、上下文 ≥128k 预警防发散 |
| **提效** | 小任务不走过场，长任务不腐烂 | Surgical Workflow 轻量路径、上下文健康管理（handoff/compaction）、CI 自动化检查 |

## 快速开始

```bash
# 1. 克隆本模板
git clone <repo-url>
```

2. 接入你的项目（二选一）：

- **母库引用（推荐）**：按 `docs/superpowers/child-repo-guide.md` 接入——子库只装运行时资产（scripts/hooks/CI），规范升级一处生效
- **全量复制**：模板文件复制进项目根目录，再运行 `./scripts/setup-dev.sh`（Windows: `.\scripts\setup-dev.ps1`）注册本地钩子

3. 在你的项目里对 AI 说：

> "在开始编码之前，请先阅读我们的规范、流程 AI SOP 仓库（母库路径）"

环境依赖清单（Node.js / GitHub CLI / python3 等）见 `docs/superpowers/tips.md` →「前提」。

## 它如何运转

AI 按固定生命周期执行：**需求澄清 → Spec（你确认）→ Plan（你批准）→ TDD 执行 → 三层验证 → 资产提纯 → PR 合并（你把关）**。
你只在暂停点决策、审查证据；提交被本地钩子守卫；上下文健康由 context-guard 监控。

- 完整流程图：`docs/superpowers/lifecycle.md`
- 人机分工细节：`AGENTS.md`

## 按任务开始

直接对 AI 描述需求，AI 读取 `AGENTS.md` 自动选择工作流：

| 你要做什么 | 对 AI 说的话 |
|-----------|-------------|
| 快速修复 Bug | "login 函数空密码时崩溃，请修复" → 自动走 Surgical Workflow |
| 全新功能开发 | "增加用户注册功能，先写 Spec" → 自动走标准生命周期 |
| 不确定改动范围 | "请先做逻辑 MRI 评估影响范围" |
| 审查 PR | 你作为 Reviewer，查阅 `docs/standards/review-standards/` |

更多场景与纠正 AI 的话术见 `docs/superpowers/human-guide.md`。

## 文档地图

| 文档 | 内容 |
|------|------|
| `AGENTS.md` | AI 规范入口（< 100 行索引 + 执行契约） |
| `docs/superpowers/lifecycle.md` | 唯一完整生命周期（Mermaid 图） |
| `docs/superpowers/human-guide.md` | 人类使用指南（环境配置、场景话术、Superpowers 安装、Scripts 速查） |
| `docs/superpowers/child-repo-guide.md` | 子库接入指南（母库引用模式） |
| `docs/superpowers/tips.md` | 环境依赖清单 + gh/Worktree 操作提示 |
| `docs/standards/` | 工程标准（索引见 `AGENTS.md`） |
| `skills/` | AI 技能系统（清单见 `skills/meta/project-entry/SKILL.md`） |

## 常见问题

**Q: 怎么确认钩子已生效？** `ls .git/hooks/pre-commit`（非 `.sample` 即生效）。

**Q: 不装 lefthook 行不行？** 可以，但提交将绕过全部安全检查（AGENTS.md 大小、破坏性命令拦截、提交规范、审计强制），不建议。

**Q: CHANGELOG.md 和 ops_changelog.md 的区别？** 前者面向外部用户（CI 自动更新的功能摘要）；后者面向内部审计（每次变更的意图与回滚命令，提交前追加）。
