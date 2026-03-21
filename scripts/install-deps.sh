#!/usr/bin/env bash
# install-deps.sh — Install Git and Node.js if missing.
# Called by /prototype-setup. Designed for non-technical users on macOS or Linux/WSL.
set -euo pipefail

# ---------- helpers ----------

info()  { echo "[setup] $*"; }
fail()  { echo "[setup] ERROR: $*" >&2; }

detect_os() {
  case "$(uname -s)" in
    Darwin) echo "macos" ;;
    Linux)  echo "linux" ;;
    *)      echo "unknown" ;;
  esac
}

command_exists() { command -v "$1" &>/dev/null; }

# ---------- Git ----------

install_git() {
  if command_exists git; then
    info "Git is ready ($(git --version))."
    return 0
  fi

  local os
  os="$(detect_os)"

  info "Git not found — installing..."

  if [[ "$os" == "macos" ]]; then
    # Xcode Command Line Tools includes git
    if command_exists xcode-select; then
      xcode-select --install 2>/dev/null || true
      # xcode-select --install is async on macOS — wait for git to appear
      info "A dialog may have appeared asking to install developer tools. Please approve it."
      info "Waiting for Git to become available..."
      local waited=0
      while ! command_exists git && (( waited < 300 )); do
        sleep 5
        waited=$(( waited + 5 ))
      done
    fi
  elif [[ "$os" == "linux" ]]; then
    if command_exists apt-get; then
      sudo apt-get update -qq && sudo apt-get install -y -qq git
    elif command_exists dnf; then
      sudo dnf install -y git
    elif command_exists yum; then
      sudo yum install -y git
    fi
  fi

  if command_exists git; then
    info "Git installed successfully ($(git --version))."
    return 0
  fi

  fail "Could not install Git automatically."
  fail "Please install it from https://git-scm.com and run /prototype-setup again."
  return 1
}

# ---------- Node.js ----------

install_node() {
  if command_exists node; then
    local node_major
    node_major="$(node --version | sed 's/v\([0-9]*\).*/\1/')"
    if (( node_major >= 18 )); then
      info "Node.js is ready ($(node --version))."
      return 0
    else
      info "Node.js $(node --version) is too old (need v18+). Upgrading..."
    fi
  else
    info "Node.js not found — installing..."
  fi

  # Try existing version managers first
  if command_exists fnm; then
    info "Using fnm to install Node.js LTS..."
    fnm install --lts
    fnm use lts-latest
    eval "$(fnm env)"
    if command_exists node; then
      info "Node.js installed via fnm ($(node --version))."
      return 0
    fi
  fi

  if command_exists nvm; then
    info "Using nvm to install Node.js LTS..."
    nvm install --lts
    nvm use --lts
    if command_exists node; then
      info "Node.js installed via nvm ($(node --version))."
      return 0
    fi
  fi

  # Source nvm if it exists but isn't loaded
  if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
    # shellcheck source=/dev/null
    source "$HOME/.nvm/nvm.sh"
    info "Using nvm to install Node.js LTS..."
    nvm install --lts
    nvm use --lts
    if command_exists node; then
      info "Node.js installed via nvm ($(node --version))."
      return 0
    fi
  fi

  # Install fnm, then use it to install Node
  info "Installing fnm (Fast Node Manager)..."
  if curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell; then
    # Load fnm into current shell
    export PATH="$HOME/.local/share/fnm:$PATH"
    if [[ -d "$HOME/.fnm" ]]; then
      export PATH="$HOME/.fnm:$PATH"
    fi
    eval "$(fnm env)" 2>/dev/null || true

    if command_exists fnm; then
      info "Installing Node.js LTS via fnm..."
      fnm install --lts
      fnm use lts-latest
      eval "$(fnm env)"
    fi
  fi

  if command_exists node; then
    local node_major
    node_major="$(node --version | sed 's/v\([0-9]*\).*/\1/')"
    if (( node_major >= 18 )); then
      info "Node.js installed successfully ($(node --version))."
      return 0
    fi
  fi

  fail "Could not install Node.js automatically."
  fail "Please install it from https://nodejs.org (download the LTS version) and run /prototype-setup again."
  return 1
}

# ---------- main ----------

main() {
  local exit_code=0

  install_git  || exit_code=1
  install_node || exit_code=1

  if (( exit_code == 0 )); then
    info "All dependencies are ready."
  fi

  return $exit_code
}

main
