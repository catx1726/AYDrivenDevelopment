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

> `setup-dev` 会自动安装 lefthook 并把 hooks 注册到 `.git/hooks/`。
> 不安装则提交不会经过 AGENTS.md 大小检查、破坏性命令拦截等安全机制。

## 文档地图（SSOT）

**本文档不重复具体流程，所有详细内容在以下文档中：**

| 文档 | 面向读者 | 内容 |
|------|---------|------|
| `AGENTS.md` | AI Agent | 系统 prompt 地图（< 100 行）。工程标准索引 + 人机交互规范 |
| `docs/superpowers/lifecycle.md` | 人类 + AI | **唯一**完整开发生命周期（Mermaid 图 + 阶段说明） |
| `docs/superpowers/tips.md` | 人类 | Issue/PR/Worktree 命令操作提示 |
| `docs/standards/` | 人类 + AI | 工程标准（代码规范、TDD、API 设计、安全等） |
| `docs/superpowers/handoffs/` | AI | 跨会话上下文交接文档 |
| `scripts/` | 人类 + AI | 开发工具脚本（setup-dev、check-agents-md 等） |

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
├── scripts/
│   ├── setup-dev.sh            # 开发环境一键安装
│   ├── check-agents-md.sh      # AGENTS.md 大小检查
│   ├── forbid-destructive.sh   # 破坏性命令检测
│   └── check-conventional-commit.sh  # Commit message 检查
└── .gemini/
    └── ops_changelog.md        # 操作审计日志
```

## 常见问题

**Q: 如何验证 hooks 已正确安装？**
A: `ls .git/hooks/pre-commit` —— 如果存在（不是 `.sample`），说明已生效。

**Q: 不想装 lefthook 可以吗？**
A: 可以跳过，但提交不会经过：AGENTS.md 大小检查、破坏性命令拦截、Conventional Commit 校验。建议至少运行一次 `./scripts/setup-dev.sh`。
