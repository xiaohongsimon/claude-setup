# Claude HUD 配置说明

Claude HUD 通过 Claude Code 插件系统安装。

## 安装步骤

1. **安装插件** (在 Claude Code 中运行):
```
/install claude-hud@jarrodwatts
```

2. **配置 settings.json**:

编辑 `~/.claude/settings.json`，添加以下内容：

```json
{
  "enabledPlugins": {
    "claude-hud@jarrodwatts": true
  },
  "statusLine": {
    "type": "command",
    "command": "bash -c 'plugin_dir=$(ls -d \"${CLAUDE_CONFIG_DIR:-$HOME/.claude}\"/plugins/cache/claude-hud/claude-hud/*/ 2>/dev/null | awk -F/ '\"'\"'{ print $(NF-1) \"\\t\" $0 }'\"'\"' | sort -t. -k1,1n -k2,2n -k3,3n -k4,4n | tail -1 | cut -f2-); exec \"/opt/homebrew/bin/node\" \"${plugin_dir}dist/index.js\"'"
  }
}
```

## 参考链接

- GitHub: https://github.com/jarrodwatts/claude-hud
- 原文档：https://github.com/jarrodwatts/claude-hud/blob/main/README.md
