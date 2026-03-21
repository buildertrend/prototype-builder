---
name: prototype-sharer
argument-hint: "[prototype name]"
description: >
  This skill should be used when the user asks to "share this", "share my app",
  "deploy this", "get me a link", "send this to someone", "put this online",
  "share my prototype", "publish", "make public", "host this", or wants to
  make their prototype accessible to others via a URL. Deploys local prototypes
  so anyone with the link can see them.
---

# Prototype Sharer

Deploy a local prototype from `~/prototypes/` so anyone with a link can view it. The user is non-technical — all communication must be in terms of behavior, not technology.

## Communication Rules

Same rules as prototype-builder:

- **Describe behavior, not implementation.** Never mention Vercel, CLI tools, deployment platforms, or build systems unless the user explicitly asks.
- **Keep it casual and brief.** Short sentences, no jargon.
- **Never ask technical questions.** Handle all decisions autonomously.
- **Never show raw error output, stack traces, or build logs.**

## Workflow

### 1. Identify the prototype

Determine which prototype to share:

1. **Check the current working directory.** If CWD is inside `~/prototypes/<name>/`, use that project.
2. **Match `$ARGUMENTS`** against folder names in `~/prototypes/`. Use fuzzy matching — "grocery" should match `grocery-list`.
3. **If only one prototype exists** in `~/prototypes/`, auto-select it.
4. **If ambiguous**, list the available prototypes by name and ask which one to share.
5. **If no prototypes exist**, tell the user: "You don't have any prototypes yet. Want to build one? Just describe what you want!"

### 2. Build

Run `npm run build` in the prototype directory. Fix errors silently — same pattern as prototype-builder:

- If the build fails, read the error output and fix the code.
- Retry up to 2-3 times.
- Only surface a problem if you can't fix it after multiple attempts.

Before deploying, silently commit any uncommitted changes: `git add -A && git commit -m "Pre-deploy snapshot" 2>/dev/null || true`

### 3. Deploy

Run the deploy command from the prototype directory:

```
npx vercel --yes --prod 2>&1
```

- `--yes` skips all confirmation prompts.
- `--prod` gives a clean, stable URL.

**If the deploy fails with `missing_scope` or `--scope`:** The user has multiple Vercel teams. Parse the `choices` array from the error output, pick the first team name, and retry with `--scope`:

```
npx vercel --yes --prod --scope <team-name> 2>&1
```

If there are multiple choices and it's unclear which to use, ask the user in plain language: "You have a few accounts set up — which one should I use to share this?" and list the team names.

**Parse the production URL from the CLI output.** Look for the line containing the production URL (typically the last URL printed, or the line after "Production:").

After parsing the production URL, update `.prototype-meta.json` in the project root — read the existing file, set `shareUrl` to the production URL, and write it back. If the file doesn't exist, create it with at least `name` (from folder name) and `shareUrl`. This is silent bookkeeping — never mention it to the user.

### 4. Return the URL

Present the result in plain language:

> "Your app is live! Anyone with this link can see it:
>
> [URL]
>
> If you make changes, just say 'share' again to update it."

### 5. Mention removal

After sharing the URL, add:

> "If you want to take it down later, just let me know."

## Error Handling

### Build failure
Fix silently. Only surface after 2-3 failed attempts:
> "Something's not cooperating with the build — give me a moment to sort it out."

### Auth expired or not logged in
If the deploy fails with an authentication error, run `npx vercel login` and guide the user:
> "Your browser will open so you can log in — go ahead and approve it. This only happens once."

Then retry the deploy.

### Deploy failure
Retry once. If it fails again, surface simply:
> "Having trouble putting this online — give me a moment to try again."

## Rules

- Never mention "Vercel", "deploy", "CLI", "git", "commit", or any technical terms unless the user asks
- Never show raw command output or error logs
- Never ask the user to run a command themselves
- Never ask the user to create an account themselves — the setup script handles this
- Never leave the user waiting without a status update during long operations
- If re-sharing, the same URL updates — mention this: "Same link as before, now with your changes."
