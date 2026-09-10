# shellcheck shell=bash
# Reimu · config: defaults, load/save of the configuration file, validation.
#
# The configuration is a set of REIMU_* shell variables. The file format is
# one `REIMU_KEY="value"` per line; it is parsed, never sourced, so a config
# file downloaded from somewhere cannot run code.

# Keys in the order they are saved. Passwords are never in this list.
CONFIG_KEYS=(
  REIMU_KEYMAP REIMU_LOCALE REIMU_EXTRA_LOCALES REIMU_TIMEZONE REIMU_HOSTNAME
  REIMU_MIRROR_COUNTRIES REIMU_KERNELS
  REIMU_DISK REIMU_DISK_MODE REIMU_FS REIMU_ENCRYPT REIMU_SWAP REIMU_SWAP_SIZE
  REIMU_PART_BOOT REIMU_PART_ROOT REIMU_PART_HOME REIMU_PART_SWAP REIMU_FORMAT_HOME
  REIMU_BOOTLOADER REIMU_SNAPSHOTS
  REIMU_USER REIMU_USER_SHELL REIMU_SUDO REIMU_ROOT_LOGIN
  REIMU_NETWORK REIMU_BLUETOOTH REIMU_PRINTING REIMU_FIREWALL REIMU_SSH REIMU_MULTILIB REIMU_POWER
  REIMU_REPOS REIMU_CUSTOM_REPOS
  REIMU_DESKTOP REIMU_DISPLAY_MANAGER REIMU_GPU REIMU_THEME REIMU_THEME_VARIANT REIMU_ICONS
  REIMU_AUR REIMU_CATALOG REIMU_EXTRA_PACKAGES REIMU_SERVICES REIMU_SANAE
)

config_defaults() {
  : "${REIMU_KEYMAP:=us}"
  : "${REIMU_LOCALE:=en_US.UTF-8}"
  : "${REIMU_EXTRA_LOCALES:=}"
  : "${REIMU_TIMEZONE:=${DETECT_TIMEZONE:-UTC}}"
  : "${REIMU_HOSTNAME:=arch}"
  : "${REIMU_MIRROR_COUNTRIES:=${DETECT_COUNTRY:-}}"
  : "${REIMU_KERNELS:=linux}"
  : "${REIMU_DISK:=}"
  : "${REIMU_DISK_MODE:=auto}"        # auto | manual
  : "${REIMU_FS:=}"                   # btrfs | ext4 | xfs  (always asked)
  : "${REIMU_ENCRYPT:=no}"
  : "${REIMU_SWAP:=}"                 # zram | partition | file | none (always asked)
  : "${REIMU_SWAP_SIZE:=}"            # GiB for partition/file, MiB for zram
  : "${REIMU_PART_BOOT:=}"; : "${REIMU_PART_ROOT:=}"; : "${REIMU_PART_HOME:=}"; : "${REIMU_PART_SWAP:=}"
  : "${REIMU_FORMAT_HOME:=no}"
  : "${REIMU_BOOTLOADER:=}"           # systemd-boot | grub (always asked)
  : "${REIMU_SNAPSHOTS:=yes}"
  : "${REIMU_USER:=}"
  : "${REIMU_USER_SHELL:=bash}"
  : "${REIMU_SUDO:=sudo}"             # sudo | doas
  : "${REIMU_ROOT_LOGIN:=no}"         # keep a root password or lock root
  : "${REIMU_NETWORK:=networkmanager}" # networkmanager | iwd | systemd-networkd
  : "${REIMU_BLUETOOTH:=auto}"
  : "${REIMU_PRINTING:=no}"
  : "${REIMU_FIREWALL:=no}"           # no | firewalld | ufw
  : "${REIMU_SSH:=no}"
  : "${REIMU_MULTILIB:=no}"
  : "${REIMU_POWER:=ppd}"             # ppd | tlp | none (laptops)
  : "${REIMU_REPOS:=}"                # multilib chaotic-aur
  : "${REIMU_CUSTOM_REPOS:=}"         # name=URL name2=URL
  : "${REIMU_DESKTOP:=none}"
  : "${REIMU_DISPLAY_MANAGER:=auto}"
  : "${REIMU_THEME:=default}"         # see THEMES in desktop.sh
  : "${REIMU_THEME_VARIANT:=dark}"    # dark | light
  : "${REIMU_ICONS:=default}"         # see ICONS in desktop.sh
  : "${REIMU_GPU:=auto}"
  : "${REIMU_AUR:=paru}"              # paru | yay | none
  : "${REIMU_CATALOG:=}"
  : "${REIMU_EXTRA_PACKAGES:=}"
  : "${REIMU_SERVICES:=}"
  : "${REIMU_SANAE:=ask}"             # yes | no | ask  (install the Sanae software store, experimental)
}

# Keep the two ways of saying "multilib" in sync (REIMU_MULTILIB is the old key).
config_normalize() {
  if [[ "$REIMU_MULTILIB" == yes ]] && ! has_word "$REIMU_REPOS" multilib; then
    REIMU_REPOS="${REIMU_REPOS:+$REIMU_REPOS }multilib"
  fi
  if has_word "$REIMU_REPOS" multilib; then REIMU_MULTILIB=yes; else REIMU_MULTILIB=no; fi
  return 0
}

# Parse a config file. Only REIMU_* assignments are accepted.
config_load() {
  local file="$1" line key val n=0
  [[ -r "$file" ]] || die "Cannot read configuration file: $file"
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%%$'\r'}"
    [[ "$line" =~ ^[[:space:]]*(#|$) ]] && continue
    if [[ "$line" =~ ^[[:space:]]*(REIMU_[A-Z0-9_]+)=(.*)$ ]]; then
      key="${BASH_REMATCH[1]}"; val="${BASH_REMATCH[2]}"
      val="${val%%[[:space:]]#*}"          # trailing comment
      val="${val%"${val##*[![:space:]]}"}" # trailing spaces
      if [[ "$val" =~ ^\"(.*)\"$ ]]; then
        val="${BASH_REMATCH[1]}"; val="${val//\\\"/\"}"; val="${val//\\\\/\\}"
      elif [[ "$val" =~ ^\'(.*)\'$ ]]; then
        val="${BASH_REMATCH[1]}"
      fi
      if has_word "${CONFIG_KEYS[*]}" "$key"; then
        printf -v "$key" '%s' "$val"; n=$((n+1))
      else
        warn "Unknown key ignored: $key"
      fi
    else
      warn "Ignored line in config: $line"
    fi
  done < "$file"
  log "Loaded $n keys from $file"
}

# Fetch a config from a URL into a temp file and load it.
config_load_any() {
  local src="$1"
  if [[ "$src" =~ ^https?:// ]]; then
    local tmp; tmp="$(mktemp)"
    curl -fsSL "$src" -o "$tmp" || die "Could not download $src"
    config_load "$tmp"
  else
    config_load "$src"
  fi
}

config_save() {
  local file="$1" quiet="${2:-}" key val
  mkdir -p "$(dirname "$file")"
  {
    printf '# Reimu %s configuration · %(%Y-%m-%d %H:%M)T\n' "$REIMU_VERSION" -1
    printf '# Passwords are never stored here. Use: reimu --config %s\n\n' "$(basename "$file")"
    for key in "${CONFIG_KEYS[@]}"; do
      val="${!key-}"
      val="${val//\\/\\\\}"; val="${val//\"/\\\"}"
      printf '%s="%s"\n' "$key" "$val"
    done
  } > "$file"
  [[ -n "$quiet" ]] || ok "Configuration saved to $file"
}

# Validate everything before touching the disk. Returns 1 with a list of problems.
config_validate() {
  local -a problems=()
  config_normalize
  local r
  for r in $REIMU_CUSTOM_REPOS; do
    [[ "$r" =~ ^[A-Za-z0-9_.-]+=https?://.+$ ]] || problems+=("Custom repository must look like name=URL (got '$r').")
  done
  [[ "$REIMU_HOSTNAME" =~ ^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$ ]] || problems+=("Hostname '$REIMU_HOSTNAME' is not valid.")
  [[ -n "$REIMU_USER" ]] || problems+=("No user name.")
  [[ -z "$REIMU_USER" || "$REIMU_USER" =~ ^[a-z_][a-z0-9_-]{0,31}$ ]] || problems+=("User name '$REIMU_USER' is not valid (lowercase, no spaces).")
  [[ "$REIMU_USER" != root ]] || problems+=("The user cannot be root.")
  case "$REIMU_FS" in btrfs|ext4|xfs) ;; *) problems+=("Filesystem must be btrfs, ext4 or xfs (got '$REIMU_FS').");; esac
  case "$REIMU_SWAP" in zram|partition|file|none) ;; *) problems+=("Swap must be zram, partition, file or none (got '$REIMU_SWAP').");; esac
  case "$REIMU_BOOTLOADER" in systemd-boot|grub|limine) ;; *) problems+=("Bootloader must be systemd-boot, grub or limine (got '$REIMU_BOOTLOADER').");; esac
  if [[ "$REIMU_BOOTLOADER" == systemd-boot && "$DETECT_FIRMWARE" == bios ]]; then
    problems+=("systemd-boot needs UEFI; this machine booted in BIOS mode. Use grub or limine.")
  fi
  case "$REIMU_DISK_MODE" in
    auto)
      [[ -n "$REIMU_DISK" ]] || problems+=("No target disk.")
      [[ "$REIMU_SWAP" == partition && -z "$REIMU_SWAP_SIZE" ]] && problems+=("Swap partition needs a size.")
      ;;
    manual)
      [[ -n "$REIMU_PART_BOOT" ]] || problems+=("Manual mode: no boot/EFI partition.")
      [[ -n "$REIMU_PART_ROOT" ]] || problems+=("Manual mode: no root partition.")
      [[ "$REIMU_SWAP" == partition && -z "$REIMU_PART_SWAP" ]] && problems+=("Manual mode: swap=partition but no swap partition chosen.")
      ;;
    *) problems+=("Disk mode must be auto or manual.") ;;
  esac
  [[ "$REIMU_SNAPSHOTS" == yes && "$REIMU_FS" != btrfs ]] && REIMU_SNAPSHOTS=no
  [[ -n "$REIMU_KERNELS" ]] || problems+=("At least one kernel is required.")
  case "$REIMU_DESKTOP" in
    none|gnome|plasma|xfce|cinnamon|mate|budgie|lxqt|cosmic|deepin|hyprland|sway|niri|i3) ;;
    *) problems+=("Unknown desktop '$REIMU_DESKTOP'.") ;;
  esac
  if (( ${#problems[@]} )); then
    local p; for p in "${problems[@]}"; do err "$p"; done
    return 1
  fi
  return 0
}
