# shellcheck shell=bash
# Reimu · boot: systemd-boot or GRUB, with LUKS and btrfs aware kernel lines.

# Kernel command line, in two halves: where the root is, and the rest.
boot_cmdline_root() {
  local line
  if [[ "$REIMU_ENCRYPT" == yes ]]; then
    line="rd.luks.name=${LUKS_UUID}=cryptroot root=/dev/mapper/cryptroot"
  else
    line="root=UUID=${ROOT_UUID}"
  fi
  [[ "$REIMU_FS" == btrfs ]] && line+=" rootflags=subvol=@"
  printf '%s rw' "$line"
}
boot_cmdline_extra() {
  local line="quiet loglevel=3"
  [[ "$REIMU_GPU" == nvidia || "$REIMU_GPU" == nvidia-proprietary ]] && line+=" nvidia_drm.modeset=1"
  printf '%s' "$line"
}
boot_cmdline() { printf '%s %s' "$(boot_cmdline_root)" "$(boot_cmdline_extra)"; }

boot_install() {
  case "$REIMU_BOOTLOADER" in
    systemd-boot) boot_systemd ;;
    grub) boot_grub ;;
  esac
}

boot_systemd() {
  chr bootctl --esp-path=/boot install
  write_file /boot/loader/loader.conf <<EOF
default  ${REIMU_KERNELS%% *}.conf
timeout  3
console-mode max
editor   no
EOF
  local k cmdline
  cmdline="$(boot_cmdline)"
  for k in $REIMU_KERNELS; do
    write_file "/boot/loader/entries/$k.conf" <<EOF
title    Arch Linux ($k)
linux    /vmlinuz-$k
initrd   /initramfs-$k.img
options  $cmdline
EOF
    write_file "/boot/loader/entries/$k-fallback.conf" <<EOF
title    Arch Linux ($k, fallback initramfs)
linux    /vmlinuz-$k
initrd   /initramfs-$k-fallback.img
options  $cmdline
EOF
  done
  # Keep systemd-boot updated together with the systemd package.
  chr_enable systemd-boot-update.service
}

boot_grub() {
  edit_file "s|^GRUB_CMDLINE_LINUX_DEFAULT=.*|GRUB_CMDLINE_LINUX_DEFAULT=\"$(boot_cmdline_extra)\"|" /etc/default/grub
  edit_file "s|^GRUB_CMDLINE_LINUX=.*|GRUB_CMDLINE_LINUX=\"$(boot_cmdline_root)\"|" /etc/default/grub
  edit_file 's/^#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/; s/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=3/' /etc/default/grub
  if [[ "$DETECT_FIRMWARE" == uefi ]]; then
    chr grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Arch --recheck
  else
    chr grub-install --target=i386-pc --recheck "$REIMU_DISK"
  fi
  chr grub-mkconfig -o /boot/grub/grub.cfg
  if [[ "$REIMU_SNAPSHOTS" == yes ]]; then
    chr_enable grub-btrfsd.service
  fi
}
