# 代码审查回复模板 (Code Review Reply Template)

本模板用于在 PR 经过多轮修改后，向 reviewer 同步变更内容。适用于 AI 自动审查或人类 reviewer 提出意见后的回复。

---

## 使用时机

在以下情况后，应使用该模板发布一条 PR 评论：

1. 完成一轮 AI CR / 人类 reviewer 提出的 Blocking 或 Nit 修复后。
2. 关键设计、验证结果或 PR 描述内容发生实质性变更后。
3. 需要请求 reviewer 重新 review（re-review）时。

**不建议**在每次微小 push 后都发评论；应在完成一个完整的修复轮次后集中同步。

---

## 评论模板

```markdown
## 🔄 Review Round Update / 第 N 轮修改同步

### 处理概览

| 原意见 | 类型 | 处理状态 | 说明 |
|--------|------|----------|------|
| <!-- 例如：B1 connectSync 时序问题 --> | Blocking / Nit | ✅ 已修复 / ⚠️ 部分修复 / ❌ 未修复（原因） | <!-- 简要说明改动文件与方式 --> |

### 关键变更

- **文件1**: `src/...` — <!-- 一句话说明 -->
- **文件2**: `src/...` — <!-- 一句话说明 -->

### 验证结果

- [ ] 单元测试：`X/Y` 通过
- [ ] 构建：`npm run build` / `pnpm build` 通过
- [ ] 手动测试：<!-- 截图/录屏/关键日志 -->
- [ ] 其他：<!-- lint / type-check / e2e -->

### 仍需讨论的点

<!-- 如果有未修复或需要确认的意见，在此列出并 @ 相关人员 -->

### 请求

请 reviewer 重新审查以上改动。若有遗漏或新的问题，欢迎继续指出。
```

---

## 填写示例

```markdown
## 🔄 Review Round Update / 第 2 轮修改同步

### 处理概览

| 原意见 | 类型 | 处理状态 | 说明 |
|--------|------|----------|------|
| B1 `Options.vue` 中 `connectSync` 的时序问题 | Blocking | ✅ 已修复 | 改为先 `triggerPull()` 再 `enabled = true`，避免拉取与推送并发 |
| B2 `canPush` 条件过于严格 | Blocking | ✅ 已修复 | 改为 `lastSyncStatus !== 'none'`，允许 error 状态下重试 |
| N1 `mergeWithRemoteFile` 命名 | Nit | 📝 已记录到 `docs/NIT_ROADMAP.md` | 本轮不修改 |

### 关键变更

- `src/options/Options.vue`: 抽离 `triggerPull()`，统一处理超时和 fallback。
- `src/background/main.ts`: `performPull` 返回 `boolean`，`performPush` 不再依赖全局 `syncStatus`。
- `src/logic/sync.ts`: `mergeWithRemoteFile` 中 `JSON.parse` 增加 `try-catch`。
- `src/tests/sync.spec.ts`: 新增远程文件损坏的测试用例。

### 验证结果

- [x] 单元测试：`16/16` 通过 (`src/tests/sync.spec.ts`)
- [x] 构建：`corepack pnpm build` 通过
- [ ] 手动测试：本地 Chrome 扩展加载中，待验证

### 请求

@reviewer 请重新审查，谢谢！
```

---

## 与 PR 描述更新的区别

| 方式 | 位置 | 用途 |
|------|------|------|
| **PR 描述更新** | PR body | 变更范围、设计决策、验证结果发生**结构性变化**时更新，方便新打开 PR 的人快速了解全貌。 |
| **PR 评论（本模板）** | PR 评论区 | 逐轮回复 reviewer 意见、说明已处理项、请求 re-review，保留审查线程历史。 |

推荐做法：**以 PR 评论为主**，仅在 PR 描述中的关键信息（如验证结果、关联 Issue、变更列表）发生较大变化时，才同步更新 PR body。

---

## 自动化建议

AI 引擎在处理完一轮 CR 意见后：

1. 汇总已修复的 Blocking / Nit 项。
2. 运行验证命令并记录结果。
3. 使用本模板生成 PR 评论内容。
4. 由 Driver 审核后，通过 `gh pr comment <PR_NUMBER> --body-file <FILE>` 发布。

---
*YOU-DRIVE-SOP - 驱动规约，掌握智力。*
