# Dotfiles / Claude Code Setup

我的 macOS 开发环境配置 / My macOS development environment setup.

An algorithm team TL's approach to turning a Mac Studio into a 24/7 AI development hub.

> **Web 用户?** 跳转到 [Web 端配置](#web-端配置claude-aicode) 查看如何在 claude.ai/code 上启用插件和 HUD。

## What's Inside / 包含内容

```
claude-setup/
├── .claude/                       # Claude Code 配置
│   ├── commands/                  # 模型切换命令
│   │   └── zenmux*.md             # Zenmux/百炼模型切换
│   ├── skills/                    # 自定义技能
│   │   ├── notebooklm/            # Google NotebookLM 集成
│   │   ├── planning-with-files/   # 文件式任务规划
│   │   └── presentation-as-code/  # HTML 演示文稿生成
│   ├── notify-dingtalk.sh         # 钉钉通知脚本
│   └── settings.json.template     # 配置模板（不含密钥）
├── ghostty/
│   └── config                     # Ghostty 终端配置
├── claude-hud/
│   └── README.md                  # HUD 插件安装说明
├── scripts/
│   ├── statusline.sh              # 状态栏脚本
│   ├── zenmux-switcher.sh         # 多账号切换
│   └── web-session-setup.sh       # Web session 自动配置
├── templates/
│   ├── settings.json              # macOS 本地配置模板
│   └── settings-web.json          # Web 端 (claude.ai/code) 配置模板
├── install.sh                     # 安装脚本
└── README.md                      # 本文件
```

## Quick Start / 快速开始

### 1. 克隆配置

```bash
git clone https://github.com/xiaohongsimon/claude-setup.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

### 2. 安装插件 (在 Claude Code 中)

```bash
/install claude-hud@jarrodwatts
/install superpowers@claude-plugins-official
```

## Components / 组件说明

### Ghostty

终端模拟器配置：
- Catppuccin Mocha 主题
- JetBrainsMono Nerd Font 字体
- macOS 标题栏样式（tabs）
- 快速终端切换（Cmd+`）

### Claude Code

AI 编程助手配置：
- 自定义 skills（notebooklm, planning-with-files, presentation-as-code）
- 模型切换命令（zenmux1/2, glm5, kimi25, minimax25, qwen35plus）
- 钉钉通知脚本

### Claude HUD

使用 [claude-hud](https://github.com/jarrodwatts/claude-hud) 插件，通过 Claude Code 插件系统安装。

## Skills

### presentation-as-code

创建高影响力、交互式 HTML 演示文稿的方法论：
- 5 阶段工作流：Narrative → Design System → Content → Interactivity → Polish
- 已在 35+ 页非技术性培训幻灯片中验证
- 离线优先，无框架依赖

详见 [skills/presentation-as-code/README-zh.md](.claude/skills/presentation-as-code/README-zh.md)。

### planning-with-files

基于文件的任务规划系统，生成：
- `task_plan.md` - 任务分解
- `findings.md` - 调研记录
- `progress.md` - 进度追踪

### notebooklm

Google NotebookLM 集成，支持：
- 直接查询 notebooks
- 返回带引用的答案
- 减少幻觉

## Scripts

### notify-dingtalk.sh

Claude Code 事件 → 钉钉单聊推送：
- 从 transcript 提取上下文
- 免打扰时段：23:30 ~ 07:30
- 密钥从 `~/.dynasty.env` 加载

## Web 端配置（claude.ai/code）

通过 Web 登录其他电脑使用 Claude Code 时，插件（HUD、superpowers 等）和 statusLine 默认不生效。原因：

| 问题 | 原因 | 解决方式 |
|------|------|----------|
| HUD / statusLine 不显示 | node 路径 `/opt/homebrew/bin/node` 是 macOS 专属 | SessionStart hook 自动修复 |
| 插件未加载 | Web session 无本地插件缓存 | 首次需手动 `/install` |
| 路径不兼容 | `/Users/xxx/` 在 Linux 上不存在 | 自动替换为 `$HOME` |

### 快速配置

**方式一：使用 Web 专用模板（推荐）**

```bash
# 在 Web session 中克隆 repo
git clone https://github.com/xiaohongsimon/claude-setup.git ~/claude-setup

# 使用 Web 专用 settings
cp ~/claude-setup/templates/settings-web.json ~/.claude/settings.json

# 复制 statusline 脚本
cp ~/claude-setup/scripts/statusline.sh ~/.claude/statusline.sh
chmod +x ~/.claude/statusline.sh

# 安装插件（在 Claude Code 中运行）
# /install claude-hud@jarrodwatts
# /install superpowers@claude-plugins-official
```

**方式二：手动运行 setup 脚本**

```bash
bash ~/claude-setup/scripts/web-session-setup.sh
```

### SessionStart Hook 自动化

`templates/settings-web.json` 已包含 SessionStart hook，每次 Web session 启动时自动：
- 修复 node 路径（macOS → Linux）
- 修复 `additionalDirectories` 路径
- 复制 statusline.sh 到 `~/.claude/`
- 检查插件状态并提示安装

### 插件兼容性

| 插件 | Web 兼容 | 备注 |
|------|----------|------|
| superpowers | ✅ | 首次需 `/install` |
| claude-hud | ✅ | 需要 node.js，首次需 `/install` |
| statusline.sh | ✅ | 需要 jq，setup 脚本自动安装 |
| 钉钉通知 | ⚠️ | 需要 `~/.dynasty.env` 密钥文件 |

## Dependencies / 依赖

- [Ghostty](https://ghostty.org/)
- [Claude Code](https://claude.ai/code)
- [JetBrainsMono Nerd Font](https://www.nerdfonts.com/font-downloads)

## License

MIT
