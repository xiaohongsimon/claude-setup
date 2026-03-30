#!/bin/bash
# Web Session Setup Script for Claude Code
# 在 claude.ai/code web session 启动时自动配置环境
# 用法: 作为 SessionStart hook 运行，或手动执行
#
# 解决的问题:
#   1. Web 端插件不自动同步 — 自动安装关键插件
#   2. statusLine 命令路径不兼容 Linux — 自动修复 node 路径
#   3. 脚本文件缺失 — 从 repo 复制到 ~/.claude/

set -e

CLAUDE_DIR="${HOME}/.claude"
REPO_DIR=""

# 尝试定位 claude-setup repo（支持多种常见位置）
for dir in "$HOME/claude-setup" "$HOME/dotfiles" "$HOME/projects/claude-setup"; do
    if [ -d "$dir/scripts" ] && [ -f "$dir/scripts/statusline.sh" ]; then
        REPO_DIR="$dir"
        break
    fi
done

echo "🔧 Claude Code Web Session Setup..."

# ── 1. 确保基础目录存在 ──
mkdir -p "$CLAUDE_DIR/commands" "$CLAUDE_DIR/skills"

# ── 2. 复制 statusline 脚本 ──
if [ -n "$REPO_DIR" ] && [ -f "$REPO_DIR/scripts/statusline.sh" ]; then
    cp -f "$REPO_DIR/scripts/statusline.sh" "$CLAUDE_DIR/statusline.sh"
    chmod +x "$CLAUDE_DIR/statusline.sh"
    echo "  ✓ statusline.sh 已复制"
fi

# ── 3. 修复 settings.json 中的 node 路径（macOS → Linux） ──
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
if [ -f "$SETTINGS_FILE" ]; then
    # 检测是否在 Linux 上运行
    if [ "$(uname)" = "Linux" ]; then
        # 查找 node 的实际路径
        NODE_PATH=$(which node 2>/dev/null || echo "")
        if [ -z "$NODE_PATH" ]; then
            # 常见 Linux node 路径
            for p in /usr/bin/node /usr/local/bin/node /home/user/.nvm/versions/node/*/bin/node; do
                if [ -x "$p" ]; then
                    NODE_PATH="$p"
                    break
                fi
            done
        fi

        if [ -n "$NODE_PATH" ]; then
            # 替换 macOS Homebrew node 路径为 Linux node 路径
            if grep -q '/opt/homebrew/bin/node' "$SETTINGS_FILE" 2>/dev/null; then
                sed -i "s|/opt/homebrew/bin/node|${NODE_PATH}|g" "$SETTINGS_FILE"
                echo "  ✓ node 路径已修复: ${NODE_PATH}"
            fi
        fi

        # 修复 macOS 特有的 additionalDirectories 路径
        if grep -q '/Users/' "$SETTINGS_FILE" 2>/dev/null; then
            sed -i "s|/Users/[^/\"']*/Library/LaunchAgents|${HOME}/.config/systemd/user|g" "$SETTINGS_FILE"
            sed -i "s|/Users/[^/\"']*/\.claude|${HOME}/.claude|g" "$SETTINGS_FILE"
            echo "  ✓ 路径已适配 Linux"
        fi
    fi
fi

# ── 4. 检测并安装缺失的插件 ──
PLUGINS_CACHE="$CLAUDE_DIR/plugins/cache"

install_plugin_if_missing() {
    local plugin_name="$1"
    local plugin_dir="$PLUGINS_CACHE/$plugin_name"

    if [ ! -d "$plugin_dir" ] || [ -z "$(ls -A "$plugin_dir" 2>/dev/null)" ]; then
        echo "  ⏳ 插件 $plugin_name 缺失，将在 Claude Code 启动后自动安装"
        echo "     运行: /install $plugin_name"
        return 1
    else
        echo "  ✓ 插件 $plugin_name 已就绪"
        return 0
    fi
}

echo ""
echo "📦 检查插件状态..."
MISSING_PLUGINS=()
install_plugin_if_missing "claude-hud" || MISSING_PLUGINS+=("claude-hud@jarrodwatts")
install_plugin_if_missing "superpowers" || MISSING_PLUGINS+=("superpowers@claude-plugins-official")

# ── 5. 确保 jq 可用（statusline.sh 依赖） ──
if ! command -v jq &>/dev/null; then
    echo ""
    echo "⚠️  jq 未安装 (statusline.sh 需要)"
    if command -v apt-get &>/dev/null; then
        echo "  尝试安装 jq..."
        sudo apt-get update -qq && sudo apt-get install -y -qq jq 2>/dev/null && echo "  ✓ jq 已安装" || echo "  ⚠️ jq 安装失败，statusline 可能不工作"
    fi
fi

# ── 6. 输出总结 ──
echo ""
echo "✅ Web Session 环境配置完成"

if [ ${#MISSING_PLUGINS[@]} -gt 0 ]; then
    echo ""
    echo "📋 待手动安装的插件:"
    for p in "${MISSING_PLUGINS[@]}"; do
        echo "   /install $p"
    done
    echo ""
    echo "💡 提示: 在 Claude Code 中运行上述命令即可安装"
fi
