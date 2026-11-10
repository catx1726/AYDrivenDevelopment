# Superpowers 插件安装探测调研（2026-11-10）

> 课题：check-adoption 能否对全部 16 个 harness 做文件级 Superpowers 安装探测。
> 背景：issue #19 落地了 OpenCode + Claude Code 探测后，Driver 提出「能安装必然落盘，
> 大概率都有办法探测」——本调研验证该假设的边界。

## 1. 事实来源

- 上游 `obra/superpowers` README Installation 章节（16 平台安装命令）
- 上游 `docs/porting-to-a-new-harness.md`（插件适配架构规则）
- 上游 `docs/README.opencode.md` / `docs/README.kimi.md`（仅此两平台有专属文档）
- Gemini CLI / Qwen Code 官方文档（extensions 机制）+ 本机实测

## 2. 关键架构事实

1. **上游只提供 repo 侧清单**：`.claude-plugin/`、`.codex-plugin/`、`.cursor-plugin/`、
   `.kimi-plugin/plugin.json`、`.devin-plugin/`、`.hermes-plugin/`、`.muse-plugin/`、
   `.antigravity-plugin/`、`.pi/extensions/`、`gemini-extension.json`、`.opencode/`——
   这些是「喂给 harness 安装器」的清单，**不是用户机器落盘路径**。
2. **落盘路径由各 harness 定义**：porting 文档核心规则「一切经由 harness 自己的安装机制，
   绝不改用户全局配置」→ 上游刻意不记录、不依赖用户侧路径。
3. **Droid 消费 Claude Code 插件格式**（porting 文档 L127）：`droid plugin install` 包装
   Claude plugin → `~/.factory/` 下应有 Claude 格式 plugin.json（推断，未官方文档化）。
4. **Qwen Code 是 gemini-cli fork**：extensions 布局与 Gemini CLI 相同
   （`~/.<harness>/extensions/<name>/gemini-extension.json`）。

## 3. 探测矩阵（按权威程度分级）

| 级别 | 平台 | 权威探测点 | 依据 |
|------|------|-----------|------|
| A（文档化清单） | OpenCode | `opencode.json` 的 `plugin`(V1)/`plugins`(V2) 数组含 superpowers | 上游 INSTALL.md |
| A | Gemini CLI | `~/.gemini/extensions/` 下出现 superpowers 目录 | 官方文档 + 本机实测 |
| A | Qwen Code | `~/.qwen/extensions/` 同上 | fork 继承 |
| A（目录约定） | Claude Code | `~/.claude/plugins/` 内 *.json 含 superpowers（config.json 记录 marketplace 安装） | 官方 marketplace 机制 |
| B（格式推断） | Droid | `~/.factory/plugins|extensions/` 内 Claude 格式清单 | porting 文档 L127 |
| C（无文档，仅启发式） | Codex / Cursor / Copilot CLI / Kimi Code / Grok / Devin / Antigravity / Pi / Hermes / Muse | 各 home 目录（`~/.<harness>/`）的 plugins|extensions 子目录与顶层 config.json/toml 中的肯定信号 | 无权威文档 |
| 兜底 | 全部 | 项目内 `skills/superpowers`、`node_modules/superpowers`（clone/npm 方式残留） | 旧安装方式 |

## 4. 逻辑边界（不可消除，必须降级）

- 文件痕迹能证明「**已装**」（肯定信号精度高：插件内容必然含 superpowers 字符串）；
  无法证明「**未装**」——C 级平台的落盘路径无官方文档，启发式扫描漏检 ≠ 未安装。
- 因此未检出时**只降级为通用提示，不报 ❌**（避免误杀导致 Driver 重复安装）。
- Kimi `/plugins info superpowers`、Claude `/plugin` 等为会话内命令，check-adoption
  （终端脚本）不可调用，脚本化只能走文件系统。

## 5. 设计红线（来自 porting 文档的启示）

- 探测脚本**只读**，绝不写任何 harness 配置（与 porting「绝不改用户全局配置」同源）；
- 启发式扫描**刻意排除** sessions/projects/history 等转录目录——历史会话讨论过
  superpowers 会产生误报；
- 未经 Driver 授权不得自动安装：交互型安装（`/plugin install` 等斜杠命令）物理上只有
  Driver 能执行；配置型安装（OpenCode 改 opencode.json）须 Driver 明确授权后 AI 方可
  按上游官方指引代办（人机分工契约，2026-11-10 Driver 决策：按平台区分）。

## 6. 落地

- `scripts/check-adoption.{sh,ps1}` [3/3] 段按本矩阵实现：
  A 级精确清单对比 + B/C 级启发式肯定信号 + 兜底项目内痕迹 + 未检出降级提示。
- 实测：fake HOME 三平台命中 ✅；本机 gemini extensions 真阳性命中 ✅。
