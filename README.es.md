[🇬🇧 English](README.md)

<div align="center">
  <br/>

# Reimu

**霊夢 · Un instalador de Arch Linux que hace las preguntas correctas y termina el trabajo.**

<br/>

![Arch Linux](https://img.shields.io/badge/arch%20linux-ISO%20live-1793d1?style=for-the-badge&logo=archlinux&logoColor=white)
![Bash](https://img.shields.io/badge/bash-5-4eaa25?style=for-the-badge&logo=gnubash&logoColor=white)
![Dependencias](https://img.shields.io/badge/dependencias-0-2b2140?style=for-the-badge)
![Licencia MIT](https://img.shields.io/badge/licencia-MIT-1b150d?style=for-the-badge)

<br/>

*Una sola pasada de la ISO al escritorio terminado · interactivo o desde un archivo de configuración · sin instalar nada antes*

</div>

---

> [!IMPORTANT]
> Reimu formatea discos. Lee el resumen que muestra antes de escribir `YES`, y pruébalo primero en una máquina virtual. Es software joven; el modo de simulación existe para que veas cada comando antes de confiar en él.

<br/>

## 🗺️ Qué es

Reimu es un instalador en Bash para Arch Linux que corre desde la ISO oficial. Pregunta lo que importa (qué disco, qué sistema de archivos, si quieres swap, qué bootloader, qué escritorio), instala el sistema base, entra al sistema nuevo con `arch-chroot` y sigue hasta dejar un escritorio funcionando con todo lo que un Arch recién instalado termina necesitando de todos modos: `xdg-user-dirs`, PipeWire, fuentes, NetworkManager, zram, snapshots, un ayudante de AUR.

Existe porque [archinstall](https://github.com/archlinux/archinstall) se detiene en el sistema base y deja las carpetas de usuario, el audio y el AUR para después, y porque [aui](https://github.com/helmuthdu/aui), que sí terminaba el trabajo, dejó de mantenerse en 2022 y es anterior a systemd-boot, los snapshots de btrfs y Wayland.

| 🧭 Pregunta | ⚙️ Hace | 📝 Recuerda |
| --- | --- | --- |
| Sistema de archivos, swap, cifrado, bootloader, kernels, escritorio, drivers, paquetes de software. Cada decisión, cada vez, con un valor razonable preseleccionado. | Particiones, LUKS2, subvolúmenes btrfs, snapper, zram, systemd-boot o GRUB, usuarios, red, escritorio, drivers de GPU, ayudante de AUR, paquetes de software. | Guarda un archivo de configuración que puedes repetir en la siguiente máquina con `reimu --config`. Las contraseñas nunca se guardan ahí. |

<br/>

## 🚀 Úsalo

Arranca la [ISO de Arch Linux](https://archlinux.org/download/), conéctate a la red (`iwctl` para Wi-Fi) y ejecuta:

```sh
pacman -Sy git
git clone https://github.com/Chidaruma696/Reimu
cd Reimu && ./reimu
```

Sin git:

```sh
curl -L https://github.com/Chidaruma696/Reimu/tarball/main | tar xz
cd Chidaruma696-Reimu-*/ && ./reimu
```

La primera vez recorre todas las secciones. Después caes en un menú que muestra lo que se va a instalar; cambia lo que quieras, guarda la configuración o arranca.

```
Reimu · what will be installed
────────────────────────────────────────────────────────────
   1) Language, keyboard, time     la-latin1 · es_MX.UTF-8 · America/Mexico_City · hakurei
   2) Disk                         /dev/nvme0n1 wipe · btrfs · snapshots · swap zram
   3) Boot                         systemd-boot · linux linux-lts
   4) Users                        reimu (zsh, sudo)
   5) Network and services         networkmanager · cups · firewalld · multilib
   6) Desktop                      xfce · gpu auto · win2k
   7) Software                     aur paru · development internet multimedia fonts japanese
   8) Save configuration to a file
   9) Start the installation
  10) Quit
```

La interfaz está en inglés por ahora; la versión en español está en la hoja de ruta.

### Desde un archivo de configuración

```sh
./reimu --config reimu.conf              # solo pregunta las contraseñas
./reimu --config https://…/reimu.conf    # lo mismo, desde una URL
REIMU_USER_PASSWORD=… ./reimu --config reimu.conf --yes   # desatendido por completo
./reimu --config reimu.conf --dry-run --yes               # imprime cada comando, no toca nada
./reimu --save mi.conf                    # recorre el asistente, guarda y no instala
```

En [`reimu.conf.example`](reimu.conf.example) están todas las claves con sus opciones. En modo desatendido las contraseñas vienen de `REIMU_USER_PASSWORD`, `REIMU_ROOT_PASSWORD` y `REIMU_LUKS_PASSWORD`.

<br/>

## 🧩 Qué obtienes

| Área | Opciones |
| --- | --- |
| **Disco** | Automático (borra un disco: EFI de 1 GiB + swap opcional + raíz) o manual (particionas con `cfdisk`, Reimu pregunta cuál es cuál y `/home` se puede conservar). |
| **Sistema de archivos** | btrfs con subvolúmenes `@`, `@home`, `@log`, `@pkg`, `@snapshots` y compresión zstd · ext4 · xfs. |
| **Cifrado** | LUKS2 en la raíz, desbloqueado por el initramfs de systemd (`sd-encrypt`). |
| **Swap** | zram (dimensionado según tu RAM) · partición · archivo (compatible con btrfs) · ninguno. |
| **Snapshots** | snapper + snap-pac sobre btrfs, un snapshot antes de cada transacción de pacman y uno justo al terminar la instalación. Con GRUB, `grub-btrfs` los añade al menú de arranque. |
| **Arranque** | systemd-boot (UEFI) o GRUB (UEFI y BIOS), una entrada por kernel más la de respaldo. Kernels: linux, lts, zen, hardened, cualquier mezcla. El microcódigo lo maneja mkinitcpio. |
| **Usuarios** | Un usuario en `wheel` con bash, zsh o fish; sudo o doas; root bloqueado salvo que lo quieras. `xdg-user-dirs` generado en el idioma del sistema. |
| **Red** | NetworkManager · iwd + systemd-networkd · systemd-networkd. Opcionales: sshd, firewalld o ufw, Bluetooth, CUPS, multilib. |
| **Escritorio** | GNOME, KDE Plasma, XFCE, Cinnamon, MATE, Budgie, LXQt, Hyprland, Sway, niri, i3, o ninguno. Gestor de inicio de sesión a juego o el que elijas. PipeWire, fuentes Noto (con CJK y emoji), portales, GVFS y Flatpak vienen con todos los escritorios. |
| **Gráficos** | Detectado o elegido: Intel, AMD, NVIDIA módulos abiertos, NVIDIA propietario, nouveau, o herramientas de invitado para VirtualBox, VMware, QEMU/KVM e Hyper-V. NVIDIA recibe su hook de pacman. |
| **AUR** | paru o yay, compilado dentro del chroot como tu usuario. |
| **Paquetes** | development, office, internet, multimedia, graphics, gaming, utilities, fonts, japanese (fcitx5 + mozc), virtualization. Listas de texto plano en [`catalog/`](catalog), fáciles de editar. |
| **Mantenimiento** | Descargas en paralelo y color en pacman, `reflector.timer`, `paccache.timer`, `fstrim.timer`, `systemd-timesyncd`, power-profiles-daemon en portátiles. |
| **Extra para XFCE** | Opcionalmente descarga [Win2k Undead](https://github.com/Chidaruma696/Win2k_undead) en tu home para el aspecto de Windows 2000. |

<br/>

## 🔧 Cómo funciona

```
reimu
├── lib/core.sh       registro, run / run_tty / run_quiet, simulación, ayudantes de chroot, write_file
├── lib/ui.sh         preguntas en Bash puro: texto, secreto, sí/no, opción, selección múltiple, menú
├── lib/detect.sh     UEFI/BIOS, CPU, GPU, virtualización, portátil, RAM, discos, zona horaria
├── lib/config.sh     valores por defecto, claves REIMU_*, leer (nunca ejecutar) y guardar configuraciones, validar
├── lib/wizard.sh     las secciones y el menú principal
├── lib/disk.sh       esquema con sgdisk, LUKS2, mkfs, subvolúmenes btrfs, montajes, archivo de swap
├── lib/base.sh       mirrors, pacstrap, fstab, locale, hostname, pacman.conf, zram, initramfs
├── lib/boot.sh       entradas de systemd-boot o configuración e instalación de GRUB
├── lib/system.sh     usuarios, sudo/doas, red, sshd, firewall, bluetooth, cups, snapper
├── lib/desktop.sh    conjuntos de paquetes por escritorio, gestores de sesión, drivers de GPU
├── lib/software.sh   compilación del ayudante de AUR, paquetes del catálogo
├── lib/apply.sh      resumen, confirmación con YES, las fases en orden, cierre
└── catalog/*.list    paquetes de software
```

Todos los comandos pasan por `run`, que los registra en `/var/log/reimu.log` y, con `--dry-run`, los imprime en lugar de ejecutarlos. Las contraseñas van a `chpasswd` y `cryptsetup` por la entrada estándar y nunca se registran. El archivo de configuración se lee línea por línea, así que un archivo descargado de una URL no puede ejecutar nada.

La secuencia es: mirrors → disco → pacstrap → fstab y archivo de swap → locale, hora, hostname, pacman → initramfs → bootloader → usuarios → red → servicios → snapshots → escritorio y GPU → ayudante de AUR → paquetes → initramfs y snapshot finales → desmontar. Todo lo posterior a pacstrap corre dentro de `arch-chroot /mnt`, así que no hay una segunda fase tras reiniciar.

### Paquetes de software

Un paquete es un archivo de texto en `catalog/`. La primera línea es su descripción; después, una entrada por línea:

```
# Development: editors, containers, languages, terminal tools
neovim                   # un paquete de los repositorios
aur:visual-studio-code-bin
multilib:lib32-gamemode  # solo si multilib está activo
svc:docker.service       # una unidad a activar
group:docker             # añadir al usuario a este grupo
env:GTK_IM_MODULE=fcitx  # una línea para /etc/environment
```

Deja un archivo nuevo en la carpeta y aparece en el asistente.

<br/>

## 🧪 Pruebas

```sh
shellcheck -x -s bash reimu lib/*.sh
REIMU_FIRMWARE=uefi REIMU_USER_PASSWORD=x ./reimu --config reimu.conf.example --dry-run --yes
```

La simulación funciona en cualquier máquina con Bash 5 y muestra los comandos exactos que ejecutaría una instalación real. La CI corre ShellCheck y dos simulaciones (UEFI + systemd-boot + btrfs, y BIOS + GRUB + ext4 + LUKS) en cada push.

<br/>

## 🗺️ Hoja de ruta

- Hibernación con partición o archivo de swap (`resume=` en la línea del kernel).
- Limine como tercer bootloader y arranque desde snapshots sin GRUB.
- LVM sobre LUKS y esquemas manuales conscientes del arranque dual.
- Interfaz en español y japonés.

<br/>

## ⚖️ Licencia

MIT. Reimu no está afiliado a Arch Linux. El nombre viene de Reimu Hakurei, de Touhou Project, la que resuelve todos los incidentes.

<div align="center">
  <br/>

霊夢 · Resuelve el incidente.

</div>
