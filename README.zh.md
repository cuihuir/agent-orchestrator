# Agent Orchestrator - 跨 Agent 调度器

[English](README.md)

Claude Code 和 Codex 的跨 Agent 编排技能。支持在 Claude Code、Codex 和第三方模型（GLM、Mimo、MiniMax）之间互相派发任务。

## 功能特性

- **Claude Code <-> Codex** 互相委派任务
- **第三方模型支持**：GLM（智谱）、Mimo（小米）、MiniMax
- **并行任务调度**：独立任务可并行执行
- **调度脚本**：支持超时、输出捕获、dry-run 模式

## 安装

```bash
git clone https://github.com/cuihuir/agent-orchestrator.git
cd agent-orchestrator
./install.sh
```

安装器会：

- 安装 Claude Code skill 到 `~/.claude/skills/agent-orchestrator`
- 安装 Codex skill 到 `~/.codex/skills/agent-orchestrator`
- 设置 `scripts/dispatch.sh` 为可执行
- 创建 `~/.local/bin/agent-dispatch`（指向 dispatch.sh 的符号链接）
- 可选：将 GLM/Mimo/MiniMax API Key 写入 `~/.zshrc`

安装选项：

```bash
./install.sh --no-api-keys  # 跳过 API Key 提示，不往 ~/.zshrc 写入任何 key
./install.sh --api-keys      # 立即进入 API Key 输入流程（非交互终端会报错）
./install.sh --no-bin        # 不创建 ~/.local/bin/agent-dispatch 快捷方式
./install.sh --dry-run       # 只预览会执行的操作，不实际写入任何文件
```

手动调度路径（与 `agent-dispatch` 是同一个脚本，适合使用了 `--no-bin` 或偏好完整路径的用户）：

```bash
~/.claude/skills/agent-orchestrator/scripts/dispatch.sh
```

## API Key 配置

在 `~/.zshrc` 中添加（只存 key，不存模型变量）：

```bash
export GLM_API_KEY="你的 GLM Key"
export MIMO_API_KEY="你的 Mimo Key"
export MINIMAX_API_KEY="你的 MiniMax Key"
```

## CLI 触发示例

在 Claude Code 或 Codex 对话中使用以下短语，skill 会自动触发：

```
# 让 Codex 干活（从 Claude Code 发起）
"use codex 来创建一个 parser 模块"
"把这个任务委派给 codex"
"let codex handle the implementation"

# 让 Claude 干活（从 Codex 发起）
"ask claude to review this file"
"use claude 做安全审计"
"delegate to claude"

# 使用第三方模型
"use glm 翻译这段内容"
"use mimo 分析一下"
"use minimax 来处理这个任务"

# 交互式别名（shell 中直接使用）
ccz     # 启动 GLM 交互式会话
ccm     # 启动 Mimo 交互式会话
ccmx    # 启动 MiniMax 交互式会话
```

## 使用方式

```bash
# 调度到 Codex
agent-dispatch codex "创建 src/utils/parser.ts"

# 调度到 Claude
agent-dispatch claude "审查 src/auth.ts 的安全性"

# 调度到第三方模型
agent-dispatch claude-glm "翻译成中文"
agent-dispatch claude-mimo "分析这段代码"
agent-dispatch claude-minimax "实现这个功能"

# 并行调度
agent-dispatch codex "任务 A" --output /tmp/a.txt &
agent-dispatch codex "任务 B" --output /tmp/b.txt &
wait

# Dry run（预览命令，不实际执行）
agent-dispatch claude "测试提示" --dry-run
```

## 交互式别名

在 `~/.zshrc` 中添加：

```bash
alias ccz='ANTHROPIC_BASE_URL="https://open.bigmodel.cn/api/anthropic" ANTHROPIC_AUTH_TOKEN="$GLM_API_KEY" ANTHROPIC_DEFAULT_OPUS_MODEL="glm-5.1" ANTHROPIC_DEFAULT_SONNET_MODEL="glm-5.1" ANTHROPIC_DEFAULT_HAIKU_MODEL="glm-5.1" claude'
alias ccm='ANTHROPIC_BASE_URL="https://token-plan-cn.xiaomimimo.com/anthropic" ANTHROPIC_AUTH_TOKEN="$MIMO_API_KEY" ANTHROPIC_DEFAULT_OPUS_MODEL="mimo-v2.5-pro" ANTHROPIC_DEFAULT_SONNET_MODEL="mimo-v2.5-pro" ANTHROPIC_DEFAULT_HAIKU_MODEL="mimo-v2.5-pro" claude'
alias ccmx='ANTHROPIC_BASE_URL="https://api.minimaxi.com/anthropic" ANTHROPIC_AUTH_TOKEN="$MINIMAX_API_KEY" ANTHROPIC_DEFAULT_OPUS_MODEL="MiniMax-M2.7" ANTHROPIC_DEFAULT_SONNET_MODEL="MiniMax-M2.7" ANTHROPIC_DEFAULT_HAIKU_MODEL="MiniMax-M2.7" CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC="1" claude'
```

## 编排模式

| 模式 | 流程 |
|------|------|
| Codex 实现，Claude 审查 | Claude 规划 -> Codex 构建 -> Claude 审查 |
| Claude 分析，Codex 实现 | Codex 需要帮助 -> Claude 分析 -> Codex 实现 |
| 多模型流水线 | Claude 规划 -> GLM 起草 -> Codex 精修 -> Claude 集成 |

## 许可证

MIT
