# shellcheck shell=bash
# Reimu · core: logging, command execution, dry-run, safety helpers.

REIMU_VERSION="0.7.1"
REIMU_RUN_DIR="${REIMU_RUN_DIR:-/run/reimu}"
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
  printf '\n%s%s══ %s ══%s\n' "$C_BOLD" "$C_CYAN" "$(t "$*")" "$C_RESET"
  log "==== $* ===="
}

# ---- command execution -----------------------------------------------------
# run CMD...      : log and execute; output goes to terminal and log. Fails loudly.
# run_tty CMD...  : same but without capturing output (interactive programs).
# run_quiet CMD...: execute without logging arguments (secrets).
# try CMD...      : like run but a failure only warns.
# A short title for the spinner, derived from the command.
run_title() {
  local -a w=("$@")
  [[ "${w[0]}" == arch-chroot ]] && w=("${w[@]:2}")
  [[ "${w[0]}" == sudo ]] && w=("${w[@]:4}")
  local t="${w[*]:0:6}"
  (( ${#t} > 64 )) && t="${t:0:61}…"
  printf '%s' "$t"
}

run() {
  log "\$ $*"
  if (( DRY_RUN )); then
    printf '%s  $ %s%s\n' "$C_DIM" "$*" "$C_RESET"
    return 0
  fi
  local rc title="${RUN_TITLE:-}"
  [[ -n "$title" ]] || title="$(run_title "$@")"
  if [[ -t 1 ]]; then
    # Pure-bash progress line: the command writes to the log, we show its last line.
    # (gum spin used to do this and died on long steps; see the 0.5.4 notes.)
    "$@" >> "$REIMU_LOG" 2>&1 &
    local pid=$! frames='|/-' i=0 last cols
    cols="$(tput cols 2>/dev/null || echo 80)"
    while kill -0 "$pid" 2>/dev/null; do
      last="$(tail -n 1 "$REIMU_LOG" 2>/dev/null | tr -d '\r' | cut -c1-$(( cols > 40 ? cols - 30 : 20 )))"
      printf '\r\033[K  %s%s%s %s %s%s%s' "$C_MAGENTA" "${frames:i%3:1}" "$C_RESET" "$title" "$C_DIM" "$last" "$C_RESET"
      i=$((i+1))
      sleep 0.5
    done
    wait "$pid"; rc=$?
    printf '\r\033[K'
  else
    "$@" >> "$REIMU_LOG" 2>&1
    rc=$?
  fi
  if (( rc != 0 )); then
    err "Failed (exit $rc): $*"
    printf '%s' "$C_DIM"; tail -n 15 "$REIMU_LOG" | sed 's/^/    | /'; printf '%s\n' "$C_RESET"
    run_recover "$@"; return $?
  fi
  printf '  %s[ok]%s %s\n' "$C_GREEN" "$C_RESET" "$title"
  return 0
}

# A command failed. Offer to retry just that command, skip it, or look around,
# instead of throwing the whole installation away.
RUN_NO_RECOVER="${RUN_NO_RECOVER:-0}"
run_recover() {
  (( RUN_NO_RECOVER )) && return 1
  if (( ASSUME_YES )) && [[ -z "${REIMU_INTERACTIVE:-}" ]]; then return 1; fi
  [[ -t 0 ]] || return 1
  local what
  export REIMU_INTERACTIVE=1
  while true; do
    UI_BACK=0
    ask_choice what "That step failed. What now?" retry \
      "retry|Retry|Run the same command again (after a network cut, for example)" \
      "skip|Skip|Continue without it · the rest of the installation goes on" \
      "shell|Shell|Open a shell to look around · type exit to come back here" \
      "abort|Abort|Stop the installation (it can be resumed later with --resume)"
    if (( UI_BACK )); then
      # The prompt itself failed or was escaped: never loop on a broken interface.
      if (( UI_GUM )); then
        UI_GUM=0; UI_BACK=0
        warn "$(t "The interface tool failed; switching to plain prompts.")"
        continue
      fi
      what=abort
    fi
    case "$what" in
      retry)
        if RUN_NO_RECOVER=1 run "$@"; then return 0; fi
        warn "$(t "Still failing. Pick again.")" ;;
      skip) warn "$(tf "Skipped: %s" "$*")"; return 0 ;;
      shell) printf '%s%s%s\n' "$C_YELLOW" "$(t 'Type exit to return to Reimu.')" "$C_RESET"; bash -i || true ;;
      abort) die "Aborted by the user. Resume later with: reimu --resume" ;;
    esac
  done
}

# Wait until the internet is back (network cuts must not kill an installation).
net_wait() {
  (( DRY_RUN )) && return 0
  network_ok && return 0
  warn "$(t "No internet connection. Waiting for it to come back… (Ctrl+C aborts)")"
  local frames='|/-' i=0
  until network_ok; do
    printf '\r\033[K  %s%s%s %s' "$C_MAGENTA" "${frames:i%3:1}" "$C_RESET" "$(t 'Waiting for the network…')"
    i=$((i+1)); sleep 3
  done
  printf '\r\033[K'
  ok "$(t "Network is back.")"
}

# run for commands that download: waits for the network and retries.
run_net() {
  local attempt
  for attempt in 1 2 3 4 5; do
    net_wait
    if run "$@"; then return 0; fi
    warn "$(tf "Attempt %s of 5 failed; retrying in 10 s…" "$attempt")"
    sleep 10
  done
  err "Gave up after 5 attempts: $*"
  return 1
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
chr_user_net() { local user="$1"; shift; run_net arch-chroot "$REIMU_MNT" sudo -u "$user" -H /bin/bash -c "$1"; }
chr_enable() { chr systemctl enable "$@"; }

# Install packages inside the target system (dedup, skip empties).
chr_pkg() {
  local -a pkgs=()
  local p
  for p in "$@"; do [[ -n "$p" ]] && pkgs+=("$p"); done
  (( ${#pkgs[@]} )) || return 0
  if RUN_NO_RECOVER=1 RUN_TITLE="${RUN_TITLE:-Installing ${#pkgs[@]} packages (${pkgs[0]}…)}" run_net arch-chroot "$REIMU_MNT" pacman -S --needed --noconfirm --ask=4 "${pkgs[@]}"; then
    return 0
  fi
  # The batch failed (a package that no longer exists, a conflict…): refresh and go one by one
  # so a single bad name does not take the whole desktop down with it.
  warn "Installing them one by one to find the culprit…"
  RUN_NO_RECOVER=1 RUN_TITLE="Refreshing package databases" run_net arch-chroot "$REIMU_MNT" pacman -Sy --noconfirm || true
  local -a failed=()
  for p in "${pkgs[@]}"; do
    RUN_NO_RECOVER=1 RUN_TITLE="Installing $p" run_net arch-chroot "$REIMU_MNT" pacman -S --needed --noconfirm --ask=4 "$p" || failed+=("$p")
  done
  if (( ${#failed[@]} )); then
    warn "Could not install: ${failed[*]}"
    log "FAILED PACKAGES: ${failed[*]}"
    FAILED_PACKAGES+=" ${failed[*]}"
  fi
  return 0
}
FAILED_PACKAGES=""

# Phase list for the side pane (tmux layout) and anyone tailing it.
progress_write() {
  (( DRY_RUN )) && return 0
  mkdir -p "$REIMU_RUN_DIR" 2>/dev/null || return 0
  printf '%s\n' "$1" > "$REIMU_RUN_DIR/progress.tmp" && mv -f "$REIMU_RUN_DIR/progress.tmp" "$REIMU_RUN_DIR/progress"
  return 0
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
