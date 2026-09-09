# shellcheck shell=bash
# Reimu · base: mirrors, pacstrap, fstab, locale, time, hostname, pacman tweaks.

base_mirrors() {
  step "Mirrors"
  (( DRY_RUN )) || timedatectl set-ntp true 2>/dev/null || true
  if has reflector; then
    local -a args=(--protocol https --latest 20 --sort rate --save /etc/pacman.d/mirrorlist)
    [[ -n "$REIMU_MIRROR_COUNTRIES" ]] && args+=(--country "$REIMU_MIRROR_COUNTRIES")
    try reflector "${args[@]}"
  else
    warn "reflector not found, keeping the current mirrorlist."
  fi
  # Faster downloads on the live system too.
  (( DRY_RUN )) || sed -i 's/^#ParallelDownloads.*/ParallelDownloads = 10/; s/^#Color$/Color/' /etc/pacman.conf
  run pacman -Sy --noconfirm archlinux-keyring
}

base_packages() {
  local -a pkgs=(base base-devel linux-firmware sof-firmware)
  local k
  for k in $REIMU_KERNELS; do pkgs+=("$k" "$k-headers"); done
  case "$DETECT_CPU" in intel) pkgs+=(intel-ucode) ;; amd) pkgs+=(amd-ucode) ;; esac
  case "$REIMU_FS" in btrfs) pkgs+=(btrfs-progs) ;; xfs) pkgs+=(xfsprogs) ;; ext4) pkgs+=(e2fsprogs) ;; esac
  pkgs+=(dosfstools exfatprogs ntfs-3g)
  [[ "$REIMU_ENCRYPT" == yes ]] && pkgs+=(cryptsetup)
  # The things a fresh Arch always ends up needing.
  pkgs+=(sudo nano vim git curl wget rsync man-db man-pages texinfo less which
         bash-completion pacman-contrib reflector zram-generator
         xdg-user-dirs xdg-utils usbutils pciutils lsof htop fastfetch
         unzip zip 7zip inetutils bind openssh smartmontools)
  case "$REIMU_USER_SHELL" in zsh) pkgs+=(zsh zsh-completions) ;; fish) pkgs+=(fish) ;; esac
  [[ "$REIMU_SUDO" == doas ]] && pkgs+=(opendoas)
  case "$REIMU_NETWORK" in
    networkmanager) pkgs+=(networkmanager wireless-regdb) ;;
    iwd) pkgs+=(iwd wireless-regdb) ;;
    systemd-networkd) ;;
  esac
  [[ "$REIMU_BOOTLOADER" == grub ]] && pkgs+=(grub efibootmgr os-prober)
  [[ "$REIMU_BOOTLOADER" == systemd-boot ]] && pkgs+=(efibootmgr)
  [[ "$REIMU_SNAPSHOTS" == yes ]] && pkgs+=(snapper snap-pac)
  [[ "$REIMU_SNAPSHOTS" == yes && "$REIMU_BOOTLOADER" == grub ]] && pkgs+=(grub-btrfs inotify-tools)
  (( DETECT_LAPTOP )) && pkgs+=(power-profiles-daemon acpi)
  printf '%s\n' "${pkgs[@]}"
}

base_install() {
  step "Base system"
  local -a pkgs
  mapfile -t pkgs < <(base_packages)
  msg "pacstrap with ${#pkgs[@]} packages"
  run pacstrap -K "$REIMU_MNT" "${pkgs[@]}"
  msg "fstab"
  if (( DRY_RUN )); then
    printf '%s  $ genfstab -U %s >> %s/etc/fstab%s\n' "$C_DIM" "$REIMU_MNT" "$REIMU_MNT" "$C_RESET"
  else
    genfstab -U "$REIMU_MNT" >> "$REIMU_MNT/etc/fstab"
  fi
  disk_swapfile
}

base_configure() {
  step "System configuration"
  chr ln -sf "/usr/share/zoneinfo/$REIMU_TIMEZONE" /etc/localtime
  chr hwclock --systohc

  local loc done_locales=""
  for loc in "$REIMU_LOCALE" $REIMU_EXTRA_LOCALES en_US.UTF-8; do
    has_word "$done_locales" "$loc" && continue
    done_locales+=" $loc"
    edit_file "s/^#\?\(${loc} \)/\1/" /etc/locale.gen
  done
  chr locale-gen
  write_file /etc/locale.conf <<EOF
LANG=$REIMU_LOCALE
EOF
  write_file /etc/vconsole.conf <<EOF
KEYMAP=$REIMU_KEYMAP
EOF
  write_file /etc/hostname <<EOF
$REIMU_HOSTNAME
EOF
  write_file /etc/hosts <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   $REIMU_HOSTNAME
EOF

  # pacman: colors, parallel downloads, optional multilib.
  edit_file 's/^#ParallelDownloads.*/ParallelDownloads = 10/; s/^#Color$/Color/; s/^#VerbosePkgLists$/VerbosePkgLists/' /etc/pacman.conf
  if [[ "$REIMU_MULTILIB" == yes ]]; then
    edit_file '/^#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf
    chr pacman -Sy --noconfirm
  fi

  # Keep the package cache small and the mirrorlist fresh.
  chr_enable paccache.timer fstrim.timer systemd-timesyncd.service
  write_file /etc/xdg/reflector/reflector.conf <<EOF
--save /etc/pacman.d/mirrorlist
--protocol https
--latest 20
--sort rate
${REIMU_MIRROR_COUNTRIES:+--country $REIMU_MIRROR_COUNTRIES}
EOF
  chr_enable reflector.timer

  # zram
  if [[ "$REIMU_SWAP" == zram ]]; then
    write_file /etc/systemd/zram-generator.conf <<EOF
[zram0]
zram-size = ${REIMU_SWAP_SIZE:-$(suggest_zram_mib)}
compression-algorithm = zstd
swap-priority = 100
EOF
    write_file /etc/sysctl.d/99-zram.conf <<'EOF'
vm.swappiness = 180
vm.watermark_boost_factor = 0
vm.watermark_scale_factor = 125
vm.page-cluster = 0
EOF
  fi

  (( DETECT_LAPTOP )) && chr_enable power-profiles-daemon.service
  return 0
}

base_initramfs() {
  step "initramfs"
  local hooks="base systemd autodetect microcode modconf kms keyboard sd-vconsole block"
  [[ "$REIMU_ENCRYPT" == yes ]] && hooks+=" sd-encrypt"
  hooks+=" filesystems fsck"
  local modules=""
  [[ "$REIMU_FS" == btrfs ]] && modules="btrfs"
  edit_file "s/^HOOKS=.*/HOOKS=($hooks)/; s/^MODULES=.*/MODULES=($modules)/" /etc/mkinitcpio.conf
  chr mkinitcpio -P
}
