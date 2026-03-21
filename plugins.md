# Recommended Plugins & Marketplaces

## Plugins

### Superpowers (Required)

The most comprehensive Claude Code plugin. Provides skills for TDD, systematic debugging, brainstorming, code review, parallel agent dispatch, and more.

```
Source: claude-plugins-official
Name: superpowers
```

**Install:** Claude Code will auto-discover from the official marketplace.

## Marketplaces

Add these to `settings.json` → `extraKnownMarketplaces` for more plugin sources:

| Name | URL | Description |
|------|-----|-------------|
| Claude Plugins Official | (built-in) | Anthropic's official plugin registry |
| Oh My Claude Code (omc) | `https://github.com/Yeachan-Heo/oh-my-claudecode.git` | Community plugins |
| Superpowers Marketplace | `github:obra/superpowers-marketplace` | Extended superpowers ecosystem |

### Adding a Marketplace

```json
{
  "extraKnownMarketplaces": {
    "omc": {
      "source": {
        "source": "git",
        "url": "https://github.com/Yeachan-Heo/oh-my-claudecode.git"
      }
    },
    "superpowers-marketplace": {
      "source": {
        "source": "github",
        "repo": "obra/superpowers-marketplace"
      }
    }
  }
}
```
