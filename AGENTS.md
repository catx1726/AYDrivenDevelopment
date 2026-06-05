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
| **运行时验证** | `skills/meta/meta-runtime-evaluator/SKILL.md` | 验证 (Verify) |
| **合规检查** | `skills/custom/meta-compliance-checker/SKILL.md` | 执行/验证 |
| **手术切入式工作流** | `docs/superpowers/surgical-workflow-concept.md` | 执行 (Act) |
| **上下文管理** | `docs/superpowers/context-management-strategy.md` | 全周期 |
| **上下文工具链** | `docs/superpowers/context-toolchain.md` | 执行 (Act) |
| **代码审查** | `docs/standards/review-standards/review/reviewer/` | 闭环 (Close) |
| **提交描述** | `docs/standards/review-standards/review/developer/` | 闭环 (Close) |

---

## 执行契约 (Execution Contract)

### 人机交互暂停点

| 阶段 | 暂停点 | 等待内容 |
| :--- | :--- | :--- |
| **启动** | `brainstorming` 后 | Driver 确认设计规范 Spec |
| **计划** | `writing-plans` 后 | Driver 批准 Plan |
| **执行** | 遇到风险操作 | Driver 指令（破坏性变更） |
| **验证** | 测试失败/歧义 | Driver 澄清或调整预期 |
| **提纯** | `meta-distiller` 后 | Driver 审查资产 |
| **闭环** | 合并请求创建后 | Driver 合并确认 |

**升级条件**：`executing-plans` 连续失败 3 次以上 / `meta-safe-executor` 检测到高风险 / TDD 歧义阻塞 / 资源不足。详见 `docs/superpowers/lifecycle.md`。

### 上下文管理

- **会话启动**：若存在 handoff，优先阅读 `docs/superpowers/handoffs/` 下最新文档
- **检查频率**：每完成 3-5 个 subtask 运行 `bash scripts/context-guard.sh`，将结果呈现给 Driver
- **禁止事项**：
  - ❌ `context-guard` 建议 RESET 时未经 Driver 确认就继续
  - ❌ 同一任务 Reset 超过 3 次不拆分
  - ❌ 新会话不阅读 handoff 就声称"我了解了"

完整策略见 `docs/superpowers/context-management-strategy.md`。

### 验证证据

验证阶段按三层架构（Layer 1 CI/Hook → Layer 2 Generator 自检 → Layer 3 独立 Evaluator）呈现证据。详见 `skills/meta/meta-runtime-evaluator/SKILL.md`。

---

## 快速参考

- **生命周期详解**: `docs/superpowers/lifecycle.md`
- **上下文管理**: `docs/superpowers/context-management-strategy.md`
- **手术工作流**: `docs/superpowers/surgical-workflow-concept.md`
- **合规检查**: `skills/custom/meta-compliance-checker/SKILL.md`
- **新成员入门**: `README.md`
