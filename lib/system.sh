# shellcheck shell=bash
# Reimu · system: users, privileges, network, snapshots, services.

USER_PASSWORD=""; ROOT_PASSWORD=""

sys_ask_passwords() {
  export REIMU_INTERACTIVE=1
  [[ -n "$USER_PASSWORD" ]] || ask_secret USER_PASSWORD "Password for $REIMU_USER"
  if [[ "$REIMU_ROOT_LOGIN" == yes && -z "$ROOT_PASSWORD" ]]; then
    ask_secret ROOT_PASSWORD "Password for root"
  fi
}

# Set a password inside the target without it touching the log.
sys_set_password() {
  local user="$1" pass="$2"
  log "chpasswd for $user"
  if (( DRY_RUN )); then
    printf '%s  $ chpasswd (%s)%s\n' "$C_DIM" "$user" "$C_RESET"; return 0
  fi
  printf '%s:%s\n' "$user" "$pass" | arch-chroot "$REIMU_MNT" chpasswd
}

sys_users() {
  local shell="/bin/bash"
  case "$REIMU_USER_SHELL" in zsh) shell="/usr/bin/zsh" ;; fish) shell="/usr/bin/fish" ;; esac
  chr_sh "id -u $REIMU_USER >/dev/null 2>&1 || useradd -m -G wheel,audio,video,storage,optical,input -s $shell $REIMU_USER"
  sys_set_password "$REIMU_USER" "$USER_PASSWORD"
  if [[ "$REIMU_ROOT_LOGIN" == yes ]]; then
    sys_set_password root "$ROOT_PASSWORD"
  else
    chr passwd -l root
  fi

  if [[ "$REIMU_SUDO" == doas ]]; then
    write_file /etc/doas.conf <<'EOF'
permit persist :wheel
EOF
    chr chmod 0400 /etc/doas.conf
    chr ln -sf /usr/bin/doas /usr/local/bin/sudo
  else
    write_file /etc/sudoers.d/10-wheel <<'EOF'
%wheel ALL=(ALL:ALL) ALL
Defaults pwfeedback
Defaults timestamp_timeout=15
EOF
    chr chmod 0440 /etc/sudoers.d/10-wheel
  fi

  # Home folders (Desktop, Documents, …) in the user's language, the thing every
  # fresh install forgets.
  chr_user "$REIMU_USER" "LANG=$REIMU_LOCALE xdg-user-dirs-update"

  if [[ "$REIMU_USER_SHELL" == zsh ]]; then
    write_file "/home/$REIMU_USER/.zshrc" <<'EOF'
autoload -Uz compinit promptinit && compinit && promptinit
HISTFILE=~/.zsh_history; HISTSIZE=10000; SAVEHIST=10000
setopt share_history hist_ignore_dups
PROMPT='%F{red}%n%f@%m %F{cyan}%~%f %# '
alias ls='ls --color=auto'
EOF
    chr chown "$REIMU_USER:$REIMU_USER" "/home/$REIMU_USER/.zshrc"
  fi
}

sys_network() {
  case "$REIMU_NETWORK" in
    networkmanager)
      chr_enable NetworkManager.service
      write_file /etc/NetworkManager/conf.d/wifi-backend.conf <<'EOF'
[device]
wifi.backend=wpa_supplicant
EOF
      ;;
    iwd)
      chr_enable iwd.service systemd-networkd.service systemd-resolved.service
      write_file /etc/iwd/main.conf <<'EOF'
[General]
EnableNetworkConfiguration=true
EOF
      write_file /etc/systemd/network/20-wired.network <<'EOF'
[Match]
Name=en* eth*
[Network]
DHCP=yes
EOF
      ;;
    systemd-networkd)
      chr_enable systemd-networkd.service systemd-resolved.service
      write_file /etc/systemd/network/20-wired.network <<'EOF'
[Match]
Name=en* eth*
[Network]
DHCP=yes
EOF
      ;;
  esac

  if [[ "$REIMU_SSH" == yes ]]; then
    chr_enable sshd.service
    write_file /etc/ssh/sshd_config.d/10-reimu.conf <<'EOF'
PermitRootLogin no
PasswordAuthentication yes
EOF
  fi

  case "$REIMU_FIREWALL" in
    firewalld) chr_pkg firewalld; chr_enable firewalld.service ;;
    ufw) chr_pkg ufw; chr_enable ufw.service; edit_file 's/^ENABLED=no/ENABLED=yes/' /etc/ufw/ufw.conf ;;
  esac
}

sys_bluetooth_wanted() {
  case "$REIMU_BLUETOOTH" in
    yes) return 0 ;;
    auto) [[ "$REIMU_DESKTOP" != none ]] ;;
    *) return 1 ;;
  esac
}

sys_extras() {
  if sys_bluetooth_wanted; then
    chr_pkg bluez bluez-utils
    chr_enable bluetooth.service
  fi
  if [[ "$REIMU_PRINTING" == yes ]]; then
    chr_pkg cups cups-pdf cups-filters ghostscript gsfonts system-config-printer
    chr_enable cups.socket
  fi
  if [[ -n "$REIMU_SERVICES" ]]; then
    # shellcheck disable=SC2086
    chr_enable $REIMU_SERVICES
  fi
}

# snapper on btrfs: the @snapshots subvolume must be handed over to snapper.
sys_snapshots() {
  [[ "$REIMU_SNAPSHOTS" == yes ]] || return 0
  if [[ -e "$REIMU_MNT/etc/snapper/configs/root" ]]; then ui_note "snapper is already configured."; return 0; fi
  run umount "$REIMU_MNT/.snapshots"
  run rm -rf "$REIMU_MNT/.snapshots"
  chr snapper --no-dbus -c root create-config /
  chr btrfs subvolume delete /.snapshots
  run mkdir -p "$REIMU_MNT/.snapshots"
  run mount -o "$BTRFS_OPTS,subvol=@snapshots" "$ROOT_DEV" "$REIMU_MNT/.snapshots"
  chr chmod 750 /.snapshots
  chr chown :wheel /.snapshots
  edit_file 's/^ALLOW_GROUPS=.*/ALLOW_GROUPS="wheel"/; s/^TIMELINE_LIMIT_HOURLY=.*/TIMELINE_LIMIT_HOURLY="5"/; s/^TIMELINE_LIMIT_DAILY=.*/TIMELINE_LIMIT_DAILY="7"/; s/^TIMELINE_LIMIT_WEEKLY=.*/TIMELINE_LIMIT_WEEKLY="0"/; s/^TIMELINE_LIMIT_MONTHLY=.*/TIMELINE_LIMIT_MONTHLY="0"/; s/^TIMELINE_LIMIT_YEARLY=.*/TIMELINE_LIMIT_YEARLY="0"/' /etc/snapper/configs/root
  chr_enable snapper-timeline.timer snapper-cleanup.timer
}
