# shellcheck shell=bash
# Reimu · apply: summary, last confirmation, the phases in order, resume.

# "id|Title|function". Each phase is safe to run again after an interruption.
PHASES=(
  "mirrors|Mirrors and keyring|base_mirrors"
  "disk|Disk|disk_prepare"
  "base|Base system|base_install"
  "configure|System configuration|base_configure"
  "repos|Repositories|sys_repos"
  "initramfs|initramfs|base_initramfs"
  "boot|Bootloader|boot_install"
  "users|Users|sys_users"
  "network|Network|sys_network"
  "services|Services|sys_extras"
  "snapshots|Snapshots|sys_snapshots"
  "desktop|Desktop and graphics|desktop_install"
  "aur|AUR helper|sw_aur_helper"
  "bundles|Software bundles|sw_install_bundles"
  "sanae|Sanae software store|sw_sanae"
  "finish|Finishing touches|apply_finish"
)

apply_summary() {
  local body=""
  body+="$(printf '%-12s %s' "$(t Machine)" "$DETECT_FIRMWARE · cpu $DETECT_CPU · gpu $DETECT_GPU · $(help_ram_gib) GiB RAM$( (( DETECT_LAPTOP )) && printf ' · %s' "$(t laptop)" )$( [[ "$DETECT_VIRT" != none ]] && printf ' · vm %s' "$DETECT_VIRT" )")"$'\n'
  if [[ "$REIMU_DISK_MODE" == auto ]]; then
    body+="$(printf '%-12s %s' "$(t Disk)" "$REIMU_DISK  ← $(t "WILL BE ERASED COMPLETELY")")"$'\n'
  else
    body+="$(printf '%-12s %s' "$(t Boot)" "$REIMU_PART_BOOT ($(t formatted))")"$'\n'
    body+="$(printf '%-12s %s' "$(t Root)" "$REIMU_PART_ROOT  ← $(t "WILL BE FORMATTED")")"$'\n'
    [[ -n "$REIMU_PART_HOME" ]] && body+="$(printf '%-12s %s' "$(t Home)" "$REIMU_PART_HOME ($( if [[ "$REIMU_FORMAT_HOME" == yes ]]; then t formatted; else t kept; fi ))")"$'\n'
    [[ -n "$REIMU_PART_SWAP" ]] && body+="$(printf '%-12s %s' "$(t "Swap part.")" "$REIMU_PART_SWAP")"$'\n'
  fi
  body+="$(printf '%-12s %s' "$(t Filesystem)" "$REIMU_FS$( [[ "$REIMU_ENCRYPT" == yes ]] && printf ' · LUKS2' )$( [[ "$REIMU_SNAPSHOTS" == yes ]] && printf ' · snapshots' )")"$'\n'
  body+="$(printf '%-12s %s' "$(t Swap)" "$REIMU_SWAP${REIMU_SWAP_SIZE:+ ($REIMU_SWAP_SIZE)}")"$'\n'
  body+="$(printf '%-12s %s' "$(t Boot)" "$REIMU_BOOTLOADER · $REIMU_KERNELS")"$'\n'
  body+="$(printf '%-12s %s' "$(t System)" "$REIMU_HOSTNAME · $REIMU_LOCALE · $REIMU_KEYMAP · $REIMU_TIMEZONE")"$'\n'
  body+="$(printf '%-12s %s' "$(t User)" "$REIMU_USER · $REIMU_USER_SHELL · $REIMU_SUDO · root $( if [[ "$REIMU_ROOT_LOGIN" == yes ]]; then t enabled; else t locked; fi )")"$'\n'
  body+="$(printf '%-12s %s' "$(t Network)" "$REIMU_NETWORK$( [[ "$REIMU_BLUETOOTH" != no ]] && printf ' · bluetooth' )$( [[ "$REIMU_PRINTING" == yes ]] && printf ' · printing' )$( [[ "$REIMU_FIREWALL" != no ]] && printf ' · %s' "$REIMU_FIREWALL" )$( [[ "$REIMU_SSH" == yes ]] && printf ' · sshd' )$( [[ "$REIMU_MULTILIB" == yes ]] && printf ' · multilib' )")"$'\n'
  body+="$(printf '%-12s %s' "$(t Repos)" "${REIMU_REPOS:-$(t none)}${REIMU_CUSTOM_REPOS:+ · $REIMU_CUSTOM_REPOS}")"$'\n'
  body+="$(printf '%-12s %s' "$(t Desktop)" "$REIMU_DESKTOP$( [[ "$REIMU_DESKTOP" != none ]] && printf ' · %s' "$(desktop_display_manager)" ) · gpu $REIMU_GPU")"$'\n'
  body+="$(printf '%-12s %s' "$(t Software)" "aur $REIMU_AUR · ${REIMU_CATALOG:-$(t "no bundles")}${REIMU_EXTRA_PACKAGES:+ · $REIMU_EXTRA_PACKAGES}$( [[ "$REIMU_SANAE" == yes ]] && printf ' · Sanae' )")"
  ui_box "Summary" "$body" 196
}

apply_confirm() {
  (( DRY_RUN )) && { msg "$(t "Dry run: nothing will be written.")"; return 0; }
  (( ASSUME_YES )) && return 0
  local ans
  printf '%s%s%s\n' "$C_RED" "$(t 'This erases the data on the partitions marked above. There is no undo.')" "$C_RESET"
  if (( UI_GUM )); then
    ans="$(gum input --header "$(t "Type YES to continue")" --placeholder "YES" --width 20)" || ans=""
  else
    read -r -p "$(printf '%s: ' "$(t 'Type YES to continue')")" ans
  fi
  [[ "$ans" == YES ]] || die "$(t "Aborted. Nothing was changed.")"
}

# The phase list with marks, for the side pane.
apply_progress() {
  local current="$1" out="" ph id title mark
  out+="  Reimu · $REIMU_HOSTNAME"$'\n'$'\n'
  for ph in "${PHASES[@]}"; do
    id="${ph%%|*}"; title="${ph#*|}"; title="${title%%|*}"
    if state_done "$id" || [[ "$id" == finish && "$current" == "done" ]]; then mark="✔"
    elif [[ "$id" == "$current" ]]; then mark="▶"
    else mark="○"; fi
    out+="  $mark $title"$'\n'
  done
  [[ "$current" == "done" ]] && out+=$'\n'"  Finished."
  progress_write "$out"
}

apply_install() {
  local start=$SECONDS total=${#PHASES[@]} n=0 ph id title fn
  # Passwords only for the phases that still need them.
  state_done users || sys_ask_passwords
  for ph in "${PHASES[@]}"; do
    n=$((n+1))
    id="${ph%%|*}"; title="${ph#*|}"; title="${title%%|*}"; fn="${ph##*|}"
    if state_done "$id"; then
      printf '  %s✔ [%s/%s] %s · %s%s\n' "$C_DIM" "$n" "$total" "$(t "$title")" "$(t 'already done')" "$C_RESET"
      continue
    fi
    apply_progress "$id"
    ui_phase "$n" "$total" "$(t "$title")"
    "$fn"
    [[ "$id" == finish ]] || state_mark "$id"
  done
  apply_progress "done"
  ok "$(tf "Done in %s min." "$(( (SECONDS - start) / 60 ))")"
  apply_goodbye
}

apply_finish() {
  # Leave the recipe and the log on the new system.
  if (( DRY_RUN )); then
    printf '%s  > %s/root/reimu.conf%s\n' "$C_DIM" "$REIMU_MNT" "$C_RESET"
  else
    config_save "$REIMU_MNT/root/reimu.conf" quiet
    mkdir -p "$REIMU_MNT/var/log/reimu"
    cp "$REIMU_LOG" "$REIMU_MNT/var/log/reimu/install.log" 2>/dev/null || true
  fi
  # DNS inside the installed system (done last so the chroot keeps the ISO's resolver until now).
  if [[ "$REIMU_NETWORK" == iwd || "$REIMU_NETWORK" == systemd-networkd ]]; then
    chr ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
  fi
  # Regenerate the initramfs once more so every hook and module is in.
  RUN_TITLE="Building the initramfs" chr mkinitcpio -P
  [[ "$REIMU_BOOTLOADER" == grub ]] && RUN_TITLE="Updating GRUB" chr grub-mkconfig -o /boot/grub/grub.cfg
  # The snapshot before first boot.
  [[ "$REIMU_SNAPSHOTS" == yes ]] && chr snapper --no-dbus -c root create -d "Reimu: fresh install"
  (( DRY_RUN )) || rm -rf "${REIMU_MNT:?}$STATE_DIR_REL"
  disk_unmount
  return 0
}

apply_goodbye() {
  local extra=""
  [[ "$REIMU_SANAE" == yes ]] && extra+=$'\n'"$(t "Sanae is installed: type sanae after logging in to browse and install software.")"
  [[ -n "$FAILED_PACKAGES" ]] && extra+=$'\n'"$(t "Packages that could not be installed (install them later by hand):")$FAILED_PACKAGES"
  ui_box "Arch Linux is installed" "$(t "Take the USB out and reboot.")
$(t "Your recipe is at /root/reimu.conf and the log at /var/log/reimu/install.log.")
$(t "Rerun the same install on another machine with:  reimu --config reimu.conf")${extra}

$(t "Reimu is made by Chidaruma. Like it? Visit github.com/Chidaruma696 and leave a star.")" 46
  if ! (( ASSUME_YES )) && ! (( DRY_RUN )); then
    if ask_yesno "Reboot now?" y; then reboot; fi
  fi
}
