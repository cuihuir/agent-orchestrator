# Third-Party Model Integration

## API Key 配置

**只在 `.zshrc` 中存 API Key，不要设置模型相关变量。** dispatch.sh 会在运行时临时注入模型变量，避免和默认 Claude 冲突。

```bash
# ~/.zshrc - 只加这几行
export GLM_API_KEY="your-glm-key"
export MIMO_API_KEY="your-mimo-key"
export MINIMAX_API_KEY="your-minimax-key"
```

原有的 `ccz`/`ccm` alias 可以保留用于交互式会话，但 dispatch.sh 不依赖它们。

## Available Models

### GLM (智谱)
- **Dispatch target**: `claude-glm`
- **Alias**: `ccz` (交互式)
- **Endpoint**: `https://open.bigmodel.cn/api/anthropic`
- **Model**: `glm-5.1`
- **Env**: `GLM_API_KEY`

### Mimo (小米)
- **Dispatch target**: `claude-mimo`
- **Alias**: `ccm` (交互式)
- **Endpoint**: `https://token-plan-cn.xiaomimimo.com/anthropic`
- **Model**: `mimo-v2.5-pro`
- **Env**: `MIMO_API_KEY`

### MiniMax
- **Dispatch target**: `claude-minimax`
- **Endpoint**: `https://api.minimaxi.com/anthropic`
- **Model**: `MiniMax-M2.7`
- **Env**: `MINIMAX_API_KEY`

## Usage

### Dispatch script (推荐)
```bash
dispatch.sh claude-glm "translate this to Chinese"
dispatch.sh claude-mimo "analyze this code"
dispatch.sh claude-minimax "implement this feature"
```

### Shell 直接调用
```bash
# GLM
ANTHROPIC_BASE_URL="https://open.bigmodel.cn/api/anthropic" \
ANTHROPIC_AUTH_TOKEN="$GLM_API_KEY" \
ANTHROPIC_DEFAULT_SONNET_MODEL="glm-5.1" \
claude -p --bare "your prompt"

# Mimo
ANTHROPIC_BASE_URL="https://token-plan-cn.xiaomimimo.com/anthropic" \
ANTHROPIC_AUTH_TOKEN="$MIMO_API_KEY" \
ANTHROPIC_DEFAULT_SONNET_MODEL="mimo-v2.5-pro" \
claude -p --bare "your prompt"

# MiniMax
ANTHROPIC_BASE_URL="https://api.minimaxi.com/anthropic" \
ANTHROPIC_AUTH_TOKEN="$MINIMAX_API_KEY" \
ANTHROPIC_DEFAULT_SONNET_MODEL="MiniMax-M2.7" \
ANTHROPIC_DEFAULT_OPUS_MODEL="MiniMax-M2.7" \
ANTHROPIC_DEFAULT_HAIKU_MODEL="MiniMax-M2.7" \
CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC="1" \
claude -p --bare "your prompt"
```

### 交互式会话（alias）
```bash
ccz   # GLM 交互式
ccm   # Mimo 交互式
# MiniMax 建议也加一个 alias:
# alias ccmx='export ANTHROPIC_BASE_URL="https://api.minimaxi.com/anthropic";export ANTHROPIC_AUTH_TOKEN="$MINIMAX_API_KEY";export ANTHROPIC_DEFAULT_SONNET_MODEL="MiniMax-M2.7";export ANTHROPIC_DEFAULT_OPUS_MODEL="MiniMax-M2.7";export ANTHROPIC_DEFAULT_HAIKU_MODEL="MiniMax-M2.7";export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC="1";claude'
```

## When to Use Third-Party Models

| Scenario | Recommended Model |
|----------|-------------------|
| Cost-sensitive tasks | GLM / Mimo / MiniMax |
| Chinese language tasks | GLM / Mimo / MiniMax |
| Complex reasoning | Claude (default) |
| Code generation | Claude (default) or Mimo |
| Quick analysis | GLM (fast) |
| Long context | MiniMax |

## Cross-Model Orchestration

Pattern: use Claude for planning, third-party for execution:
1. Claude creates implementation plan
2. GLM/Mimo/MiniMax executes individual file changes
3. Claude reviews and integrates results
