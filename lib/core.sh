# shellcheck shell=bash
# Reimu · core: logging, command execution, dry-run, safety helpers.

REIMU_VERSION="0.1.0"
REIMU_LOG="${REIMU_LOG:-/var/log/reimu.log}"
REIMU_MNT="${REIMU_MNT:-/mnt}"
DRY_RUN="${DRY_RUN:-0}"
ASSUME_YES="${ASSUME_YES:-0}"

# ---- colors ----------------------------------------------------------------
if [[ -t 1 ]]; then
  C_RESET=$'\e[0m'; C_BOLD=$'\e[1m'; C_DIM=$'\e[2m'
  C_RED=$'\e[31m'; C_GREEN=$'\e[32m'; C_YELLOW=$'\e[33m'; C_BLUE=$'\e[34m'; C_MAGENTA=$'\e[35m'; C_CYAN=$'\e[36m'
else
  C_RESET=""; C_BOLD=""; C_DIM=""; C_RED=""; C_GREEN=""; C_YELLOW=""; C_BLUE=""; C_MAGENTA=""; C_CYAN=""
fi

# ---- logging ---------------------------------------------------------------
log_init() {
  if (( DRY_RUN )); then
    REIMU_LOG="${TMPDIR:-/tmp}/reimu-dry.log"
  fi
  mkdir -p "$(dirname "$REIMU_LOG")" 2>/dev/null || REIMU_LOG="/tmp/reimu.log"
  : >> "$REIMU_LOG" 2>/dev/null || REIMU_LOG="/dev/null"
  log "reimu $REIMU_VERSION started (dry-run=$DRY_RUN)"
}

log() { printf '[%(%H:%M:%S)T] %s\n' -1 "$*" >> "$REIMU_LOG"; }

msg()  { printf '%s◆%s %s\n' "$C_MAGENTA" "$C_RESET" "$*"; log "$*"; }
ok()   { printf '%s✔%s %s\n' "$C_GREEN" "$C_RESET" "$*"; log "OK: $*"; }
warn() { printf '%s▲%s %s\n' "$C_YELLOW" "$C_RESET" "$*" >&2; log "WARN: $*"; }
err()  { printf '%s✖%s %s\n' "$C_RED" "$C_RESET" "$*" >&2; log "ERROR: $*"; }
die()  { err "$*"; exit 1; }

step() {
  printf '\n%s%s══ %s ══%s\n' "$C_BOLD" "$C_CYAN" "$*" "$C_RESET"
  log "==== $* ===="
}

# ---- command execution -----------------------------------------------------
# run CMD...      : log and execute; output goes to terminal and log. Fails loudly.
# run_tty CMD...  : same but without capturing output (interactive programs).
# run_quiet CMD...: execute without logging arguments (secrets).
# try CMD...      : like run but a failure only warns.
run() {
  log "\$ $*"
  if (( DRY_RUN )); then
    printf '%s  $ %s%s\n' "$C_DIM" "$*" "$C_RESET"
    return 0
  fi
  local rc
  "$@" 2>&1 | tee -a "$REIMU_LOG"
  rc=${PIPESTATUS[0]}
  if (( rc != 0 )); then
    err "Command failed (exit $rc): $*"
    return "$rc"
  fi
}

run_tty() {
  log "\$ $* (tty)"
  if (( DRY_RUN )); then
    printf '%s  $ %s%s\n' "$C_DIM" "$*" "$C_RESET"
    return 0
  fi
  "$@"
}

run_quiet() {
  log "\$ ${1} … (arguments hidden)"
  if (( DRY_RUN )); then
    printf '%s  $ %s … (arguments hidden)%s\n' "$C_DIM" "$1" "$C_RESET"
    return 0
  fi
  "$@" >> "$REIMU_LOG" 2>&1
}

try() {
  run "$@" || warn "Continuing despite the failure above."
  return 0
}

# Write a file inside the target system. Usage: write_file /path <<'EOF' ... EOF
write_file() {
  local path="$REIMU_MNT$1" content
  content="$(cat)"
  log "write $path"
  if (( DRY_RUN )); then
    printf '%s  > %s%s\n' "$C_DIM" "$path" "$C_RESET"
    printf '%s' "$content" | sed "s/^/${C_DIM}    │ /; s/\$/${C_RESET}/"
    printf '\n'
    return 0
  fi
  mkdir -p "$(dirname "$path")"
  printf '%s\n' "$content" > "$path"
}

# Append a line to a file inside the target system.
append_file() {
  local path="$REIMU_MNT$1"; shift
  log "append $path: $*"
  if (( DRY_RUN )); then
    printf '%s  >> %s: %s%s\n' "$C_DIM" "$path" "$*" "$C_RESET"
    return 0
  fi
  mkdir -p "$(dirname "$path")"
  printf '%s\n' "$*" >> "$path"
}

# sed -i inside the target system.
edit_file() {
  local expr="$1" path="$REIMU_MNT$2"
  log "sed '$expr' $path"
  if (( DRY_RUN )); then
    printf '%s  sed %q %s%s\n' "$C_DIM" "$expr" "$path" "$C_RESET"
    return 0
  fi
  sed -i "$expr" "$path"
}

# ---- chroot helpers --------------------------------------------------------
chr() { run arch-chroot "$REIMU_MNT" "$@"; }
chr_sh() { run arch-chroot "$REIMU_MNT" /bin/bash -c "$1"; }
chr_user() { local user="$1"; shift; run arch-chroot "$REIMU_MNT" sudo -u "$user" -H /bin/bash -c "$1"; }
chr_enable() { chr systemctl enable "$@"; }

# Install packages inside the target system (dedup, skip empties).
chr_pkg() {
  local -a pkgs=()
  local p
  for p in "$@"; do [[ -n "$p" ]] && pkgs+=("$p"); done
  (( ${#pkgs[@]} )) || return 0
  chr pacman -S --needed --noconfirm "${pkgs[@]}"
}

# ---- misc ------------------------------------------------------------------
has() { command -v "$1" >/dev/null 2>&1; }

require_root() {
  (( DRY_RUN )) && return 0
  [[ $EUID -eq 0 ]] || die "Reimu must run as root (you are root by default on the Arch ISO)."
}

# Join array elements with a separator.
join_by() { local IFS="$1"; shift; printf '%s' "$*"; }

# Does the space-separated list $1 contain word $2?
has_word() {
  local w
  for w in $1; do [[ "$w" == "$2" ]] && return 0; done
  return 1
}
