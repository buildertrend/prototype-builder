---
description: "Set up everything needed to build and share prototypes. Run this once after installing the plugin."
disable-model-invocation: true
argument-hint: ""
---

Run the following setup steps in order. Use the communication style described below — never mention technical tool names like npm, CLI, or cache.

## Step 1: Install dependencies

Tell the user: "Checking your setup and installing anything that's missing... this might take a minute."

Run the install script from the plugin directory:

```
bash "${CLAUDE_PLUGIN_ROOT}/scripts/install-deps.sh"
```

This script detects the operating system and automatically installs Git and Node.js if missing. It uses the system package manager for Git and `fnm` (Fast Node Manager) for Node.js.

- If the script exits successfully (exit code 0): continue silently.
- If it fails (exit code 1): the script will print what went wrong. Relay the message to the user in plain language and **stop**. Example: "I wasn't able to install everything automatically. You may need to install Node.js from https://nodejs.org, then come back and run `/prototype-setup` again."

After the script completes, verify both are available:

- Run `git --version` — if missing, **stop** with manual instructions.
- Run `node --version` — if missing or below v18, **stop** with manual instructions.
- Run `npm --version` — if missing, tell the user: "Something didn't install correctly. Try closing this terminal, reopening it, and running `/prototype-setup` again." Then **stop**.

## Step 2: Pre-warm cache

Tell the user: "Downloading some things so your first prototype starts faster..."

Run:
```
npm cache add create-vite@latest vite@latest react@latest react-dom@latest typescript@latest @vitejs/plugin-react@latest vercel@latest
```

If it fails, continue silently — this is an optimization, not a requirement.

## Step 3: Set up sharing account

Tell the user: "Let's set up sharing so you can send your prototypes to anyone with a link. Your browser will open — go ahead and log in or create a free account."

Run:
```
npx vercel login 2>&1
```

- If the command succeeds (prints "Congratulations!" or similar): continue.
- If it fails or the user cancels: tell the user "No worries — we can set up sharing later when you're ready. Just say 'share this' and I'll walk you through it." Then continue to the next step (this is not a blocker).

## Step 4: Connect Figma (optional)

Tell the user: "One last thing — if you want to build from Figma designs, let's connect that now. Your browser will open for Figma login."

Call any Figma MCP tool (e.g., `mcp__figma__get_file` with a dummy file key) to trigger the MCP authentication flow. The Figma MCP server will prompt the user to authorize via their browser.

- If auth succeeds: tell the user "Figma is connected! You can paste Figma links when describing what to build."
- If it fails or the user skips: tell the user "No problem — you can connect Figma later by pasting a Figma link when describing what to build." Then continue.

This step is optional — the plugin works fine without Figma.

## Step 5: Done

Tell the user: "All set! Describe what you want to build and I'll make it happen."

## Communication Rules

- **Never** mention npm, CLI, Vercel, cache, or package managers by name.
- Use phrases like "downloading some things", "installing sharing tools", "setting up your account".
- Keep it casual and brief. The user is non-technical.
