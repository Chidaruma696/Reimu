# shellcheck shell=bash
# Reimu · wizard: the interactive part.
#
# Every setting is one small question function (q_*). The guided first run
# asks them in order; the main menu lists every setting with its current value
# so a single one can be changed without redoing a whole section.

# ---- language, keyboard, time ---------------------------------------------

q_keymap()   { ui_help "$(help_locale)"; ask_filter REIMU_KEYMAP "Console keyboard layout" "$REIMU_KEYMAP" list_keymaps; }
q_locale()   { ask_filter REIMU_LOCALE "System language (locale)" "$REIMU_LOCALE" list_locales; }
q_extra_locales() {
  ask_multi REIMU_EXTRA_LOCALES "Extra languages to generate" "$REIMU_EXTRA_LOCALES" \
    "en_US.UTF-8|English (US)" "es_MX.UTF-8|Español (México)" "es_ES.UTF-8|Español (España)" \
    "es_AR.UTF-8|Español (Argentina)" "es_CO.UTF-8|Español (Colombia)" "es_CL.UTF-8|Español (Chile)" \
    "pt_BR.UTF-8|Português (Brasil)" "ja_JP.UTF-8|日本語" "ko_KR.UTF-8|한국어" "zh_CN.UTF-8|中文 (简体)" \
    "de_DE.UTF-8|Deutsch" "fr_FR.UTF-8|Français" "it_IT.UTF-8|Italiano" "ru_RU.UTF-8|Русский"
}
q_timezone() { ui_help "$(help_timezone)"; ask_filter REIMU_TIMEZONE "Time zone" "$REIMU_TIMEZONE" list_timezones; }
q_hostname() { ui_help "$(help_hostname)"; ask_text REIMU_HOSTNAME "Host name" "$REIMU_HOSTNAME"; }
q_mirrors() {
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

# ---- disk ------------------------------------------------------------------

q_disk() {
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
    q_partitions
  fi
  return 0
}

q_partitions() {
  [[ "$REIMU_DISK_MODE" == manual ]] || { ui_note "Automatic mode: partitions are created for you."; return 0; }
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

q_fs() {
  ui_help "$(help_fs)"
  ask_choice REIMU_FS "Root filesystem" "${REIMU_FS:-btrfs}" \
    "btrfs|btrfs|Snapshots and compression · best for desktops and laptops" \
    "ext4|ext4|The classic · simple and proven · no snapshots" \
    "xfs|xfs|Fast with huge files · cannot shrink"
  [[ "$REIMU_FS" == btrfs ]] || REIMU_SNAPSHOTS=no
  return 0
}

q_snapshots() {
  [[ "$REIMU_FS" == btrfs ]] || { ui_note "Snapshots need btrfs."; REIMU_SNAPSHOTS=no; return 0; }
  ui_help "$(help_snapshots)"
  ask_yesno "Enable snapshots (snapper + snap-pac)?" "$( [[ "$REIMU_SNAPSHOTS" == yes ]] && echo y || echo n )" \
    && REIMU_SNAPSHOTS=yes || REIMU_SNAPSHOTS=no
  return 0
}

q_encrypt() {
  ui_help "$(help_encrypt)"
  ask_yesno "Encrypt the disk with LUKS2?" "$( [[ "$REIMU_ENCRYPT" == yes ]] && echo y || echo n )" \
    && REIMU_ENCRYPT=yes || REIMU_ENCRYPT=no
  return 0
}

q_swap() {
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

# ---- boot ------------------------------------------------------------------

q_bootloader() {
  ui_help "$(help_bootloader)"
  local -a items=()
  local def="${REIMU_BOOTLOADER:-systemd-boot}"
  if [[ "$DETECT_FIRMWARE" == uefi ]]; then
    items+=("systemd-boot|systemd-boot|Simple and fast · UEFI only · recommended")
  else
    [[ "$def" == systemd-boot ]] && def=grub
  fi
  items+=("grub|GRUB|Full menu · other systems · boots into snapshots" "limine|Limine|Modern and small · UEFI and BIOS")
  ask_choice REIMU_BOOTLOADER "Bootloader" "$def" "${items[@]}"
}

q_kernels() {
  ui_help "$(help_kernels)"
  ask_multi REIMU_KERNELS "Kernels" "$REIMU_KERNELS" \
    "linux|linux|The normal one · recommended" "linux-lts|linux-lts|Long term support · safe fallback" \
    "linux-zen|linux-zen|Tuned for desktops" "linux-hardened|linux-hardened|Security over speed"
  [[ -z "$REIMU_KERNELS" ]] && REIMU_KERNELS=linux
  return 0
}

# ---- users -----------------------------------------------------------------

q_user()  { ui_help "$(help_user)"; ask_text REIMU_USER "User name" "$REIMU_USER" "lowercase, no spaces"; }
q_shell() {
  ui_help "$(help_shell)"
  ask_choice REIMU_USER_SHELL "Shell" "$REIMU_USER_SHELL" "bash|bash|The default everywhere" "zsh|zsh|Smarter completion · what macOS uses" "fish|fish|Friendliest · colors and suggestions"
}
q_sudo() {
  ui_help "$(help_sudo)"
  ask_choice REIMU_SUDO "Administrator tool" "$REIMU_SUDO" "sudo|sudo|The standard · every guide uses it" "doas|doas|Tiny · with a sudo alias"
}
q_root() {
  ui_help "$(help_root)"
  ask_yesno "Give root its own password? (No locks the root account)" "$( [[ "$REIMU_ROOT_LOGIN" == yes ]] && echo y || echo n )" \
    && REIMU_ROOT_LOGIN=yes || REIMU_ROOT_LOGIN=no
  return 0
}

# ---- network and services --------------------------------------------------

q_network() {
  ui_help "$(help_network)"
  ask_choice REIMU_NETWORK "Network manager" "$REIMU_NETWORK" \
    "networkmanager|NetworkManager|Wi-Fi · VPN · desktop icon · recommended" \
    "iwd|iwd|Light Wi-Fi from the terminal" \
    "systemd-networkd|systemd-networkd|Wired only · servers"
}

q_extras() {
  ui_help "$(help_extras)"
  local pre=""
  [[ "$REIMU_BLUETOOTH" != no ]] && pre+=" bluetooth"
  [[ "$REIMU_PRINTING" == yes ]] && pre+=" printing"
  [[ "$REIMU_FIREWALL" != no ]] && pre+=" firewall"
  [[ "$REIMU_SSH" == yes ]] && pre+=" ssh"
  local extras
  ask_multi extras "Services" "$pre" \
    "bluetooth|Bluetooth|Headphones · mice · controllers" \
    "printing|Printing|CUPS with PDF printing" \
    "firewall|Firewall|Block incoming connections" \
    "ssh|SSH server|Log in from another machine"
  has_word "$extras" bluetooth && REIMU_BLUETOOTH=yes || REIMU_BLUETOOTH=no
  has_word "$extras" printing && REIMU_PRINTING=yes || REIMU_PRINTING=no
  has_word "$extras" ssh && REIMU_SSH=yes || REIMU_SSH=no
  if has_word "$extras" firewall; then
    [[ "$REIMU_FIREWALL" == no ]] && REIMU_FIREWALL=firewalld
    ask_choice REIMU_FIREWALL "Firewall" "$REIMU_FIREWALL" "firewalld|firewalld|Integrates with GNOME and KDE" "ufw|ufw|Simple · one command"
  else
    REIMU_FIREWALL=no
  fi
  return 0
}

q_power() {
  (( DETECT_LAPTOP )) || { ui_note "No battery detected: power management is for laptops."; return 0; }
  ui_help "$(help_power)"
  ask_choice REIMU_POWER "Laptop power management" "$REIMU_POWER" \
    "ppd|power-profiles-daemon|Power modes in GNOME and KDE · recommended" \
    "tlp|TLP|More battery · no desktop integration" "none|None|"
}

# ---- repositories ----------------------------------------------------------

q_repos() {
  ui_help "$(help_repos)"
  ask_multi REIMU_REPOS "Extra repositories" "$REIMU_REPOS" \
    "multilib|multilib|32-bit libraries · Steam and Wine · official" \
    "chaotic-aur|Chaotic-AUR|Thousands of AUR programs prebuilt · nothing to compile"
  config_normalize
  return 0
}

q_custom_repos() {
  ui_help "$(help_custom_repos)"
  ask_optional REIMU_CUSTOM_REPOS "Custom repositories: name=URL, space separated" "$REIMU_CUSTOM_REPOS" "Enter to skip · e.g. myrepo=https://example.org/\$arch"
}

# ---- desktop ---------------------------------------------------------------

q_desktop() {
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
    REIMU_DISPLAY_MANAGER=none
  else
    ui_box "What $REIMU_DESKTOP installs" "$(desktop_packages "$REIMU_DESKTOP" | tr ' ' '\n' | paste -sd ' ')
plus, with every desktop: ${DESKTOP_COMMON[*]}" 240
  fi
  return 0
}

q_dm() {
  [[ "$REIMU_DESKTOP" == none ]] && { REIMU_DISPLAY_MANAGER=none; ui_note "No desktop, no login manager."; return 0; }
  ui_help "$(help_dm)"
  ask_choice REIMU_DISPLAY_MANAGER "Login manager" "$REIMU_DISPLAY_MANAGER" \
    "auto|Auto|The one that fits the desktop · recommended" "gdm|GDM|GNOME's" "sddm|SDDM|KDE's" \
    "lightdm|LightDM|Light and classic" "ly|ly|Text mode" "none|None|Start from a TTY"
}

q_theme() {
  [[ "$REIMU_DESKTOP" == xfce ]] || { ui_note "Themes are applied automatically for XFCE only (for now)."; return 0; }
  ui_help "$(help_theme)"
  ask_choice REIMU_THEME "Theme" "$REIMU_THEME" \
    "greybird|Greybird|XFCE's classic · light or dark · AUR" \
    "arc|Arc|Flat with transparency · the popular one · AUR" \
    "materia|Materia|Material Design · official repo" \
    "orchis|Orchis|Rounded and modern · official repo" \
    "flat-remix|Flat Remix|Flat and colorful · AUR" \
    "skeuos|Skeuos|Kali Linux look · AUR" \
    "dracula|Dracula|Dark purple · AUR" \
    "nordic|Nordic|Nord palette · AUR" \
    "catppuccin|Catppuccin Mocha|Pastel dark · AUR" \
    "default|Default|Adwaita · nothing extra"
  ask_choice REIMU_THEME_VARIANT "Variant" "$REIMU_THEME_VARIANT" "dark|Dark|" "light|Light|"
  ask_choice REIMU_ICONS "Icons" "$REIMU_ICONS" \
    "papirus|Papirus|The most popular · official repo" \
    "tela|Tela|Rounded and colorful · AUR" \
    "flat-remix|Flat Remix|Matches the Flat Remix theme · AUR" \
    "elementary|elementary|Clean · official repo" \
    "breeze|Breeze|KDE's · official repo" \
    "arc|Arc|Matches the Arc theme · AUR" \
    "default|Default|Adwaita"
  if [[ "$REIMU_AUR" == none ]]; then
    local t="${THEMES[$REIMU_THEME]:-}" i="${ICONS[$REIMU_ICONS]:-}"
    if [[ "$(theme_field "$t" 2)" == aur || "$(theme_field "$i" 2)" == aur ]]; then
      warn "That theme comes from the AUR: pick an AUR helper in Software, or it will be skipped."
    fi
  fi
  return 0
}

q_gpu() {
  ui_help "$(help_gpu)"
  ask_choice REIMU_GPU "Graphics driver" "$REIMU_GPU" \
    "auto|Detect|Found: $DETECT_GPU · recommended" "intel|Intel|" "amd|AMD|" \
    "nvidia|NVIDIA open modules|GTX 16xx · RTX · 2018 onwards" \
    "nvidia-proprietary|NVIDIA proprietary|Older cards" "nouveau|nouveau|Free NVIDIA driver · slow" \
    "vm|Virtual machine|Guest tools" "none|None|"
}

# ---- software --------------------------------------------------------------

q_aur() {
  ui_help "$(help_aur)"
  ask_choice REIMU_AUR "AUR helper" "$REIMU_AUR" "paru|paru|Modern · recommended" "yay|yay|The classic" "none|None|"
}

q_bundles() {
  local -a cats=()
  local f name desc contents=""
  for f in "$REIMU_DIR"/catalog/*.list; do
    [[ -r "$f" ]] || continue
    name="$(basename "$f" .list)"
    desc="$(sed -n '1s/^# *//p' "$f")"
    cats+=("$name|$name|${desc#*: }")
    contents+="$(printf '%s: %s' "$name" "$(sw_bundle_contents "$name")")"$'\n'
  done
  (( ${#cats[@]} )) || return 0
  ui_help "$(help_bundles)"
  ui_box "What each bundle installs" "${contents%$'\n'}" 240
  ask_multi REIMU_CATALOG "Software bundles" "$REIMU_CATALOG" "${cats[@]}"
}

q_extra_packages() { ask_optional REIMU_EXTRA_PACKAGES "Extra packages, space separated" "$REIMU_EXTRA_PACKAGES" "Enter to skip · e.g. neovim htop"; }
q_services()       { ask_optional REIMU_SERVICES "Extra systemd units to enable" "$REIMU_SERVICES" "Enter to skip · e.g. docker.service"; }

# ---- sections and menu -----------------------------------------------------

wiz_guided() {
  step "Language, keyboard and time"; q_keymap; q_locale; q_extra_locales; q_timezone; q_hostname; q_mirrors
  step "Disk"; q_disk; q_fs; q_snapshots; q_encrypt; q_swap
  step "Boot"; q_bootloader; q_kernels
  step "Users"; q_user; q_shell; q_sudo; q_root
  step "Network and services"; q_network; q_extras; q_power
  step "Repositories"; q_repos; q_custom_repos
  step "Desktop"; q_desktop; q_dm; q_theme; q_gpu
  step "Software"; q_aur; q_bundles; q_extra_packages; q_services
}

wiz_disk_value() {
  if [[ "$REIMU_DISK_MODE" == auto ]]; then printf 'auto · %s' "${REIMU_DISK:-?}"
  else printf 'manual · root %s' "${REIMU_PART_ROOT:-?}"; fi
}

wizard() {
  export REIMU_INTERACTIVE=1
  local choice
  if [[ -z "$REIMU_USER" ]]; then
    ui_box "Welcome" "Reimu asks a few questions, explains each one, and then installs Arch Linux from start to finish: base system, desktop, drivers, the lot.
Made a mistake? Every answer can be changed one by one from the menu at the end.
Nothing is written to the disk until you see the summary and type YES." 196
    wiz_guided
  fi
  while true; do
    ask_menu choice "Everything Reimu will do · pick a line to change it" \
      "keymap|Keyboard layout|$REIMU_KEYMAP" \
      "locale|Language|$REIMU_LOCALE" \
      "extra_locales|Extra languages|${REIMU_EXTRA_LOCALES:-none}" \
      "timezone|Time zone|$REIMU_TIMEZONE" \
      "hostname|Host name|$REIMU_HOSTNAME" \
      "mirrors|Mirror countries|${REIMU_MIRROR_COUNTRIES:-worldwide}" \
      "disk|Disk|$(wiz_disk_value)" \
      "partitions|Partitions (manual mode)|$( [[ "$REIMU_DISK_MODE" == manual ]] && printf 'boot %s · root %s' "$REIMU_PART_BOOT" "$REIMU_PART_ROOT" || printf 'automatic' )" \
      "fs|Filesystem|$REIMU_FS" \
      "snapshots|Snapshots|$REIMU_SNAPSHOTS" \
      "encrypt|Encryption|$REIMU_ENCRYPT" \
      "swap|Swap|$REIMU_SWAP${REIMU_SWAP_SIZE:+ $REIMU_SWAP_SIZE}" \
      "bootloader|Bootloader|$REIMU_BOOTLOADER" \
      "kernels|Kernels|$REIMU_KERNELS" \
      "user|User name|$REIMU_USER" \
      "shell|Shell|$REIMU_USER_SHELL" \
      "sudo|Administrator tool|$REIMU_SUDO" \
      "root|Root account|$( [[ "$REIMU_ROOT_LOGIN" == yes ]] && echo 'own password' || echo locked )" \
      "network|Network manager|$REIMU_NETWORK" \
      "extras|Services|$( [[ "$REIMU_BLUETOOTH" != no ]] && printf 'bluetooth ' )$( [[ "$REIMU_PRINTING" == yes ]] && printf 'printing ' )$( [[ "$REIMU_FIREWALL" != no ]] && printf '%s ' "$REIMU_FIREWALL" )$( [[ "$REIMU_SSH" == yes ]] && printf 'ssh' )" \
      "power|Laptop power|$( (( DETECT_LAPTOP )) && printf '%s' "$REIMU_POWER" || printf 'not a laptop' )" \
      "repos|Extra repositories|${REIMU_REPOS:-none}" \
      "custom_repos|Custom repositories|${REIMU_CUSTOM_REPOS:-none}" \
      "desktop|Desktop|$REIMU_DESKTOP" \
      "dm|Login manager|$REIMU_DISPLAY_MANAGER" \
      "theme|Theme and icons|$( [[ "$REIMU_DESKTOP" == xfce ]] && printf '%s %s · %s' "$REIMU_THEME" "$REIMU_THEME_VARIANT" "$REIMU_ICONS" || printf 'xfce only' )" \
      "gpu|Graphics driver|$REIMU_GPU" \
      "aur|AUR helper|$REIMU_AUR" \
      "bundles|Software bundles|${REIMU_CATALOG:-none}" \
      "extra_packages|Extra packages|${REIMU_EXTRA_PACKAGES:-none}" \
      "services|Extra services|${REIMU_SERVICES:-none}" \
      "save|💾 Save configuration to a file|" \
      "install|🚀 Start the installation|" \
      "quit|✖ Quit|"
    case "$choice" in
      save)
        local f; ask_text f "File" "${REIMU_SAVE_PATH:-./reimu.conf}"
        config_save "$f" ;;
      install)
        config_normalize
        if config_validate; then return 0; fi
        warn "Fix the problems above before installing." ;;
      quit) exit 0 ;;
      *) "q_$choice" ;;
    esac
  done
}
