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

## 关于 Superpowers

本模板基于 [obra/superpowers](https://github.com/obra/superpowers) 构建。Superpowers 是一个开源的 AI 开发技能框架，定义了标准化的开发流程与可复用的 agent 技能。

**核心工作流：**

1. **brainstorming** — 需求澄清与设计确认（Socratic questioning）
2. **writing-plans** — 生成可执行的实施计划（one task per file）
3. **executing-plans** — 按步骤执行并验证
4. **test-driven-development** — RED-GREEN-REFACTOR 循环
5. **requesting-code-review** — 代码审查与反馈

**完整技能库：** 测试（TDD）、调试（systematic-debugging）、
协作（brainstorming/writing-plans/executing-plans/subagent-driven-development）、
元技能（writing-skills/using-superpowers）等 14+ 个可组合技能。

### 安装 Superpowers

按你的 AI 工具选择安装方式：

| AI 工具 | 安装方式 |
|---------|---------|
| **Claude Code** | `/plugin install superpowers@claude-plugins-official` |
| **Codex CLI** | `/plugins` → 搜索 `superpowers` → `Install Plugin` |
| **Codex App** | 侧边栏 Plugins → Coding section → `+` next to Superpowers |
| **Gemini CLI** | `gemini extensions install https://github.com/obra/superpowers` |
| **OpenCode** | `Fetch and follow instructions from https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/.opencode/INSTALL.md` |
| **Cursor** | `/add-plugin superpowers` 或在 marketplace 搜索 |
| **GitHub Copilot CLI** | `copilot plugin marketplace add obra/superpowers-marketplace` → `copilot plugin install superpowers@superpowers-marketplace` |
| **Factory Droid** | `droid plugin marketplace add https://github.com/obra/superpowers` → `droid plugin install superpowers@superpowers` |

### 项目内集成（Kimi Code CLI / 通用）

如果你的 AI 工具不支持上述插件市场，可将 Superpowers 技能库直接集成到本模板中：

```bash
# 方式 1：直接克隆（推荐，简单）
git clone https://github.com/obra/superpowers.git skills/superpowers

# 方式 2：Git submodule（方便后续更新）
git submodule add https://github.com/obra/superpowers.git skills/superpowers
```

> ⚠️ **注意**：Superpowers 的 skills 主要为 Claude Code / Codex CLI 设计，
> 部分平台特定工具调用（如 `TodoWrite`、`Skill`）在不同 AI 工具间存在差异。
> 以 Kimi Code CLI 为例，它会读取 SKILL.md 中的文本指令并执行，
> 但特定工具行为会以纯文本形式完成。

## 按任务开始

根据你要做的事，直接对 AI 描述需求即可。AI 会读取 `AGENTS.md` 并自动选择合适的工作流。

| 你要做什么 | 对 AI 说的话 | AI 自动走什么流程 |
|-----------|-------------|-------------------|
| 快速修复 Bug | "login 函数空密码时崩溃，请修复" | Surgical Workflow |
| 全新功能开发 | "增加用户注册功能，先写 Spec" | 标准生命周期 |
| 不确定改动范围 | "请先做逻辑 MRI 评估影响范围" | 由 AI 判断 |
| 审查 PR | （你作为 Reviewer）看 `review-standards` | — |

> 详细使用指南（各平台配置、完整对话示例、纠正 AI 的话术）见 `docs/superpowers/human-guide.md`

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
| `docs/superpowers/human-guide.md` | 人类    | **本模板使用指南**：按任务类型导航 + 纠正 AI 话术           |
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
