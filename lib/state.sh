# shellcheck shell=bash
# Reimu · state: what has been done so far, kept on the target disk so an
# interrupted installation (network cut, power loss) can be resumed with
# `reimu --resume`.

STATE_DIR_REL="/var/lib/reimu"
STATE_DONE=""

state_file() { printf '%s%s/state' "$REIMU_MNT" "$STATE_DIR_REL"; }

state_save() {
  (( DRY_RUN )) && return 0
  local f; f="$(state_file)"
  mkdir -p "$(dirname "$f")"
  {
    printf 'PART_BOOT=%q\nPART_ROOT=%q\nPART_HOME=%q\nPART_SWAP=%q\n' "$PART_BOOT" "$PART_ROOT" "$PART_HOME" "$PART_SWAP"
    printf 'ROOT_DEV=%q\nROOT_UUID=%q\nLUKS_UUID=%q\n' "$ROOT_DEV" "$ROOT_UUID" "$LUKS_UUID"
    printf 'STATE_DONE=%q\n' "$STATE_DONE"
  } > "$f"
  config_save "$REIMU_MNT$STATE_DIR_REL/reimu.conf" quiet
}

state_mark() {
  has_word "$STATE_DONE" "$1" || STATE_DONE="${STATE_DONE:+$STATE_DONE }$1"
  state_save
}

state_done() { has_word "$STATE_DONE" "$1"; }

# Read a state file written by state_save (only known keys, %q-quoted values).
state_load() {
  local f="$1" line key val
  [[ -r "$f" ]] || return 1
  while IFS= read -r line; do
    [[ "$line" =~ ^(PART_BOOT|PART_ROOT|PART_HOME|PART_SWAP|ROOT_DEV|ROOT_UUID|LUKS_UUID|STATE_DONE)=(.*)$ ]] || continue
    key="${BASH_REMATCH[1]}"; val="${BASH_REMATCH[2]}"
    # %q output: either bare, $'...' or '...'; eval only this vetted assignment.
    [[ "$val" =~ ^(\$?\'.*\'|[A-Za-z0-9_/.@=:+-]*)$ ]] || continue
    eval "$key=$val"
  done < "$f"
  return 0
}

# Find an interrupted installation: mounted at $REIMU_MNT already, or on a
# partition the user points at. Leaves the target mounted and the config loaded.
state_resume() {
  export REIMU_INTERACTIVE=1
  local f; f="$(state_file)"
  if [[ ! -r "$f" ]]; then
    msg "Nothing mounted at $REIMU_MNT. Which partition holds the interrupted installation?"
    local -a parts=()
    local d p name rest
    while IFS= read -r d; do
      [[ -z "$d" ]] && continue
      while IFS= read -r p; do
        [[ -z "$p" ]] && continue
        name="${p%%|*}"; rest="${p#*|}"
        parts+=("$name|$name|${rest%%|*} ${rest#*|}")
      done < <(list_partitions "${d%%|*}")
    done < <(list_disks)
    (( ${#parts[@]} )) || die "No partitions found."
    local root
    ask_choice root "Root partition of the interrupted installation" "" "${parts[@]}"
    local dev="$root"
    if [[ "$(blkid -s TYPE -o value "$root" 2>/dev/null)" == crypto_LUKS ]]; then
      ask_secret LUKS_PASSWORD "Disk encryption password"
      printf '%s' "$LUKS_PASSWORD" | cryptsetup open "$root" cryptroot - || die "Could not open the LUKS volume."
      dev="/dev/mapper/cryptroot"
    fi
    local fstype; fstype="$(blkid -s TYPE -o value "$dev" 2>/dev/null || true)"
    mkdir -p "$REIMU_MNT"
    if [[ "$fstype" == btrfs ]]; then
      mount -o subvol=@ "$dev" "$REIMU_MNT" || die "Could not mount $dev."
    else
      mount "$dev" "$REIMU_MNT" || die "Could not mount $dev."
    fi
    if [[ ! -r "$f" ]]; then
      umount "$REIMU_MNT"
      die "No Reimu state on $root. Was the installation started with Reimu 0.2 or later?"
    fi
    state_load "$f"
    config_load "$REIMU_MNT$STATE_DIR_REL/reimu.conf"
    config_defaults
    umount "$REIMU_MNT"
    disk_mount_existing
  else
    state_load "$f"
    config_load "$REIMU_MNT$STATE_DIR_REL/reimu.conf"
    config_defaults
  fi
  ok "Resuming. Done so far: ${STATE_DONE:-nothing}"
}
