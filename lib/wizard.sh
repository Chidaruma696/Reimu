# shellcheck shell=bash
# Reimu · wizard: the interactive part. A main menu with every section and
# its current value, plus a guided mode that walks through all of them.

# ---- sections --------------------------------------------------------------

wiz_locale() {
  step "Language, keyboard and time"
  ask_choice REIMU_KEYMAP "Console keyboard layout" "$REIMU_KEYMAP" \
    "us|US English (us)" "la-latin1|Latin American Spanish (la-latin1)" "es|Spain Spanish (es)" \
    "br-abnt2|Brazilian (br-abnt2)" "de-latin1|German (de-latin1)" "fr|French (fr)" "it|Italian (it)" \
    "pt-latin1|Portuguese (pt-latin1)" "uk|British (uk)" "dvorak|Dvorak" "other|Other (type it)"
  if [[ "$REIMU_KEYMAP" == other ]]; then
    ask_text REIMU_KEYMAP "Keymap name (see: localectl list-keymaps)" "us"
  fi
  ask_choice REIMU_LOCALE "System language (locale)" "$REIMU_LOCALE" \
    "en_US.UTF-8|English (US)" "es_MX.UTF-8|Español (México)" "es_ES.UTF-8|Español (España)" \
    "es_AR.UTF-8|Español (Argentina)" "es_CO.UTF-8|Español (Colombia)" "es_CL.UTF-8|Español (Chile)" \
    "pt_BR.UTF-8|Português (Brasil)" "de_DE.UTF-8|Deutsch" "fr_FR.UTF-8|Français" "it_IT.UTF-8|Italiano" \
    "ja_JP.UTF-8|日本語" "other|Other (type it)"
  if [[ "$REIMU_LOCALE" == other ]]; then
    ask_text REIMU_LOCALE "Locale (e.g. nl_NL.UTF-8)" "en_US.UTF-8"
  fi
  ask_text REIMU_EXTRA_LOCALES "Extra locales to generate, space separated (or '-' for none)" "${REIMU_EXTRA_LOCALES:--}"
  [[ "$REIMU_EXTRA_LOCALES" == "-" ]] && REIMU_EXTRA_LOCALES=""
  ask_text REIMU_TIMEZONE "Time zone (Region/City)" "$REIMU_TIMEZONE"
  ask_text REIMU_HOSTNAME "Host name" "$REIMU_HOSTNAME"
  ask_text REIMU_MIRROR_COUNTRIES "Mirror countries for reflector, comma separated (or '-' for worldwide)" "${REIMU_MIRROR_COUNTRIES:--}"
  [[ "$REIMU_MIRROR_COUNTRIES" == "-" ]] && REIMU_MIRROR_COUNTRIES=""
  return 0
}

wiz_disk() {
  step "Disk"
  local -a items=()
  local d
  while IFS= read -r d; do
    [[ -z "$d" ]] && continue
    local name="${d%%|*}" rest="${d#*|}"
    local size="${rest%%|*}" model="${rest#*|}"
    local tag=""
    is_live_media "$name" && tag=" (live media, do not use)"
    items+=("$name|$name  $size  $model$tag")
  done < <(list_disks)
  (( ${#items[@]} )) || die "No disks found."

  ask_choice REIMU_DISK_MODE "How do you want to partition?" "$REIMU_DISK_MODE" \
    "auto|Automatic: wipe a whole disk and lay it out for me" \
    "manual|Manual: I partition with cfdisk and tell Reimu which partition is what"

  ask_choice REIMU_DISK "Target disk" "$REIMU_DISK" "${items[@]}"
  is_live_media "$REIMU_DISK" && die "That disk is the live media you booted from."

  if [[ "$REIMU_DISK_MODE" == manual ]]; then
    if ask_yesno "Open cfdisk on $REIMU_DISK now to create the partitions?" y; then
      run_tty cfdisk "$REIMU_DISK"
    fi
    wiz_manual_partitions
  fi

  ask_choice REIMU_FS "Root filesystem" "${REIMU_FS:-btrfs}" \
    "btrfs|btrfs · subvolumes, compression, snapshots (recommended)" \
    "ext4|ext4 · the classic, no snapshots" \
    "xfs|xfs · fast with big files, no shrink"

  if [[ "$REIMU_FS" == btrfs ]]; then
    ask_yesno "Enable snapshots (snapper + snap-pac; boot into snapshots with GRUB)?" "$( [[ "$REIMU_SNAPSHOTS" == yes ]] && echo y || echo n )" \
      && REIMU_SNAPSHOTS=yes || REIMU_SNAPSHOTS=no
  else
    REIMU_SNAPSHOTS=no
  fi

  ask_yesno "Encrypt the root partition with LUKS2? (password asked at install time)" "$( [[ "$REIMU_ENCRYPT" == yes ]] && echo y || echo n )" \
    && REIMU_ENCRYPT=yes || REIMU_ENCRYPT=no

  local swap_items=("zram|zram · compressed swap in RAM, no disk space (recommended)")
  [[ "$REIMU_DISK_MODE" == auto || -n "$REIMU_PART_SWAP" ]] && swap_items+=("partition|Swap partition on disk (needed for hibernation)")
  swap_items+=("file|Swap file on the root filesystem" "none|No swap")
  ask_choice REIMU_SWAP "Swap" "${REIMU_SWAP:-zram}" "${swap_items[@]}"
  case "$REIMU_SWAP" in
    zram) ask_text REIMU_SWAP_SIZE "zram size in MiB" "${REIMU_SWAP_SIZE:-$(suggest_zram_mib)}" ;;
    partition|file) ask_text REIMU_SWAP_SIZE "Swap size in GiB" "${REIMU_SWAP_SIZE:-$(suggest_swap_gib)}" ;;
    none) REIMU_SWAP_SIZE="" ;;
  esac
  return 0
}

wiz_manual_partitions() {
  local -a parts=()
  local p
  while IFS= read -r p; do
    [[ -z "$p" ]] && continue
    local name="${p%%|*}" rest="${p#*|}"
    parts+=("$name|$name  ${rest%%|*}  ${rest#*|}")
  done < <(list_partitions "$REIMU_DISK")
  (( ${#parts[@]} )) || die "No partitions on $REIMU_DISK. Create them first."
  local label="EFI system partition (FAT32, 512 MiB or more)"
  [[ "$DETECT_FIRMWARE" == bios ]] && label="Boot partition (will be FAT32; BIOS GPT also needs a 1 MiB 'BIOS boot' partition)"
  ask_choice REIMU_PART_BOOT "$label" "$REIMU_PART_BOOT" "${parts[@]}"
  ask_choice REIMU_PART_ROOT "Root partition (will be formatted)" "$REIMU_PART_ROOT" "${parts[@]}"
  ask_choice REIMU_PART_HOME "Separate /home partition" "${REIMU_PART_HOME:-none}" "none|None (home lives in root)" "${parts[@]}"
  [[ "$REIMU_PART_HOME" == none ]] && REIMU_PART_HOME=""
  if [[ -n "$REIMU_PART_HOME" ]]; then
    ask_yesno "Format $REIMU_PART_HOME? (No keeps existing data)" n && REIMU_FORMAT_HOME=yes || REIMU_FORMAT_HOME=no
  fi
  ask_choice REIMU_PART_SWAP "Swap partition" "${REIMU_PART_SWAP:-none}" "none|None" "${parts[@]}"
  [[ "$REIMU_PART_SWAP" == none ]] && REIMU_PART_SWAP=""
  return 0
}

wiz_boot() {
  step "Boot"
  local -a items=()
  local def="${REIMU_BOOTLOADER:-systemd-boot}"
  if [[ "$DETECT_FIRMWARE" == uefi ]]; then
    items+=("systemd-boot|systemd-boot · simple, fast, UEFI only" "grub|GRUB · menus, themes, boots into btrfs snapshots")
  else
    items+=("grub|GRUB · the only option for BIOS boot"); def=grub
    ui_note "This machine booted in BIOS (legacy) mode."
  fi
  ask_choice REIMU_BOOTLOADER "Bootloader" "$def" "${items[@]}"
  ask_multi REIMU_KERNELS "Kernels" "$REIMU_KERNELS" \
    "linux|linux · stable" "linux-lts|linux-lts · long term support" \
    "linux-zen|linux-zen · desktop tuned" "linux-hardened|linux-hardened · security focused"
  [[ -z "$REIMU_KERNELS" ]] && REIMU_KERNELS=linux
  return 0
}

wiz_user() {
  step "Users"
  ask_text REIMU_USER "User name (lowercase)" "$REIMU_USER"
  ask_choice REIMU_USER_SHELL "Shell" "$REIMU_USER_SHELL" "bash|bash" "zsh|zsh" "fish|fish"
  ask_choice REIMU_SUDO "Privilege tool" "$REIMU_SUDO" "sudo|sudo" "doas|doas (opendoas, with a sudo alias)"
  ask_yesno "Set a root password too? (No locks the root account; use $REIMU_SUDO)" "$( [[ "$REIMU_ROOT_LOGIN" == yes ]] && echo y || echo n )" \
    && REIMU_ROOT_LOGIN=yes || REIMU_ROOT_LOGIN=no
  return 0
}

wiz_network() {
  step "Network and services"
  ask_choice REIMU_NETWORK "Network manager" "$REIMU_NETWORK" \
    "networkmanager|NetworkManager · Wi-Fi, VPNs, desktop applets (recommended)" \
    "iwd|iwd + systemd-networkd · light, Wi-Fi from the terminal" \
    "systemd-networkd|systemd-networkd · wired only, servers"
  ask_choice REIMU_BLUETOOTH "Bluetooth" "$REIMU_BLUETOOTH" "auto|Enable if a desktop is installed" "yes|Enable" "no|Skip"
  ask_yesno "Printing (CUPS)?" "$( [[ "$REIMU_PRINTING" == yes ]] && echo y || echo n )" && REIMU_PRINTING=yes || REIMU_PRINTING=no
  ask_choice REIMU_FIREWALL "Firewall" "$REIMU_FIREWALL" "no|None" "firewalld|firewalld (GNOME/KDE integration)" "ufw|ufw (simple)"
  ask_yesno "OpenSSH server enabled?" "$( [[ "$REIMU_SSH" == yes ]] && echo y || echo n )" && REIMU_SSH=yes || REIMU_SSH=no
  ask_yesno "Enable the multilib repository (32-bit libs: Steam, Wine)?" "$( [[ "$REIMU_MULTILIB" == yes ]] && echo y || echo n )" && REIMU_MULTILIB=yes || REIMU_MULTILIB=no
  return 0
}

wiz_desktop() {
  step "Desktop"
  ask_choice REIMU_DESKTOP "Desktop environment or window manager" "$REIMU_DESKTOP" \
    "none|None · terminal only (server, or build your own)" \
    "gnome|GNOME" "plasma|KDE Plasma" "xfce|XFCE" "cinnamon|Cinnamon" "mate|MATE" "budgie|Budgie" "lxqt|LXQt" \
    "hyprland|Hyprland (Wayland)" "sway|Sway (Wayland)" "niri|niri (Wayland)" "i3|i3 (X11)"
  if [[ "$REIMU_DESKTOP" == none ]]; then
    REIMU_DISPLAY_MANAGER=none; REIMU_XFCE_WIN2K=no
  else
    ask_choice REIMU_DISPLAY_MANAGER "Login manager" "$REIMU_DISPLAY_MANAGER" \
      "auto|The one that fits the desktop (gdm / sddm / lightdm)" "gdm|GDM" "sddm|SDDM" "lightdm|LightDM" "ly|ly (terminal)" "none|None, start from a TTY"
    if [[ "$REIMU_DESKTOP" == xfce ]]; then
      ask_yesno "Fetch the Win2k Undead theme (Windows 2000 look for XFCE)?" "$( [[ "$REIMU_XFCE_WIN2K" == yes ]] && echo y || echo n )" \
        && REIMU_XFCE_WIN2K=yes || REIMU_XFCE_WIN2K=no
    fi
  fi
  ask_choice REIMU_GPU "Graphics driver" "$REIMU_GPU" \
    "auto|Detect (found: $DETECT_GPU)" "intel|Intel" "amd|AMD" "nvidia|NVIDIA (open kernel modules, Turing+)" \
    "nvidia-proprietary|NVIDIA proprietary (older cards)" "nouveau|NVIDIA with nouveau (open source)" "vm|Virtual machine guest tools" "none|None"
  return 0
}

wiz_software() {
  step "Software"
  ask_choice REIMU_AUR "AUR helper" "$REIMU_AUR" "paru|paru" "yay|yay" "none|None"
  local -a cats=()
  local f name desc
  for f in "$REIMU_DIR"/catalog/*.list; do
    [[ -r "$f" ]] || continue
    name="$(basename "$f" .list)"
    desc="$(sed -n '1s/^# *//p' "$f")"
    cats+=("$name|$name · $desc")
  done
  if (( ${#cats[@]} )); then
    ask_multi REIMU_CATALOG "Software bundles" "$REIMU_CATALOG" "${cats[@]}"
  fi
  ask_text REIMU_EXTRA_PACKAGES "Extra packages, space separated (or '-')" "${REIMU_EXTRA_PACKAGES:--}"
  [[ "$REIMU_EXTRA_PACKAGES" == "-" ]] && REIMU_EXTRA_PACKAGES=""
  ask_text REIMU_SERVICES "Extra systemd units to enable (or '-')" "${REIMU_SERVICES:--}"
  [[ "$REIMU_SERVICES" == "-" ]] && REIMU_SERVICES=""
  return 0
}

# ---- main menu -------------------------------------------------------------

wiz_summary_disk() {
  if [[ "$REIMU_DISK_MODE" == auto ]]; then
    printf '%s wipe · %s' "${REIMU_DISK:-?}" "${REIMU_FS:-?}"
  else
    printf 'manual · root %s · %s' "${REIMU_PART_ROOT:-?}" "${REIMU_FS:-?}"
  fi
  [[ "$REIMU_ENCRYPT" == yes ]] && printf ' · LUKS'
  [[ "$REIMU_SNAPSHOTS" == yes ]] && printf ' · snapshots'
  printf ' · swap %s' "${REIMU_SWAP:-?}"
}

wizard() {
  export REIMU_INTERACTIVE=1
  local choice
  if [[ -z "$REIMU_USER" ]]; then
    msg "First time here. Let's go through every section; you can revisit any of them from the menu."
    wiz_locale; wiz_disk; wiz_boot; wiz_user; wiz_network; wiz_desktop; wiz_software
  fi
  while true; do
    ask_menu choice "Reimu · what will be installed" \
      "locale|Language, keyboard, time|$REIMU_KEYMAP · $REIMU_LOCALE · $REIMU_TIMEZONE · $REIMU_HOSTNAME" \
      "disk|Disk|$(wiz_summary_disk)" \
      "boot|Boot|$REIMU_BOOTLOADER · $REIMU_KERNELS" \
      "user|Users|$REIMU_USER ($REIMU_USER_SHELL, $REIMU_SUDO)$( [[ "$REIMU_ROOT_LOGIN" == yes ]] && printf ' · root enabled' )" \
      "network|Network and services|$REIMU_NETWORK$( [[ "$REIMU_PRINTING" == yes ]] && printf ' · cups' )$( [[ "$REIMU_FIREWALL" != no ]] && printf ' · %s' "$REIMU_FIREWALL" )$( [[ "$REIMU_SSH" == yes ]] && printf ' · ssh' )$( [[ "$REIMU_MULTILIB" == yes ]] && printf ' · multilib' )" \
      "desktop|Desktop|$REIMU_DESKTOP · gpu $REIMU_GPU$( [[ "$REIMU_XFCE_WIN2K" == yes ]] && printf ' · win2k' )" \
      "software|Software|aur $REIMU_AUR · ${REIMU_CATALOG:-no bundles}${REIMU_EXTRA_PACKAGES:+ · +$REIMU_EXTRA_PACKAGES}" \
      "save|Save configuration to a file|" \
      "install|Start the installation|" \
      "quit|Quit|"
    case "$choice" in
      locale) wiz_locale ;; disk) wiz_disk ;; boot) wiz_boot ;; user) wiz_user ;;
      network) wiz_network ;; desktop) wiz_desktop ;; software) wiz_software ;;
      save)
        local f; ask_text f "File" "${REIMU_SAVE_PATH:-./reimu.conf}"
        config_save "$f" ;;
      install)
        if config_validate; then return 0; fi
        warn "Fix the problems above before installing." ;;
      quit) exit 0 ;;
    esac
  done
}
