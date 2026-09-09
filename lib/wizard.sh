# shellcheck shell=bash
# Reimu · wizard: the interactive part. Every question comes with a short
# explanation, lists instead of typing wherever a list exists, and a main
# menu that shows what will be installed.

# ---- sections --------------------------------------------------------------

wiz_locale() {
  step "Language, keyboard and time"
  ui_help "$(help_locale)"
  ask_filter REIMU_KEYMAP "Console keyboard layout" "$REIMU_KEYMAP" list_keymaps
  ask_filter REIMU_LOCALE "System language (locale)" "$REIMU_LOCALE" list_locales
  ask_multi REIMU_EXTRA_LOCALES "Extra locales to generate" "$REIMU_EXTRA_LOCALES" \
    "en_US.UTF-8|English (US)" "es_MX.UTF-8|Español (México)" "es_ES.UTF-8|Español (España)" \
    "es_AR.UTF-8|Español (Argentina)" "es_CO.UTF-8|Español (Colombia)" "es_CL.UTF-8|Español (Chile)" \
    "pt_BR.UTF-8|Português (Brasil)" "ja_JP.UTF-8|日本語" "ko_KR.UTF-8|한국어" "zh_CN.UTF-8|中文 (简体)" \
    "de_DE.UTF-8|Deutsch" "fr_FR.UTF-8|Français" "it_IT.UTF-8|Italiano" "ru_RU.UTF-8|Русский"
  ui_help "$(help_timezone)"
  ask_filter REIMU_TIMEZONE "Time zone" "$REIMU_TIMEZONE" list_timezones
  ui_help "$(help_hostname)"
  ask_text REIMU_HOSTNAME "Host name" "$REIMU_HOSTNAME"
  ui_help "$(help_mirrors)"
  local -a countries=()
  local c
  while IFS= read -r c; do [[ -n "$c" ]] && countries+=("$c"); done < <(list_countries)
  if (( ${#countries[@]} )); then
    ask_multi REIMU_MIRROR_COUNTRIES "Mirror countries (none = worldwide)" "${REIMU_MIRROR_COUNTRIES//,/ }" "${countries[@]}"
    REIMU_MIRROR_COUNTRIES="${REIMU_MIRROR_COUNTRIES// /,}"
  else
    ask_optional REIMU_MIRROR_COUNTRIES "Mirror country codes, comma separated (Enter = worldwide)" "$REIMU_MIRROR_COUNTRIES" "MX,US"
  fi
  return 0
}

wiz_disk() {
  step "Disk"
  ui_help "$(help_disk_mode)"
  ask_choice REIMU_DISK_MODE "How do you want to partition?" "$REIMU_DISK_MODE" \
    "auto|Automatic|Erase one whole disk and lay it out for me" \
    "manual|Manual|I create the partitions with cfdisk and point Reimu at them"

  local -a items=()
  local d name rest size model tag
  while IFS= read -r d; do
    [[ -z "$d" ]] && continue
    name="${d%%|*}"; rest="${d#*|}"; size="${rest%%|*}"; model="${rest#*|}"
    tag=""; is_live_media "$name" && tag=" (live media · do not use)"
    items+=("$name|$name|$size  $model$tag")
  done < <(list_disks)
  (( ${#items[@]} )) || die "No disks found."
  ui_help "$(help_disk)"
  ask_choice REIMU_DISK "Target disk" "$REIMU_DISK" "${items[@]}"
  is_live_media "$REIMU_DISK" && die "That disk is the live media you booted from."

  if [[ "$REIMU_DISK_MODE" == manual ]]; then
    if ask_yesno "Open cfdisk on $REIMU_DISK now to create the partitions?" y; then
      run_tty cfdisk "$REIMU_DISK"
    fi
    wiz_manual_partitions
  fi

  ui_help "$(help_fs)"
  ask_choice REIMU_FS "Root filesystem" "${REIMU_FS:-btrfs}" \
    "btrfs|btrfs|Snapshots and compression · best for desktops and laptops" \
    "ext4|ext4|The classic · simple and proven · no snapshots" \
    "xfs|xfs|Fast with huge files · cannot shrink"

  if [[ "$REIMU_FS" == btrfs ]]; then
    ui_help "$(help_snapshots)"
    ask_yesno "Enable snapshots (snapper + snap-pac)?" "$( [[ "$REIMU_SNAPSHOTS" == yes ]] && echo y || echo n )" \
      && REIMU_SNAPSHOTS=yes || REIMU_SNAPSHOTS=no
  else
    REIMU_SNAPSHOTS=no
  fi

  ui_help "$(help_encrypt)"
  ask_yesno "Encrypt the disk with LUKS2?" "$( [[ "$REIMU_ENCRYPT" == yes ]] && echo y || echo n )" \
    && REIMU_ENCRYPT=yes || REIMU_ENCRYPT=no

  ui_help "$(help_swap)"
  local -a swap_items=("zram|zram|Compressed swap in RAM · no disk space · recommended")
  [[ "$REIMU_DISK_MODE" == auto || -n "$REIMU_PART_SWAP" ]] && swap_items+=("partition|Swap partition|On disk · needed for hibernation")
  swap_items+=("file|Swap file|On disk · easy to resize" "none|No swap|Only with plenty of RAM")
  ask_choice REIMU_SWAP "Swap" "${REIMU_SWAP:-zram}" "${swap_items[@]}"
  local gib; gib="$(help_ram_gib)"
  case "$REIMU_SWAP" in
    zram)
      ask_choice REIMU_SWAP_SIZE "zram size" "${REIMU_SWAP_SIZE:-$(suggest_zram_mib)}" \
        "$(suggest_zram_mib)|$(suggest_zram_mib) MiB|Half of your RAM · recommended" \
        "2048|2 GiB|" "4096|4 GiB|" "8192|8 GiB|" "custom|Custom|Type a size in MiB"
      [[ "$REIMU_SWAP_SIZE" == custom ]] && ask_text REIMU_SWAP_SIZE "zram size in MiB" "$(suggest_zram_mib)" ;;
    partition|file)
      ask_choice REIMU_SWAP_SIZE "Swap size" "${REIMU_SWAP_SIZE:-$(suggest_swap_gib)}" \
        "$(suggest_swap_gib)|$(suggest_swap_gib) GiB|Recommended for your ${gib} GiB of RAM" \
        "$(( gib + 2 ))|$(( gib + 2 )) GiB|RAM plus 2 · safe for hibernation" \
        "4|4 GiB|" "8|8 GiB|" "16|16 GiB|" "custom|Custom|Type a size in GiB"
      [[ "$REIMU_SWAP_SIZE" == custom ]] && ask_text REIMU_SWAP_SIZE "Swap size in GiB" "$(suggest_swap_gib)" ;;
    none) REIMU_SWAP_SIZE="" ;;
  esac
  return 0
}

wiz_manual_partitions() {
  local -a parts=()
  local p name rest
  while IFS= read -r p; do
    [[ -z "$p" ]] && continue
    name="${p%%|*}"; rest="${p#*|}"
    parts+=("$name|$name|${rest%%|*}  ${rest#*|}")
  done < <(list_partitions "$REIMU_DISK")
  (( ${#parts[@]} )) || die "No partitions on $REIMU_DISK. Create them first."
  local label="EFI system partition (FAT32, 512 MiB or more)"
  [[ "$DETECT_FIRMWARE" == bios ]] && label="Boot partition (will be FAT32; BIOS on GPT also needs a 1 MiB 'BIOS boot' partition)"
  ask_choice REIMU_PART_BOOT "$label" "$REIMU_PART_BOOT" "${parts[@]}"
  ask_choice REIMU_PART_ROOT "Root partition (will be formatted)" "$REIMU_PART_ROOT" "${parts[@]}"
  ask_choice REIMU_PART_HOME "Separate /home partition" "${REIMU_PART_HOME:-none}" "none|None|Home lives inside root" "${parts[@]}"
  [[ "$REIMU_PART_HOME" == none ]] && REIMU_PART_HOME=""
  if [[ -n "$REIMU_PART_HOME" ]]; then
    ask_yesno "Format $REIMU_PART_HOME? (No keeps the existing files)" n && REIMU_FORMAT_HOME=yes || REIMU_FORMAT_HOME=no
  fi
  ask_choice REIMU_PART_SWAP "Swap partition" "${REIMU_PART_SWAP:-none}" "none|None|" "${parts[@]}"
  [[ "$REIMU_PART_SWAP" == none ]] && REIMU_PART_SWAP=""
  return 0
}

wiz_boot() {
  step "Boot"
  ui_help "$(help_bootloader)"
  local -a items=()
  local def="${REIMU_BOOTLOADER:-systemd-boot}"
  if [[ "$DETECT_FIRMWARE" == uefi ]]; then
    items+=("systemd-boot|systemd-boot|Simple and fast · UEFI only · recommended" "grub|GRUB|Full menu · other systems · boots into snapshots")
  else
    items+=("grub|GRUB|The only option for BIOS boot"); def=grub
    ui_note "This machine booted in BIOS (legacy) mode."
  fi
  ask_choice REIMU_BOOTLOADER "Bootloader" "$def" "${items[@]}"
  ui_help "$(help_kernels)"
  ask_multi REIMU_KERNELS "Kernels" "$REIMU_KERNELS" \
    "linux|linux|The normal one · recommended" "linux-lts|linux-lts|Long term support · safe fallback" \
    "linux-zen|linux-zen|Tuned for desktops" "linux-hardened|linux-hardened|Security over speed"
  [[ -z "$REIMU_KERNELS" ]] && REIMU_KERNELS=linux
  return 0
}

wiz_user() {
  step "Users"
  ui_help "$(help_user)"
  ask_text REIMU_USER "User name" "$REIMU_USER" "lowercase, no spaces"
  ui_help "$(help_shell)"
  ask_choice REIMU_USER_SHELL "Shell" "$REIMU_USER_SHELL" "bash|bash|The default everywhere" "zsh|zsh|Smarter completion · what macOS uses" "fish|fish|Friendliest · colors and suggestions"
  ui_help "$(help_sudo)"
  ask_choice REIMU_SUDO "Administrator tool" "$REIMU_SUDO" "sudo|sudo|The standard · every guide uses it" "doas|doas|Tiny · with a sudo alias"
  ui_help "$(help_root)"
  ask_yesno "Give root its own password? (No locks the root account)" "$( [[ "$REIMU_ROOT_LOGIN" == yes ]] && echo y || echo n )" \
    && REIMU_ROOT_LOGIN=yes || REIMU_ROOT_LOGIN=no
  return 0
}

wiz_network() {
  step "Network and services"
  ui_help "$(help_network)"
  ask_choice REIMU_NETWORK "Network manager" "$REIMU_NETWORK" \
    "networkmanager|NetworkManager|Wi-Fi · VPN · desktop icon · recommended" \
    "iwd|iwd|Light Wi-Fi from the terminal" \
    "systemd-networkd|systemd-networkd|Wired only · servers"
  ui_help "$(help_extras)"
  local pre=""
  [[ "$REIMU_BLUETOOTH" != no ]] && pre+=" bluetooth"
  [[ "$REIMU_PRINTING" == yes ]] && pre+=" printing"
  [[ "$REIMU_FIREWALL" != no ]] && pre+=" firewall"
  [[ "$REIMU_SSH" == yes ]] && pre+=" ssh"
  [[ "$REIMU_MULTILIB" == yes ]] && pre+=" multilib"
  local extras
  ask_multi extras "Extras" "$pre" \
    "bluetooth|Bluetooth|Headphones · mice · controllers" \
    "printing|Printing|CUPS with PDF printing" \
    "firewall|Firewall|Block incoming connections" \
    "ssh|SSH server|Log in from another machine" \
    "multilib|multilib|32-bit libraries for Steam and Wine"
  has_word "$extras" bluetooth && REIMU_BLUETOOTH=yes || REIMU_BLUETOOTH=no
  has_word "$extras" printing && REIMU_PRINTING=yes || REIMU_PRINTING=no
  has_word "$extras" ssh && REIMU_SSH=yes || REIMU_SSH=no
  has_word "$extras" multilib && REIMU_MULTILIB=yes || REIMU_MULTILIB=no
  if has_word "$extras" firewall; then
    [[ "$REIMU_FIREWALL" == no ]] && REIMU_FIREWALL=firewalld
    ask_choice REIMU_FIREWALL "Firewall" "$REIMU_FIREWALL" "firewalld|firewalld|Integrates with GNOME and KDE" "ufw|ufw|Simple · one command"
  else
    REIMU_FIREWALL=no
  fi
  if (( DETECT_LAPTOP )); then
    ui_help "$(help_power)"
    ask_choice REIMU_POWER "Laptop power management" "$REIMU_POWER" \
      "ppd|power-profiles-daemon|Power modes in GNOME and KDE · recommended" \
      "tlp|TLP|More battery · no desktop integration" "none|None|"
  fi
  return 0
}

wiz_desktop() {
  step "Desktop"
  ui_help "$(help_desktop)"
  ask_choice REIMU_DESKTOP "Desktop environment" "$REIMU_DESKTOP" \
    "gnome|GNOME|Modern and simple · like macOS · touch friendly" \
    "plasma|KDE Plasma|Like Windows · customize everything" \
    "xfce|XFCE|Light and classic · old machines" \
    "cinnamon|Cinnamon|Windows-style · from Linux Mint" \
    "mate|MATE|The old GNOME 2 · traditional" \
    "budgie|Budgie|Simple and elegant" \
    "lxqt|LXQt|Very light · weak machines" \
    "cosmic|COSMIC|New desktop by System76 · in Rust" \
    "deepin|Deepin|Pretty · macOS-like" \
    "hyprland|Hyprland|Tiling Wayland · animations · you configure it" \
    "sway|Sway|Tiling Wayland · minimal" \
    "niri|niri|Scrolling tiling Wayland" \
    "i3|i3|Tiling X11 classic" \
    "none|None|Terminal only"
  if [[ "$REIMU_DESKTOP" == none ]]; then
    REIMU_DISPLAY_MANAGER=none; REIMU_XFCE_WIN2K=no
  else
    ui_help "$(help_dm)"
    ask_choice REIMU_DISPLAY_MANAGER "Login manager" "$REIMU_DISPLAY_MANAGER" \
      "auto|Auto|The one that fits the desktop · recommended" "gdm|GDM|GNOME's" "sddm|SDDM|KDE's" \
      "lightdm|LightDM|Light and classic" "ly|ly|Text mode" "none|None|Start from a TTY"
    if [[ "$REIMU_DESKTOP" == xfce ]]; then
      ask_yesno "Fetch the Win2k Undead theme (Windows 2000 look for XFCE)?" "$( [[ "$REIMU_XFCE_WIN2K" == yes ]] && echo y || echo n )" \
        && REIMU_XFCE_WIN2K=yes || REIMU_XFCE_WIN2K=no
    fi
  fi
  ui_help "$(help_gpu)"
  ask_choice REIMU_GPU "Graphics driver" "$REIMU_GPU" \
    "auto|Detect|Found: $DETECT_GPU · recommended" "intel|Intel|" "amd|AMD|" \
    "nvidia|NVIDIA open modules|GTX 16xx · RTX · 2018 onwards" \
    "nvidia-proprietary|NVIDIA proprietary|Older cards" "nouveau|nouveau|Free NVIDIA driver · slow" \
    "vm|Virtual machine|Guest tools" "none|None|"
  return 0
}

wiz_software() {
  step "Software"
  ui_help "$(help_aur)"
  ask_choice REIMU_AUR "AUR helper" "$REIMU_AUR" "paru|paru|Modern · recommended" "yay|yay|The classic" "none|None|"
  local -a cats=()
  local f name desc
  for f in "$REIMU_DIR"/catalog/*.list; do
    [[ -r "$f" ]] || continue
    name="$(basename "$f" .list)"
    desc="$(sed -n '1s/^# *//p' "$f")"
    cats+=("$name|$name|${desc#*: }")
  done
  if (( ${#cats[@]} )); then
    ui_help "$(help_bundles)"
    ask_multi REIMU_CATALOG "Software bundles" "$REIMU_CATALOG" "${cats[@]}"
  fi
  ask_optional REIMU_EXTRA_PACKAGES "Extra packages, space separated" "$REIMU_EXTRA_PACKAGES" "Enter to skip · e.g. neovim htop"
  ask_optional REIMU_SERVICES "Extra systemd units to enable" "$REIMU_SERVICES" "Enter to skip · e.g. docker.service"
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
    ui_box "Welcome" "Reimu will ask a few questions, explain each one, and then install Arch Linux from start to finish: base system, desktop, drivers, the lot.
Nothing is written to the disk until you see the summary and type YES." 196
    wiz_locale; wiz_disk; wiz_boot; wiz_user; wiz_network; wiz_desktop; wiz_software
  fi
  while true; do
    ask_menu choice "What will be installed · pick a section to change it" \
      "locale|Language, keyboard, time|$REIMU_KEYMAP · $REIMU_LOCALE · $REIMU_TIMEZONE · $REIMU_HOSTNAME" \
      "disk|Disk|$(wiz_summary_disk)" \
      "boot|Boot|$REIMU_BOOTLOADER · $REIMU_KERNELS" \
      "user|Users|$REIMU_USER ($REIMU_USER_SHELL, $REIMU_SUDO)$( [[ "$REIMU_ROOT_LOGIN" == yes ]] && printf ' · root enabled' )" \
      "network|Network and services|$REIMU_NETWORK$( [[ "$REIMU_BLUETOOTH" != no ]] && printf ' · bt' )$( [[ "$REIMU_PRINTING" == yes ]] && printf ' · cups' )$( [[ "$REIMU_FIREWALL" != no ]] && printf ' · %s' "$REIMU_FIREWALL" )$( [[ "$REIMU_SSH" == yes ]] && printf ' · ssh' )$( [[ "$REIMU_MULTILIB" == yes ]] && printf ' · multilib' )" \
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
