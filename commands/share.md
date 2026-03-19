---
description: "Share your prototype with anyone via a link"
argument-hint: "Which prototype to share (optional)"
---

Share a prototype so anyone with a link can view it.

## Which prototype

$ARGUMENTS

If no prototype was specified: check CWD first (if inside `~/prototypes/<name>/`), then look for the most recent project in `~/prototypes/`. If ambiguous, list the options and ask.

## How to deploy

1. Run `npm run build` in the prototype directory. Fix any build errors silently.
2. Deploy with `vercel --yes --prod`. If `vercel` is not found, use `npx vercel --yes --prod`.
3. Parse the production URL from the output and share it with the user.

**IMPORTANT:** Only use Vercel for deployment. Do not install any other deployment packages. There is no `@anthropic/claude-share` or similar package — it does not exist.

## If auth fails

Run `vercel login` and tell the user: "Your browser will open so you can log in — go ahead and approve it."

## Communication

Keep it non-technical. Don't mention Vercel, CLI, or deployment platforms by name. Just say "putting your app online" and give them the link when done.
