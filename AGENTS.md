# 工程标准索引 (Engineering Standards Index)

AI 引擎在执行任务时，必须参考以下标准文档以确保工程质量。**严禁跳过规范直接编写代码。**

| 领域 | 规范文档路径 | 适用阶段 |
| :--- | :--- | :--- |
| **代码质量** | `docs/standards/code-standards/README.md` | 执行 (Act) |
| **测试驱动** | `docs/standards/test-driven-development.md` | 验证 (Verify) |
| **API 设计** | `docs/standards/api-design-standards.md` | 启动 (Launch) |
| **系统安全** | `docs/standards/security-standards.md` | 计划/执行 |
| **日志记录** | `docs/standards/logging-standards.md` | 执行 (Act) |
| **环境配置** | `docs/standards/environment-standards.md` | 启动/执行 |
| **代码审查** | `docs/standards/review-standards/review/reviewer/` | 闭环 (Close) |
| **提交描述** | `docs/standards/review-standards/review/developer/` | 闭环 (Close) |

---

# 人机交互规范 (Human-in-the-Loop Standards)

完整生命周期见 `docs/superpowers/lifecycle.md`。

### 1. AI 暂停点 (AI Pause Points)

| 阶段 | 暂停点 | 等待内容 |
| :--- | :--- | :--- |
| **启动** | `brainstorming` 后 | Driver 确认设计规范 Spec |
| **计划** | `writing-plans` 后 | Driver 批准 Plan |
| **执行** | 遇到风险操作 | Driver 指令（破坏性变更） |
| **验证** | 测试失败/歧义 | Driver 澄清或调整预期 |
| **提纯** | `meta-distiller` 后 | Driver 审查资产 |
| **闭环** | 合并请求创建后 | Driver 合并确认 |

### 2. AI 升级条件 (Escalation Conditions)

- **执行失败**：`executing-plans` 连续失败 3 次以上。
- **风险检测**：`meta-safe-executor` 检测到高风险操作。
- **歧义阻塞**：TDD 测试中发现需求歧义，无法继续。
- **资源不足**：需要外部 API 密钥、设计资源或跨团队协调。

### 3. 证据呈现规范 (Evidence Presentation)

AI 在 `verification-before-completion` 阶段必须呈现以下证据：

```markdown
### 验证证据
- [ ] 单元测试通过率：X/Y
- [ ] 手动测试截图/录屏：[附件]
- [ ] 性能对比：优化前后数据
- [ ] 兼容性测试：相关平台/环境
```

---

# 快速参考

- **生命周期详解**: `docs/superpowers/lifecycle.md`
- **Issue/PR 最佳实践**: `docs/superpowers/tips.md`
- **Worktree 管理**: `activate_skill using-git-worktrees` (superpowers skill)
- **Harness 调研上下文**: `docs/superpowers/handoffs/harness-engineering-research-2026-05-27.md`
