# Issue / PR 最佳实践

## Windows 环境注意事项

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
