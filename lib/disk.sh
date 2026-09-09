# shellcheck shell=bash
# Reimu · disk: partitioning, encryption, filesystems, mounting.
#
# Automatic layout (GPT):
#   [BIOS only] 1 MiB   BIOS boot (ef02)
#   1 GiB               EFI system partition / boot, FAT32, mounted at /boot
#   [swap=partition]    swap, REIMU_SWAP_SIZE GiB
#   rest                root (btrfs subvolumes / ext4 / xfs), LUKS2 if requested
#
# Results are exported for the other modules:
#   PART_BOOT PART_ROOT PART_HOME PART_SWAP  (block devices)
#   ROOT_DEV                                 (what gets mounted: partition or /dev/mapper/cryptroot)
#   ROOT_UUID LUKS_UUID

PART_BOOT=""; PART_ROOT=""; PART_HOME=""; PART_SWAP=""; ROOT_DEV=""; ROOT_UUID=""; LUKS_UUID=""
LUKS_PASSWORD=""

BTRFS_OPTS="noatime,compress=zstd:3,space_cache=v2,discard=async"
BTRFS_SUBVOLS=("@:/" "@home:/home" "@log:/var/log" "@pkg:/var/cache/pacman/pkg" "@snapshots:/.snapshots")

disk_prepare() {
  if [[ "$REIMU_DISK_MODE" == auto ]]; then
    disk_auto_partition
  else
    PART_BOOT="$REIMU_PART_BOOT"; PART_ROOT="$REIMU_PART_ROOT"
    PART_HOME="$REIMU_PART_HOME"; PART_SWAP="$REIMU_PART_SWAP"
  fi
  disk_encrypt
  disk_format
  disk_create_subvolumes
  disk_mount_existing
  state_save
}

disk_auto_partition() {
  local disk="$REIMU_DISK" n=1
  step "Disk"
  msg "Wiping $disk and creating a new GPT layout"
  (( DRY_RUN )) || { swapoff -a 2>/dev/null; umount -R "$REIMU_MNT" 2>/dev/null || true; }
  run wipefs -af "$disk"
  run sgdisk --zap-all "$disk"
  if [[ "$DETECT_FIRMWARE" == bios ]]; then
    run sgdisk -n "$n:0:+1M" -t "$n:ef02" -c "$n:BIOS boot" "$disk"; n=$((n+1))
  fi
  run sgdisk -n "$n:0:+1G" -t "$n:ef00" -c "$n:EFI" "$disk"
  PART_BOOT="$(part_name "$disk" "$n")"; n=$((n+1))
  if [[ "$REIMU_SWAP" == partition ]]; then
    run sgdisk -n "$n:0:+${REIMU_SWAP_SIZE}G" -t "$n:8200" -c "$n:swap" "$disk"
    PART_SWAP="$(part_name "$disk" "$n")"; n=$((n+1))
  fi
  run sgdisk -n "$n:0:0" -t "$n:8304" -c "$n:root" "$disk"
  PART_ROOT="$(part_name "$disk" "$n")"
  run partprobe "$disk"
  (( DRY_RUN )) || { udevadm settle; sleep 1; }
}

disk_encrypt() {
  ROOT_DEV="$PART_ROOT"
  [[ "$REIMU_ENCRYPT" == yes ]] || return 0
  msg "Encrypting $PART_ROOT with LUKS2"
  if [[ -z "$LUKS_PASSWORD" ]]; then
    export REIMU_INTERACTIVE=1
    ask_secret LUKS_PASSWORD "Disk encryption password"
  fi
  if (( DRY_RUN )); then
    printf '%s  $ cryptsetup luksFormat --type luks2 %s%s\n' "$C_DIM" "$PART_ROOT" "$C_RESET"
    printf '%s  $ cryptsetup open %s cryptroot%s\n' "$C_DIM" "$PART_ROOT" "$C_RESET"
  else
    printf '%s' "$LUKS_PASSWORD" | cryptsetup luksFormat --type luks2 --batch-mode "$PART_ROOT" - || die "luksFormat failed"
    printf '%s' "$LUKS_PASSWORD" | cryptsetup open "$PART_ROOT" cryptroot - || die "Could not open the LUKS volume"
  fi
  ROOT_DEV="/dev/mapper/cryptroot"
  LUKS_UUID="$(blkid -s UUID -o value "$PART_ROOT" 2>/dev/null || echo LUKS-UUID)"
}

disk_format() {
  msg "Formatting"
  run mkfs.fat -F 32 -n BOOT "$PART_BOOT"
  case "$REIMU_FS" in
    btrfs) run mkfs.btrfs -f -L arch "$ROOT_DEV" ;;
    ext4)  run mkfs.ext4 -F -L arch "$ROOT_DEV" ;;
    xfs)   run mkfs.xfs -f -L arch "$ROOT_DEV" ;;
  esac
  if [[ -n "$PART_HOME" && "$REIMU_FORMAT_HOME" == yes ]]; then
    case "$REIMU_FS" in
      btrfs) run mkfs.btrfs -f -L home "$PART_HOME" ;;
      ext4)  run mkfs.ext4 -F -L home "$PART_HOME" ;;
      xfs)   run mkfs.xfs -f -L home "$PART_HOME" ;;
    esac
  fi
  [[ -n "$PART_SWAP" ]] && run mkswap -L swap "$PART_SWAP"
  ROOT_UUID="$(blkid -s UUID -o value "$ROOT_DEV" 2>/dev/null || echo ROOT-UUID)"
}

disk_create_subvolumes() {
  [[ "$REIMU_FS" == btrfs ]] || return 0
  msg "Creating btrfs subvolumes"
  run mount "$ROOT_DEV" "$REIMU_MNT"
  local sv name
  for sv in "${BTRFS_SUBVOLS[@]}"; do
    name="${sv%%:*}"
    [[ "$name" == @home && -n "$PART_HOME" ]] && continue
    [[ "$name" == @snapshots && "$REIMU_SNAPSHOTS" != yes ]] && continue
    run btrfs subvolume create "$REIMU_MNT/$name"
  done
  [[ "$REIMU_SWAP" == file ]] && run btrfs subvolume create "$REIMU_MNT/@swap"
  run umount "$REIMU_MNT"
  return 0
}

# Mount an already formatted layout (fresh install or resume).
disk_mount_existing() {
  msg "Mounting at $REIMU_MNT"
  [[ -n "$ROOT_DEV" ]] || ROOT_DEV="$PART_ROOT"
  if [[ "$REIMU_FS" == btrfs ]]; then
    run mount -o "$BTRFS_OPTS,subvol=@" "$ROOT_DEV" "$REIMU_MNT"
    local sv name target
    for sv in "${BTRFS_SUBVOLS[@]}"; do
      name="${sv%%:*}"; target="${sv#*:}"
      [[ "$name" == @ ]] && continue
      [[ "$name" == @home && -n "$PART_HOME" ]] && continue
      [[ "$name" == @snapshots && "$REIMU_SNAPSHOTS" != yes ]] && continue
      run mount --mkdir -o "$BTRFS_OPTS,subvol=$name" "$ROOT_DEV" "$REIMU_MNT$target"
    done
    if [[ "$REIMU_SWAP" == file ]]; then
      run mount --mkdir -o "noatime,subvol=@swap" "$ROOT_DEV" "$REIMU_MNT/swap"
    fi
  else
    run mount -o noatime "$ROOT_DEV" "$REIMU_MNT"
  fi
  if [[ -n "$PART_HOME" ]]; then
    run mount --mkdir -o noatime "$PART_HOME" "$REIMU_MNT/home"
  fi
  run mount --mkdir -o "umask=0077" "$PART_BOOT" "$REIMU_MNT/boot"
  [[ -n "$PART_SWAP" ]] && try swapon "$PART_SWAP"
  [[ "$REIMU_SWAP" == file && -e "$REIMU_MNT/swap/swapfile" ]] && try swapon "$REIMU_MNT/swap/swapfile"
  [[ "$REIMU_SWAP" == file && -e "$REIMU_MNT/swapfile" ]] && try swapon "$REIMU_MNT/swapfile"
  return 0
}

# Swap file, created after pacstrap so the tools exist on the target.
disk_swapfile() {
  [[ "$REIMU_SWAP" == file ]] || return 0
  local path="/swapfile"
  [[ "$REIMU_FS" == btrfs ]] && path="/swap/swapfile"
  if [[ ! -e "$REIMU_MNT$path" ]]; then
    msg "Creating a ${REIMU_SWAP_SIZE} GiB swap file"
    if [[ "$REIMU_FS" == btrfs ]]; then
      run btrfs filesystem mkswapfile --size "${REIMU_SWAP_SIZE}g" --uuid clear "$REIMU_MNT$path"
    else
      run mkswap -U clear --size "${REIMU_SWAP_SIZE}G" --file "$REIMU_MNT$path"
    fi
    try swapon "$REIMU_MNT$path"
  fi
  if (( DRY_RUN )) || ! grep -qs "^$path " "$REIMU_MNT/etc/fstab"; then
    append_file /etc/fstab "$path none swap defaults 0 0"
  fi
}

disk_unmount() {
  (( DRY_RUN )) && return 0
  swapoff -a 2>/dev/null || true
  umount -R "$REIMU_MNT" 2>/dev/null || true
  if [[ -e /dev/mapper/cryptroot ]]; then cryptsetup close cryptroot 2>/dev/null || true; fi
}
