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
![Experimental](https://img.shields.io/badge/estado-experimental-d20f39?style=for-the-badge)

<br/>

*Una sola pasada de la ISO al escritorio terminado · cada pregunta explicada · aguanta cortes de internet · configuraciones repetibles*

</div>

---

> [!IMPORTANT]
> **Experimental.** Reimu formatea discos. Lee el resumen que muestra antes de escribir `YES`, y pruébalo primero en una máquina virtual. Es software joven; el modo de simulación existe para que veas cada comando antes de confiar en él.

<br/>

## 🗺️ Qué es

Reimu es un instalador en Bash para Arch Linux que corre desde la ISO oficial. Pregunta lo que importa (qué disco, qué sistema de archivos, si quieres swap, qué bootloader, qué escritorio), instala el sistema base, entra al sistema nuevo con `arch-chroot` y sigue hasta dejar un escritorio funcionando con todo lo que un Arch recién instalado termina necesitando de todos modos: `xdg-user-dirs`, PipeWire, fuentes, NetworkManager, zram, snapshots, un ayudante de AUR.

Está pensado para quien instala Arch por primera vez: cada pregunta lleva una explicación corta de lo que la decisión implica en su equipo (por qué btrfs frente a ext4, qué supone LUKS, cuánto swap tiene sentido con la RAM detectada), listas para elegir en vez de cosas que escribir, y un indicador de progreso en lugar de una pared de texto de pacman. Por debajo, cada comando queda registrado, las descargas reintentan cuando se cae la conexión y una instalación interrumpida se retoma con `reimu --resume`.

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

Reimu abre una disposición tipo Calamares en tmux: las preguntas y el progreso a la izquierda, la lista de fases arriba a la derecha y el log en vivo abajo a la derecha (`--no-tmux` para un solo panel). La interfaz usa [gum](https://github.com/charmbracelet/gum), descargado de los repositorios de Arch o directamente de su release si la base de datos de paquetes de la ISO está desactualizada, con preguntas de texto plano como último recurso. La primera vez recorre todas las preguntas con un cuadro de explicación encima de cada una. Después caes en un menú con cada ajuste y su valor actual: cambia uno solo, guarda la configuración o arranca.

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

Cuando un comando falla durante la instalación (un mirror que se cayó, un paquete que cambió de nombre), Reimu no tira todo por la borda: muestra las últimas líneas del log y pregunta si reintentar ese comando, omitirlo, abrir una shell para mirar, o abortar. Los conjuntos de paquetes que fallan en bloque se reintentan uno por uno, y lo que aun así no se pudo instalar se lista al final.

La interfaz está en inglés por ahora; la versión en español está en la hoja de ruta.

### Desde un archivo de configuración

```sh
./reimu --config reimu.conf              # solo pregunta las contraseñas
./reimu --config https://…/reimu.conf    # lo mismo, desde una URL
REIMU_USER_PASSWORD=… ./reimu --config reimu.conf --yes   # desatendido por completo
./reimu --config reimu.conf --dry-run --yes               # imprime cada comando, no toca nada
./reimu --save mi.conf                    # recorre el asistente, guarda y no instala
./reimu --resume                          # continúa una instalación interrumpida
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
| **Arranque** | systemd-boot (UEFI), GRUB (UEFI y BIOS) o Limine (UEFI y BIOS), una entrada por kernel más la de respaldo. Kernels: linux, lts, zen, hardened, cualquier mezcla. El microcódigo lo maneja mkinitcpio. |
| **Usuarios** | Un usuario en `wheel` con bash, zsh o fish; sudo o doas; root bloqueado salvo que lo quieras. `xdg-user-dirs` generado en el idioma del sistema. |
| **Red** | NetworkManager · iwd + systemd-networkd · systemd-networkd. Opcionales: sshd, firewalld o ufw, Bluetooth, CUPS. |
| **Repositorios** | multilib, [Chaotic-AUR](https://aur.chaotic.cx/) (paquetes del AUR ya compilados, con su keyring y mirrorlist configurados), y cualquier repositorio propio como `nombre=URL`. |
| **Portátiles** | power-profiles-daemon (se integra con GNOME y KDE) o TLP, elegido cuando detecta batería. |
| **Escritorio** | GNOME, KDE Plasma, XFCE, Cinnamon, MATE, Budgie, LXQt, COSMIC, Deepin, Hyprland, Sway, niri, i3, o ninguno. Gestor de inicio de sesión a juego o el que elijas. PipeWire, fuentes Noto (con CJK y emoji), portales, GVFS y Flatpak vienen con todos los escritorios. |
| **Gráficos** | Detectado o elegido: Intel, AMD, NVIDIA módulos abiertos, NVIDIA propietario, nouveau, o herramientas de invitado para VirtualBox, VMware, QEMU/KVM e Hyper-V. NVIDIA recibe su hook de pacman. |
| **AUR** | paru o yay, compilado dentro del chroot como tu usuario. |
| **Paquetes** | development, office, internet, multimedia, graphics, gaming, utilities, fonts, japanese (fcitx5 + mozc), virtualization. El asistente muestra exactamente qué paquetes instala cada uno antes de elegir. Listas de texto plano en [`catalog/`](catalog), fáciles de editar. |
| **Mantenimiento** | Descargas en paralelo y color en pacman, `reflector.timer`, `paccache.timer`, `fstrim.timer`, `systemd-timesyncd`, power-profiles-daemon en portátiles. |
| **Sanae** | Al final, Reimu ofrece instalar [Sanae](https://github.com/Chidaruma696/Sanae), la tienda de software para la terminal (experimental): un binario estático en `/usr/local/bin`, más `expac`, `pacman-contrib` y los datos AppStream que lee. |
| **Temas (XFCE)** | Greybird, Arc, Materia, Orchis, Flat Remix, Skeuos (el aspecto de Kali), Dracula, Nordic, Catppuccin, en oscuro o claro, con iconos Papirus, Tela, Flat Remix, elementary, Breeze o Arc. Se instalan y quedan como predeterminados de tu usuario, así que el primer inicio de sesión ya se ve así. |

<br/>

## 🔧 Cómo funciona

```
reimu
├── lib/core.sh       registro, run / run_tty / run_quiet, simulación, ayudantes de chroot, write_file
├── lib/ui.sh         preguntas sobre gum con respaldo en Bash puro: texto, secreto, sí/no, opción, selección múltiple, menú, búsqueda
├── lib/help.sh       las explicaciones que se muestran antes de cada pregunta
├── lib/state.sh      progreso guardado en el disco destino, para que --resume pueda continuar
├── lib/detect.sh     UEFI/BIOS, CPU, GPU, virtualización, portátil, RAM, discos, zona horaria
├── lib/config.sh     valores por defecto, claves REIMU_*, leer (nunca ejecutar) y guardar configuraciones, validar
├── lib/wizard.sh     una función de pregunta por ajuste, el recorrido guiado y el menú
├── lib/disk.sh       esquema con sgdisk, LUKS2, mkfs, subvolúmenes btrfs, montajes, archivo de swap
├── lib/base.sh       mirrors, pacstrap, fstab, locale, hostname, pacman.conf, zram, initramfs
├── lib/boot.sh       entradas de systemd-boot o configuración e instalación de GRUB
├── lib/system.sh     usuarios, sudo/doas, red, sshd, firewall, bluetooth, cups, snapper
├── lib/desktop.sh    conjuntos de paquetes por escritorio, gestores de sesión, drivers de GPU
├── lib/software.sh   compilación del ayudante de AUR, paquetes del catálogo
├── lib/apply.sh      resumen, confirmación con YES, las fases en orden, cierre
└── catalog/*.list    paquetes de software
```

Todos los comandos pasan por `run`, que los registra en `/var/log/reimu.log`, muestra un indicador mientras corren y, con `--dry-run`, los imprime en lugar de ejecutarlos. Todo lo que descarga pasa por `run_net`: si se cae la conexión espera a que vuelva y reintenta hasta cinco veces. Las contraseñas van a `chpasswd` y `cryptsetup` por la entrada estándar y nunca se registran. El archivo de configuración se lee línea por línea, así que un archivo descargado de una URL no puede ejecutar nada.

La secuencia es: mirrors → disco → pacstrap → fstab y archivo de swap → locale, hora, hostname, pacman → initramfs → bootloader → usuarios → red → servicios → snapshots → escritorio y GPU → ayudante de AUR → paquetes → initramfs y snapshot finales → desmontar. Todo lo posterior a pacstrap corre dentro de `arch-chroot /mnt`, así que no hay una segunda fase tras reiniciar. Cada fase queda anotada en el disco destino al terminar; si la instalación muere a medias (red, corriente, un error en un paquete), `reimu --resume` vuelve a montar el disco, pide la contraseña de cifrado si la hay y sigue desde la primera fase que no terminó.

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
- Arranque desde snapshots con Limine (limine-snapper-sync).
- LVM sobre LUKS y esquemas manuales conscientes del arranque dual.
- Interfaz en español y japonés.

<br/>

## ⚖️ Licencia

MIT. Reimu no está afiliado a Arch Linux. El nombre viene de Reimu Hakurei, de Touhou Project, la que resuelve todos los incidentes.

<div align="center">
  <br/>

霊夢 · Resuelve el incidente.

</div>
