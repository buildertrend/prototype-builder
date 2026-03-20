## Prototypes Folder

This folder contains prototypes built with Claude Code. Each subfolder is a standalone Vite + React app.

### Working with prototypes

- Run `npm run dev` inside any project folder to start it
- Each project is independent — has its own dependencies and config
- To continue working on a prototype, just tell Claude which one (e.g., "let's keep working on the grocery list app")

### For Claude

When a user opens Claude in this directory or a subdirectory:
- They are likely continuing work on an existing prototype
- Check for an existing project folder matching what they describe before scaffolding a new one
- The prototype-builder skill has full instructions for communication style and workflow

### Matching a user's request to a project folder

When the user refers to a prototype vaguely (e.g., "my app", "the one I was working on"):

1. **Fuzzy match folder names** — "grocery" should match `grocery-list`, "tracker" should match `workout-tracker`.
2. **Check `package.json`** — Read the `name` and `description` fields for additional context about what the project does.
3. **Inspect `src/`** — If the folder name and `package.json` aren't enough, scan source files for clues about the app's purpose.
4. **Use last-modified as a tiebreaker** — When the user says "my app" and there's only recency to go on, prefer the most recently modified project.

### Multiple matches

If more than one project could match, list the options with their last-modified dates and ask the user to pick. Never guess when there's ambiguity — the wrong project could get overwritten.

### Manually-edited projects

Don't assume every project is a clean Vite scaffold. A user may have edited files by hand or added dependencies outside of Claude. Before making changes:
- Check for custom build scripts or non-standard config
- Respect existing project structure and dependencies
- Don't overwrite manual customizations

### No prototypes exist

If `~/prototypes/` is empty or doesn't exist and the user asks about an app:
> "You don't have any prototypes yet. Describe what you want to build and I'll get started!"
