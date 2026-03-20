@echo off
setlocal EnableDelayedExpansion

echo.
echo  ===================================
echo   Prototype Builder - Setup
echo  ===================================
echo.
echo  This will install everything you need to
echo  build app prototypes with Claude Code.
echo.

:: ------------------------------------------
:: Try to delegate to bash if available
:: ------------------------------------------
where bash >nul 2>nul
if %ERRORLEVEL% equ 0 (
    echo  Git Bash detected — using install.sh for best experience.
    echo.
    bash -c "curl -fsSL https://raw.githubusercontent.com/buildertrend/prototype-builder/main/install.sh | bash"
    if %ERRORLEVEL% equ 0 (
        pause
        exit /b 0
    )
    echo.
    echo  Bash installer failed. Falling back to CMD installer...
    echo.
)

echo  Running CMD installer...
echo.

set "REPO_BASE=https://raw.githubusercontent.com/buildertrend/prototype-builder/main"

:: ------------------------------------------
:: 1. Check for Node.js
:: ------------------------------------------
echo  [1/7] Checking for Node.js...
where node >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo         Not found. Installing Node.js...
    echo.
    winget install OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements
    if %ERRORLEVEL% neq 0 (
        echo.
        echo  ** Automatic install didn't work. **
        echo  Please go to https://nodejs.org and download the
        echo  version that says "LTS". Run the installer with
        echo  all the defaults, then run this script again.
        echo.
        pause
        exit /b 1
    )
    echo.
    echo         Installed! Refreshing PATH...
    set "PATH=%PROGRAMFILES%\nodejs;%APPDATA%\npm;%PATH%"
) else (
    for /f "tokens=*" %%v in ('node --version') do echo         Found Node.js %%v
)

:: ------------------------------------------
:: 2. Check for npm
:: ------------------------------------------
echo.
echo  [2/7] Checking for npm...
where npm >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo         npm not found. It should come with Node.js.
    echo         Try closing this window, reopening it, and
    echo         running setup again.
    pause
    exit /b 1
) else (
    for /f "tokens=*" %%v in ('npm --version') do echo         Found npm %%v
)

:: ------------------------------------------
:: 3. Download and install files from GitHub
:: ------------------------------------------
echo.
echo  [3/7] Installing files...

:: Create directories
if not exist "%USERPROFILE%\.claude\commands" mkdir "%USERPROFILE%\.claude\commands"
if not exist "%USERPROFILE%\.claude\skills\prototype-builder" mkdir "%USERPROFILE%\.claude\skills\prototype-builder"
if not exist "%USERPROFILE%\.claude\skills\prototype-sharer" mkdir "%USERPROFILE%\.claude\skills\prototype-sharer"
if not exist "%USERPROFILE%\prototypes" mkdir "%USERPROFILE%\prototypes"
if not exist "%USERPROFILE%\prototypes\.claude" mkdir "%USERPROFILE%\prototypes\.claude"

:: Clean up old command names from previous installs
if exist "%USERPROFILE%\.claude\commands\prototype.md" del "%USERPROFILE%\.claude\commands\prototype.md"
if exist "%USERPROFILE%\.claude\commands\share.md" del "%USERPROFILE%\.claude\commands\share.md"

:: Download each file using curl (built into Windows 10+)
curl -fsSL "%REPO_BASE%/commands/prototype-create.md" -o "%USERPROFILE%\.claude\commands\prototype-create.md"
if %ERRORLEVEL% equ 0 (
    echo         Installed /prototype-create command.
) else (
    echo         WARNING: Could not download /prototype-create command.
)

curl -fsSL "%REPO_BASE%/commands/prototype-share.md" -o "%USERPROFILE%\.claude\commands\prototype-share.md"
if %ERRORLEVEL% equ 0 (
    echo         Installed /prototype-share command.
) else (
    echo         WARNING: Could not download /prototype-share command.
)

curl -fsSL "%REPO_BASE%/skills/prototype-builder/SKILL.md" -o "%USERPROFILE%\.claude\skills\prototype-builder\SKILL.md"
if %ERRORLEVEL% equ 0 (
    echo         Installed prototype-builder skill.
) else (
    echo         WARNING: Could not download prototype-builder skill.
)

curl -fsSL "%REPO_BASE%/skills/prototype-sharer/SKILL.md" -o "%USERPROFILE%\.claude\skills\prototype-sharer\SKILL.md"
if %ERRORLEVEL% equ 0 (
    echo         Installed prototype-sharer skill.
) else (
    echo         WARNING: Could not download prototype-sharer skill.
)

curl -fsSL "%REPO_BASE%/prototypes-CLAUDE.md" -o "%USERPROFILE%\prototypes\CLAUDE.md"
if %ERRORLEVEL% equ 0 (
    echo         Installed prototypes CLAUDE.md.
) else (
    echo         WARNING: Could not download prototypes CLAUDE.md.
)

curl -fsSL "%REPO_BASE%/prototypes-settings.json" -o "%USERPROFILE%\prototypes\.claude\settings.json"
if %ERRORLEVEL% equ 0 (
    echo         Installed prototypes settings.
) else (
    echo         WARNING: Could not download prototypes settings.
)

:: ------------------------------------------
:: 4. Connect Figma
:: ------------------------------------------
echo.
echo  [4/7] Connecting Figma...
where claude >nul 2>nul
if %ERRORLEVEL% equ 0 (
    call claude mcp add --transport http --scope user figma https://mcp.figma.com/mcp >nul 2>nul
    echo         Figma MCP configured.
    echo.
    echo         NOTE: The first time you mention a Figma file
    echo         in Claude, it will open your browser to log in
    echo         to Figma. This only happens once.
) else (
    echo         WARNING: 'claude' command not found.
    echo         Install Claude Code first, then re-run this script.
)

:: ------------------------------------------
:: 5. Pre-warm Vite template cache
:: ------------------------------------------
echo.
echo  [5/7] Pre-downloading dependencies so your first
echo         prototype starts faster...
call npm cache add create-vite@latest vite@latest react@latest react-dom@latest typescript@latest @vitejs/plugin-react@latest 2>nul
echo         Done!

:: ------------------------------------------
:: 6. Install Vercel CLI
:: ------------------------------------------
echo.
echo  [6/7] Installing sharing tools...
call npm install -g vercel >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo         WARNING: Could not install sharing tools globally.
    echo         Sharing will still work, just a bit slower the first time.
)

:: ------------------------------------------
:: 7. Vercel login
:: ------------------------------------------
echo.
echo  [7/7] Setting up sharing account...
echo.
echo         Your browser will open so you can create a free
echo         account (or log in). This lets you share your
echo         prototypes with a link.
echo.
where vercel >nul 2>nul
if %ERRORLEVEL% equ 0 (
    call vercel login 2>&1 | findstr /i "vercel.com"
    call vercel whoami >nul 2>nul
    if !ERRORLEVEL! neq 0 (
        echo.
        echo         WARNING: Could not log in right now.
        echo         That's OK - you'll be prompted to log in the
        echo         first time you use /prototype-share.
    ) else (
        echo         Logged in^^!
    )
) else (
    echo         Vercel CLI not available - skipping login.
    echo         You'll be prompted to log in the first time you use /prototype-share.
)

:: ------------------------------------------
:: Done!
:: ------------------------------------------
echo.
echo  ===================================
echo   All set!
echo  ===================================
echo.
echo  To start building prototypes:
echo.
echo    1. Open a terminal (Command Prompt, PowerShell,
echo       or Windows Terminal)
echo    2. Run: cd %USERPROFILE%\prototypes
echo    3. Type: claude
echo    4. Describe what you want to build, or type
echo       /prototype-create followed by a description
echo.
echo  To share a prototype with anyone:
echo    /prototype-share
echo.
echo  Examples:
echo    "I want an app where I can add items to a
echo     grocery list and check them off"
echo.
echo    /prototype-create A to-do list app where I can
echo    add items and check them off
echo.
echo  Your prototypes will be saved in:
echo    %USERPROFILE%\prototypes
echo.
pause
