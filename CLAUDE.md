# Prototype Builder

A Claude Code plugin that turns plain-language descriptions into working web apps for non-technical users (designers, PMs).

## Architecture

This is a standard Claude Code plugin with `.claude-plugin/plugin.json`. Install with `claude plugin install` or load locally with `claude --plugin-dir .`.

### Components

| Component | File | Purpose |
|-----------|------|---------|
| Plugin manifest | `.claude-plugin/plugin.json` | Plugin metadata, version, MCP reference |
| Figma MCP config | `.mcp.json` | Auto-configures Figma MCP on plugin install |
| `/prototype-setup` command | `commands/prototype-setup.md` | One-time env setup: Node check, cache warm, Vercel install + login |
| Prototype Builder skill | `skills/prototype-builder/SKILL.md` | Auto-triggers on "build me an app", etc. — full build workflow |
| Prototype Sharer skill | `skills/prototype-sharer/SKILL.md` | Auto-triggers on "share this", etc. — full deploy workflow |
| Prototypes context | `prototypes-CLAUDE.md` | Placed in `~/prototypes/CLAUDE.md` to guide Claude in that directory |

### Data flow

1. User installs plugin → runs `/prototype-setup` once
2. User describes an app → builder skill triggers automatically
3. Scaffolds `~/prototypes/<name>/` with `npm create vite@latest -- --template react-ts`
4. Installs deps, starts dev server, builds the app iteratively
5. User says "share this" → sharer skill triggers automatically
6. Runs `npm run build` then `vercel --yes --prod`, returns public URL

### Tech stack (for generated prototypes)

- React + TypeScript + Vite (always, no exceptions)
- No UI framework libraries unless the prototype demands it
- Deployed via Vercel CLI

## Key Design Principles

- **Non-technical communication**: Describe behavior ("you'll see a list"), never implementation ("React component with useState"). This applies to ALL user-facing text in skills and commands.
- **Silent error recovery**: Fix errors behind the scenes. Only surface after 2-3 failed attempts.
- **Autonomy**: Never ask the user to make a technical choice, edit a file, or run a command.
- **Speed first**: Get a rough working version visible fast, then iterate.
- **Self-sufficient**: Skills must not reference packages that don't exist. Every tool/package mentioned must be real and installed.

## Working on This Repo

### Testing changes

Load the plugin directly from your local checkout:

```bash
claude --plugin-dir .
```

This auto-discovers skills from `skills/*/SKILL.md` and commands from `commands/*.md`.

### Validation checklist

- [ ] `claude --plugin-dir .` loads the plugin (skills and `/prototype-setup` appear)
- [ ] Figma MCP is configured (check with `claude mcp list`)
- [ ] `/prototype-setup` checks Node.js, warms cache, installs Vercel, runs login
- [ ] "build me an app" triggers the builder skill
- [ ] "share this" triggers the sharer skill

### Editing skills and commands

When modifying skill/command files:
- **Preserve non-technical language** — read the Communication Rules sections carefully before editing.
- **Test trigger phrases** — if you change a skill's `description` frontmatter, verify it still triggers on the expected user inputs.
- **Don't add external packages** — the "self-sufficient" principle means skills should only reference tools that are guaranteed installed (Node, npm, Vite, React, Vercel).
