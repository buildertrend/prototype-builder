# Prototype Builder — Improvements Plan

## Context

Prototype Builder is a Claude Code plugin that turns plain-language descriptions into working web apps for non-technical users. It currently installs as raw files copied into `~/.claude/` via shell scripts. This plan converts it to a proper plugin and addresses 14 improvement items.

## Key Decisions

- **Install flow**: Plugin-only. `claude plugin install` to install, `/prototype-setup` command handles prerequisites (Node.js, Vercel, npm cache). No install scripts.
- **Uninstall**: `claude plugin remove prototype-builder`. README documents manual cleanup if needed. No uninstall script.
- **Commands vs skills**: Skills only for build/share (auto-triggered). `/prototype-setup` is the only explicit command.
- **Branching**: All phases as sequential commits on `improvements`, one PR.

---

## Phase 1: Plugin Structure Conversion

*Items: 1 (proper plugin), 3 (version tracking), 7 (Figma MCP), 2 (dedup commands/skills), 8 (install.bat), 9 (NodeSource)*

This phase converts the repo from loose files + install scripts into a proper Claude Code plugin. After this phase, the repo is a working plugin that can be loaded with `claude --plugin-dir .` or installed via `claude plugin install`.

### 1a. Create `.claude-plugin/plugin.json`

New file. Follows the same schema as ado-skills and atlassian plugins.

```json
{
  "name": "prototype-builder",
  "version": "0.1.0",
  "description": "Turn plain-language descriptions into working web app prototypes. Designed for non-technical users.",
  "author": {
    "name": "Buildertrend",
    "email": "daric.teske@buildertrend.com"
  },
  "license": "MIT",
  "keywords": ["prototype", "web-app", "react", "no-code", "figma", "vite", "deploy", "vercel"],
  "mcpServers": "./.mcp.json"
}
```

No `"skills"` or `"commands"` fields — Claude Code auto-discovers from `skills/*/SKILL.md` and `commands/*.md` by convention (same as ado-skills plugin).

### 1b. Create `.mcp.json` for Figma

New file at plugin root. Follows the Atlassian plugin's HTTP MCP pattern.

```json
{
  "mcpServers": {
    "figma": {
      "type": "http",
      "url": "https://mcp.figma.com/mcp"
    }
  }
}
```

When the plugin is installed, Figma MCP is auto-configured. Replaces the `claude mcp add` call from the old install.sh.

### 1c. Create `/prototype-setup` command

**NEW:** `commands/prototype-setup.md`

One-time environment setup command. Uses frontmatter format from existing plugins (e.g., `revise-claude-md.md` uses `description` and `allowed-tools`).

```yaml
---
description: "Set up everything needed to build and share prototypes. Run this once after installing the plugin."
---
```

**Steps the command instructs Claude to perform:**

1. **Check Node.js** — Run `node --version`.
   - If found: report version, continue.
   - If missing: tell user "To build prototypes, you'll need Node.js installed. Go to https://nodejs.org, download the version that says LTS, and run the installer with all the default options. Once that's done, come back and run `/prototype-setup` again." Then stop.

2. **Check npm** — Run `npm --version`.
   - If found: continue silently.
   - If missing: "npm should have come with Node.js. Try closing this terminal, reopening it, and running `/prototype-setup` again."

3. **Pre-warm npm cache** — Run:
   ```
   npm cache add create-vite@latest vite@latest react@latest react-dom@latest typescript@latest @vitejs/plugin-react@latest
   ```
   Tell user: "Downloading some things so your first prototype starts faster..."

4. **Install Vercel CLI** — Run `npm install -g vercel`.
   - If it fails: "Couldn't install sharing tools globally, but that's OK — sharing will still work, just a bit slower the first time."

5. **Vercel login** — Run `vercel login`.
   - Tell user: "Your browser will open so you can create a free account (or log in). This lets you share your prototypes with a link."
   - If it fails: "No worries — you'll be prompted to log in the first time you share a prototype."

6. **Done** — "All set! Describe what you want to build and I'll make it happen."

**Communication style:** Same non-technical tone as the skills. No mention of npm, CLI, cache, or package managers by name. Use phrases like "downloading some things", "installing sharing tools", "setting up your account".

### 1d. Delete install/uninstall scripts

**DELETE:** `install.sh`, `install.bat`, `uninstall.sh`

These are fully replaced by:
- **Install:** `claude plugin install prototype-builder` → `/prototype-setup`
- **Uninstall:** `claude plugin remove prototype-builder` (documented in README, with note about optional `npm uninstall -g vercel` for cleanup)

### 1e. Delete old commands

**DELETE:** `commands/prototype-create.md`, `commands/prototype-share.md`

Skills handle build/share via natural language triggers. No explicit slash commands needed — users just describe what they want.

### 1f. Rewrite `README.md`

Full rewrite. New structure:

1. **Header + one-liner** — same "Turn plain-language descriptions into working web apps"
2. **Install** — two steps:
   - Prerequisites: Claude Code installed and working
   - `claude plugin install prototype-builder`
   - Open Claude, type `/prototype-setup`
3. **Uninstall** — `claude plugin remove prototype-builder`, optional Vercel CLI cleanup
4. **Getting Started** — same content (open claude, describe what you want, examples)
5. **Iterate** — same content
6. **Share** — updated: just say "share this" instead of `/prototype-share`
7. **Tips** — same content
8. **Contributing** — updated repo structure, testing with `claude --plugin-dir .`

### 1g. Update `CLAUDE.md`

Update to reflect:
- Plugin structure with `.claude-plugin/plugin.json`
- Figma via `.mcp.json` instead of install script
- `/prototype-setup` as only command
- Skills as the primary interaction method
- Dev testing: `claude --plugin-dir .`
- Remove all references to install scripts

### File Summary

| Action | File |
|--------|------|
| NEW | `.claude-plugin/plugin.json` |
| NEW | `.mcp.json` |
| NEW | `commands/prototype-setup.md` |
| DELETE | `commands/prototype-create.md` |
| DELETE | `commands/prototype-share.md` |
| DELETE | `install.sh` |
| DELETE | `install.bat` |
| DELETE | `uninstall.sh` |
| REWRITE | `README.md` |
| REWRITE | `CLAUDE.md` |

### Verification
- [ ] `claude --plugin-dir .` loads the plugin (skills and `/prototype-setup` appear)
- [ ] Figma MCP is configured (check with `claude mcp list`)
- [ ] `/prototype-setup` checks Node.js, warms cache, installs Vercel, runs login
- [ ] "build me an app" triggers the builder skill
- [ ] "share this" triggers the sharer skill
- [ ] Old commands (`/prototype-create`, `/prototype-share`) no longer exist

---

## Phase 2: Content Quality Improvements

*Items: 4 (launch.json fix), 5 (trigger phrases), 13 (prototypes-CLAUDE.md)*

### 2a. Fix missing launch.json content (Item 4)

In builder skill step 5, add the actual `.claude/launch.json` content to write.

### 2b. Expand skill trigger phrases (Item 5)

**prototype-builder** — add: "web app", "landing page", "wireframe", "UI for", "form that", "tool to"

**prototype-sharer** — add: "publish", "make public", "host this"

### 2c. Improve prototypes-CLAUDE.md (Item 13)

Expand with guidance on: identifying prototypes from vague descriptions, handling manually-edited projects, listing when ambiguous, using last-modified dates.

### Verification
- [ ] Skill auto-triggers on new phrases
- [ ] Dev server starts with live preview (launch.json works)
- [ ] prototypes-CLAUDE.md handles ambiguous project selection

---

## Phase 3: New Capabilities

*Items: 6 (prototype management), 11 (metadata), 12 (templates)*

### 3a. Add prototype management skill (Item 6)

Triggers on: "list my prototypes", "show my apps", "what have I built", "delete the old one", "what's the URL for"

### 3b. Add prototype metadata (Item 11)

Builder generates `.prototype-meta.json` per project. Sharer writes `shareUrl` back after deploy.

### 3c. Add template system (Item 12)

Template descriptions for: dashboard, CRUD list, form, landing page.

### Verification
- [ ] "List my prototypes" triggers manager skill
- [ ] `.prototype-meta.json` created during build, updated on share
- [ ] Builder references templates for matching patterns

---

## Phase 4: Infrastructure

*Items: 10 (CI), 14 (security/permissions docs)*

### 4a. Add CI (Item 10)

Markdown lint, link check, plugin structure validation.

### 4b. Document permissions (Item 14)

Note in README about what `/prototype-setup` installs globally and what permissions the plugin needs.

### Verification
- [ ] CI passes on push
