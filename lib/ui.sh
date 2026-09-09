# shellcheck shell=bash
# Reimu · ui: pure-bash prompts and menus. No dialog, no whiptail, nothing to install.
#
# ask_text VAR "prompt" "default"
# ask_secret VAR "prompt"                      (asked twice, never logged)
# ask_yesno "prompt" [y|n]                     -> return code
# ask_choice VAR "prompt" "default_key" "key|Label" ...
# ask_multi VAR "prompt" "preselected keys" "key|Label" ...
# ask_menu VAR "title" "key|Label|value" ...   (menu with current values)

banner() {
  printf '%s%s' "$C_RED" "$C_BOLD"
  cat <<'EOF'
   ___      _
  | _ \___ (_)_ __ _  _
  |   / -_)| | '  \ || |
  |_|_\___||_|_|_|_\_,_|   霊夢
EOF
  printf '%s' "$C_RESET"
  printf '  %sArch Linux installer · v%s%s\n\n' "$C_DIM" "$REIMU_VERSION" "$C_RESET"
}

hr() { printf '%s%s%s\n' "$C_DIM" "────────────────────────────────────────────────────────────" "$C_RESET"; }

ui_note() { printf '  %s%s%s\n' "$C_DIM" "$*" "$C_RESET"; }

# In unattended mode, prompts are not allowed: they mean the config is incomplete.
_ui_guard() {
  if (( ASSUME_YES )) && [[ -z "${REIMU_INTERACTIVE:-}" ]]; then
    die "Missing value in unattended mode: $1. Add it to the configuration file."
  fi
}

ask_text() {
  local -n _out=$1
  local prompt="$2" def="${3:-}" ans
  _ui_guard "$1"
  while true; do
    if [[ -n "$def" ]]; then
      read -r -e -p "$(printf '%s?%s %s %s[%s]%s: ' "$C_CYAN" "$C_RESET" "$prompt" "$C_DIM" "$def" "$C_RESET")" ans
      ans="${ans:-$def}"
    else
      read -r -e -p "$(printf '%s?%s %s: ' "$C_CYAN" "$C_RESET" "$prompt")" ans
    fi
    [[ -n "$ans" ]] && break
    warn "A value is required."
  done
  _out="$ans"
}

ask_secret() {
  local -n _out=$1
  local prompt="$2" a b
  _ui_guard "$1"
  while true; do
    read -r -s -p "$(printf '%s?%s %s: ' "$C_CYAN" "$C_RESET" "$prompt")" a; printf '\n'
    if [[ -z "$a" ]]; then warn "Empty passwords are not allowed."; continue; fi
    read -r -s -p "$(printf '%s?%s Repeat: ' "$C_CYAN" "$C_RESET")" b; printf '\n'
    [[ "$a" == "$b" ]] && break
    warn "They do not match, try again."
  done
  _out="$a"
}

ask_yesno() {
  local prompt="$1" def="${2:-y}" ans hint
  if (( ASSUME_YES )) && [[ -z "${REIMU_INTERACTIVE:-}" ]]; then
    [[ "$def" == y ]]; return
  fi
  [[ "$def" == y ]] && hint="Y/n" || hint="y/N"
  while true; do
    read -r -p "$(printf '%s?%s %s %s[%s]%s ' "$C_CYAN" "$C_RESET" "$prompt" "$C_DIM" "$hint" "$C_RESET")" ans
    ans="${ans:-$def}"
    case "${ans,,}" in
      y|yes|s|si|sí) return 0 ;;
      n|no) return 1 ;;
    esac
  done
}

# Numbered single choice. Items are "key|Label". Accepts number or key.
ask_choice() {
  local -n _out=$1
  local prompt="$2" def="$3"; shift 3
  local -a keys=() labels=()
  local it i ans
  _ui_guard "$1"
  for it in "$@"; do keys+=("${it%%|*}"); labels+=("${it#*|}"); done
  printf '%s?%s %s\n' "$C_CYAN" "$C_RESET" "$prompt"
  for i in "${!keys[@]}"; do
    if [[ "${keys[$i]}" == "$def" ]]; then
      printf '   %s%2d)%s %s %s(default)%s\n' "$C_BOLD" $((i+1)) "$C_RESET" "${labels[$i]}" "$C_DIM" "$C_RESET"
    else
      printf '   %2d) %s\n' $((i+1)) "${labels[$i]}"
    fi
  done
  while true; do
    read -r -p "$(printf '   %s>%s ' "$C_CYAN" "$C_RESET")" ans
    if [[ -z "$ans" && -n "$def" ]]; then _out="$def"; return 0; fi
    if [[ "$ans" =~ ^[0-9]+$ ]] && (( ans >= 1 && ans <= ${#keys[@]} )); then
      _out="${keys[$((ans-1))]}"; return 0
    fi
    for i in "${!keys[@]}"; do
      if [[ "${keys[$i]}" == "$ans" ]]; then _out="$ans"; return 0; fi
    done
    warn "Pick a number between 1 and ${#keys[@]}."
  done
}

# Multi-select with toggles. Type numbers separated by spaces to toggle,
# "all" / "none", or Enter to accept. Result: space-separated keys in item order.
ask_multi() {
  local -n _out=$1
  local prompt="$2" pre="$3"; shift 3
  local -a keys=() labels=() on=()
  local it i ans tok
  _ui_guard "$1"
  for it in "$@"; do
    keys+=("${it%%|*}"); labels+=("${it#*|}")
    if has_word "$pre" "${it%%|*}"; then on+=(1); else on+=(0); fi
  done
  while true; do
    printf '%s?%s %s %s(numbers toggle · all · none · Enter accepts)%s\n' "$C_CYAN" "$C_RESET" "$prompt" "$C_DIM" "$C_RESET"
    for i in "${!keys[@]}"; do
      if (( on[i] )); then
        printf '   %s[x]%s %2d) %s\n' "$C_GREEN" "$C_RESET" $((i+1)) "${labels[$i]}"
      else
        printf '   [ ] %2d) %s\n' $((i+1)) "${labels[$i]}"
      fi
    done
    read -r -p "$(printf '   %s>%s ' "$C_CYAN" "$C_RESET")" ans
    [[ -z "$ans" ]] && break
    for tok in $ans; do
      case "$tok" in
        all)  for i in "${!keys[@]}"; do on[i]=1; done ;;
        none) for i in "${!keys[@]}"; do on[i]=0; done ;;
        *)
          if [[ "$tok" =~ ^[0-9]+$ ]] && (( tok >= 1 && tok <= ${#keys[@]} )); then
            on[tok-1]=$(( 1 - on[tok-1] ))
          else
            warn "Ignored: $tok"
          fi ;;
      esac
    done
  done
  local -a sel=()
  for i in "${!keys[@]}"; do (( on[i] )) && sel+=("${keys[$i]}"); done
  _out="${sel[*]}"
}

# Menu with current values. Items are "key|Label|current value" (value may be empty).
ask_menu() {
  local -n _out=$1
  local title="$2"; shift 2
  local -a keys=() labels=() values=()
  local it i ans rest
  for it in "$@"; do
    keys+=("${it%%|*}"); rest="${it#*|}"; labels+=("${rest%%|*}"); values+=("${rest#*|}")
  done
  printf '\n%s%s%s\n' "$C_BOLD" "$title" "$C_RESET"
  hr
  for i in "${!keys[@]}"; do
    if [[ -n "${values[$i]}" ]]; then
      printf '  %2d) %-26s %s%s%s\n' $((i+1)) "${labels[$i]}" "$C_DIM" "${values[$i]}" "$C_RESET"
    else
      printf '  %2d) %s\n' $((i+1)) "${labels[$i]}"
    fi
  done
  hr
  while true; do
    read -r -p "$(printf '  %s>%s ' "$C_CYAN" "$C_RESET")" ans
    if [[ "$ans" =~ ^[0-9]+$ ]] && (( ans >= 1 && ans <= ${#keys[@]} )); then
      _out="${keys[$((ans-1))]}"; return 0
    fi
    for i in "${!keys[@]}"; do
      if [[ "${keys[$i]}" == "$ans" ]]; then _out="$ans"; return 0; fi
    done
    warn "Pick a number between 1 and ${#keys[@]}."
  done
}

# Press Enter to continue (skipped in unattended mode).
pause() {
  (( ASSUME_YES )) && return 0
  read -r -p "$(printf '  %sPress Enter to continue…%s' "$C_DIM" "$C_RESET")" _
}
