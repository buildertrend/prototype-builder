#!/bin/bash
# Prototype Builder - Uninstaller
# Usage: curl -fsSL https://raw.githubusercontent.com/buildertrend/prototype-builder/main/uninstall.sh | bash

echo ""
echo "  ==================================="
echo "   Prototype Builder - Uninstall"
echo "  ==================================="
echo ""
echo "  This will remove the Prototype Builder"
echo "  commands and skills from Claude Code."
echo ""
echo "  Your prototypes in ~/prototypes/ will NOT"
echo "  be deleted — those are yours to keep."
echo ""

# Commands (current names)
if [ -f "$HOME/.claude/commands/prototype-create.md" ]; then
    rm "$HOME/.claude/commands/prototype-create.md"
    echo "  Removed /prototype-create command"
fi

if [ -f "$HOME/.claude/commands/prototype-share.md" ]; then
    rm "$HOME/.claude/commands/prototype-share.md"
    echo "  Removed /prototype-share command"
fi

# Commands (old names — clean up previous installs)
if [ -f "$HOME/.claude/commands/prototype.md" ]; then
    rm "$HOME/.claude/commands/prototype.md"
    echo "  Removed old /prototype command"
fi

if [ -f "$HOME/.claude/commands/share.md" ]; then
    rm "$HOME/.claude/commands/share.md"
    echo "  Removed old /share command"
fi

# Skills
if [ -d "$HOME/.claude/skills/prototype-builder" ]; then
    rm -rf "$HOME/.claude/skills/prototype-builder"
    echo "  Removed prototype-builder skill"
fi

if [ -d "$HOME/.claude/skills/prototype-sharer" ]; then
    rm -rf "$HOME/.claude/skills/prototype-sharer"
    echo "  Removed prototype-sharer skill"
fi

# CLAUDE.md in prototypes folder
if [ -f "$HOME/prototypes/CLAUDE.md" ]; then
    rm "$HOME/prototypes/CLAUDE.md"
    echo "  Removed ~/prototypes/CLAUDE.md"
fi

# Figma MCP
if command -v claude &>/dev/null; then
    claude mcp remove figma &>/dev/null || true
    echo "  Removed Figma MCP connection"
fi

echo ""
echo "  Done! Prototype Builder has been removed."
echo ""
echo "  NOT removed (safe to keep):"
echo "    - ~/prototypes/ and your prototype projects"
echo "    - Git, Node.js, npm, Vercel CLI"
echo "    - Your Vercel account"
echo ""
