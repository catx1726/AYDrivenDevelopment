# 人类使用指南（Driver Manual）

本指南面向使用本模板驱动 AI 开发的人类（Driver）。你不需要记住所有细节，只需知道面对不同任务时该做什么、该对 AI 说什么。

---

## 1. 环境准备（一次性）

本模板支持两种使用模式：

- **模式 A（全量复制）**：将模板文件复制到你的项目根目录，项目自足——按下表配置即可
- **模式 B（母库引用）**：本地保留母库 clone，子库只安装运行时资产（scripts/hook/CI），规范直读母库——接入步骤见 `docs/superpowers/child-repo-guide.md`

模式 A 下，根据你的 AI 平台做一次性配置：

> **工具前提（两种模式通用）**：Issue/PR 环节依赖 GitHub CLI——安装与认证见 `docs/superpowers/tips.md` →「前提：GitHub CLI 安装与认证」。

| 平台 | 配置步骤 |
|------|---------|
| **Kimi Code CLI** | 无需额外操作。`AGENTS.md` 放在项目根目录即可自动被读取 |
| **Gemini CLI** | 运行 `./scripts/sync-skills.sh`（或 `.ps1`），确保 `.gemini/skills/` 目录存在 |
| **Claude Code** | 运行 `./scripts/sync-skills.sh --target .claude/skills`（或 `.ps1`） |
| **Copilot / ChatGPT** | 无 skill 系统支持。首次对话时手动粘贴 `AGENTS.md` 内容作为系统提示 |

---

## 2. 发起任务时该说什么

### 场景 A：快速修复 Bug（预计 ≤10 文件）

**直接描述问题即可：**

> "login 函数在传入空密码时崩溃，请修复"

AI 的自动流程：
1. 读取 `AGENTS.md` → 快速参考 → `手术切入式工作流`
2. 读取 `surgical-workflow-concept.md`
3. 自检条件（目标明确？已有代码？无架构变更？）
4. 进入 Surgical Workflow：逻辑 MRI → 安全垫 → 极简计划 → 增量开发 → 闭环

**如果 AI 没有自动使用 Surgical Workflow，追加一句：**

> "这是一个小修复，请使用 surgical workflow"

或更明确地约束范围：

> "修改 `src/auth.ts` 的 login 函数，处理 password 为空的边界情况。预计只改 1 个文件，使用 surgical workflow"

### 场景 B：全新功能开发

**描述需求 + 明确范围：**

> "需要增加用户注册功能，包括邮箱验证和密码加密。请走完整生命周期，先写 Spec"

AI 的自动流程：
1. 检测到"全新功能"+"先写 Spec" → 标准生命周期
2. Launch 阶段：brainstorming → Spec → Issue → Branch
3. 在 `brainstorming` 和 `writing-plans` 后 AI 会暂停，等待你确认

### 场景 C：不确定改动范围

**让 AI 先评估：**

> "我想重构 auth 模块，请先做逻辑 MRI 评估影响范围，再决定用哪个工作流"

AI 会先扫描代码、输出影响地图，然后根据文件数和架构变更风险推荐工作流。

### 场景 D：代码审查（Reviewer）

你作为人类 Reviewer，直接查阅标准文档：

- **Reviewer 指南**：`docs/standards/review-standards/review/reviewer/standard.md`
- **审查清单**：`docs/standards/review-standards/review/reviewer/looking-for.md`

### 场景 E：写 PR 描述（Author）

查阅：`docs/standards/review-standards/review/developer/cl-descriptions.md`

---

## 3. 判断 AI 是否走对流程

| 正确信号 ✅ | 错误信号 ❌ |
|-----------|-----------|
| AI 说"检测到这是小范围修复，使用 Surgical Workflow" | AI 直接开始改代码，没有 MRI/计划 |
| AI 输出逻辑简报和影响地图 | AI 说"让我看看代码"然后直接改 |
| AI 在关键节点暂停等你确认（Spec/Plan/资产审查） | AI 一路自动执行到底，没有暂停 |
| AI 提交了符合 Conventional Commits 的 commit（如 `fix(auth): handle empty password`） | commit message 没有 `type(scope)` 前缀 |
| AI 更新了 `.project/ops_changelog.md` | AI 说"任务完成"但没有更新审计日志 |

---

## 4. 纠正 AI 的话术

如果 AI 走偏了，直接告诉它：

| 问题 | 你该说什么 |
|------|-----------|
| AI 直接改代码，没有先做 MRI | "请先执行逻辑 MRI，不要直接改代码" |
| AI 范围膨胀了（发现要改 >10 文件） | "这个改动可能涉及接口变更，请切换回标准生命周期，补写 Spec" |
| AI 忘记更新 ops_changelog | "请按照 meta-safe-executor 协议更新 ops_changelog" |
| AI 使用了错误的 skill | "请重新读取 project-entry skill，按正确的触发条件执行" |
| AI 上下文太长，开始 hallucinate | "请执行 Compaction/Offloading，把分析结果写入文件" |
| AI 声称完成但没有验证 | "请展示三层验证的证据（Layer 1/2/3）" |

---

## 5. 快速参考

| 文档 | 什么时候看 |
|------|-----------|
| `AGENTS.md` | AI 行为异常时，检查它是否遵循了规范 |
| `docs/superpowers/lifecycle.md` | 不确定当前处于什么阶段时 |
| `docs/superpowers/surgical-workflow-concept.md` | AI 应该用 Surgical Workflow 但没有用时 |
| `docs/superpowers/context-management-strategy.md` | 会话太长、AI 开始遗忘上下文时 |
| `docs/standards/code-standards-QUICK-REF.md` | 审查 AI 写的代码质量时 |
| `docs/superpowers/tips.md` | 需要具体的 `gh` 命令或 worktree 操作时 |

---

## 6. Superpowers 技能库

本模板基于 [obra/superpowers](https://github.com/obra/superpowers) 构建。Superpowers 是一个开源的 AI 开发技能框架，定义了标准化的开发流程与可复用的 agent 技能。

**核心工作流：**

1. **brainstorming** — 需求澄清与设计确认（Socratic questioning）
2. **writing-plans** — 生成可执行的实施计划（one task per file）
3. **executing-plans** — 按步骤执行并验证
4. **test-driven-development** — RED-GREEN-REFACTOR 循环
5. **requesting-code-review** — 代码审查与反馈

完整技能库：测试（TDD）、调试（systematic-debugging）、协作（brainstorming/writing-plans/executing-plans/subagent-driven-development）、元技能（writing-skills/using-superpowers）等 14+ 个可组合技能。

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

### 项目内集成（不支持插件市场时）

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

---

## 7. Scripts 速查

> **平台后缀约定**：`.sh` = Bash（macOS / Linux / WSL），`.ps1` = PowerShell（Windows）。每个脚本功能相同，按你的环境选一种运行。

| 脚本 | 是什么 | 什么时候用 | 怎么做 | 为什么 |
| --- | --- | --- | --- | --- |
| `setup-dev` | 安装 lefthook 并注册 Git hooks | 首次 clone 仓库后 | `./scripts/setup-dev.sh`（或 `.ps1`） | 不安装则提交不会经过任何安全检查 |
| `check-agents-md` | 检查 `AGENTS.md` 是否 ≤ 100 行 | 每次提交前（自动） | lefthook 自动调用 | 防止系统 prompt 膨胀，降低 Agent 推理质量 |
| `check-docs-structure` | 检查 handoff/skill 文件的 front matter 完整性 | 每次提交前（自动） | lefthook 自动调用 | 确保 AI 上下文交接文档和技能文件可被正确解析 |
| `forbid-destructive` | 在 diff 中检测 `rm -rf`、`git push --force`、`DROP TABLE` 等危险模式 | 每次提交前（自动） | lefthook 自动调用 | 拦截破坏性操作，要求 Driver 确认 |
| `check-conventional-commit` | 检查 commit message 是否符合 `type(scope): description` 格式；**人机区分**：检测到 AI CLI 环境变量（`OPENCODE`/`CLAUDECODE`/`AGENT`/`CURSOR_AGENT`）时不合规则强制阻断，人工终端提交仅警告不阻断（可用 `AI_AGENT=1/0` 显式覆盖） | 每次提交前（自动） | lefthook 自动调用 | 生成标准化 CHANGELOG，便于追溯；同时不给人工日常提交增加负担 |
| `check-ops-changelog` | 代码变更时要求更新 `.project/ops_changelog.md`；**人机区分**同上（AI 强制阻断，人工仅警告） | 每次提交前（自动） | lefthook 自动调用 | 保证 AI 自动化操作有审计记录；PR 层 `audit_check` CI 对所有人无差别强制兜底 |
| `context-guard` | 上下文健康检查（--tokens 报告用量） | 每完成 3-5 个 subtask（AI 执行） | `bash scripts/context-guard.sh --tokens N` | ≥256k 防发散预警、≥128k 建议卸载 |
| `sync-skills` | 将平台无关的 `skills/` 同步到 `.gemini/skills/` 等平台目录 | 修改 `skills/` 后手动运行 | `./scripts/sync-skills.sh`（或 `.ps1`） | `.gemini/skills/` 是副本，主库在 `skills/` |
| `ai_reviewer` | AI 代码审查（供应商可配置，默认 DeepSeek，可换智谱等任意 OpenAI 兼容端点） | CI 中自动触发 | GitHub Actions 自动调用（凭据配置见 tips.md「AI 审查供应商配置」） | 用标准文档统一审查尺度，减少人工漏检 |
