# shellcheck shell=bash
# Reimu · apply: summary, last confirmation, and the installation in order.

apply_summary() {
  printf '\n%s%sSummary%s\n' "$C_BOLD" "$C_RED" "$C_RESET"
  hr
  printf '  %-14s %s\n' "Firmware" "$DETECT_FIRMWARE · cpu $DETECT_CPU · gpu $DETECT_GPU · ram ${DETECT_RAM_MIB} MiB$( (( DETECT_LAPTOP )) && printf ' · laptop' )$( [[ "$DETECT_VIRT" != none ]] && printf ' · vm %s' "$DETECT_VIRT" )"
  if [[ "$REIMU_DISK_MODE" == auto ]]; then
    printf '  %-14s %s%s WILL BE WIPED%s\n' "Disk" "$C_RED" "$REIMU_DISK" "$C_RESET"
  else
    printf '  %-14s %s\n' "Boot" "$REIMU_PART_BOOT (formatted)"
    printf '  %-14s %s%s (formatted)%s\n' "Root" "$C_RED" "$REIMU_PART_ROOT" "$C_RESET"
    [[ -n "$REIMU_PART_HOME" ]] && printf '  %-14s %s (%s)\n' "Home" "$REIMU_PART_HOME" "$( [[ "$REIMU_FORMAT_HOME" == yes ]] && echo formatted || echo kept )"
    [[ -n "$REIMU_PART_SWAP" ]] && printf '  %-14s %s\n' "Swap part." "$REIMU_PART_SWAP"
  fi
  printf '  %-14s %s\n' "Filesystem" "$REIMU_FS$( [[ "$REIMU_ENCRYPT" == yes ]] && printf ' · LUKS2' )$( [[ "$REIMU_SNAPSHOTS" == yes ]] && printf ' · snapshots' )"
  printf '  %-14s %s\n' "Swap" "$REIMU_SWAP${REIMU_SWAP_SIZE:+ ($REIMU_SWAP_SIZE)}"
  printf '  %-14s %s\n' "Boot" "$REIMU_BOOTLOADER · $REIMU_KERNELS"
  printf '  %-14s %s\n' "System" "$REIMU_HOSTNAME · $REIMU_LOCALE · $REIMU_KEYMAP · $REIMU_TIMEZONE"
  printf '  %-14s %s\n' "User" "$REIMU_USER · $REIMU_USER_SHELL · $REIMU_SUDO · root $( [[ "$REIMU_ROOT_LOGIN" == yes ]] && echo enabled || echo locked )"
  printf '  %-14s %s\n' "Network" "$REIMU_NETWORK$( [[ "$REIMU_FIREWALL" != no ]] && printf ' · %s' "$REIMU_FIREWALL" )$( [[ "$REIMU_SSH" == yes ]] && printf ' · sshd' )"
  printf '  %-14s %s\n' "Desktop" "$REIMU_DESKTOP$( [[ "$REIMU_DESKTOP" != none ]] && printf ' · %s' "$(desktop_display_manager)" ) · gpu $REIMU_GPU"
  printf '  %-14s %s\n' "Software" "aur $REIMU_AUR · ${REIMU_CATALOG:-no bundles}${REIMU_EXTRA_PACKAGES:+ · $REIMU_EXTRA_PACKAGES}"
  hr
}

apply_confirm() {
  (( DRY_RUN )) && { msg "Dry run: nothing will be written."; return 0; }
  if (( ASSUME_YES )); then return 0; fi
  local ans
  printf '\n%sThis will destroy the data on the partitions marked above.%s\n' "$C_RED" "$C_RESET"
  read -r -p "$(printf 'Type %sYES%s to continue: ' "$C_BOLD" "$C_RESET")" ans
  [[ "$ans" == YES ]] || die "Aborted."
}

apply_install() {
  local start=$SECONDS
  sys_ask_passwords
  base_mirrors
  disk_prepare
  base_install
  base_configure
  base_initramfs
  boot_install
  sys_users
  sys_network
  sys_extras
  sys_snapshots
  desktop_install
  sw_aur_helper
  sw_install_bundles
  apply_finish
  ok "Done in $(( (SECONDS - start) / 60 )) min."
}

apply_finish() {
  step "Finishing"
  # Leave the recipe and the log on the new system.
  local conf="$REIMU_MNT/root/reimu.conf"
  if (( DRY_RUN )); then
    printf '%s  > %s%s\n' "$C_DIM" "$conf" "$C_RESET"
  else
    config_save "$conf"
    mkdir -p "$REIMU_MNT/var/log/reimu"
    cp "$REIMU_LOG" "$REIMU_MNT/var/log/reimu/install.log" 2>/dev/null || true
  fi
  # Regenerate the initramfs once more so every hook and module is in.
  chr mkinitcpio -P
  [[ "$REIMU_BOOTLOADER" == grub ]] && chr grub-mkconfig -o /boot/grub/grub.cfg
  # The snapshot before first boot.
  [[ "$REIMU_SNAPSHOTS" == yes ]] && chr snapper --no-dbus -c root create -d "Reimu: fresh install"
  disk_unmount
  printf '\n'
  ok "Arch Linux is installed. Configuration kept at /root/reimu.conf, log at /var/log/reimu/install.log."
  if [[ "$REIMU_DESKTOP" == xfce && "$REIMU_XFCE_WIN2K" == yes ]]; then
    ui_note "Win2k Undead is in ~/Win2k_undead; run ./install.sh after your first login."
  fi
  if ! (( ASSUME_YES )) && ! (( DRY_RUN )); then
    if ask_yesno "Reboot now?" y; then reboot; fi
  fi
}
