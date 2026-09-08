# 子库接入指南（Child Repo Adoption Guide)

面向以「母库引用」模式使用本模板的开发者与 AI：**规范读母库（SSOT），运行时资产归子库**。

> 术语约定：**子库**（又称字库 / child repo）= 承载实际业务代码的项目仓库；
> **母库**（SOP repo / 本仓库）= 规范、流程与工具链的单一事实来源。

## 1. 两种使用模式

| 模式 | 做法 | 适合场景 |
|------|------|---------|
| **A. 全量复制** | 将模板文件复制进项目根目录，项目自足 | 独立分发、不依赖本地母库存在 |
| **B. 母库引用（本指南）** | 本地 clone 母库；子库只持有运行时资产；规范按需直读母库 | 规范升级一处生效、多子库共享 SOP |

模式 B 的日常形态：开发者在子库启动 AI CLI，告知母库本地路径；AI 按本指南的
路径解析规则工作。母库路径**由开发者每会话口头提供**（或填写在子库 AGENTS.md 中，
见 §4），不做环境变量等全局持久化。

## 2. 资产分类规则表（AI 必读，最高优先级）

判定基准：**母库 = 只读规范；子库 = 可写运行时**。

| 类别 | 资产 | 读取/写入位置 |
|------|------|--------------|
| **规范（只读母库）** | `AGENTS.md`、`docs/standards/**`、`docs/domain/**`、`skills/**`、`docs/superpowers/` 下的规范文件（`lifecycle.md`、`context-management-strategy.md`、`surgical-workflow-concept.md`、`context-toolchain.md`、`human-guide.md`、`tips.md`） | `<SOP-HOME>/...` |
| **安装件（复制到子库）** | `scripts/**`、`lefthook.yml`、`.github/**`（workflows、Issue/PR 模板、CODEOWNERS） | 子库根（本地 hook 与子库 GitHub CI 硬依赖仓库内文件） |
| **运行时产物（写入子库）** | `docs/superpowers/{specs,plans,handoffs,decisions,evaluator-handoffs}/`、`docs/playbooks/`（案例归档）、`.project/**`（审计日志、context-session、distill_stage）、`CHANGELOG.md` | 子库 CWD |

`docs/superpowers/` 内部判定规则（消除歧义的关键）：

- 其下的**子目录** `specs/ plans/ handoffs/ decisions/ evaluator-handoffs/` 是运行时容器 → **子库**
- 其下的**散置 `.md` 文件**（lifecycle 等）是规范 → **母库**
- 其下的 `research/` 是模板设计依据存档 → 规范，**母库**

母库边界说明：母库自身**不设**运行时容器（子库的这些目录由 §3 接入步骤创建）。
若发现母库中新生成了 handoff/decision 等运行时文档，视为违规写入（见下方红线）。

红线：

- ❌ 禁止向 `<SOP-HOME>` 写入任何文件（规范污染）
- ❌ 禁止在母库 CWD 执行脚本（产物会落错仓库）
- ❌ 禁止把规范文件的相对路径解析到子库（会 404）

## 3. 接入步骤（一次性，人类或 AI 照作）

以下命令中 `<SOP-HOME>` 替换为母库本地实际路径。

### Step 1: 复制安装件到子库根

```bash
# bash (macOS / Linux / WSL / Git Bash)
cp -r <SOP-HOME>/scripts ./scripts
cp <SOP-HOME>/lefthook.yml ./
cp -r <SOP-HOME>/.github ./.github
```

```powershell
# PowerShell (Windows)
Copy-Item -Recurse <SOP-HOME>\scripts .\scripts
Copy-Item <SOP-HOME>\lefthook.yml .\
Copy-Item -Recurse <SOP-HOME>\.github .\.github
```

### Step 2: 创建运行时骨架

```bash
# bash
mkdir -p docs/superpowers/specs docs/superpowers/plans docs/superpowers/handoffs \
         docs/superpowers/decisions docs/superpowers/evaluator-handoffs \
         docs/playbooks .project/distill_stage
```

```powershell
# PowerShell
@('specs','plans','handoffs','decisions','evaluator-handoffs') |
  ForEach-Object { New-Item -ItemType Directory -Force -Path "docs\superpowers\$_" }
New-Item -ItemType Directory -Force -Path "docs\playbooks", ".project\distill_stage"
```

再创建三个初始文件：

- `docs/superpowers/handoffs/INDEX.md`：内容一行 `# Handoff 索引`
- `docs/superpowers/decisions/INDEX.md`：内容一行 `# Decision 索引`
- `.project/ops_changelog.md`：复制 `<SOP-HOME>/.project/ops_changelog.md` 的**表头**（前 4 行）作为初始审计日志

可选：复制 `<SOP-HOME>/docs/playbooks/README.md`（归档框架说明）与 `CHANGELOG.md`（CI `close_loop` 会向其追加）。

### Step 3: 创建子库 AGENTS.md

用 §4 模板在子库根创建 `AGENTS.md`（AI CLI 会自动发现它）。
若子库已有 AGENTS.md，将模板内容合并到文件顶部。

### Step 4: 在子库注册本地 hook

```bash
./scripts/setup-dev.sh       # macOS / Linux / WSL
```

```powershell
.\scripts\setup-dev.ps1      # Windows PowerShell
```

（要求子库机器已安装 Node.js；`lefthook.yml` 与 `scripts/` 必须先就位。）

### Step 5: 验证清单

- [ ] `scripts/context-guard.sh` 存在且 `bash scripts/context-guard.sh --tokens 50000` 输出 NONE
- [ ] `.git/hooks/pre-commit` 存在（hook 已注册）
- [ ] `.github/workflows/` 下有 4 个 yml（ai_review / audit_check / close_loop / spec_plan_sync）
- [ ] 在子库 CWD 运行 `bash scripts/generate-handoff.sh <task-id>`，生成的文件落在子库 `docs/superpowers/handoffs/`
- [ ] AI 能读到 `<SOP-HOME>/docs/superpowers/lifecycle.md`（让 AI 复述阶段名即可验证）

## 4. 子库 AGENTS.md 模板

```markdown
# <项目名> AI 执行契约

本项目以「母库引用」模式接入 Base-AI-Driven-Template。完整接入说明见
<SOP-HOME>/docs/superpowers/child-repo-guide.md。

## SOP 位置

- SOP-HOME：<开发者填写本机母库路径，如 D:/code/2026/Base-AI-Driven-Template；
  留空则每会话由开发者口头告知>

## 路径解析规则（最高优先级，冲突时覆盖 SOP 文档内的相对路径）

1. 规范/流程/技能：一律从 <SOP-HOME>/ 读取，入口为 <SOP-HOME>/AGENTS.md
2. 运行时产物（Spec/Plan/handoff/decision/审计日志/CHANGELOG）：一律写入当前工作目录（子库）
3. 脚本：执行子库 scripts/ 副本（bash scripts/xxx.sh 或 .\scripts\xxx.ps1），产物落当前 CWD
4. 禁止向 <SOP-HOME> 写入任何文件

## 资产分类速查

| 类别 | 位置 |
|------|------|
| 读 | <SOP-HOME>：AGENTS.md、docs/standards/、docs/domain/、skills/、docs/superpowers/*.md（规范文件） |
| 写 | 子库：docs/superpowers/{specs,plans,handoffs,decisions,evaluator-handoffs}/、docs/playbooks/、.project/、CHANGELOG.md |
| 子库持有 | scripts/、lefthook.yml、.github/ |
```

## 5. 升级同步

| 母库变更 | 子库动作 |
|---------|---------|
| 规范文档（docs/、skills/、AGENTS.md） | 零动作——下次会话直读即最新 |
| `scripts/`、`lefthook.yml`、`.github/` | 重做 §3 Step 1 复制；若子库有过本地定制，先 diff 再覆盖 |
| 新增运行时目录约定 | 按母库 `child-repo-guide.md` 最新版补建骨架 |

## 6. 常见问题（排错）

| 症状 | 根因与处理 |
|------|-----------|
| AI 报规范文件不存在（404） | 把 `<SOP-HOME>/docs/...` 误解析到子库 CWD——重申路径解析规则 §4 |
| 产物被写进母库 | AI 在母库 CWD 执行了脚本——删除误写文件，提醒 AI「产物写当前子库」 |
| 提交无任何 hook 检查 | Step 4 未在子库执行，或子库缺 Node.js/lefthook |
| 子库 CI 报 `scripts/ai_reviewer.py` 缺失 | Step 1 未执行或 `.github/`、`scripts/` 未提交到子库 |
| `check-ops-changelog` 拦截提交 | 子库 `.project/ops_changelog.md` 未随代码变更更新（Step 2 骨架缺失也会导致） |
| 子库与母库 AGENTS.md 同时存在，AI 读哪个 | 先读子库（CLI 自动发现），子库负责指引去母库——这正是 §4 模板的桥接作用 |
