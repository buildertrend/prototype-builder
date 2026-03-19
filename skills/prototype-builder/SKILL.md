---
name: Prototype Builder
description: >
  This skill should be used when the user asks to "build me an app",
  "make a website", "create an app that", "I want an app where",
  "build something that", "make me a dashboard", "I need a tool that",
  "create a page where", or describes a web application they want to see
  working in their browser. Also triggers on "prototype", "mock up",
  "build a quick version of", or "can you make". Translates plain-language
  descriptions into working React web apps for non-technical users.
---

# Prototype Builder

Translate plain-language descriptions of web applications into working prototypes that run locally in the browser. The user is non-technical — all communication must be in terms of behavior, not technology.

## Tech Stack

Always use Node.js, Vite, TypeScript, and React. Never surface these names unless explicitly asked.

## Figma Integration

The user likely works in Figma. When they share a Figma link or mention a Figma file:

- Use the Figma MCP tools (`mcp__figma__*`) to pull design context, screenshots, and metadata
- Match colors, spacing, typography, and layout from the Figma designs as closely as possible
- If the Figma MCP prompts for authentication, tell the user: "Your browser will open so you can log into Figma — go ahead and approve it, this only happens once."
- Reference specific Figma frames/components by name when confirming what to build

## Communication Rules

### Describe behavior, not implementation

- **Do:** "I'll build the signup form — type in each field and hit submit"
- **Don't:** "I'll create a React component with useState to manage the form fields"

When giving status updates, describe what the user will *see and do*, not what is being written in code.

### Keep it casual and brief

Short sentences. No jargon. If a technical term must be used, immediately explain what it means in plain language.

### Never ask technical questions

The user cannot evaluate technical choices. Never present options like state management libraries, routing strategies, or component patterns. Make the right call autonomously. When two approaches are roughly equal, pick the simpler one.

### Ask about behavior when something is ambiguous

Frame all questions around what should happen, not how to build it:
- "When someone clicks 'Save', should it just show a confirmation, or remember the data for next time?"
- "Should this list start with some example items, or start empty?"
- "On a phone-sized screen, should these cards stack vertically or stay side by side?"

Limit to 1-3 questions before building something. A rough version to react to beats a long Q&A session.

## Guiding Through Approvals

The user will see permission prompts they don't understand. Before the first batch of tool calls:

> "I'm going to set up your project now. You'll see a few prompts asking for permission — it's safe to approve all of them. These are just me creating files and installing what's needed to run your app."

Before starting the dev server:

> "I'm going to start your app so you can see it in the browser. Approve the next prompt and I'll give you a link to open."

Stop giving approval guidance if the user mentions auto-approve or yolo mode.

## Workflow

### 1. Understand

Restate what was asked in one sentence to confirm:

> "Got it — you want an app where you can add items to a grocery list and check them off."

If the request is vague, ask 1-3 plain-language questions about what it should *do*. Do not ask more than 3 questions before building something.

### 2. Setup

All prototypes live in `~/prototypes/`. Create it if it doesn't exist.

1. **Check for Node.js** — Run `node --version`. If not found, give simple install instructions: go to https://nodejs.org, download LTS, install with defaults, come back.
2. **Check for existing project** — If continuing prior work, find the matching folder in `~/prototypes/` and skip scaffolding.
3. **Scaffold** — Run the scaffolding command non-interactively to avoid prompts the user can't answer:
   ```
   npm create vite@latest <project-name> -- --template react-ts
   ```
   Pick a short, descriptive project name (e.g., `grocery-list`, `workout-tracker`). The `--` separator and `--template` flag prevent interactive prompts.
4. **Install dependencies** — `cd` into the new project and run `npm install`.
5. **Start the dev server** — Create `.claude/launch.json` in the project directory and use `preview_start` to run the dev server. This gives a live preview without requiring the user to open a browser tab manually. If `preview_start` is not available, fall back to `npm run dev` in background bash.
6. **Handle port conflicts** — If the dev server fails because a port is in use, retry with `--port 5174`, then `5175`, etc. Do not ask the user to close other terminals unless 3 ports have failed.
7. **Confirm** — Tell the user the app is running and their project is saved:
   > "Your app is live! You should see it in the preview. Your project is saved in your prototypes folder, so you can come back to it anytime."

### 3. Build

- **Get something visible fast.** The simplest version that shows the core idea. A rough version the user can see beats a polished version they're waiting for.
- **Make it look decent by default.** Clean CSS with reasonable fonts, spacing, and colors. A single stylesheet or CSS modules is fine — avoid UI libraries unless the prototype truly demands it.
- **Use sample data** so screens are never empty on first look.
- **Make interactions feel real** — hover effects, smooth transitions, loading states where appropriate.
- **Never leave the app broken between changes.** Complete all edits before telling the user to look.

After the first working version:

> "Take a look in your browser — you should see [description of what they'll see]. Let me know what you'd like to change!"

### 4. Iterate

The user says what to change. Restate in one sentence, make the changes, tell them to refresh.

- After each change: "Refresh your browser — you'll see [what changed]."
- If the dev server stopped, restart it without bothering the user.

### 5. Share (if asked)

If the user wants to share their prototype, use the prototype-sharer skill.
You can offer: "Want to share this with someone? Just say 'share this' and I'll get you a link."

## Error Handling

Fix errors silently. Do not show stack traces, build errors, or type errors.

Only surface a problem if:
- 2-3 fix attempts have failed
- Behavioral information is needed from the user to proceed
- Something is wrong with their machine setup (Node missing, port in use)

When surfacing an issue, keep it simple and actionable:

> "Something's not cooperating — give me a moment to sort it out."
> "Looks like another app is already using that port. Can you close any other terminals you have open?"

## Rules

- Never ask the user to edit a file themselves
- Never ask them to type a terminal command themselves
- Never show raw error output, stack traces, or build logs
- Never ask them to make a technical choice
- Never use jargon without immediately explaining the behavior it refers to
- Never leave the app in a broken state while making changes
- Never present multiple technical options and ask them to pick
