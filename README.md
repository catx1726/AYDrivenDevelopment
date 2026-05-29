# Base AI-Driven Template

面向 AI 辅助开发的工程化模板，深度融合 Harness Engineering 与 Superpowers 方法论。

## 快速开始

```bash
# 1. 克隆仓库
git clone <repo-url>
cd <repo-name>

# 2. 安装开发环境（Local Hooks）
./scripts/setup-dev.sh        # macOS / Linux / WSL
# 或
.\scripts\setup-dev.ps1      # Windows PowerShell
```

> `setup-dev` 会自动安装 lefthook 并把 hooks 注册到 `.git/hooks/`。不安装则提交不会经过 AGENTS.md 大小检查、破坏性命令拦截等安全机制。

## 核心机制

### 人类（Driver）的职责

1. **启动任务**：提出需求，确认 AI 产出的 Spec 和 Plan
2. **关键决策**：在 AI 暂停点（Pause Points）给出确认或指令
3. **审查合并**：验证 AI 的产出物证据，批准 PR

详细的人机交互规范见 `AGENTS.md` → `人机交互规范` 章节。

### AI Agent 的执行纪律

AI 遵循 Superpowers 技能系统：`brainstorming` → `writing-plans` → `executing-plans` → `verification-before-completion`。

详细生命周期见 `docs/superpowers/lifecycle.md`。

## 项目结构

```text
.
├── AGENTS.md                   # AI 系统 prompt 地图（SSOT：AI 规范入口）
├── README.md                   # 本文档（SSOT：人类入口）
├── lefthook.yml                # Local Hooks 配置
├── CHANGELOG.md                # 变更日志
├── docs/
│   ├── standards/              # 工程标准（代码规范、TDD、API 设计等）
│   └── superpowers/
│       ├── lifecycle.md        # SSOT：唯一完整生命周期
│       ├── tips.md             # SSOT：人类操作提示
│       └── handoffs/           # AI 跨会话上下文交接
├── skills/                     # 技能系统主目录（平台无关）
│   ├── meta/                   # 核心元技能
│   └── custom/                 # 自定义技能
├── scripts/
│   ├── setup-dev.{sh,ps1}              # 开发环境一键安装
│   ├── check-agents-md.{sh,ps1}        # AGENTS.md 大小检查
│   ├── check-docs-structure.{sh,ps1}   # 文档结构检查
│   ├── forbid-destructive.{sh,ps1}     # 破坏性命令检测
│   ├── check-conventional-commit.{sh,ps1}  # Commit message 检查
│   ├── check-ops-changelog.{sh,ps1}    # 审计日志更新检查
│   ├── sync-skills.{sh,ps1}            # 技能同步（跨平台）
│   └── ai_reviewer.py                  # PR AI 代码审查（CI 用）
└── .project/
    ├── ops_changelog.md        # 操作审计日志
    ├── compliance_log.md       # 合规审计日志
    └── distill_stage/          # 资产提纯暂存区
```

## 文档地图（SSOT）

**本文档不重复具体流程，所有详细内容在以下文档中：**

| 文档                            | 面向读者  | 内容                                                          |
| ------------------------------- | --------- | ------------------------------------------------------------- |
| `AGENTS.md`                     | AI Agent  | 系统 prompt 地图（< 100 行）。工程标准索引 + 人机交互规范     |
| `docs/superpowers/lifecycle.md` | 人类 + AI | **唯一**完整开发生命周期（Mermaid 图 + 阶段说明）             |
| `docs/superpowers/tips.md`      | 人类      | Issue/PR/Worktree 命令操作提示                                |
| `docs/standards/`               | 人类 + AI | 工程标准实体。完整索引（领域、路径、适用阶段）见 `AGENTS.md`  |
| `docs/superpowers/handoffs/`    | AI        | 跨会话上下文交接文档                                          |
| `skills/`                       | AI        | 技能系统。可用技能清单见 `skills/meta/project-entry/SKILL.md` |
| `scripts/`                      | 人类 + AI | 开发工具脚本，详见「Scripts 速查」                            |

## Scripts 速查

> **平台后缀约定**：`.sh` = Bash（macOS / Linux / WSL），`.ps1` = PowerShell（Windows）。每个脚本功能相同，按你的环境选一种运行。

| 脚本 | 是什么 | 什么时候用 | 怎么做 | 为什么 |
| --- | --- | --- | --- | --- |
| `setup-dev` | 安装 lefthook 并注册 Git hooks | 首次 clone 仓库后 | `./scripts/setup-dev.sh`（或 `.ps1`） | 不安装则提交不会经过任何安全检查 |
| `check-agents-md` | 检查 `AGENTS.md` 是否 ≤ 100 行 | 每次提交前（自动） | lefthook 自动调用 | 防止系统 prompt 膨胀，降低 Agent 推理质量 |
| `check-docs-structure` | 检查 handoff/skill 文件的 front matter 完整性 | 每次提交前（自动） | lefthook 自动调用 | 确保 AI 上下文交接文档和技能文件可被正确解析 |
| `forbid-destructive` | 在 diff 中检测 `rm -rf`、`git push --force`、`DROP TABLE` 等危险模式 | 每次提交前（自动） | lefthook 自动调用 | 拦截破坏性操作，要求 Driver 确认 |
| `check-conventional-commit` | 检查 commit message 是否符合 `type(scope): description` 格式 | 每次提交前（自动） | lefthook 自动调用 | 生成标准化 CHANGELOG，便于追溯 |
| `check-ops-changelog` | 代码变更时强制要求更新 `.project/ops_changelog.md` | 每次提交前（自动） | lefthook 自动调用 | 保证每次代码变更都有审计记录 |
| `sync-skills` | 将平台无关的 `skills/` 同步到 `.gemini/skills/` 等平台目录 | 修改 `skills/` 后手动运行 | `./scripts/sync-skills.sh`（或 `.ps1`） | `.gemini/skills/` 是副本，主库在 `skills/` |
| `ai_reviewer` | 基于 DeepSeek API 对 PR 进行代码审查（需 `DEEPSEEK_API_KEY`） | CI 中自动触发 | GitHub Actions 自动调用 | 用标准文档统一审查尺度，减少人工漏检 |

## 常见问题

**Q: 如何验证 hooks 已正确安装？**
A: `ls .git/hooks/pre-commit` —— 如果存在（不是 `.sample`），说明已生效。

**Q: CHANGELOG.md 和 .project/ops_changelog.md 有什么区别？**
A: `CHANGELOG.md` 面向**外部用户**——记录功能变更摘要（由 CI 自动更新）；`.project/ops_changelog.md` 面向**内部审计**——记录每次代码变更的操作意图和回滚命令（由开发者/AI 在提交前手动追加）。

**Q: 不想装 lefthook 可以吗？**
A: 可以跳过，但提交不会经过：AGENTS.md 大小检查、破坏性命令拦截、Conventional Commit 校验。建议至少运行一次 `./scripts/setup-dev.sh`。
