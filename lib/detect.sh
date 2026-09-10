# shellcheck shell=bash
# Reimu · detect: hardware and environment facts. Every function degrades
# gracefully so the dry-run mode works on any machine.

DETECT_FIRMWARE="bios"; DETECT_CPU="unknown"; DETECT_GPU="none"; DETECT_VIRT="none"
DETECT_LAPTOP=0; DETECT_RAM_MIB=0; DETECT_TIMEZONE=""; DETECT_COUNTRY=""

detect_all() {
  [[ -d /sys/firmware/efi/efivars ]] && DETECT_FIRMWARE="uefi"
  # Dry runs on other machines can pretend: REIMU_FIRMWARE=uefi|bios
  if (( DRY_RUN )) && [[ -n "${REIMU_FIRMWARE:-}" ]]; then DETECT_FIRMWARE="$REIMU_FIRMWARE"; fi

  if [[ -r /proc/cpuinfo ]]; then
    case "$(grep -m1 vendor_id /proc/cpuinfo)" in
      *GenuineIntel*) DETECT_CPU="intel" ;;
      *AuthenticAMD*) DETECT_CPU="amd" ;;
    esac
  fi

  if has lspci; then
    local vga
    vga="$(lspci 2>/dev/null | grep -Ei 'vga|3d|display' || true)"
    if grep -qi nvidia <<< "$vga"; then DETECT_GPU="nvidia"
    elif grep -Eqi 'amd|ati|radeon' <<< "$vga"; then DETECT_GPU="amd"
    elif grep -qi intel <<< "$vga"; then DETECT_GPU="intel"
    elif grep -Eqi 'virtio|vmware|virtualbox|qxl|bochs' <<< "$vga"; then DETECT_GPU="vm"
    fi
  fi

  if has systemd-detect-virt; then
    DETECT_VIRT="$(systemd-detect-virt 2>/dev/null)" || DETECT_VIRT="none"
    [[ -z "$DETECT_VIRT" ]] && DETECT_VIRT="none"
    [[ "$DETECT_VIRT" != none ]] && DETECT_GPU="vm"
  fi

  if compgen -G '/sys/class/power_supply/BAT*' >/dev/null; then
    DETECT_LAPTOP=1
  fi

  if [[ -r /proc/meminfo ]]; then
    DETECT_RAM_MIB=$(( $(awk '/MemTotal/ {print $2}' /proc/meminfo) / 1024 ))
  fi
  return 0
}

# Timezone and country from the network, with a short timeout. Silent on failure.
detect_geo() {
  has curl || return 0
  local tz cc
  tz="$(curl -fsS --max-time 4 https://ipapi.co/timezone 2>/dev/null || true)"
  [[ "$tz" =~ ^[A-Za-z_]+/[A-Za-z_/+-]+$ ]] && DETECT_TIMEZONE="$tz"
  cc="$(curl -fsS --max-time 4 https://ipapi.co/country 2>/dev/null || true)"
  [[ "$cc" =~ ^[A-Z]{2}$ ]] && DETECT_COUNTRY="$cc"
  return 0
}

network_ok() {
  (( DRY_RUN )) && return 0
  has curl || return 1
  curl -fsS --max-time 6 -o /dev/null https://archlinux.org >/dev/null 2>&1
}

# Whole disks (no partitions, no loop, no ISO media): "name|size|model"
list_disks() {
  if ! has lsblk; then
    (( DRY_RUN )) && printf '%s\n' "/dev/sda|64 GiB|Dry-run disk" "/dev/nvme0n1|512 GiB|Dry-run NVMe"
    return 0
  fi
  lsblk -dlpno NAME,SIZE,TYPE,MODEL 2>/dev/null | awk '$3=="disk" { model=""; for(i=4;i<=NF;i++) model=model" "$i; sub(/^ /,"",model); printf "%s|%s|%s\n",$1,$2,model }'
}

# Partitions of a disk: "name|size|fstype"
list_partitions() {
  local disk="$1"
  if ! has lsblk; then
    (( DRY_RUN )) && printf '%s\n' "${disk}1|1G|vfat" "${disk}2|63G|"
    return 0
  fi
  lsblk -lpno NAME,SIZE,TYPE,FSTYPE "$disk" 2>/dev/null | awk '$3=="part" { printf "%s|%s|%s\n",$1,$2,$4 }'
}

# Is the given block device the one the live ISO booted from?
is_live_media() {
  local disk="$1"
  [[ -r /run/archiso/bootmnt ]] || return 1
  findmnt -no SOURCE /run/archiso/bootmnt 2>/dev/null | grep -q "^$disk" && return 0
  return 1
}

# Partition device name for disk + number (handles nvme/mmcblk "p" suffix).
part_name() {
  local disk="$1" n="$2"
  if [[ "$disk" =~ [0-9]$ ]]; then printf '%sp%s' "$disk" "$n"; else printf '%s%s' "$disk" "$n"; fi
}

# Suggested zram size in MiB: half of RAM, capped at 8 GiB.
suggest_zram_mib() {
  local half=$(( DETECT_RAM_MIB / 2 ))
  (( half < 512 )) && half=2048
  (( half > 8192 )) && half=8192
  printf '%s' "$half"
}

# Suggested swap partition/file size in GiB (RAM, capped at 16, min 2).
suggest_swap_gib() {
  local g=$(( DETECT_RAM_MIB / 1024 ))
  (( g < 2 )) && g=2
  (( g > 16 )) && g=16
  printf '%s' "$g"
}

# ---- lists for the pickers ---------------------------------------------------
list_keymaps() {
  if has localectl; then localectl list-keymaps 2>/dev/null && return 0; fi
  printf '%s\n' us la-latin1 es br-abnt2 de-latin1 fr it pt-latin1 uk dvorak
}

list_locales() {
  if [[ -r /usr/share/i18n/SUPPORTED ]]; then
    awk '$2=="UTF-8" {print $1}' /usr/share/i18n/SUPPORTED && return 0
  fi
  printf '%s\n' en_US.UTF-8 es_MX.UTF-8 es_ES.UTF-8 es_AR.UTF-8 es_CO.UTF-8 es_CL.UTF-8 pt_BR.UTF-8 de_DE.UTF-8 fr_FR.UTF-8 it_IT.UTF-8 ja_JP.UTF-8
}

list_timezones() {
  if has timedatectl; then timedatectl list-timezones 2>/dev/null && return 0; fi
  if [[ -d /usr/share/zoneinfo ]]; then
    (cd /usr/share/zoneinfo && find . -type f -path './[A-Z]*/*' | sed 's|^\./||' | grep -v '^posix\|^right\|^Etc' | sort) && return 0
  fi
  printf '%s\n' UTC America/Mexico_City America/Bogota America/Lima America/Santiago America/Argentina/Buenos_Aires America/Sao_Paulo Europe/Madrid America/New_York America/Los_Angeles
}

# "CODE|Country|mirrors" from reflector, for the mirror multi-select.
list_countries() {
  has reflector || return 0
  local cache="${TMPDIR:-/tmp}/reimu-countries"
  if [[ ! -s "$cache" ]]; then
    reflector --list-countries 2>/dev/null > "$cache.tmp" && mv -f "$cache.tmp" "$cache"
  fi
  [[ -s "$cache" ]] || return 0
  awk 'NR>2 && $NF ~ /^[0-9]+$/ { code=$(NF-1); n=$NF; name=""; for(i=1;i<=NF-2;i++) name=name" "$i; sub(/^ /,"",name); printf "%s|%s|%s mirrors\n", code, name, n }' "$cache"
}

