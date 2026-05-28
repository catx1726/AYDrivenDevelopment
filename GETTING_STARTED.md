# Getting Started

本文档面向首次加入本项目的**人类开发者**和**AI Agent**。

## 环境准备（一次性）

```bash
# 1. 克隆仓库
git clone <repo-url>
cd <repo-name>

# 2. 安装开发环境依赖（Local Hooks + 工具链）
./scripts/setup-dev.sh        # macOS / Linux / WSL
# 或
.\scripts\setup-dev.ps1      # Windows PowerShell
```

`setup-dev` 会自动完成以下安装：

- [lefthook](https://github.com/evilmartians/lefthook) —— Git hooks 管理器
- 注册 pre-commit / commit-msg hooks 到 `.git/hooks/`

> 不运行 setup-dev 会怎样？你的 `git commit` 不会触发
> AGENTS.md 大小检查、破坏性命令拦截等安全机制，
> 可能导致不合规的提交进入仓库。

## 日常开发流程

### 人类开发者

1. **阅读 AGENTS.md** —— 这是项目的"飞行员检查单"，
   了解工程标准和 AI 交互规范

2. **开始任务前创建隔离工作区**：

   ```bash
   git worktree add ../<repo>-issue-N -b issue-N-feature-name
   cd ../<repo>-issue-N
   ```

   或使用 superpowers skill：`activate_skill using-git-worktrees`

3. **开发 → 提交 → Push → 创建 PR**

4. **PR 合并后清理**：`git worktree remove ../<repo>-issue-N`

### AI Agent（Driver 启动 AI 时）

1. **加载 AGENTS.md** —— 系统 prompt 自动注入

2. **按生命周期执行**：

   - `activate_skill brainstorming` → 设计 Spec → Driver 确认
   - `activate_skill writing-plans` → 编写 Plan → Driver 批准
   - `activate_skill executing-plans` → 按 Task 执行
   - `activate_skill verification-before-completion` → 验证并呈现证据

3. **关键约束**：

   - 任何写操作前必须执行 `meta-safe-executor`（Git 快照 + 审计日志）
   - 破坏性操作必须升级给 Driver 确认
   - 必须通过 `check-agents-md.sh` 等 Local Hooks 检查

## 项目结构速查

```text
.
├── AGENTS.md              # AI 系统 prompt 地图（< 100 行）
├── GETTING_STARTED.md     # 本文档（人类 onboarding）
├── lefthook.yml           # Local Hooks 配置
├── docs/
│   ├── standards/         # 工程标准（代码规范、TDD、API 设计等）
│   └── superpowers/       # Superpowers 工作流文档
│       ├── lifecycle.md   # 完整生命周期 Mermaid 图
│       ├── tips.md        # Issue/PR/Worktree 最佳实践
│       └── handoffs/      # 跨会话上下文交接文档
├── scripts/
│   ├── setup-dev.sh       # 开发环境一键安装
│   ├── check-agents-md.sh # AGENTS.md 大小检查
│   └── forbid-destructive.sh # 破坏性命令检测
└── .gemini/
    └── ops_changelog.md   # 操作审计日志
```

## 常见问题

### Q: 我已经装了 lefthook，为什么 hooks 没生效？

A: `lefthook.yml` 只是配置，必须执行 `npx lefthook install`
才能把配置注册到 `.git/hooks/`。运行 `./scripts/setup-dev.sh`
会自动完成这一步。

### Q: 我不想装 lefthook，可以跳过吗？

A: 可以，但你的提交不会经过以下检查：

- AGENTS.md 是否超过 100 行（挤占 AI 上下文）
- diff 中是否包含 `rm -rf`、`git push --force` 等危险命令
- Commit message 是否符合 Conventional Commits 规范

这些检查是 Harness Engineering 的**执行层**，跳过等于放弃安全网。

### Q: 如何验证 hooks 已正确安装？

A: 运行 `ls .git/hooks/pre-commit` —— 如果存在（不是 `.sample`），
说明已生效。
