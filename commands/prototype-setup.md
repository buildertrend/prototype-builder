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

## Step 3: Done

Tell the user: "All set! Describe what you want to build and I'll make it happen. If you want to use Figma designs, just paste a Figma link when describing what to build."

## Communication Rules

- **Never** mention npm, CLI, Vercel, cache, or package managers by name.
- Use phrases like "downloading some things", "installing sharing tools", "setting up your account".
- Keep it casual and brief. The user is non-technical.
