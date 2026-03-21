# Prototype Builder

Turn plain-language descriptions into working web apps. No coding needed — just describe what you want and Claude builds it for you.

## Install

### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed and working
- **Windows users:** use [WSL](https://learn.microsoft.com/en-us/windows/wsl/install) (Windows Subsystem for Linux)

### Setup

```bash
claude plugin install buildertrend/prototype-builder
```

Then open Claude and run the one-time setup:

```
/prototype-setup
```

This checks your environment, installs any missing tools (Git, Node.js), and downloads what's needed for fast builds.

### Uninstall

```bash
claude plugin remove prototype-builder
```

Your prototypes in `~/prototypes/` are **not** deleted.

### What this plugin installs

When you run `/prototype-setup`, it:

- **Checks for Node.js** — needed to run your prototypes locally. If missing, it will try to install it for you automatically.
- **Downloads build tools** — saves common packages to your computer so prototypes start faster. Nothing runs until you build a prototype.

The plugin only creates files inside `~/prototypes/` (your prototype projects) and your npm cache. Sharing tools are downloaded on-demand when you first share a prototype — nothing is permanently installed.

## Getting Started

### Build your first prototype

1. Open a terminal
2. Type `claude` and press Enter
3. Describe what you want to build

That's it. Claude will scaffold the project, install dependencies, and open a live preview — all automatically.

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

Claude keeps the app running while making changes — updates appear in your browser automatically.

### Share with anyone

Just say "share this" or "get me a link" and Claude will put your app online and give you a public URL. Anyone with the link can see your prototype — no account or install needed on their end.

To update a shared prototype after making changes, just say "share this" again. The same link updates automatically.

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
├── .claude-plugin/
│   └── plugin.json           # Plugin manifest
├── .github/
│   └── workflows/
│       └── ci.yml            # Markdown lint + plugin structure validation
├── .gitignore
├── .markdownlint.json        # Markdownlint config for CI
├── .mcp.json                 # Figma MCP configuration
├── commands/
│   └── prototype-setup.md    # /prototype-setup one-time setup command
├── skills/
│   ├── prototype-builder/
│   │   └── SKILL.md          # Auto-triggers when user describes an app
│   ├── prototype-manager/
│   │   └── SKILL.md          # Auto-triggers on "list my prototypes", etc.
│   └── prototype-sharer/
│       └── SKILL.md          # Auto-triggers on "share this", "get me a link", etc.
├── scripts/
│   ├── approve-commands.sh   # PermissionRequest hook — auto-approves safe Bash commands
│   └── install-deps.sh       # Auto-installs Git and Node.js if missing
├── CLAUDE.md
└── README.md
```

### How it works

Prototype Builder is a [Claude Code](https://docs.anthropic.com/en/docs/claude-code) plugin with **skills** and a **setup command**:

- **Skills** are prompt files that Claude auto-triggers based on what the user says. The prototype-builder skill activates on phrases like "build me an app" or "make a dashboard". The prototype-sharer skill activates on "share this" or "get me a link".
- **`/prototype-setup`** is a one-time command that checks prerequisites (Node.js, Git), pre-warms caches, and prepares the environment for building and sharing prototypes.
- **`.mcp.json`** configures the Figma MCP so Claude can read designs when users paste Figma links.
- **`scripts/approve-commands.sh`** is a PermissionRequest hook that auto-approves safe Bash commands (npm, node, git, etc.) so non-technical users don't get bombarded with permission prompts.

Both skills are written for non-technical users — all communication describes behavior ("you'll see a list of items"), never implementation ("a React component with useState").

### Making changes

1. Clone the repo
2. Edit the files you want to change
3. Test locally: `claude --plugin-dir .`
4. Open a PR

### Testing

Load the plugin from a local checkout:

```bash
claude --plugin-dir /path/to/prototype-builder
```

Verify:
- [ ] `/prototype-setup` checks Node.js, warms cache (including Vercel)
- [ ] "Build me a simple counter app" → app builds and runs
- [ ] "Share this" → returns a working public URL
- [ ] Skills auto-trigger on natural language

### Editing skills

The skill files (`SKILL.md`) contain detailed instructions for Claude's behavior. Key things to preserve:

- **Non-technical language** — users are designers and PMs, not developers
- **Error handling** — skills fix build errors silently, only surfacing issues after 2-3 failed attempts
- **Figma integration** — the builder skill uses Figma MCP tools when the user shares a Figma link
- **Approval guidance** — the builder skill coaches users through Claude Code's permission prompts
