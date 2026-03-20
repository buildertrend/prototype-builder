---
description: "Set up everything needed to build and share prototypes. Run this once after installing the plugin."
---

Run the following setup steps in order. Use the communication style described below — never mention technical tool names like npm, CLI, or cache.

## Step 1: Check Git

Run `git --version`.

- If found: continue silently.
- If missing: tell the user exactly this and then **stop**:

  "To track your prototypes, you'll need Git installed. Go to https://git-scm.com, download the installer, and run it with all the default options. Once that's done, come back and run `/prototype-setup` again."

## Step 2: Check Node.js

Run `node --version`.

- If found: report the version briefly ("You've got Node.js ready"), then continue.
- If missing: tell the user exactly this and then **stop** (do not continue to step 3):

  "To build prototypes, you'll need Node.js installed. Go to https://nodejs.org, download the version that says LTS, and run the installer with all the default options. Once that's done, come back and run `/prototype-setup` again."

## Step 3: Check npm

Run `npm --version`.

- If found: continue silently.
- If missing: tell the user: "npm should have come with Node.js. Try closing this terminal, reopening it, and running `/prototype-setup` again." Then **stop**.

## Step 4: Pre-warm cache

Tell the user: "Downloading some things so your first prototype starts faster..."

Run:
```
npm cache add create-vite@latest vite@latest react@latest react-dom@latest typescript@latest @vitejs/plugin-react@latest
```

If it fails, continue silently — this is an optimization, not a requirement.

## Step 5: Install sharing tools

Run `npm install -g vercel`.

- If it succeeds: continue silently.
- If it fails: tell the user: "Couldn't install sharing tools globally, but that's OK — sharing will still work, just a bit slower the first time." Then continue.

## Step 6: Sharing account login

Tell the user: "Your browser will open so you can create a free account (or log in). This lets you share your prototypes with a link."

Run `vercel login`.

- If it fails: tell the user: "No worries — you'll be prompted to log in the first time you share a prototype." Then continue.

## Step 7: Done

Tell the user: "All set! Describe what you want to build and I'll make it happen."

## Communication Rules

- **Never** mention npm, CLI, Vercel, cache, or package managers by name.
- Use phrases like "downloading some things", "installing sharing tools", "setting up your account".
- Keep it casual and brief. The user is non-technical.
