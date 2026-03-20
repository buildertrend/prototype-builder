---
name: Prototype Manager
description: >
  This skill should be used when the user asks to "list my prototypes",
  "show my prototypes", "what prototypes do I have", "what apps have I built",
  "delete the old one", "remove that prototype", "clean up my prototypes",
  "what's the URL for", "is my app still live", "check if it's shared",
  "which ones are shared", or wants to see, manage, or remove their
  existing prototypes.
---

# Prototype Manager

List, inspect, and delete prototypes in `~/prototypes/`. The user is non-technical — all communication must be in terms of behavior, not technology.

## Communication Rules

Same rules as prototype-builder and prototype-sharer:

- **Describe behavior, not implementation.** Never mention file paths, JSON files, CLI tools, or folder structures unless the user explicitly asks.
- **Keep it casual and brief.** Short sentences, no jargon.
- **Never ask technical questions.** Handle all decisions autonomously.
- **Never show raw error output, stack traces, or build logs.**

## Workflow

### 1. List

When the user asks to see their prototypes, scan all subfolders in `~/prototypes/`.

For each subfolder:
1. Read `.prototype-meta.json` if it exists — use `name`, `description`, `createdAt`, and `shareUrl`.
2. If no metadata file exists, fall back to the folder name and check for `package.json` to confirm it's a prototype.

Present the results as a human-readable list. For each prototype, show:
- **Name** — from metadata or folder name, formatted nicely (e.g., "grocery-list" becomes "Grocery List")
- **Description** — from metadata, or omit if unavailable
- **Share status** — "Shared" with the URL if `shareUrl` is set, or "Not shared yet" otherwise

Example:

> Here's what you've built:
>
> 1. **Grocery List** — Add items and check them off. *Shared:* [URL]
> 2. **Workout Tracker** — Log exercises and track progress. *Not shared yet.*
>
> Want to open, share, or delete any of these?

### 2. Status

When the user asks about a specific prototype:

1. Match the user's description against prototype names (use fuzzy matching — "grocery" matches `grocery-list`).
2. Read `.prototype-meta.json` if available.
3. Show: name, description, whether it's shared (with URL if so), and when it was created.

Example:

> **Grocery List** — Add items and check them off.
> Created on March 15. Shared at [URL].

If the prototype has no metadata, show what's available from the folder name and mention that details aren't tracked for older prototypes.

### 3. Delete

When the user asks to delete or remove a prototype:

1. Match the user's description against prototype names.
2. **Always confirm before deleting.** If the prototype has a shared URL, mention that the link will stop working:
   > "Are you sure you want to delete **Grocery List**? The shared link will stop working too."
   If it's not shared:
   > "Are you sure you want to delete **Grocery List**? This can't be undone."
3. On confirmation, delete the prototype folder (`rm -rf ~/prototypes/<name>`).
4. Confirm deletion:
   > "Done — **Grocery List** has been removed."

## Error Handling

### No prototypes exist
If `~/prototypes/` is empty or doesn't exist:
> "You don't have any prototypes yet. Want to build one? Just describe what you want!"

### Missing metadata
Use the folder name as the prototype name. Don't mention that metadata is missing — just show what's available.

### Ambiguous match
If the user's description matches multiple prototypes, list the matches and ask which one:
> "I found a few that could match — did you mean **Grocery List** or **Gift List**?"

## Rules

- Never show file paths, folder names, or JSON content to the user
- Never ask the user to navigate to a directory or run a command
- Never show raw error output
- Always confirm before deleting
- Format folder names as readable titles (e.g., "grocery-list" → "Grocery List")
- Never mention `.prototype-meta.json` or any internal file names
