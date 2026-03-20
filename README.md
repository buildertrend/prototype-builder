# Prototype Builder

Turn plain-language descriptions into working web apps. No coding needed — just describe what you want and Claude builds it for you.

## Install

### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed and working
- A terminal app (see below)

### One-liner install

Open a terminal and paste:

```
curl -fsSL https://raw.githubusercontent.com/buildertrend/prototype-builder/main/install.sh | bash
```

### Which terminal to use

| OS | Use |
|----|-----|
| **Mac** | Terminal (built-in) or iTerm |
| **Windows** | Git Bash, PowerShell, or Windows Terminal |

> **Windows Command Prompt users:** `curl | bash` won't work in CMD. Instead, download [`install.bat`](https://github.com/buildertrend/prototype-builder/raw/main/install.bat) and double-click it.

### What the installer does

The installer runs 8 steps — no input needed except logging in when your browser opens.

| Step | What happens |
|------|-------------|
| 1. Git | Installs Git if missing (via Homebrew on Mac, winget on Windows, apt on Linux) |
| 2. Node.js | Installs Node.js if missing (via Homebrew on Mac, winget on Windows, apt on Linux) |
| 3. npm | Verifies npm is available (comes with Node) |
| 4. Files | Downloads commands and skills into `~/.claude/` |
| 5. Figma | Connects the Figma MCP so Claude can read your designs |
| 6. Dependencies | Pre-downloads React/Vite so your first prototype starts fast |
| 7. Sharing tools | Installs Vercel CLI for one-command sharing |
| 8. Sharing account | Opens your browser to create a free Vercel account |

Your browser opens twice during setup — once for Figma (step 5) and once for Vercel (step 8). Just log in when prompted.

The installer is **idempotent** — safe to re-run anytime to update to the latest version.

### What gets installed where

| Item | Location |
|------|----------|
| `/prototype-create` command | `~/.claude/commands/prototype-create.md` |
| `/prototype-share` command | `~/.claude/commands/prototype-share.md` |
| Prototype builder skill | `~/.claude/skills/prototype-builder/SKILL.md` |
| Prototype sharer skill | `~/.claude/skills/prototype-sharer/SKILL.md` |
| Prototypes folder + config | `~/prototypes/CLAUDE.md` |
| Figma integration | Claude MCP (user scope) |

### Uninstall

```
curl -fsSL https://raw.githubusercontent.com/buildertrend/prototype-builder/main/uninstall.sh | bash
```

Removes commands, skills, and the Figma MCP connection. Your prototypes in `~/prototypes/` are **not** deleted.

## Getting Started

### Build your first prototype

1. Open a terminal
2. Type `claude` and press Enter
3. Describe what you want to build

That's it. Claude will scaffold the project, install dependencies, and open a live preview — all automatically.

You can also use the `/prototype-create` command to be explicit:

```
/prototype-create A to-do list app where I can add items, check them off, and filter by status
```

### Examples of things you can build

- **Dashboards** — "A dashboard with sales numbers in cards and a bar chart"
- **Trackers** — "An app to track daily habits with checkboxes and weekly streaks"
- **Tools** — "A recipe organizer where I can add recipes and search by ingredient"
- **Forms** — "A signup page with name, email, and password fields"
- **From Figma** — paste a Figma link and Claude matches the design

### Iterate on your prototype

Just say what you want to change in plain language:

- "Make the header blue"
- "Add a button to delete items"
- "Make it look better on mobile"
- "Add a search bar at the top"

Claude keeps the app running while making changes — refresh your browser to see updates.

### Share with anyone

Type `/prototype-share` in Claude to get a public link. Anyone with the link can see your prototype — no account or install needed on their end.

To update a shared prototype after making changes, just `/prototype-share` again. The same link updates automatically.

### Come back to a prototype later

Your prototypes are saved in `~/prototypes/`, each in its own folder. To pick up where you left off:

1. Open a terminal
2. Type `claude`
3. Say "I want to keep working on my grocery list app"

### Tips

- **Describe what you want to see and do**, not how to build it
- **You'll see permission prompts** — Claude asking to create files and run your app. Safe to approve.
- **Paste Figma links** — Claude reads the design and matches colors, layout, and spacing
- **Start rough, then refine** — a basic version you can react to is faster than trying to describe everything upfront

## Contributing

### Repo structure

```
prototype-builder/
├── commands/
│   ├── prototype-create.md    # /prototype-create slash command
│   └── prototype-share.md    # /prototype-share slash command
├── skills/
│   ├── prototype-builder/
│   │   └── SKILL.md          # Auto-triggers when user describes an app
│   └── prototype-sharer/
│       └── SKILL.md          # Auto-triggers on "share this", "get me a link", etc.
├── prototypes-CLAUDE.md      # CLAUDE.md placed in ~/prototypes/ to guide Claude
├── install.sh                # Cross-platform bash installer
├── install.bat               # Windows CMD fallback installer
├── uninstall.sh              # Clean removal script
└── README.md
```

### How it works

Prototype Builder is a [Claude Code](https://docs.anthropic.com/en/docs/claude-code) plugin made up of **commands** and **skills**:

- **Commands** (`/prototype-create`, `/prototype-share`) are explicit slash commands the user types.
- **Skills** are prompt files that Claude auto-triggers based on what the user says. The prototype-builder skill activates on phrases like "build me an app" or "make a dashboard". The prototype-sharer skill activates on "share this" or "get me a link".
- **`prototypes-CLAUDE.md`** is placed in `~/prototypes/` to give Claude context about existing prototypes when the user opens Claude in that directory.

Both skills are written for non-technical users — all communication describes behavior ("you'll see a list of items"), never implementation ("a React component with useState").

### Making changes

1. Clone the repo
2. Edit the files you want to change
3. Test locally by copying files to `~/.claude/commands/` and `~/.claude/skills/` (or run `install.sh` pointed at your local branch)
4. Open a PR

### Testing

To test the full install flow from scratch:

```bash
# Remove existing install
curl -fsSL https://raw.githubusercontent.com/buildertrend/prototype-builder/main/uninstall.sh | bash

# Install from your branch
curl -fsSL https://raw.githubusercontent.com/<you>/prototype-builder/<branch>/install.sh | bash
```

Verify:
- [ ] All 8 install steps complete without errors
- [ ] `claude` → `/prototype-create a simple counter app` → app builds and runs
- [ ] `/prototype-share` → returns a working public URL
- [ ] Re-running install succeeds (idempotent)

### Editing skills

The skill files (`SKILL.md`) contain detailed instructions for Claude's behavior. Key things to preserve:

- **Non-technical language** — users are designers and PMs, not developers
- **Error handling** — skills fix build errors silently, only surfacing issues after 2-3 failed attempts
- **Figma integration** — the builder skill uses Figma MCP tools when the user shares a Figma link
- **Approval guidance** — the builder skill coaches users through Claude Code's permission prompts
