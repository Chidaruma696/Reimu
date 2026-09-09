# shellcheck shell=bash
# Reimu · desktop: desktop environments, login managers, graphics drivers.

# Packages every graphical install gets, whatever the desktop.
DESKTOP_COMMON=(pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber
  noto-fonts noto-fonts-cjk noto-fonts-emoji ttf-dejavu ttf-liberation
  gvfs gvfs-mtp gvfs-smb xdg-desktop-portal flatpak xf86-input-libinput)

desktop_packages() {
  case "${1:-$REIMU_DESKTOP}" in
    gnome)    echo gnome gnome-tweaks gnome-browser-connector xdg-desktop-portal-gnome ;;
    plasma)   echo plasma-meta konsole dolphin kate ark spectacle gwenview okular kdeconnect xdg-desktop-portal-kde ;;
    xfce)     echo xfce4 xfce4-goodies xorg-server network-manager-applet xdg-desktop-portal-gtk xarchiver ristretto mousepad ;;
    cinnamon) echo cinnamon xorg-server gnome-terminal gnome-screenshot xed xreader file-roller xdg-desktop-portal-gtk ;;
    mate)     echo mate mate-extra xorg-server network-manager-applet xdg-desktop-portal-gtk ;;
    budgie)   echo budgie-desktop budgie-desktop-view budgie-control-center xorg-server gnome-terminal nautilus network-manager-applet xdg-desktop-portal-gtk ;;
    lxqt)     echo lxqt breeze-icons xorg-server network-manager-applet xdg-desktop-portal-gtk ;;
    cosmic)   echo cosmic cosmic-greeter xdg-desktop-portal-cosmic ;;
    deepin)   echo deepin deepin-extra xorg-server xdg-desktop-portal-gtk ;;
    hyprland) echo hyprland xdg-desktop-portal-hyprland hyprpaper hyprlock hypridle waybar foot wofi mako grim slurp wl-clipboard cliphist polkit-kde-agent qt5-wayland qt6-wayland thunar network-manager-applet brightnessctl playerctl ;;
    sway)     echo sway swaybg swaylock swayidle waybar foot wmenu mako grim slurp wl-clipboard polkit xdg-desktop-portal-wlr thunar network-manager-applet brightnessctl playerctl ;;
    niri)     echo niri xwayland-satellite waybar foot fuzzel mako swaybg swaylock swayidle grim slurp wl-clipboard polkit-kde-agent xdg-desktop-portal-gnome thunar network-manager-applet brightnessctl playerctl ;;
    i3)       echo i3-wm i3status i3lock dmenu xorg-server xorg-xinit alacritty picom feh thunar network-manager-applet xdg-desktop-portal-gtk ;;
  esac
}

desktop_display_manager() {
  local dm="$REIMU_DISPLAY_MANAGER"
  if [[ "$dm" == auto ]]; then
    case "$REIMU_DESKTOP" in
      gnome) dm=gdm ;;
      plasma|lxqt|hyprland|sway|niri) dm=sddm ;;
      xfce|mate|i3|cinnamon|budgie|deepin) dm=lightdm ;;
      cosmic) dm=cosmic-greeter ;;
      *) dm=none ;;
    esac
  fi
  printf '%s' "$dm"
}

desktop_install() {
  [[ "$REIMU_DESKTOP" == none ]] && { desktop_gpu; return 0; }
  msg "Desktop: $REIMU_DESKTOP"
  local -a pkgs=() all
  read -r -a all <<< "$(desktop_packages "$REIMU_DESKTOP")"
  local p
  for p in "${all[@]}"; do
    # NetworkManager applets only make sense with NetworkManager.
    [[ "$p" == network-manager-applet && "$REIMU_NETWORK" != networkmanager ]] && continue
    pkgs+=("$p")
  done
  chr_pkg "${DESKTOP_COMMON[@]}" "${pkgs[@]}"

  local dm; dm="$(desktop_display_manager)"
  case "$dm" in
    gdm) chr_pkg gdm; chr_enable gdm.service ;;
    sddm) chr_pkg sddm; chr_enable sddm.service ;;
    lightdm) chr_pkg lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings; chr_enable lightdm.service ;;
    ly) chr_pkg ly; chr_enable ly.service ;;
    cosmic-greeter) chr_enable cosmic-greeter.service ;;
    none) ;;
  esac

  [[ "$REIMU_DESKTOP" == xfce && "$REIMU_XFCE_WIN2K" == yes ]] && desktop_win2k
  desktop_gpu
}

desktop_win2k() {
  msg "Fetching Win2k Undead for $REIMU_USER"
  RUN_TITLE="Fetching Win2k Undead" chr_user_net "$REIMU_USER" "[ -d ~/Win2k_undead ] || git clone --depth 1 https://github.com/Chidaruma696/Win2k_undead ~/Win2k_undead"
  write_file "/home/$REIMU_USER/Win2k_undead/READ-ME-FIRST.txt" <<'EOF'
Win2k Undead was downloaded by Reimu but not applied: the theme configures
your XFCE session, so it needs you logged in. Open a terminal and run:

    cd ~/Win2k_undead && ./install.sh

EOF
  chr chown -R "$REIMU_USER:$REIMU_USER" "/home/$REIMU_USER/Win2k_undead"
}

desktop_gpu() {
  local gpu="$REIMU_GPU"
  [[ "$gpu" == auto ]] && gpu="$DETECT_GPU"
  [[ "$gpu" == none ]] && return 0
  msg "Graphics: $gpu"
  local -a pkgs=(mesa)
  [[ "$REIMU_MULTILIB" == yes ]] && pkgs+=(lib32-mesa)
  case "$gpu" in
    intel)
      pkgs+=(vulkan-intel intel-media-driver libva-intel-driver vulkan-icd-loader)
      [[ "$REIMU_MULTILIB" == yes ]] && pkgs+=(lib32-vulkan-intel) ;;
    amd)
      pkgs+=(vulkan-radeon libva-mesa-driver vulkan-icd-loader)
      [[ "$REIMU_MULTILIB" == yes ]] && pkgs+=(lib32-vulkan-radeon) ;;
    nvidia|nvidia-proprietary)
      local k drv="nvidia-open-dkms"
      [[ "$gpu" == nvidia-proprietary ]] && drv="nvidia-dkms"
      pkgs+=("$drv" nvidia-utils nvidia-settings libva-nvidia-driver vulkan-icd-loader)
      [[ "$REIMU_MULTILIB" == yes ]] && pkgs+=(lib32-nvidia-utils)
      for k in $REIMU_KERNELS; do pkgs+=("$k-headers"); done
      write_file /etc/modprobe.d/nvidia.conf <<'EOF'
options nvidia_drm modeset=1 fbdev=1
EOF
      write_file /etc/pacman.d/hooks/nvidia.hook <<EOF
[Trigger]
Operation=Install
Operation=Upgrade
Operation=Remove
Type=Package
Target=$drv
$(for k in $REIMU_KERNELS; do printf 'Target=%s\n' "$k"; done)

[Action]
Description=Updating NVIDIA module in initcpio
Depends=mkinitcpio
When=PostTransaction
NeedsTargets
Exec=/bin/sh -c 'while read -r trg; do case \$trg in linux*) exit 0; esac; done; /usr/bin/mkinitcpio -P'
EOF
      ;;
    nouveau) pkgs+=(vulkan-nouveau libva-mesa-driver) ;;
    vm)
      case "$DETECT_VIRT" in
        oracle) pkgs+=(virtualbox-guest-utils); chr_enable vboxservice.service ;;
        vmware) pkgs+=(open-vm-tools xf86-video-vmware); chr_enable vmtoolsd.service vmware-vmblock-fuse.service ;;
        kvm|qemu) pkgs+=(qemu-guest-agent spice-vdagent); chr_enable qemu-guest-agent.service ;;
        microsoft) pkgs+=(hyperv); chr_enable hv_fcopy_daemon.service hv_kvp_daemon.service hv_vss_daemon.service ;;
        *) pkgs+=(qemu-guest-agent spice-vdagent) ;;
      esac ;;
  esac
  chr_pkg "${pkgs[@]}"
}
