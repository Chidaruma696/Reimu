# shellcheck shell=bash
# Reimu · help: what each question means, written for someone installing Arch
# for the first time. Some texts look at the detected hardware.

help_ram_gib() { printf '%d' $(( (DETECT_RAM_MIB + 512) / 1024 )); }

help_disk_mode() {
  cat <<'EOF'
Automatic erases the whole disk and creates the partitions for you. It is the
right choice for a machine that will run only Arch Linux.
Manual lets you keep other systems or partitions: you create the partitions
with cfdisk, then tell Reimu which one is which.
EOF
}

help_disk() {
  cat <<'EOF'
The disk that will hold Arch Linux. NVMe drives are usually the fast SSD
inside laptops; sda/sdb are SATA drives or USB sticks. Do not pick the USB
you booted from.
EOF
}

help_fs() {
  cat <<'EOF'
The filesystem is how files are organized on the disk.
• btrfs can take snapshots: a photo of the system you can go back to if an
  update breaks something. It also compresses files, so you gain space. It is
  the best choice for a desktop or laptop.
• ext4 is the classic, simple and proven. No snapshots, no compression.
• xfs is very fast with huge files (video, databases) but cannot shrink.
EOF
}

help_snapshots() {
  cat <<'EOF'
Snapshots are automatic restore points. Reimu takes one before every pacman
update and keeps a few hours and days of history. If something breaks, you
roll back in seconds. With GRUB you can even boot straight into a snapshot.
It costs almost nothing while your files stay the same.
EOF
}

help_encrypt() {
  local tail=""
  (( DETECT_LAPTOP )) && tail=$'\nThis is a laptop: encryption is strongly recommended. Laptops get lost.'
  cat <<EOF
Encryption (LUKS) scrambles the whole disk so nobody can read your files
without your password, even if they take the drive out. You will type that
password at every boot, before the system starts. If you forget it, the
data is gone for good. No noticeable slowdown on modern machines.$tail
EOF
}

help_swap() {
  local gib; gib="$(help_ram_gib)"
  cat <<EOF
Swap is spare memory on disk, used when RAM runs out. Your machine has ${gib} GiB
of RAM.
• zram compresses memory in RAM itself: fast, no disk space, ideal for most
  people. Hibernation (suspend to disk) is not possible with zram alone.
• A swap partition is required if you want to hibernate: make it at least
  the size of your RAM (${gib} GiB).
• A swap file is like a partition but easier to resize later.
• None: fine with lots of RAM, risky under 8 GiB.
EOF
}

help_bootloader() {
  local note=""
  if [[ "$DETECT_FIRMWARE" == bios ]]; then
    note=$'\nThis machine booted in BIOS (legacy) mode, so systemd-boot cannot be offered.\nIn VirtualBox turn on "Enable EFI" under System; in QEMU use OVMF; on a real\nPC look for UEFI mode in the firmware setup.'
  fi
  cat <<EOF
The bootloader is the tiny program that starts Linux when you turn on the
machine.
• systemd-boot is simple and fast, with a plain menu. UEFI only.
• GRUB shows a full menu, can boot other systems (Windows) and can boot into
  btrfs snapshots. Works on UEFI and old BIOS machines.
• Limine is modern and tiny, with a clean menu, and works on both UEFI and
  BIOS.${note}
EOF
}

help_kernels() {
  cat <<'EOF'
The kernel is the core of Linux. "linux" is the normal one. "linux-lts" is
older but supported longer: a safe second option if the newest one has a
problem with your hardware. "zen" is tuned for responsiveness on desktops;
"hardened" trades some speed for security. You can install several and pick
one at boot.
EOF
}

help_user() {
  cat <<'EOF'
Your everyday account. Lowercase letters, digits, dash or underscore, no
spaces. It gets administrator rights through sudo (you type your password to
do system changes).
EOF
}

help_shell() {
  cat <<'EOF'
The shell is the program behind the terminal. bash is the default everywhere.
zsh adds smarter completion and is what macOS uses. fish is the friendliest:
colors and suggestions out of the box, but its syntax is not bash compatible.
EOF
}

help_sudo() {
  cat <<'EOF'
sudo is the standard tool to run commands as administrator; every guide on
the internet uses it. doas does the same with far less code; Reimu adds a
"sudo" alias so guides still work.
EOF
}

help_root() {
  cat <<'EOF'
root is the all-powerful account. Most people never log in as root: they use
sudo from their own account. Locking root (recommended) removes one way in.
EOF
}

help_network() {
  cat <<'EOF'
• NetworkManager handles Wi-Fi, wired, VPNs and shows a network icon in every
  desktop. The right choice for laptops and desktops.
• iwd is a lighter Wi-Fi daemon controlled from the terminal.
• systemd-networkd is for wired servers, no Wi-Fi tools.
EOF
}

help_extras() {
  cat <<'EOF'
• Bluetooth: headphones, mice, controllers.
• Printing: CUPS, the print system, with PDF printing.
• Firewall: blocks incoming connections. Harmless on a desktop, good on a
  laptop that joins public Wi-Fi.
• SSH server: lets you log in to this machine from another one.
• multilib: 32-bit libraries. Needed for Steam and Wine (games).
EOF
}

help_power() {
  cat <<'EOF'
Laptop power management. power-profiles-daemon integrates with GNOME and KDE
(the power mode switch in the menu). TLP squeezes more battery on its own but
does not talk to the desktop. Pick one, never both.
EOF
}

help_desktop() {
  cat <<'EOF'
The desktop environment is what you see: panels, menus, windows, settings.
GNOME and KDE Plasma are the two big complete desktops. XFCE, MATE, LXQt are
lighter and simpler. Hyprland, Sway, niri and i3 are "tiling" managers for
keyboard-driven power users: fast, but you configure everything yourself.
None gives you a terminal only.
EOF
}

help_dm() {
  cat <<'EOF'
The login manager is the screen where you type your password. "Auto" picks the
one that matches your desktop. "None" means you log in on a text console and
start the desktop by hand.
EOF
}

help_gpu() {
  local found="$DETECT_GPU"
  [[ "$DETECT_VIRT" != none ]] && found="a virtual machine ($DETECT_VIRT)"
  cat <<EOF
The graphics driver makes the desktop smooth and games fast. Reimu detected:
${found}. Intel and AMD drivers are open source and just work. NVIDIA needs
its own driver: "open kernel modules" for cards from 2018 on (GTX 16xx, RTX),
"proprietary" for older ones, "nouveau" is the free but slow alternative.
EOF
}

help_aur() {
  cat <<'EOF'
The AUR is the community repository with thousands of extra programs (Spotify,
Google Chrome, fonts…). An AUR helper installs them like normal packages.
paru and yay are equivalent; paru is the more modern one.
EOF
}

help_bundles() {
  cat <<'EOF'
Ready-made sets of programs by theme. Pick any; each one installs a handful of
well-known apps. You can always add or remove programs later.
EOF
}

help_locale() {
  cat <<'EOF'
The locale is the language of menus, dates and numbers. Extra locales let
programs switch language later without reinstalling. The keyboard layout is
for the text console; desktops have their own setting that Reimu also sets.
EOF
}

help_mirrors() {
  cat <<'EOF'
Mirrors are the servers packages are downloaded from. Picking your country
or a neighbour makes downloads much faster. Reimu keeps the list fresh with
a weekly timer.
EOF
}

help_hostname() {
  cat <<'EOF'
The name of this machine on the network (what you see in the terminal
prompt). Letters, digits and dashes.
EOF
}

help_timezone() {
  cat <<'EOF'
Your time zone as Region/City. Type part of a city to search.
EOF
}

help_repos() {
  cat <<'EOF'
Repositories are the sources pacman installs from. Arch's own are always on.
• multilib: official 32-bit libraries; Steam, Wine and many games need it.
• Chaotic-AUR: a community repository with thousands of AUR programs already
  compiled (browsers, editors, games, fonts…) so you install them in seconds
  instead of building them. Widely used; maintained by Arch community members.
EOF
}

help_custom_repos() {
  cat <<'EOF'
Add any other pacman repository as name=URL, separated by spaces. The URL is
the "Server =" line from that repository's instructions and may contain
$arch. Reimu adds them with signatures optional and fully trusted, so only add
repositories you trust.
EOF
}

help_theme() {
  cat <<'EOF'
A theme changes how windows, buttons and menus look; icons change the pictures
in menus and file managers. Reimu installs the packages and sets them as the
default for your user, so XFCE already looks like that at the first login.
"AUR" themes need the AUR helper from the Software section (paru or yay).
This is optional: say No and XFCE stays exactly as it ships.
EOF
}

help_sanae() {
  cat <<'EOF'
Sanae is a software store that runs in the terminal, made by the same author
as Reimu: browse apps by shelf (Internet, Games, Office…) with human names and
popularity, search the repositories and the AUR together, keep the system
updated with the Arch news in front of you, and apply "recipes" that install
and configure things in one go (Docker, QEMU, fonts, Japanese input, XFCE
themes). It is experimental. It is a single binary in /usr/local/bin/sanae;
remove it with: sudo rm /usr/local/bin/sanae
EOF
}
