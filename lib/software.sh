# shellcheck shell=bash
# Reimu · software: AUR helper, software bundles from catalog/*.list, extras.
#
# Bundle file format (catalog/<name>.list):
#   # one-line description (first line)
#   package            # from the official repositories
#   aur:package        # from the AUR (needs an AUR helper)
#   multilib:package   # only if multilib is enabled
#   svc:unit.service   # a unit to enable when the bundle is chosen
#   group:name         # add the user to this group
#   env:KEY=value      # a line for /etc/environment

SW_REPO=(); SW_AUR=(); SW_SVC=(); SW_GROUPS=(); SW_ENV=()

sw_read_bundles() {
  SW_REPO=(); SW_AUR=(); SW_SVC=(); SW_GROUPS=(); SW_ENV=()
  local name file line
  for name in $REIMU_CATALOG; do
    file="$REIMU_DIR/catalog/$name.list"
    [[ -r "$file" ]] || { warn "Bundle not found: $name"; continue; }
    while IFS= read -r line || [[ -n "$line" ]]; do
      line="${line%%#*}"; line="${line//[[:space:]]/}"
      [[ -z "$line" ]] && continue
      case "$line" in
        aur:*) SW_AUR+=("${line#aur:}") ;;
        multilib:*) [[ "$REIMU_MULTILIB" == yes ]] && SW_REPO+=("${line#multilib:}") ;;
        svc:*) SW_SVC+=("${line#svc:}") ;;
        group:*) SW_GROUPS+=("${line#group:}") ;;
        env:*) SW_ENV+=("${line#env:}") ;;
        *) SW_REPO+=("$line") ;;
      esac
    done < "$file"
  done
  local -a extra
  read -r -a extra <<< "$REIMU_EXTRA_PACKAGES"
  SW_REPO+=("${extra[@]}")
  # Theme and icon packages (any desktop).
  if [[ "$REIMU_DESKTOP" != none ]]; then
    local t
    for t in "$(theme_package "${THEMES[$REIMU_THEME]:-}")" "$(theme_package "${ICONS[$REIMU_ICONS]:-}")"; do
      case "$t" in "") ;; aur:*) SW_AUR+=("${t#aur:}") ;; *) SW_REPO+=("$t") ;; esac
    done
  fi
}

# Temporary passwordless sudo for builds inside the chroot.
sw_sudo_nopass_on()  { write_file /etc/sudoers.d/99-reimu-build <<EOF
$REIMU_USER ALL=(ALL) NOPASSWD: ALL
EOF
}
sw_sudo_nopass_off() { run rm -f "$REIMU_MNT/etc/sudoers.d/99-reimu-build"; }

sw_aur_helper() {
  [[ "$REIMU_AUR" == none ]] && return 0
  if [[ -x "$REIMU_MNT/usr/bin/$REIMU_AUR" ]]; then ui_note "$REIMU_AUR is already installed."; return 0; fi
  local pkg="$REIMU_AUR-bin"
  sw_sudo_nopass_on
  RUN_TITLE="Building $REIMU_AUR from the AUR" chr_user_net "$REIMU_USER" "cd /tmp && rm -rf $pkg && git clone --depth 1 https://aur.archlinux.org/$pkg.git && cd $pkg && makepkg -si --noconfirm --needed" \
    || warn "Could not build $REIMU_AUR; AUR packages will be skipped."
  sw_sudo_nopass_off
  if [[ "$REIMU_AUR" == paru ]]; then
    write_file /etc/paru.conf <<'EOF'
[options]
PgpFetch
Devel
Provides
DevelSuffixes = -git -cvs -svn -bzr -darcs -always -hg -fossil
BottomUp
SudoLoop
NewsOnUpgrade
EOF
  fi
}

sw_install_bundles() {
  sw_read_bundles
  (( ${#SW_REPO[@]} + ${#SW_AUR[@]} )) || { desktop_apply_theme; return 0; }
  if (( ${#SW_REPO[@]} )); then
    msg "${#SW_REPO[@]} packages from the repositories"
    chr_pkg "${SW_REPO[@]}"
  fi
  if (( ${#SW_AUR[@]} )); then
    if [[ "$REIMU_AUR" == none ]]; then
      warn "Skipping AUR packages (no helper): ${SW_AUR[*]}"
    else
      msg "${#SW_AUR[@]} packages from the AUR"
      sw_sudo_nopass_on
      RUN_TITLE="Building ${#SW_AUR[@]} AUR packages" chr_user_net "$REIMU_USER" "$REIMU_AUR -S --noconfirm --needed --skipreview ${SW_AUR[*]}" \
        || warn "Some AUR packages failed to build; see the log."
      sw_sudo_nopass_off
    fi
  fi
  local g e
  for g in "${SW_GROUPS[@]}"; do chr usermod -aG "$g" "$REIMU_USER"; done
  for e in "${SW_ENV[@]}"; do grep -qsxF "$e" "$REIMU_MNT/etc/environment" || append_file /etc/environment "$e"; done
  (( ${#SW_SVC[@]} )) && chr_enable "${SW_SVC[@]}"
  desktop_apply_theme
  return 0
}

# Human list of what a bundle installs (for the wizard).
sw_bundle_contents() {
  local file="$REIMU_DIR/catalog/$1.list" line out=""
  [[ -r "$file" ]] || return 0
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%%#*}"; line="${line//[[:space:]]/}"
    [[ -z "$line" ]] && continue
    case "$line" in
      svc:*|group:*|env:*) continue ;;
      aur:*) out+=" ${line#aur:} (AUR)" ;;
      multilib:*) out+=" ${line#multilib:}" ;;
      *) out+=" $line" ;;
    esac
  done < "$file"
  printf '%s' "${out# }"
}

# Sanae: the software store for the terminal. One static binary
# from its latest release, plus the two tools it reads pacman through.
SANAE_URL="https://github.com/Chidaruma696/Sanae/releases/latest/download/sanae-x86_64-linux"
sw_sanae() {
  [[ "$REIMU_SANAE" == yes ]] || return 0
  msg "Sanae"
  chr_pkg expac pacman-contrib archlinux-appstream-data wget
  if (( DRY_RUN )); then
    printf '%s  $ wget -c --tries=5 -O %s/usr/local/bin/sanae %s && chmod 755 …%s\n' "$C_DIM" "$REIMU_MNT" "$SANAE_URL" "$C_RESET"
    return 0
  fi
  net_wait
  local tmp="$REIMU_MNT/usr/local/bin/sanae.part"
  mkdir -p "$REIMU_MNT/usr/local/bin"
  if RUN_TITLE="Downloading Sanae" run_net fetch "$SANAE_URL" "$tmp" && [[ "$(head -c 4 "$tmp" 2>/dev/null)" == $'\x7fELF' ]]; then
    mv -f "$tmp" "$REIMU_MNT/usr/local/bin/sanae"
    chmod 755 "$REIMU_MNT/usr/local/bin/sanae"
    ok "Sanae installed: run 'sanae' after the first login."
  else
    rm -f "$tmp"
    warn "Could not download Sanae; install it later from github.com/Chidaruma696/Sanae."
  fi
  return 0
}
