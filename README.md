# Claude Code Setup

My Claude Code configuration: skills, scripts, and settings templates.

An algorithm team TL's approach to turning a Mac Studio into a 24/7 AI development hub.

## What's Inside

```
claude-setup/
├── skills/                          # Reusable skills (copy to ~/.claude/skills/)
│   └── presentation-as-code/        # Interactive HTML presentation methodology
├── scripts/                         # Utility scripts (copy to ~/.claude/)
│   ├── statusline.sh                # Context window usage display
│   └── zenmux-switcher.sh           # Multi-account API key switching
├── templates/                       # Configuration templates
│   └── settings.json                # Settings reference (sanitized)
└── plugins.md                       # Plugin recommendations
```

## Quick Start

### 1. Install Skills

```bash
# Copy all skills
cp -r skills/* ~/.claude/skills/

# Or just one
cp -r skills/presentation-as-code ~/.claude/skills/
```

### 2. Install Scripts

```bash
cp scripts/statusline.sh ~/.claude/
chmod +x ~/.claude/statusline.sh
```

### 3. Configure Settings

Copy `templates/settings.json` to `~/.claude/settings.json` and fill in your own values.

## Skills

### presentation-as-code

A methodology for creating high-impact, interactive HTML presentations with AI.

- 5-phase workflow: Narrative → Design System → Content → Interactivity → Polish
- Proven on 35+ slide training deck for non-technical audience
- Offline-first, zero framework dependency
- Includes component library and design system reference

See [skills/presentation-as-code/README-zh.md](skills/presentation-as-code/README-zh.md) for Chinese documentation.

## Scripts

### statusline.sh

Shows model name + context window usage in your terminal status line.

```
🟢 [Claude Opus 4.6] ▓▓▓▓░░░░░░░░░░░░░░░░ 20%
🟡 [Claude Opus 4.6] ▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░ 55%
🔴 [Claude Opus 4.6] ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░ 85%
```

### zenmux-switcher.sh

Switch between multiple Zenmux API accounts without restarting Claude Code.

```bash
# Switch to account 1
echo 1 > ~/.claude/zenmux-active

# Switch to account 2
echo 2 > ~/.claude/zenmux-active
```

## Plugins

See [plugins.md](plugins.md) for recommended plugins and marketplaces.

## License

MIT
