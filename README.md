# Prototype Builder

Build web app prototypes by describing what you want. No coding needed.

## Install

Open a terminal and paste this:

    curl -fsSL https://raw.githubusercontent.com/buildertrend/prototype-builder/main/install.sh | bash

**Windows users:** Open Git Bash, PowerShell, or Windows Terminal (not Command Prompt).
If you only have Command Prompt, download and double-click [`install.bat`](https://raw.githubusercontent.com/buildertrend/prototype-builder/main/install.bat) instead.

Setup takes about 2 minutes. Your browser will open twice — once for
Figma and once to set up sharing. Just log in when prompted.

## Uninstall

    curl -fsSL https://raw.githubusercontent.com/buildertrend/prototype-builder/main/uninstall.sh | bash

This removes the commands and skills but keeps your prototypes.

## Usage

1. Open a terminal
2. Type `claude` and press Enter
3. Describe what you want to build — or type `/prototype` followed by a description

### Examples

```
/prototype I want an app where I can track my daily habits with checkboxes and see a weekly streak
```

```
/prototype A simple dashboard that shows sales numbers in cards with a bar chart at the bottom
```

```
/prototype A recipe organizer where I can add recipes with ingredients and search through them
```

You don't even need the `/prototype` part — just describe what you want and Claude will figure it out.

### Sharing

Type `/share` in Claude to deploy your prototype and get a link anyone can open.

## Tips

- **Describe what you want to see and do**, not how to build it — that's handled for you
- **You'll see permission prompts** — these are Claude asking to create files and run your app. It's safe to approve them.
- **Ask for changes in plain language** — "make the header blue", "add a button to delete items", "make it look better on mobile"
- **You can iterate as much as you want** — just keep describing what you'd like to change
- **Come back anytime** — your prototypes are saved in `~/prototypes`. Just run `claude` and say "I want to keep working on my grocery list app"
- **Share Figma links** — paste a Figma link and Claude will match the design as closely as possible

## What's Installed

| Item | Location |
|------|----------|
| `/prototype` command | `~/.claude/commands/prototype.md` |
| `/share` command | `~/.claude/commands/share.md` |
| Prototype builder skill | `~/.claude/skills/prototype-builder/` |
| Prototype sharer skill | `~/.claude/skills/prototype-sharer/` |
| Prototypes folder | `~/prototypes/` |
| Figma integration | Claude MCP (user scope) |
