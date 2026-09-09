# shellcheck shell=bash
# Reimu · ui: prompts and menus. Uses gum (https://github.com/charmbracelet/gum)
# when it is available, which Reimu fetches on the live ISO; falls back to
# plain Bash prompts otherwise. Every function has the same contract in both.
#
# ask_text   VAR "prompt" "default" ["placeholder"]
# ask_secret VAR "prompt"                              asked twice, never logged
# ask_yesno  "prompt" [y|n]                            return code
# ask_choice VAR "prompt" "default_key" "key|Label|hint" ...
# ask_multi  VAR "prompt" "preselected keys" "key|Label|hint" ...
# ask_menu   VAR "title" "key|Label|current value" ...
# ask_filter VAR "prompt" "default" list_cmd...       searchable list
# ui_help "text"                                       explanation box
# ui_box "title" "text"                                framed block
# ui_phase n total "title"                             progress header

UI_GUM=0
UI_WIDTH=78
GUM_VERSION="2.0.0"

# Reimu's palette for gum: shrine red, paper white, dim grey.
ui_theme() {
  export GUM_CHOOSE_CURSOR_FOREGROUND=196 GUM_CHOOSE_SELECTED_FOREGROUND=203 GUM_CHOOSE_HEADER_FOREGROUND=255
  export GUM_CHOOSE_CURSOR="▸ " GUM_CHOOSE_SELECTED_PREFIX="◉ " GUM_CHOOSE_UNSELECTED_PREFIX="○ " GUM_CHOOSE_CURSOR_PREFIX="  "
  export GUM_FILTER_INDICATOR="▸" GUM_FILTER_INDICATOR_FOREGROUND=196 GUM_FILTER_MATCH_FOREGROUND=203 GUM_FILTER_HEADER_FOREGROUND=255
  export GUM_FILTER_PROMPT="🔍 " GUM_FILTER_PLACEHOLDER="type to search"
  export GUM_INPUT_CURSOR_FOREGROUND=196 GUM_INPUT_HEADER_FOREGROUND=255 GUM_INPUT_PROMPT="▸ "
  export GUM_CONFIRM_PROMPT_FOREGROUND=255 GUM_CONFIRM_SELECTED_BACKGROUND=196 GUM_CONFIRM_SELECTED_FOREGROUND=255
  export GUM_CONFIRM_UNSELECTED_BACKGROUND=237 GUM_CONFIRM_UNSELECTED_FOREGROUND=250
  export GUM_SPIN_SPINNER_FOREGROUND=196 GUM_SPIN_TITLE_FOREGROUND=252
}

# Called once at start. Gets gum on the ISO if it is missing.
ui_init() {
  if [[ ! -t 0 || ! -t 1 ]]; then
    UI_GUM=0; return 0
  fi
  if ! has gum && ! (( DRY_RUN )); then
    printf '%s◆%s Preparing the interface (fetching gum)…\n' "$C_MAGENTA" "$C_RESET"
    if has pacman; then
      pacman -Sy --noconfirm --needed gum >> "$REIMU_LOG" 2>&1 || true
    fi
    if ! has gum && has curl; then
      # Static binary straight from the release; works even when the ISO's package database is stale.
      local arch tgz dir="/tmp/reimu-gum"
      case "$(uname -m)" in x86_64) arch=x86_64 ;; aarch64) arch=arm64 ;; *) arch="" ;; esac
      if [[ -n "$arch" ]]; then
        tgz="https://github.com/charmbracelet/gum/releases/download/v${GUM_VERSION}/gum_${GUM_VERSION}_Linux_${arch}.tar.gz"
        mkdir -p "$dir"
        if curl -fsSL --max-time 60 "$tgz" | tar xz -C "$dir" --strip-components=1 2>> "$REIMU_LOG"; then
          chmod +x "$dir/gum" 2>/dev/null; export PATH="$dir:$PATH"
        fi
      fi
    fi
  fi
  local cols; cols="$(tput cols 2>/dev/null || echo 80)"
  (( cols - 4 < UI_WIDTH )) && UI_WIDTH=$(( cols - 4 ))
  if has gum; then
    UI_GUM=1; ui_theme
  else
    UI_GUM=0
    warn "gum could not be fetched (no network?). Using plain prompts: type the number of an option and press Enter."
  fi
  return 0
}

banner() {
  local -a lines=(
    '██████╗ ███████╗██╗███╗   ███╗██╗   ██╗'
    '██╔══██╗██╔════╝██║████╗ ████║██║   ██║'
    '██████╔╝█████╗  ██║██╔████╔██║██║   ██║'
    '██╔══██╗██╔══╝  ██║██║╚██╔╝██║██║   ██║'
    '██║  ██║███████╗██║██║ ╚═╝ ██║╚██████╔╝'
    '╚═╝  ╚═╝╚══════╝╚═╝╚═╝     ╚═╝ ╚═════╝ '
  )
  local -a shades=(196 196 197 198 199 200)
  local i
  printf '\n'
  for i in "${!lines[@]}"; do
    if [[ -t 1 ]]; then printf '  \e[38;5;%sm%s\e[0m\n' "${shades[$i]}" "${lines[$i]}"; else printf '  %s\n' "${lines[$i]}"; fi
  done
  printf '  %s霊夢 · Arch Linux installer · v%s%s\n\n' "$C_DIM" "$REIMU_VERSION" "$C_RESET"
}

hr() { printf '%s%s%s\n' "$C_DIM" "────────────────────────────────────────────────────────────────────────" "$C_RESET"; }

ui_note() { printf '  %s%s%s\n' "$C_DIM" "$*" "$C_RESET"; }

# Explanation box shown before a question.
ui_help() {
  [[ -n "$1" ]] || return 0
  (( ASSUME_YES )) && [[ -z "${REIMU_INTERACTIVE:-}" ]] && return 0
  if (( UI_GUM )); then
    gum style --border rounded --border-foreground 240 --foreground 252 --padding "0 1" --margin "0 0 1 0" --width "$UI_WIDTH" "$1"
  else
    printf '\n'
    printf '%s' "$1" | fold -s -w 80 | sed "s/^/  ${C_DIM}│ /; s/\$/${C_RESET}/"
    printf '\n\n'
  fi
}

# Framed block with a title (summary, warnings).
ui_box() {
  local title="$1" body="$2" color="${3:-196}"
  if (( UI_GUM )); then
    gum style --border double --border-foreground "$color" --padding "0 2" --margin "1 0" --width "$UI_WIDTH" "$(gum style --bold --foreground "$color" "$title")" "" "$body"
  else
    printf '\n%s%s%s\n' "$C_BOLD" "$title" "$C_RESET"; hr; printf '%s\n' "$body"; hr
  fi
}

# Progress header for a phase.
ui_phase() {
  local n="$1" total="$2" title="$3"
  printf '\n'
  if (( UI_GUM )); then
    gum style --foreground 196 --bold "  [$n/$total] $title"
  else
    printf '%s%s[%s/%s] %s%s\n' "$C_BOLD" "$C_RED" "$n" "$total" "$title" "$C_RESET"
  fi
  log "==== [$n/$total] $title ===="
}

# Unattended mode must not prompt: a prompt means the configuration is incomplete.
_ui_guard() {
  if (( ASSUME_YES )) && [[ -z "${REIMU_INTERACTIVE:-}" ]]; then
    die "Missing value in unattended mode: $1. Add it to the configuration file."
  fi
}

# Commas break gum's --selected list; hints never need them.
_ui_clean() { printf '%s' "${1//,/ ·}"; }

ask_text() {
  local -n _out=$1
  local prompt="$2" def="${3:-}" ph="${4:-}" ans
  _ui_guard "$1"
  while true; do
    if (( UI_GUM )); then
      ans="$(gum input --header "$prompt" --value "$def" --placeholder "$ph" --width 60)" || ans="$def"
    elif [[ -n "$def" ]]; then
      read -r -e -p "$(printf '%s?%s %s %s[%s]%s: ' "$C_CYAN" "$C_RESET" "$prompt" "$C_DIM" "$def" "$C_RESET")" ans
      ans="${ans:-$def}"
    else
      read -r -e -p "$(printf '%s?%s %s: ' "$C_CYAN" "$C_RESET" "$prompt")" ans
    fi
    [[ -n "$ans" ]] && break
    warn "A value is required."
  done
  _out="$ans"
  (( UI_GUM )) && printf '  %s%s: %s%s\n' "$C_DIM" "$prompt" "$ans" "$C_RESET"
  return 0
}

# Like ask_text but an empty answer is fine (returns "").
ask_optional() {
  local -n _out=$1
  local prompt="$2" def="${3:-}" ph="${4:-Enter to skip}" ans
  if (( ASSUME_YES )) && [[ -z "${REIMU_INTERACTIVE:-}" ]]; then _out="$def"; return 0; fi
  if (( UI_GUM )); then
    ans="$(gum input --header "$prompt" --value "$def" --placeholder "$ph" --width 60)" || ans="$def"
  else
    read -r -e -p "$(printf '%s?%s %s %s[%s]%s: ' "$C_CYAN" "$C_RESET" "$prompt" "$C_DIM" "${def:-none}" "$C_RESET")" ans
    ans="${ans:-$def}"
  fi
  [[ "$ans" == "-" ]] && ans=""
  _out="$ans"
  return 0
}

ask_secret() {
  local -n _out=$1
  local prompt="$2" a b
  _ui_guard "$1"
  while true; do
    if (( UI_GUM )); then
      a="$(gum input --password --header "$prompt" --placeholder "" --width 60)" || a=""
      [[ -z "$a" ]] && { warn "Empty passwords are not allowed."; continue; }
      b="$(gum input --password --header "Repeat it" --placeholder "" --width 60)" || b=""
    else
      read -r -s -p "$(printf '%s?%s %s: ' "$C_CYAN" "$C_RESET" "$prompt")" a; printf '\n'
      [[ -z "$a" ]] && { warn "Empty passwords are not allowed."; continue; }
      read -r -s -p "$(printf '%s?%s Repeat: ' "$C_CYAN" "$C_RESET")" b; printf '\n'
    fi
    [[ "$a" == "$b" ]] && break
    warn "They do not match, try again."
  done
  _out="$a"
  return 0
}

ask_yesno() {
  local prompt="$1" def="${2:-y}" ans hint rc
  if (( ASSUME_YES )) && [[ -z "${REIMU_INTERACTIVE:-}" ]]; then
    [[ "$def" == y ]]; return
  fi
  if (( UI_GUM )); then
    if [[ "$def" == y ]]; then gum confirm --default=true "$prompt"; else gum confirm --default=false "$prompt"; fi
    rc=$?
    (( rc == 130 )) && { [[ "$def" == y ]]; rc=$?; }
    if (( rc == 0 )); then printf '  %s%s: yes%s\n' "$C_DIM" "$prompt" "$C_RESET"; else printf '  %s%s: no%s\n' "$C_DIM" "$prompt" "$C_RESET"; fi
    return "$rc"
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

# Single choice. Items are "key|Label|hint" (hint optional).
ask_choice() {
  local -n _out=$1
  local prompt="$2" def="$3"; shift 3
  local -a keys=() labels=()
  local it i ans rest deflabel="" width=0
  _ui_guard "$1"
  for it in "$@"; do
    keys+=("${it%%|*}"); rest="${it#*|}"
    labels+=("$(_ui_clean "${rest%%|*}")")
    (( ${#rest} > width )) && width=${#rest}
  done
  # Align hints in a second column.
  local -a shown=()
  for i in "${!keys[@]}"; do
    it="${*:$((i+1)):1}"; rest="${it#*|}"
    if [[ "$rest" == *"|"* ]]; then
      shown+=("$(printf '%-22s %s' "${labels[$i]}" "$(_ui_clean "${rest#*|}")")")
    else
      shown+=("${labels[$i]}")
    fi
    [[ "${keys[$i]}" == "$def" ]] && deflabel="${shown[$i]}"
  done

  if (( UI_GUM )); then
    local -a opts=()
    for i in "${!keys[@]}"; do opts+=("${shown[$i]}"$'\t'"${keys[$i]}"); done
    local h=${#keys[@]}; (( h > 16 )) && h=16
    ans="$(gum choose --header "$prompt" --height "$h" --label-delimiter $'\t' ${deflabel:+--selected "$deflabel"} "${opts[@]}")" || ans="$def"
    [[ -z "$ans" ]] && ans="$def"
    _out="$ans"
    for i in "${!keys[@]}"; do [[ "${keys[$i]}" == "$ans" ]] && printf '  %s%s: %s%s\n' "$C_DIM" "$prompt" "${labels[$i]}" "$C_RESET"; done
    return 0
  fi

  printf '%s?%s %s\n' "$C_CYAN" "$C_RESET" "$prompt"
  for i in "${!keys[@]}"; do
    if [[ "${keys[$i]}" == "$def" ]]; then
      printf '   %s%2d)%s %s %s(default)%s\n' "$C_BOLD" $((i+1)) "$C_RESET" "${shown[$i]}" "$C_DIM" "$C_RESET"
    else
      printf '   %2d) %s\n' $((i+1)) "${shown[$i]}"
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

# Multi-select. Items are "key|Label|hint". Result: space-separated keys in item order.
ask_multi() {
  local -n _out=$1
  local prompt="$2" pre="$3"; shift 3
  local -a keys=() shown=() on=()
  local it i ans tok rest
  _ui_guard "$1"
  for it in "$@"; do
    keys+=("${it%%|*}"); rest="${it#*|}"
    if [[ "$rest" == *"|"* ]]; then
      shown+=("$(printf '%-22s %s' "$(_ui_clean "${rest%%|*}")" "$(_ui_clean "${rest#*|}")")")
    else
      shown+=("$(_ui_clean "$rest")")
    fi
    if has_word "$pre" "${it%%|*}"; then on+=(1); else on+=(0); fi
  done

  if (( UI_GUM )); then
    # A checkbox list: Enter marks or unmarks the line under the cursor, "Done" finishes.
    local -a opts=()
    local pick cursor="" count h
    while true; do
      opts=(); count=0
      for i in "${!keys[@]}"; do
        if (( on[i] )); then opts+=("[x] ${shown[$i]}"$'\t'"${keys[$i]}"); count=$((count+1)); else opts+=("[ ] ${shown[$i]}"$'\t'"${keys[$i]}"); fi
      done
      opts+=("✔ Done · continue with $count selected"$'\t'"__done__")
      h=${#opts[@]}; (( h > 16 )) && h=16
      pick="$(gum choose --header "$prompt  ·  enter marks or unmarks, pick Done when finished" --height "$h" --label-delimiter $'\t' ${cursor:+--selected "$cursor"} "${opts[@]}")" || pick="__done__"
      [[ "$pick" == "__done__" || -z "$pick" ]] && break
      for i in "${!keys[@]}"; do
        if [[ "${keys[$i]}" == "$pick" ]]; then
          on[i]=$(( 1 - on[i] ))
          cursor="$( (( on[i] )) && printf '[x] %s' "${shown[$i]}" || printf '[ ] %s' "${shown[$i]}" )"
        fi
      done
    done
    local -a result=()
    for i in "${!keys[@]}"; do (( on[i] )) && result+=("${keys[$i]}"); done
    _out="${result[*]}"
    printf '  %s%s: %s%s\n' "$C_DIM" "$prompt" "${_out:-none}" "$C_RESET"
    return 0
  fi

  while true; do
    printf '%s?%s %s %s(type numbers to mark or unmark, e.g. 1 3 · all · none · Enter alone when done)%s\n' "$C_CYAN" "$C_RESET" "$prompt" "$C_DIM" "$C_RESET"
    for i in "${!keys[@]}"; do
      if (( on[i] )); then
        printf '   %s[x]%s %2d) %s\n' "$C_GREEN" "$C_RESET" $((i+1)) "${shown[$i]}"
      else
        printf '   [ ] %2d) %s\n' $((i+1)) "${shown[$i]}"
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
  local -a result=()
  for i in "${!keys[@]}"; do (( on[i] )) && result+=("${keys[$i]}"); done
  _out="${result[*]}"
  return 0
}

# Menu with current values. Items are "key|Label|current value".
ask_menu() {
  local -n _out=$1
  local title="$2"; shift 2
  local -a keys=() labels=() values=()
  local it i ans rest
  for it in "$@"; do
    keys+=("${it%%|*}"); rest="${it#*|}"; labels+=("${rest%%|*}"); values+=("${rest#*|}")
  done
  if (( UI_GUM )); then
    local -a opts=()
    for i in "${!keys[@]}"; do
      opts+=("$(printf '%-28s %s' "${labels[$i]}" "$(_ui_clean "${values[$i]}")")"$'\t'"${keys[$i]}")
    done
    local h=${#keys[@]}; (( h > 22 )) && h=22
    ans="$(gum choose --header "$title" --height "$h" --label-delimiter $'\t' "${opts[@]}")" || ans="quit"
    _out="$ans"
    return 0
  fi
  printf '\n%s%s%s\n' "$C_BOLD" "$title" "$C_RESET"
  hr
  for i in "${!keys[@]}"; do
    if [[ -n "${values[$i]}" ]]; then
      printf '  %2d) %-28s %s%s%s\n' $((i+1)) "${labels[$i]}" "$C_DIM" "${values[$i]}" "$C_RESET"
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

# Searchable list produced by a command (one option per line). Falls back to typing.
ask_filter() {
  local var="$1"
  local -n _out=$1
  local prompt="$2" def="${3:-}" ans; shift 3
  local -a lines
  mapfile -t lines < <("$@")
  _ui_guard "$var"
  if (( UI_GUM )) && (( ${#lines[@]} )); then
    local -a ordered=()
    local l
    [[ -n "$def" ]] && ordered+=("$def")
    for l in "${lines[@]}"; do [[ "$l" == "$def" ]] || ordered+=("$l"); done
    ans="$(printf '%s\n' "${ordered[@]}" | gum filter --header "$prompt  ·  type to search, enter picks" --height 12 --fuzzy)" || ans="$def"
    [[ -z "$ans" ]] && ans="$def"
    _out="$ans"
    printf '  %s%s: %s%s\n' "$C_DIM" "$prompt" "$ans" "$C_RESET"
    return 0
  fi
  ask_text "$var" "$prompt" "$def"
}

pause() {
  (( ASSUME_YES )) && return 0
  read -r -p "$(printf '  %sPress Enter to continue…%s' "$C_DIM" "$C_RESET")" _
}
