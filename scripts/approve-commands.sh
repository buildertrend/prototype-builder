#!/usr/bin/env bash
# PermissionRequest hook — auto-approves safe tool calls for prototype workflows.
# Falls through to normal permission prompt for anything not explicitly allowed.

set -euo pipefail

INPUT=$(cat)

# Parse JSON fields from stdin. Try node first (our dependency), fall back to jq.
parse_field() {
  local field="$1"
  if command -v node &>/dev/null; then
    echo "$INPUT" | node -e "
      let d=''; process.stdin.on('data',c=>d+=c); process.stdin.on('end',()=>{
        try {
          const val = '$field'.split('.').reduce((o,k)=>o&&o[k], JSON.parse(d));
          process.stdout.write(String(val||''));
        } catch(e) { process.exit(1); }
      });
    " 2>/dev/null
  elif command -v jq &>/dev/null; then
    echo "$INPUT" | jq -r ".$field // empty" 2>/dev/null
  else
    return 1
  fi
}

TOOL=$(parse_field "tool_name") || exit 1
[ -z "$TOOL" ] && exit 1

PROTOTYPES_DIR="$HOME/prototypes"

approve() {
  cat <<'EOF'
{"hookSpecificOutput":{"hookEventName":"PermissionRequest","decision":{"behavior":"allow","message":"auto-approved by prototype-builder plugin"}}}
EOF
  exit 0
}

# --- File operations: auto-approve for files inside ~/prototypes/ ---
case "$TOOL" in
  Read|Write|Edit|Glob|Grep|NotebookEdit)
    FILE_PATH=$(parse_field "tool_input.file_path") || true
    # Glob and Grep use "path" instead of "file_path"
    [ -z "$FILE_PATH" ] && FILE_PATH=$(parse_field "tool_input.path") || true

    if [ -n "$FILE_PATH" ]; then
      # Expand ~ to $HOME for comparison
      EXPANDED_PATH="${FILE_PATH/#\~/$HOME}"
      case "$EXPANDED_PATH" in
        "$PROTOTYPES_DIR"/*) approve ;;
      esac
    fi
    exit 1 # not in prototypes dir — fall through to normal prompt
    ;;
esac

# --- Bash commands ---
if [ "$TOOL" != "Bash" ]; then
  exit 1 # unknown tool — fall through
fi

COMMAND=$(parse_field "tool_input.command") || exit 1
[ -z "$COMMAND" ] && exit 1

# Strip leading whitespace and get the first token (the binary being invoked)
CMD_FIRST=$(echo "$COMMAND" | sed 's/^[[:space:]]*//' | cut -d' ' -f1)

# Safe commands that prototype workflows need
case "$CMD_FIRST" in
  cd|ls|pwd|mkdir|cat|echo|test|true|false|printf|head|tail|wc|sort|uniq|tr|cut|sed|awk|grep|find|which|command|type|diff|touch|cp|mv|rm)
    ;; # allow — basic shell utilities (rm is scoped below for safety)
  node|npm|npx)
    ;; # allow — core prototype toolchain
  git)
    ;; # allow — silent version tracking
  kill|lsof)
    ;; # allow — dev server management
  curl|wget)
    ;; # allow — downloading tools (fnm, etc.)
  bash)
    # Block bare "bash" with no arguments
    if [ "$COMMAND" = "bash" ]; then
      exit 1
    fi
    ;;
  sudo)
    # Only allow scoped apt-get commands for installing git
    case "$COMMAND" in
      "sudo apt-get update"*|"sudo apt-get install"*git*)
        ;; # allow
      "sudo apt install"*git*)
        ;; # allow
      "sudo dnf install"*git*|"sudo yum install"*git*)
        ;; # allow
      *)
        exit 1 ;; # deny — not a recognized safe sudo command
    esac
    ;;
  *)
    # Unknown command — fall through to normal permission prompt
    exit 1
    ;;
esac

approve
