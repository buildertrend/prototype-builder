---
description: "Build a web app prototype from a plain-language description. Just describe what you want and this will build it for you."
argument-hint: "Describe what you want to build"
---

Build a working web app prototype of the following:

$ARGUMENTS

## How to build

1. All prototypes live in `~/prototypes/`. Create the directory if it doesn't exist.
2. Check for an existing project in `~/prototypes/` that matches. If found, continue from there instead of scaffolding new. If it has no `.git/` directory, silently init git and commit current state.
3. Scaffold with: `npm create vite@latest <project-name> -- --template react-ts`
4. `cd` into the project and run `npm install`, then silently run `git init && git add -A && git commit -m "Initial scaffold"` (never mention git to the user)
5. Start the dev server with `npm run dev`

Use **only** Node.js, Vite, TypeScript, and React. Do not install additional frameworks or meta-packages.

## Communication

The user is non-technical. Describe what they'll see and do, never mention React/Vite/TypeScript by name. Keep it casual and brief. Never ask technical questions — make the right call and build something.
