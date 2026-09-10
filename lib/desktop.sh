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

  desktop_gpu
}


desktop_gpu() {
  local gpu="$REIMU_GPU"
  [[ "$gpu" == auto ]] && gpu="$DETECT_GPU"
  [[ "$gpu" == none ]] && return 0
  msg "Graphics: $gpu"
  local -a pkgs=(mesa) svcs=()
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
      # Guest tools. The services can only be enabled once the packages are in (that
      # ordering bug is what used to crash the desktop phase in a VirtualBox VM).
      case "$DETECT_VIRT" in
        oracle) pkgs+=(virtualbox-guest-utils); svcs+=(vboxservice.service) ;;
        vmware) pkgs+=(open-vm-tools xf86-video-vmware); svcs+=(vmtoolsd.service vmware-vmblock-fuse.service) ;;
        kvm|qemu) pkgs+=(qemu-guest-agent spice-vdagent); svcs+=(qemu-guest-agent.service) ;;
        microsoft) pkgs+=(hyperv); svcs+=(hv_fcopy_daemon.service hv_kvp_daemon.service hv_vss_daemon.service) ;;
        *) pkgs+=(qemu-guest-agent spice-vdagent) ;;
      esac ;;
  esac
  chr_pkg "${pkgs[@]}"
  local s
  for s in "${svcs[@]}"; do
    RUN_TITLE="Enabling $s" try arch-chroot "$REIMU_MNT" systemctl enable "$s"
  done
  return 0
}

# ---- themes ------------------------------------------------------------------
# key -> "package|aur?|dark name|light name". Names are the directories under /usr/share/themes.
declare -A THEMES=(
  [default]="||Adwaita|Adwaita"
  [greybird]="greybird-gtk-theme|aur|Greybird-dark|Greybird"
  [arc]="arc-gtk-theme|aur|Arc-Dark|Arc"
  [materia]="materia-gtk-theme||Materia-dark|Materia-light"
  [orchis]="orchis-theme||Orchis-Dark|Orchis-Light"
  [flat-remix]="flat-remix-gtk|aur|Flat-Remix-GTK-Blue-Dark|Flat-Remix-GTK-Blue-Light"
  [skeuos]="skeuos-gtk|aur|Skeuos-Blue-Dark|Skeuos-Blue-Light"
  [dracula]="dracula-gtk-theme|aur|Dracula|Dracula"
  [nordic]="nordic-theme|aur|Nordic|Nordic"
  [catppuccin]="catppuccin-gtk-theme-mocha|aur|catppuccin-mocha-blue-standard+default|catppuccin-mocha-blue-standard+default"
)
declare -A ICONS=(
  [default]="||Adwaita|Adwaita"
  [papirus]="papirus-icon-theme||Papirus-Dark|Papirus"
  [tela]="tela-icon-theme|aur|Tela-dark|Tela"
  [flat-remix]="flat-remix|aur|Flat-Remix-Blue-Dark|Flat-Remix-Blue-Light"
  [elementary]="elementary-icon-theme||elementary|elementary"
  [breeze]="breeze-icons||breeze-dark|breeze"
  [arc]="arc-icon-theme|aur|Arc|Arc"
)

# Field n (1-4) of a THEMES/ICONS entry.
theme_field() { local entry="$1" n="$2"; cut -d'|' -f"$n" <<< "$entry"; }

# Package (or "aur:package") for a theme/icon key, empty for default.
theme_package() {
  local entry="$1" pkg aur
  pkg="$(theme_field "$entry" 1)"; aur="$(theme_field "$entry" 2)"
  [[ -z "$pkg" ]] && return 0
  if [[ "$aur" == aur ]]; then printf 'aur:%s' "$pkg"; else printf '%s' "$pkg"; fi
}

theme_name() {
  local entry="$1"
  if [[ "$REIMU_THEME_VARIANT" == light ]]; then theme_field "$entry" 4; else theme_field "$entry" 3; fi
}

# XFCE reads these files on the user's first login: no session needed.
# Does the chosen GTK theme ship a part (xfwm4, metacity-1, cinnamon, gtk-4.0…)?
# Assumed yes in a dry run, where nothing is installed.
theme_has() { (( DRY_RUN )) || [[ -e "$REIMU_MNT/usr/share/themes/$1/$2" ]]; }

# A dconf keyfile that becomes the system default for every user at first login
# (no session bus exists at install time, so gsettings is not an option).
theme_dconf() {
  write_file /etc/dconf/profile/user <<'EOF'
user-db:user
system-db:local
EOF
  write_file /etc/dconf/db/local.d/00-reimu-theme <<< "$1"
  chr_pkg dconf
  try arch-chroot "$REIMU_MNT" dconf update
}

desktop_apply_theme() {
  [[ "$REIMU_DESKTOP" == none ]] && return 0
  [[ "$REIMU_THEME" == default && "$REIMU_ICONS" == default ]] && return 0
  local gtk icons dark=0 scheme=default home="/home/$REIMU_USER" f
  gtk="$(theme_name "${THEMES[$REIMU_THEME]:-${THEMES[default]}}")"
  icons="$(theme_name "${ICONS[$REIMU_ICONS]:-${ICONS[default]}}")"
  [[ "$REIMU_THEME_VARIANT" == dark ]] && { dark=1; scheme=prefer-dark; }
  msg "Theme: $gtk · icons: $icons · $REIMU_DESKTOP"

  # GTK 2, 3 and 4: every desktop and every GTK app reads these.
  write_file "$home/.gtkrc-2.0" <<EOF
gtk-theme-name="$gtk"
gtk-icon-theme-name="$icons"
EOF
  for f in gtk-3.0 gtk-4.0; do
    write_file "$home/.config/$f/settings.ini" <<EOF
[Settings]
gtk-theme-name=$gtk
gtk-icon-theme-name=$icons
gtk-application-prefer-dark-theme=$dark
EOF
  done
  # GTK 4 and libadwaita apps only follow a theme that is linked into ~/.config/gtk-4.0.
  if theme_has "$gtk" gtk-4.0; then
    for f in gtk.css gtk-dark.css assets; do
      theme_has "$gtk" "gtk-4.0/$f" && run ln -sfn "/usr/share/themes/$gtk/gtk-4.0/$f" "$REIMU_MNT$home/.config/gtk-4.0/$f"
    done
  fi

  case "$REIMU_DESKTOP" in
    xfce)
      write_file "$home/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xsettings" version="1.0">
  <property name="Net" type="empty">
    <property name="ThemeName" type="string" value="$gtk"/>
    <property name="IconThemeName" type="string" value="$icons"/>
  </property>
  <property name="Gtk" type="empty">
    <property name="CursorThemeName" type="string" value="Adwaita"/>
  </property>
</channel>
EOF
      if theme_has "$gtk" xfwm4; then
        write_file "$home/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfwm4" version="1.0">
  <property name="general" type="empty">
    <property name="theme" type="string" value="$gtk"/>
  </property>
</channel>
EOF
      fi ;;
    plasma)
      # Plasma keeps its own widget style; the GTK theme reaches GTK apps, the
      # icons reach everything, and Breeze goes dark or light to match.
      local colors=BreezeLight lnf=org.kde.breeze.desktop
      (( dark )) && { colors=BreezeDark; lnf=org.kde.breezedark.desktop; }
      write_file "$home/.config/kdeglobals" <<EOF
[General]
ColorScheme=$colors

[Icons]
Theme=$icons

[KDE]
LookAndFeelPackage=$lnf
EOF
      ;;
    lxqt)
      local lx=light; (( dark )) && lx=dark
      write_file "$home/.config/lxqt/lxqt.conf" <<EOF
[General]
icon_theme=$icons
theme=$lx
EOF
      ;;
    cosmic)
      local cd=false; (( dark )) && cd=true
      write_file "$home/.config/cosmic/com.system76.CosmicTheme.Mode/v1/is_dark" <<< "$cd" ;;
    cinnamon)
      local extra=""
      theme_has "$gtk" metacity-1 && extra+=$'\n[org/cinnamon/desktop/wm/preferences]\ntheme=\''"$gtk"$'\''
      theme_has "$gtk" cinnamon && extra+=$'\n[org/cinnamon/theme]\nname=\''"$gtk"$'\''
      theme_dconf "[org/cinnamon/desktop/interface]
gtk-theme='$gtk'
icon-theme='$icons'
$extra" ;;
    mate)
      local extra=""
      theme_has "$gtk" metacity-1 && extra+=$'\n[org/mate/marco/general]\ntheme=\''"$gtk"$'\''
      theme_dconf "[org/mate/desktop/interface]
gtk-theme='$gtk'
icon-theme='$icons'
$extra" ;;
    deepin)
      theme_dconf "[com/deepin/xsettings]
gtk-theme-name='$gtk'
icon-theme-name='$icons'

[org/gnome/desktop/interface]
gtk-theme='$gtk'
icon-theme='$icons'
color-scheme='$scheme'" ;;
    *)
      # GNOME, Budgie and the Wayland/X11 window managers: GTK apps and portals
      # read org.gnome.desktop.interface. The shell theme needs the user-theme
      # extension; the key is harmless without it.
      local extra=""
      theme_has "$gtk" gnome-shell && extra+=$'\n[org/gnome/shell/extensions/user-theme]\nname=\''"$gtk"$'\''
      theme_dconf "[org/gnome/desktop/interface]
gtk-theme='$gtk'
icon-theme='$icons'
color-scheme='$scheme'
$extra" ;;
  esac
  chr chown -R "$REIMU_USER:$REIMU_USER" "$home/.config" "$home/.gtkrc-2.0"
  return 0
}
