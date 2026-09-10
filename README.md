[🇪🇸 Español](README.es.md)

<div align="center">
  <br/>

# Reimu

**霊夢 · An Arch Linux installer that asks the right questions and finishes the job.**

<br/>

![Arch Linux](https://img.shields.io/badge/arch%20linux-live%20ISO-1793d1?style=for-the-badge&logo=archlinux&logoColor=white)
![Bash](https://img.shields.io/badge/bash-5-4eaa25?style=for-the-badge&logo=gnubash&logoColor=white)
![Dependencies](https://img.shields.io/badge/dependencies-0-2b2140?style=for-the-badge)
![License MIT](https://img.shields.io/badge/license-MIT-1b150d?style=for-the-badge)
![Experimental](https://img.shields.io/badge/status-experimental-d20f39?style=for-the-badge)

<br/>

*One pass from the live ISO to a finished desktop · every question explained · survives network cuts · replayable config files*

</div>

---

> [!IMPORTANT]
> **Experimental.** Reimu formats disks. Read the summary it shows before typing `YES`, and try it in a virtual machine first. It is young software; the dry-run mode exists so you can see every command before trusting it.

<br/>

## 🗺️ What it is

Reimu is a Bash installer for Arch Linux that runs from the official live ISO. It asks what matters (which disk, which filesystem, swap or not, which bootloader, which desktop), installs the base system, enters the new system with `arch-chroot` and keeps going until there is a working desktop with the things every fresh Arch ends up needing anyway: `xdg-user-dirs`, PipeWire, fonts, NetworkManager, zram, snapshots, an AUR helper.

It is built for someone installing Arch for the first time: every question comes with a short explanation of what the choice means for their machine (why btrfs over ext4, what LUKS implies, how much swap makes sense with the RAM it detected), lists to pick from instead of things to type, and a spinner instead of a wall of pacman output. Under the hood every command is logged, downloads retry when the connection drops, and an interrupted installation can be resumed with `reimu --resume`.

It exists because [archinstall](https://github.com/archlinux/archinstall) stops at the base system and leaves the user folders, the audio stack and the AUR for later, and because [aui](https://github.com/helmuthdu/aui), which did finish the job, stopped being maintained in 2022 and predates systemd-boot, btrfs snapshots and Wayland.

| 🧭 Asks | ⚙️ Does | 📝 Remembers |
| --- | --- | --- |
| Filesystem, swap, encryption, bootloader, kernels, desktop, drivers, software bundles. Every choice, every time, with a sensible default preselected. | Partitions, LUKS2, btrfs subvolumes, snapper, zram, systemd-boot or GRUB, users, network, desktop, GPU drivers, AUR helper, software bundles. | Saves a configuration file you can replay on the next machine with `reimu --config`. Passwords never touch that file. |

<br/>

## 🚀 Use it

Boot the [Arch Linux ISO](https://archlinux.org/download/), connect to the network (`iwctl` for Wi-Fi) and run:

```sh
pacman -Sy git
git clone https://github.com/Chidaruma696/Reimu
cd Reimu && ./reimu
```

Without git:

```sh
curl -L https://github.com/Chidaruma696/Reimu/tarball/main | tar xz
cd Chidaruma696-Reimu-*/ && ./reimu
```

Reimu opens a Calamares-style layout in tmux: the questions and progress on the left, the list of phases at the top right and the live log at the bottom right (`--no-tmux` for a single pane). The interface itself uses [gum](https://github.com/charmbracelet/gum) 0.17.0, fetched as a static binary from its release (gum 2.0, the one in the repositories, has a broken space bar in lists: [gum#1143](https://github.com/charmbracelet/gum/issues/1143)), with the repository package and then plain prompts as fallbacks. The first run walks through every question with an explanation box above it. After that you land on a menu with every single setting and its current value: change one, save the configuration, or start.

```
Everything Reimu will do · pick a line to change it
  Keyboard layout              la-latin1
  Language                     es_MX.UTF-8
  Time zone                    America/Mexico_City
  Disk                         auto · /dev/nvme0n1
  Filesystem                   btrfs
  Snapshots                    yes
  Encryption                   no
  Swap                         zram 4096
  Bootloader                   systemd-boot
  Kernels                      linux linux-lts
  …
  Extra repositories           multilib chaotic-aur
  Desktop                      xfce
  Software bundles             development internet fonts japanese
  💾 Save configuration to a file
  🚀 Start the installation
```

When a command fails during the installation (a mirror that dropped, a package that was renamed), Reimu does not throw everything away: it shows the last lines of the log and asks whether to retry that command, skip it, open a shell to look around, or abort. Package sets that fail as a batch are retried one by one, and anything that still cannot be installed is listed at the end.

### From a configuration file

```sh
./reimu --config reimu.conf              # asks only for the passwords
./reimu --config https://…/reimu.conf    # same, from a URL
REIMU_USER_PASSWORD=… ./reimu --config reimu.conf --yes   # fully unattended
./reimu --config reimu.conf --dry-run --yes               # print every command, touch nothing
./reimu --save my.conf                    # run the wizard, save, do not install
./reimu --resume                          # continue an interrupted installation
```

See [`reimu.conf.example`](reimu.conf.example) for every key with its options. Unattended runs take passwords from `REIMU_USER_PASSWORD`, `REIMU_ROOT_PASSWORD` and `REIMU_LUKS_PASSWORD`.

<br/>

## 🧩 What you get

| Area | Options |
| --- | --- |
| **Disk** | Automatic (wipe a disk: EFI 1 GiB + optional swap + root) or manual (you partition with `cfdisk`, Reimu asks which partition is which, `/home` can be kept). |
| **Filesystem** | btrfs with `@`, `@home`, `@log`, `@pkg`, `@snapshots` subvolumes and zstd compression · ext4 · xfs. |
| **Encryption** | LUKS2 on root, unlocked by the systemd initramfs (`sd-encrypt`). |
| **Swap** | zram (sized from your RAM) · partition · file (btrfs aware) · none. |
| **Snapshots** | snapper + snap-pac on btrfs, a snapshot before every pacman transaction and one right after the install. With GRUB, `grub-btrfs` adds them to the boot menu. |
| **Boot** | systemd-boot (UEFI), GRUB (UEFI and BIOS) or Limine (UEFI and BIOS), one entry per kernel plus fallback. Kernels: linux, lts, zen, hardened, any mix. Microcode handled by mkinitcpio. |
| **Users** | One user in `wheel` with bash, zsh or fish; sudo or doas; root locked unless you want it. `xdg-user-dirs` generated in the system language. |
| **Network** | NetworkManager · iwd + systemd-networkd · systemd-networkd. Optional sshd, firewalld or ufw, Bluetooth, CUPS. |
| **Repositories** | multilib, [Chaotic-AUR](https://aur.chaotic.cx/) (prebuilt AUR packages, keyring and mirrorlist set up for you), and any custom repository as `name=URL`. |
| **Laptops** | power-profiles-daemon (integrates with GNOME and KDE) or TLP, chosen when a battery is detected. |
| **Desktop** | GNOME, KDE Plasma, XFCE, Cinnamon, MATE, Budgie, LXQt, COSMIC, Deepin, Hyprland, Sway, niri, i3, or none. Login manager picked to match or chosen by you. PipeWire, Noto fonts (CJK and emoji included), portals, GVFS and Flatpak come with every desktop. |
| **Graphics** | Detected or chosen: Intel, AMD, NVIDIA open modules, NVIDIA proprietary, nouveau, or guest tools for VirtualBox, VMware, QEMU/KVM and Hyper-V. NVIDIA gets its pacman hook. |
| **AUR** | paru or yay, built inside the chroot as your user. |
| **Bundles** | development, office, internet, multimedia, graphics, gaming, utilities, fonts, japanese (fcitx5 + mozc), virtualization. The wizard shows exactly which packages each one installs before you pick. Plain text lists in [`catalog/`](catalog), easy to edit. |
| **Housekeeping** | Parallel downloads and color in pacman, `reflector.timer`, `paccache.timer`, `fstrim.timer`, `systemd-timesyncd`, power-profiles-daemon on laptops. |
| **Sanae** | At the end, Reimu offers to install [Sanae](https://github.com/Chidaruma696/Sanae), the software store for the terminal (experimental): one static binary in `/usr/local/bin`, plus `expac`, `pacman-contrib` and the AppStream data it reads. |
| **Themes (XFCE)** | Greybird, Arc, Materia, Orchis, Flat Remix, Skeuos (the Kali look), Dracula, Nordic, Catppuccin, in dark or light, with Papirus, Tela, Flat Remix, elementary, Breeze or Arc icons. Installed and set as your user's default, so the first login already looks like that. |

<br/>

## 🔧 How it works

```
reimu
├── lib/core.sh       logging, run / run_tty / run_quiet, dry-run, chroot helpers, write_file
├── lib/ui.sh         prompts on gum with a pure-bash fallback: text, secret, yes/no, choice, multi-select, menu, search
├── lib/help.sh       the explanations shown before each question
├── lib/state.sh      progress kept on the target disk, so --resume can continue
├── lib/detect.sh     UEFI/BIOS, CPU, GPU, virtualization, laptop, RAM, disks, time zone
├── lib/config.sh     defaults, REIMU_* keys, parse (never source) and save config files, validate
├── lib/wizard.sh     one small question function per setting, the guided run and the menu
├── lib/disk.sh       sgdisk layout, LUKS2, mkfs, btrfs subvolumes, mounts, swap file
├── lib/base.sh       mirrors, pacstrap, fstab, locale, hostname, pacman.conf, zram, initramfs
├── lib/boot.sh       systemd-boot entries or GRUB config and install
├── lib/system.sh     users, sudo/doas, network, sshd, firewall, bluetooth, cups, snapper
├── lib/desktop.sh    desktop package sets, login managers, GPU drivers
├── lib/software.sh   AUR helper build, catalog bundles
├── lib/apply.sh      summary, YES confirmation, the phases in order, finish
└── catalog/*.list    software bundles
```

Every command goes through `run`, which logs it to `/var/log/reimu.log`, shows a spinner while it runs and, with `--dry-run`, prints it instead of executing it. Anything that downloads goes through `run_net`: if the connection drops it waits for it to come back and retries up to five times. Passwords go through `chpasswd` and `cryptsetup` on standard input and are never logged. The configuration file is parsed line by line, so a file fetched from a URL cannot execute anything.

The sequence is: mirrors → disk → pacstrap → fstab and swap file → locale, time, hostname, pacman → initramfs → bootloader → users → network → services → snapshots → desktop and GPU → AUR helper → bundles → final initramfs and snapshot → unmount. Everything after pacstrap runs inside `arch-chroot /mnt`, so there is no second phase after reboot. Each phase is recorded on the target disk once it finishes; if the installation dies halfway (network, power, a typo in a bundle), `reimu --resume` mounts the disk again, asks for the encryption password if there is one, and picks up at the first phase that did not finish.

### Bundles

A bundle is a text file in `catalog/`. The first line is its description; then one entry per line:

```
# Development: editors, containers, languages, terminal tools
neovim                   # a package from the repositories
aur:visual-studio-code-bin
multilib:lib32-gamemode  # only when multilib is enabled
svc:docker.service       # a unit to enable
group:docker             # add the user to this group
env:GTK_IM_MODULE=fcitx  # a line for /etc/environment
```

Drop a new file in the folder and it shows up in the wizard.

<br/>

## 🧪 Testing

```sh
shellcheck -x -s bash reimu lib/*.sh
REIMU_FIRMWARE=uefi REIMU_USER_PASSWORD=x ./reimu --config reimu.conf.example --dry-run --yes
```

The dry run works on any machine with Bash 5 and shows the exact commands a real run would execute. CI runs ShellCheck and two dry runs (UEFI + systemd-boot + btrfs, and BIOS + GRUB + ext4 + LUKS) on every push.

<br/>

## 🗺️ Roadmap

- Hibernation with a swap partition or file (`resume=` on the kernel line).
- Booting into snapshots with Limine (limine-snapper-sync).
- LVM on LUKS and dual-boot aware manual layouts.
- Spanish and Japanese interface.

<br/>

## ⚖️ License

MIT. Reimu is not affiliated with Arch Linux. The name comes from Reimu Hakurei of Touhou Project, who resolves every incident.

<div align="center">
  <br/>

霊夢 · Resolves the incident.

</div>
