#!/bin/bash
# Prototype Builder - Cross-platform installer
# Usage: curl -fsSL https://raw.githubusercontent.com/buildertrend/prototype-builder/main/install.sh | bash
# NOTE: intentionally NOT using set -e so we can show friendly errors instead of silently dying

REPO_BASE="https://raw.githubusercontent.com/buildertrend/prototype-builder/main"

echo ""
echo "  ==================================="
echo "   Prototype Builder - Setup"
echo "  ==================================="
echo ""
echo "  This will install everything you need to"
echo "  build app prototypes with Claude Code."
echo ""

# ------------------------------------------
# OS Detection
# ------------------------------------------
OS="unknown"
case "$(uname -s)" in
    Darwin*)  OS="mac" ;;
    Linux*)
        if grep -qi microsoft /proc/version 2>/dev/null; then
            OS="wsl"
        else
            OS="linux"
        fi
        ;;
    MINGW*|MSYS*|CYGWIN*)  OS="windows" ;;
esac

if [ "$OS" = "unknown" ]; then
    echo "  Could not detect your operating system."
    echo "  Supported: macOS, Linux, WSL, Git Bash on Windows."
    exit 1
fi

echo "  Detected: $OS"
echo ""

ensure_brew() {
    if ! command -v brew &>/dev/null; then
        echo "         Homebrew not found. Installing Homebrew first..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        if [ -f /opt/homebrew/bin/brew ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [ -f /usr/local/bin/brew ]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    fi
    command -v brew &>/dev/null
}

# ------------------------------------------
# 1. Check for Git
# ------------------------------------------
echo "  [1/8] Checking for Git..."
if ! command -v git &>/dev/null; then
    echo "         Not found. Installing Git..."
    if [ "$OS" = "mac" ]; then
        if ensure_brew; then
            brew install git
        else
            echo ""
            echo "  ** Could not install Homebrew. **"
            echo "  Please install Git from https://git-scm.com"
            echo "  then run this script again."
            exit 1
        fi
    elif [ "$OS" = "windows" ]; then
        if command -v winget &>/dev/null; then
            winget install Git.Git --accept-package-agreements --accept-source-agreements
            export PATH="$PROGRAMFILES/Git/cmd:$PATH"
        else
            echo ""
            echo "  ** Please install Git from https://git-scm.com **"
            echo "  Download the installer, run it, then"
            echo "  close and reopen Git Bash and run this script again."
            exit 1
        fi
    elif [ "$OS" = "linux" ] || [ "$OS" = "wsl" ]; then
        if command -v apt-get &>/dev/null; then
            echo "         Using apt to install Git..."
            sudo apt-get install -y git
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y git
        else
            echo ""
            echo "  ** Please install Git from https://git-scm.com **"
            echo "  then run this script again."
            exit 1
        fi
    fi

    if ! command -v git &>/dev/null; then
        echo ""
        echo "  ** Git installation didn't seem to work. **"
        echo "  Please install it from https://git-scm.com"
        echo "  then run this script again."
        exit 1
    fi
    echo "         Installed Git $(git --version | cut -d' ' -f3)"
else
    echo "         Found Git $(git --version | cut -d' ' -f3)"
fi

# ------------------------------------------
# 2. Check for Node.js
# ------------------------------------------
echo ""
echo "  [2/8] Checking for Node.js..."
if ! command -v node &>/dev/null; then
    echo "         Not found. Installing Node.js..."
    if [ "$OS" = "mac" ]; then
        if ensure_brew; then
            brew install node
        else
            echo ""
            echo "  ** Could not install Homebrew. **"
            echo "  Please install Node.js from https://nodejs.org"
            echo "  then run this script again."
            exit 1
        fi
    elif [ "$OS" = "windows" ]; then
        if command -v winget &>/dev/null; then
            winget install OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements
            # Refresh PATH
            export PATH="$PROGRAMFILES/nodejs:$APPDATA/npm:$PATH"
        else
            echo ""
            echo "  ** Please install Node.js from https://nodejs.org **"
            echo "  Download the LTS version, run the installer, then"
            echo "  close and reopen Git Bash and run this script again."
            exit 1
        fi
    elif [ "$OS" = "linux" ] || [ "$OS" = "wsl" ]; then
        if command -v apt-get &>/dev/null; then
            echo "         Using apt to install Node.js..."
            curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
            sudo apt-get install -y nodejs
        elif command -v dnf &>/dev/null; then
            curl -fsSL https://rpm.nodesource.com/setup_lts.x | sudo bash -
            sudo dnf install -y nodejs
        else
            echo ""
            echo "  ** Please install Node.js from https://nodejs.org **"
            echo "  then run this script again."
            exit 1
        fi
    fi

    if ! command -v node &>/dev/null; then
        echo ""
        echo "  ** Node.js installation didn't seem to work. **"
        echo "  Please install it from https://nodejs.org"
        echo "  then run this script again."
        exit 1
    fi
    echo "         Installed Node.js $(node --version)"
else
    echo "         Found Node.js $(node --version)"
fi

# ------------------------------------------
# 3. Check for npm
# ------------------------------------------
echo ""
echo "  [3/8] Checking for npm..."
if ! command -v npm &>/dev/null; then
    echo "  npm not found. It should come with Node.js."
    echo "  Try closing this terminal and running setup again."
    exit 1
fi
echo "         Found npm $(npm --version)"

# ------------------------------------------
# 4. Install files from GitHub
# ------------------------------------------
echo ""
echo "  [4/8] Installing files..."

# Create directories
mkdir -p "$HOME/.claude/commands" || { echo "  ** Could not create ~/.claude/commands **"; exit 1; }
mkdir -p "$HOME/.claude/skills/prototype-builder" || { echo "  ** Could not create skills dir **"; exit 1; }
mkdir -p "$HOME/.claude/skills/prototype-sharer" || { echo "  ** Could not create skills dir **"; exit 1; }
mkdir -p "$HOME/prototypes" || { echo "  ** Could not create ~/prototypes **"; exit 1; }

# Download each file
download() {
    local src="$1" dest="$2" label="$3"
    if curl -fsSL "$REPO_BASE/$src" -o "$dest"; then
        echo "         Installed $label"
    else
        echo "         WARNING: Could not download $label"
    fi
}

# Clean up old command names from previous installs
rm -f "$HOME/.claude/commands/prototype.md" "$HOME/.claude/commands/share.md" 2>/dev/null

download "commands/prototype-create.md"       "$HOME/.claude/commands/prototype-create.md"       "/prototype-create command"
download "commands/prototype-share.md"        "$HOME/.claude/commands/prototype-share.md"        "/prototype-share command"
download "skills/prototype-builder/SKILL.md"  "$HOME/.claude/skills/prototype-builder/SKILL.md"  "prototype-builder skill"
download "skills/prototype-sharer/SKILL.md"   "$HOME/.claude/skills/prototype-sharer/SKILL.md"   "prototype-sharer skill"
download "prototypes-CLAUDE.md"               "$HOME/prototypes/CLAUDE.md"                       "prototypes CLAUDE.md"

# ------------------------------------------
# 5. Connect Figma
# ------------------------------------------
echo ""
echo "  [5/8] Connecting Figma..."
if command -v claude &>/dev/null; then
    claude mcp add --transport http --scope user figma https://mcp.figma.com/mcp &>/dev/null || true
    echo "         Figma MCP configured."
    echo ""
    echo "         NOTE: The first time you mention a Figma file"
    echo "         in Claude, your browser will open to log in."
    echo "         This only happens once."
else
    echo "         WARNING: 'claude' command not found."
    echo "         Install Claude Code first, then re-run this script"
    echo "         or manually run:"
    echo "           claude mcp add --transport http --scope user figma https://mcp.figma.com/mcp"
fi

# ------------------------------------------
# 6. Pre-warm dependency cache
# ------------------------------------------
echo ""
echo "  [6/8] Pre-downloading dependencies so your first"
echo "        prototype starts faster..."
npm cache add create-vite@latest vite@latest react@latest react-dom@latest typescript@latest @vitejs/plugin-react@latest 2>/dev/null || true
echo "         Done!"

# ------------------------------------------
# 7. Install Vercel CLI
# ------------------------------------------
echo ""
echo "  [7/8] Installing sharing tools..."
if ! npm install -g vercel &>/dev/null; then
    echo "         WARNING: Could not install sharing tools globally."
    echo "         Sharing will still work, just a bit slower the first time."
fi

# ------------------------------------------
# 8. Vercel login
# ------------------------------------------
echo ""
echo "  [8/8] Setting up sharing account..."
echo ""
echo "        Your browser will open so you can create a free"
echo "        account (or log in). This lets you share your"
echo "        prototypes with a link."
echo ""
if command -v vercel &>/dev/null; then
    vercel login < /dev/tty 2>&1 | grep --line-buffered "vercel.com"
    if [ "${PIPESTATUS[0]}" -ne 0 ]; then
        echo ""
        echo "         WARNING: Could not log in right now."
        echo "         That's OK - you'll be prompted to log in the"
        echo "         first time you use /prototype-share."
    else
        echo "         Logged in!"
    fi
else
    echo "         Vercel CLI not available — skipping login."
    echo "         You'll be prompted to log in the first time you use /prototype-share."
fi

# ------------------------------------------
# Done!
# ------------------------------------------
echo ""
echo "  ==================================="
echo "   All set!"
echo "  ==================================="
echo ""
echo "  To start building prototypes:"
echo ""
echo "    1. Open a terminal"
echo "    2. Run: cd ~/prototypes"
echo "    3. Type: claude"
echo "    4. Describe what you want to build, or type"
echo "       /prototype-create followed by a description"
echo ""
echo "  To share a prototype with anyone:"
echo "    /prototype-share"
echo ""
echo "  Examples:"
echo "    \"I want an app where I can add items to a"
echo "     grocery list and check them off\""
echo ""
echo "    /prototype-create A to-do list app where I can"
echo "    add items and check them off"
echo ""
echo "  Your prototypes will be saved in:"
echo "    ~/prototypes"
echo ""
