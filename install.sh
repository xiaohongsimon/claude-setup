#!/bin/bash
# Dotfiles 安装脚本
# 创建符号链接到 ~/.config 和 ~ 目录

set -e

DOTFILES_DIR="$HOME/dotfiles"
CONFIG_DIR="$HOME/.config"

echo "🔧 开始安装 dotfiles..."

# Ghostty
echo "📦 安装 Ghostty 配置..."
mkdir -p "$CONFIG_DIR/ghostty"
ln -sf "$DOTFILES_DIR/ghostty/config" "$CONFIG_DIR/ghostty/config"
echo "  ✓ Ghostty 配置完成"

# Claude Code (.claude 目录下的配置文件)
echo "📦 安装 Claude Code 配置..."
mkdir -p "$HOME/.claude/commands"
mkdir -p "$HOME/.claude/skills"

# 复制命令文件
if [ -d "$DOTFILES_DIR/.claude/commands" ]; then
    for f in "$DOTFILES_DIR/.claude/commands"/*.md; do
        [ -f "$f" ] && cp -f "$f" "$HOME/.claude/commands/"
    done
    echo "  ✓ Claude Code 命令配置完成"
fi

# 复制 skills
if [ -d "$DOTFILES_DIR/.claude/skills" ]; then
    cp -rf "$DOTFILES_DIR/.claude/skills"/* "$HOME/.claude/skills/" 2>/dev/null || true
    echo "  ✓ Claude Code skills 配置完成"
fi

echo ""
echo "✅ 安装完成！"
echo ""
echo "📝 注意：以下内容需要手动配置"
echo ""
echo "1. Claude HUD 插件需要在 Claude Code 中运行:"
echo "   /install claude-hud@jarrodwatts"
echo ""
echo "2. 确保已安装以下依赖:"
echo "   - Ghostty: https://ghostty.org/"
echo "   - JetBrainsMono Nerd Font"
echo "   - Claude Code"
echo ""
