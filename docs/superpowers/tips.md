# Issue / PR 最佳实践

## 前提：环境依赖清单

| 依赖 | 用途 | 必要性 | 安装/配置 |
|------|------|--------|----------|
| git（Windows 需 Git for Windows） | 基础 + `.sh` 钩子的 bash 来源 | 必须 | 自带/官网安装 |
| Node.js | `setup-dev` 安装 lefthook、markdownlint 钩子 | 必须 | https://nodejs.org |
| GitHub CLI（`gh`） | 生命周期 Issue/PR 环节 | 必须（Issue/PR 流程） | 见下方安装 |
| **Superpowers 插件** | 生命周期技能（brainstorming/writing-plans/TDD 等）由 AI CLI 插件提供，**不是母库内置功能** | 必须（完整生命周期） | 按 AI 平台安装，见 human-guide.md §6 |
| python3 | `context-guard.sh` 的会话耗时计算 | 可选（缺失时 elapsed 显示 unknown，token 检测不受影响） | 系统包管理器 |
| AI 审查凭据（repo secrets/variables） | `ai_review` CI 的 AI 代码审查，供应商可配置 | 可选（不配置则该 workflow 不可用，其余 CI 不受影响） | 见下方「AI 审查供应商配置」 |

GitHub CLI 安装与认证：

```bash
# 安装（按平台选一）
winget install GitHub.cli          # Windows（或 scoop install gh）
brew install gh                    # macOS
sudo apt install gh                # Debian/Ubuntu（WSL 同）
# sudo dnf install gh              # Fedora

gh auth login                      # 认证（推荐浏览器流程，自动创建并存储 token）
gh auth status                     # 验证：显示已登录账号即就绪
```

> **token 权限**：`gh auth login` 浏览器流程自动配置。若手动使用 PAT，
> 需勾选 `repo` 完整权限（代码读写 + Issue/PR 创建与评论），
> 否则 `gh issue create` / `gh pr create` 会因 401/403 失败。
> 未安装或未认证时，`gh` 命令直接失败——应先检查此前提，而不是当作流程故障。

一键自检：`bash <SOP-HOME>/scripts/check-adoption.sh`（或 `.ps1`）会检测以上依赖与接入资产。

### AI 审查供应商配置（ai_review CI）

三个仓库级变量，任意 OpenAI 兼容端点即可（以智谱 GLM 为例）：

| 变量 | 配置位置 | 智谱示例值 | 不配置时的默认 |
|------|---------|-----------|---------------|
| `AI_API_KEY` | Settings → Secrets and variables → Actions → **Secrets** 标签 | 你的智谱 API Key | 兼容读取旧名 `DEEPSEEK_API_KEY`；都没有则 ai_review 跳过 |
| `AI_BASE_URL` | 同上 → **Variables** 标签 | `https://open.bigmodel.cn/api/paas/v4` | `https://api.deepseek.com` |
| `AI_MODEL` | 同上 → **Variables** 标签 | `glm-4.6`（按需选型） | `deepseek-chat` |

> Secrets 与 Variables 在同一设置页的两个标签：**Secrets** 存凭据（日志中打码），
> **Variables** 存非敏感配置。配错标签是常见失误。

## Windows 环境注意事项

### 红线：禁止用 PowerShell 5.1 文本管道编辑仓库文件

`Get-Content | Set-Content` 会破坏 BOM-less UTF-8：中文注释乱码、吞掉字符串闭合引号
（本地无感知，CI bash 直接语法错误）。改用编辑器、`sed` 或 `gh --body-file`。

相关提示：

- **控制台中文乱码**：GBK 代码页下显示乱码 ≠ 文件损坏，先 `chcp 65001` 再看，勿误判后"修复"文件
- **bash 解析到 WSL stub**：若 `bash` 指向 `C:\Windows\System32\bash.exe`（WSL 未装发行版），
  钩子全部失效——安装 Git for Windows 并确保 Git Bash 在 PATH，或在 lefthook.yml 中写 Git Bash 绝对路径
  （`setup-dev.ps1` 会检测并警告）
- **`gh ssh-key add`**：需要 `admin:public_key` scope，缺失时先 `gh auth refresh -s admin:public_key`
- **PowerShell 执行策略**：Windows 默认 Restricted 会拦截 `.\scripts\*.ps1`（报"禁止运行脚本"）。
  Driver 手动执行一次 `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`，
  或单次绕过 `powershell -ExecutionPolicy Bypass -File <脚本>`

### gh issue create 必须使用 `--body-file`

**⚠️ 原因**：Windows 下 `--body "文本"` 会导致 Markdown 内容丢失。

```bash
# ✅ 正确方式：使用临时文件
echo "## 📋 需求描述..." > temp_body.md
gh issue create --title "标题" --body-file temp_body.md --label "enhancement"
rm temp_body.md

# ❌ 错误方式：Windows 下 Markdown 内容会丢失
gh issue create --title "标题" --body "## 内容..."
```

## Worktree 快速命令

本项目使用 **superpowers `using-git-worktrees` skill** 管理 worktree。Agent 会自动按规范执行。

如需手动操作，项目命名规范为：

```bash
# 创建隔离工作区
git worktree add ../<repo>-issue-N -b issue-N-feature-name

# 进入工作区工作
cd ../<repo>-issue-N

# 完成后清理
git worktree remove ../<repo>-issue-N
```

## 破坏性操作 checklist

执行以下操作前必须记录审计日志并确认：

- `rm -rf` 删除目录
- `git push --force`
- 数据库迁移 / schema 变更
- 核心逻辑重构

## 上下文管理快速参考

长任务中 AI 可能出现**上下文腐烂**（遗忘早期决策）或**上下文焦虑**
（ prematurely wrapping up）。参考 `docs/superpowers/context-management-strategy.md`。

### 触发信号（满足任一即执行）

- 连续执行超过 **60 分钟**
- 修改/读取文件超过 **25 个**
- AI 开始重复之前的分析
- AI 主动说"让我简要总结"

### 三种策略

| 策略 | 操作 | 适用场景 |
|------|------|---------|
| **Compaction** | 精简 todo、归档决策、删除已完成分支详情 | 同一会话内，上下文臃肿但未失效 |
| **Offloading** | 将大段分析写入文件，会话只留引用 | 调研报告、Logic MRI 输出 |
| **Reset** | 结束会话，新建会话，通过 handoff 文件接续 | 超过 2h 或 AI 多次出现焦虑症状 |

### Reset Handoff 文件位置

```text
docs/superpowers/evaluator-handoffs/<task-id>-<timestamp>.md
```

### 危险信号

- 🟡 AI 说"由于上下文限制，我简要说明..." → **立即 Reset**
- 🟡 AI 遗忘了 10 分钟前的决策 → **立即 Compaction**
- 🟡 同一任务 Reset 超过 3 次 → **任务拆分过粗，需要重新 Plan**

## 技能同步（跨平台）

本项目技能存储在平台无关的 `skills/` 目录，通过脚本同步到各 AI CLI 平台。

```bash
# 默认同步到 .gemini/skills/
bash scripts/sync-skills.sh

# 同步到多个平台
bash scripts/sync-skills.sh --target .gemini/skills --target .claude/skills
```

```powershell
# PowerShell
.\scripts\sync-skills.ps1 -Target .gemini/skills
```

## 合规检查快速参考

任务完成前，激活 `meta-compliance-checker` skill 并逐项勾选 checklist：

- **安全标准**：输入校验 / 敏感信息 / 错误响应 / 权限检查 / 最小权限
- **TDD 标准**：测试先行 / 回归测试 / 测试通过 / 覆盖合理
- **日志标准**：级别正确 / 无敏感信息 / 结构化 / 上下文完整
- **文档结构**：文件名规范 / front matter 完整 / 目录正确

违规记录：`docs/superpowers/handoffs/` 中的任务 handoff 或 `.project/compliance_log.md`

> **Surgical Workflow 精简版**：使用手术切入式工作流时，只需勾选 3 项阻断项（输入校验 / 无敏感信息 / 测试通过），无需完整 checklist。详见 `docs/superpowers/surgical-workflow-concept.md`。
