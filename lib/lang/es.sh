# shellcheck shell=bash
# Reimu · español. Tabla de traducción (inglés → español) y textos de ayuda.
# Las claves son las cadenas en inglés tal como aparecen en el código.

# ---- interfaz ----------------------------------------------------------------
T["Esc goes back"]="Esc vuelve atrás"
T["Enter picks"]="Enter elige"
T["type to search"]="escribe para buscar"
T["Repeat it"]="Repítela"
T["Empty passwords are not allowed."]="No se permiten contraseñas vacías."
T["They do not match, try again."]="No coinciden, prueba otra vez."
T["A value is required."]="Hace falta un valor."
T["Enter to skip"]="Enter para omitir"
T["yes"]="sí"
T["no"]="no"
T["marks [x] each one you want"]="marca [x] cada una que quieras"
T["ENTER when done"]="ENTER al terminar"
T["NOTHING WAS MARKED. Move to an option and press %s: it turns into [x]. Then ENTER. Mark [none] to pick nothing"]="NO MARCASTE NADA. Ponte sobre una opción y pulsa %s: se convierte en [x]. Luego ENTER. Marca [ninguna] para no elegir nada"
T["[none] pick nothing"]="[ninguna] no elegir nada"
T["Pick a number between 1 and %s."]="Elige un número entre 1 y %s."
T["type numbers to mark or unmark, e.g. 1 3 · all · none · Enter alone when done"]="escribe números para marcar o desmarcar, p. ej. 1 3 · all · none · Enter solo al terminar"
T["default"]="por defecto"
T["Press Enter to continue…"]="Pulsa Enter para continuar…"
T["That step failed. What now?"]="Ese paso falló. ¿Qué hacemos?"
T["Retry"]="Reintentar"
T["Run the same command again (after a network cut, for example)"]="Ejecutar el mismo comando otra vez (tras un corte de red, por ejemplo)"
T["Skip"]="Omitir"
T["Continue without it · the rest of the installation goes on"]="Seguir sin él · el resto de la instalación continúa"
T["Shell"]="Shell"
T["Open a shell to look around · type exit to come back here"]="Abrir una shell para mirar · escribe exit para volver aquí"
T["Abort"]="Abortar"
T["Stop the installation (it can be resumed later with --resume)"]="Detener la instalación (se puede retomar luego con --resume)"
T["Type exit to return to Reimu."]="Escribe exit para volver a Reimu."
T["The interface tool failed; switching to plain prompts."]="La herramienta de interfaz falló; paso a preguntas de texto."
T["Still failing. Pick again."]="Sigue fallando. Elige otra vez."
T["Skipped: %s"]="Omitido: %s"
T["Waiting for the network…"]="Esperando a la red…"
T["No internet connection. Waiting for it to come back… (Ctrl+C aborts)"]="Sin conexión a internet. Esperando a que vuelva… (Ctrl+C aborta)"
T["Network is back."]="Volvió la red."
T["Attempt %s of 5 failed; retrying in 10 s…"]="Intento %s de 5 fallido; reintento en 10 s…"

# ---- grupos y ajustes ----------------------------------------------------------
T["Language"]="Idioma"
T["Disk"]="Disco"
T["Boot"]="Arranque"
T["Users"]="Usuarios"
T["Network"]="Red"
T["Repositories"]="Repositorios"
T["Desktop"]="Escritorio"
T["Software"]="Software"
T["Interface language"]="Idioma de la interfaz"
T["Keyboard layout"]="Distribución del teclado"
T["Extra languages"]="Idiomas adicionales"
T["Time zone"]="Zona horaria"
T["Host name"]="Nombre del equipo"
T["Mirror countries"]="Países de los mirrors"
T["Partitions"]="Particiones"
T["Filesystem"]="Sistema de archivos"
T["Snapshots"]="Snapshots"
T["Encryption"]="Cifrado"
T["Swap"]="Swap"
T["Bootloader"]="Gestor de arranque"
T["Kernels"]="Kernels"
T["User name"]="Nombre de usuario"
T["Shell"]="Shell"
T["Administrator tool"]="Herramienta de administrador"
T["Root account"]="Cuenta root"
T["Network manager"]="Gestor de red"
T["Services"]="Servicios"
T["Laptop power"]="Energía del portátil"
T["Extra repositories"]="Repositorios extra"
T["Custom repositories"]="Repositorios propios"
T["Login manager"]="Gestor de sesión"
T["Theme and icons"]="Tema e iconos"
T["Graphics driver"]="Driver de gráficos"
T["AUR helper"]="Ayudante de AUR"
T["Software bundles"]="Paquetes de software"
T["Extra packages"]="Paquetes extra"
T["Extra services"]="Servicios extra"
T["Sanae software store"]="Tienda de software Sanae"
T["Your choices"]="Tus elecciones"
T["Your choices will appear here."]="Tus elecciones aparecerán aquí."
T["Esc in a question goes back one."]="Esc en una pregunta vuelve a la anterior."
T["Back to: %s"]="Volviendo a: %s"
T["Everything Reimu will do · pick a line to change it"]="Todo lo que hará Reimu · elige una línea para cambiarla"
T["💾 Save configuration to a file"]="💾 Guardar la configuración en un archivo"
T["🚀 Start the installation"]="🚀 Empezar la instalación"
T["✖ Quit"]="✖ Salir"
T["File"]="Archivo"
T["Fix the problems above before installing."]="Corrige los problemas de arriba antes de instalar."
T["Welcome"]="Bienvenida"
T["Reimu asks a few questions, explains each one, and then installs Arch Linux from start to finish: base system, desktop, drivers, the lot.
Your answers pile up on the left as you go. Esc in any question goes back to the previous one; the menu at the end lets you change any single answer.
Nothing is written to the disk until you see the summary and type YES.

Made by Chidaruma · github.com/Chidaruma696"]="Reimu hace unas pocas preguntas, explica cada una, y luego instala Arch Linux de principio a fin: sistema base, escritorio, drivers, todo.
Tus respuestas se van acumulando a la izquierda. Esc en cualquier pregunta vuelve a la anterior; el menú del final permite cambiar cualquier respuesta suelta.
No se escribe nada en el disco hasta que veas el resumen y escribas YES.

Hecho por Chidaruma · github.com/Chidaruma696"

# valores mostrados
T["worldwide"]="todo el mundo"
T["none"]="ninguno"
T["automatic"]="automático"
T["own password"]="contraseña propia"
T["locked"]="bloqueada"
T["not a laptop"]="no es portátil"
T["xfce only"]="solo XFCE"
T["as it comes"]="tal como viene"
T["auto · %s"]="auto · %s"
T["manual · root %s"]="manual · raíz %s"
T["boot %s · root %s"]="boot %s · raíz %s"

# ---- preguntas y opciones ------------------------------------------------------
T["Console keyboard layout"]="Distribución del teclado en consola"
T["System language (locale)"]="Idioma del sistema (locale)"
T["Extra languages to generate"]="Idiomas adicionales que generar"
T["Mirror countries (none = worldwide)"]="Países de los mirrors (ninguno = todo el mundo)"
T["Mirror country codes, comma separated (Enter = worldwide)"]="Códigos de país de los mirrors, separados por comas (Enter = todo el mundo)"
T["How do you want to partition?"]="¿Cómo quieres particionar?"
T["Automatic"]="Automático"
T["Erase one whole disk and lay it out for me"]="Borrar un disco entero y organizarlo por mí"
T["Manual"]="Manual"
T["I create the partitions with cfdisk and point Reimu at them"]="Yo creo las particiones con cfdisk y le digo a Reimu cuál es cuál"
T["Target disk"]="Disco de destino"
T["live media · do not use"]="medio de arranque · no usar"
T["Open cfdisk on %s now to create the partitions?"]="¿Abrir cfdisk en %s ahora para crear las particiones?"
T["Automatic mode: partitions are created for you."]="Modo automático: las particiones se crean solas."
T["EFI system partition (FAT32, 512 MiB or more)"]="Partición de sistema EFI (FAT32, 512 MiB o más)"
T["Boot partition (will be FAT32; BIOS on GPT also needs a 1 MiB 'BIOS boot' partition)"]="Partición de arranque (será FAT32; BIOS sobre GPT necesita además una partición 'BIOS boot' de 1 MiB)"
T["Root partition (will be formatted)"]="Partición raíz (se formateará)"
T["Separate /home partition"]="Partición /home separada"
T["Home lives inside root"]="Home vive dentro de la raíz"
T["Format %s? (No keeps the existing files)"]="¿Formatear %s? (No conserva los archivos que hay)"
T["Swap partition"]="Partición de swap"
T["Root filesystem"]="Sistema de archivos de la raíz"
T["Snapshots and compression · best for desktops and laptops"]="Snapshots y compresión · lo mejor para escritorios y portátiles"
T["The classic · simple and proven · no snapshots"]="El clásico · simple y probado · sin snapshots"
T["Fast with huge files · cannot shrink"]="Rápido con archivos enormes · no se puede encoger"
T["Snapshots need btrfs."]="Los snapshots necesitan btrfs."
T["Enable snapshots (snapper + snap-pac)?"]="¿Activar snapshots (snapper + snap-pac)?"
T["Encrypt the disk with LUKS2?"]="¿Cifrar el disco con LUKS2?"
T["Compressed swap in RAM · no disk space · recommended"]="Swap comprimida en la RAM · sin espacio en disco · recomendado"
T["On disk · needed for hibernation"]="En disco · necesaria para hibernar"
T["Swap file"]="Archivo de swap"
T["On disk · easy to resize"]="En disco · fácil de redimensionar"
T["No swap"]="Sin swap"
T["Only with plenty of RAM"]="Solo con mucha RAM"
T["zram size"]="Tamaño de la zram"
T["%s MiB"]="%s MiB"
T["Half of your RAM · recommended"]="La mitad de tu RAM · recomendado"
T["2 GiB"]="2 GiB"
T["4 GiB"]="4 GiB"
T["8 GiB"]="8 GiB"
T["16 GiB"]="16 GiB"
T["Custom"]="Personalizado"
T["Type a size in MiB"]="Escribe un tamaño en MiB"
T["Type a size in GiB"]="Escribe un tamaño en GiB"
T["zram size in MiB"]="Tamaño de la zram en MiB"
T["Swap size"]="Tamaño de la swap"
T["%s GiB"]="%s GiB"
T["Recommended for your %s GiB of RAM"]="Recomendado para tus %s GiB de RAM"
T["RAM plus 2 · safe for hibernation"]="RAM más 2 · seguro para hibernar"
T["Swap size in GiB"]="Tamaño de la swap en GiB"
T["Simple and fast · UEFI only · recommended"]="Simple y rápido · solo UEFI · recomendado"
T["Full menu · other systems · boots into snapshots"]="Menú completo · otros sistemas · arranca desde snapshots"
T["Modern and small · UEFI and BIOS"]="Moderno y pequeño · UEFI y BIOS"
T["This machine booted in BIOS (legacy) mode."]="Este equipo arrancó en modo BIOS (heredado)."
T["The normal one · recommended"]="El normal · recomendado"
T["Long term support · safe fallback"]="Soporte a largo plazo · respaldo seguro"
T["Tuned for desktops"]="Afinado para escritorios"
T["Security over speed"]="Seguridad antes que velocidad"
T["lowercase, no spaces"]="minúsculas, sin espacios"
T["The default everywhere"]="El de siempre en todas partes"
T["Smarter completion · what macOS uses"]="Autocompletado más listo · el que usa macOS"
T["Friendliest · colors and suggestions"]="El más amable · colores y sugerencias"
T["The standard · every guide uses it"]="El estándar · todas las guías lo usan"
T["Tiny · with a sudo alias"]="Diminuto · con alias sudo"
T["Give root its own password? (No locks the root account)"]="¿Darle a root su propia contraseña? (No bloquea la cuenta root)"
T["Wi-Fi · VPN · desktop icon · recommended"]="Wi-Fi · VPN · icono en el escritorio · recomendado"
T["Light Wi-Fi from the terminal"]="Wi-Fi ligero desde la terminal"
T["Wired only · servers"]="Solo cable · servidores"
T["Headphones · mice · controllers"]="Auriculares · ratones · mandos"
T["Printing"]="Impresión"
T["CUPS with PDF printing"]="CUPS con impresión a PDF"
T["Firewall"]="Cortafuegos"
T["Block incoming connections"]="Bloquear conexiones entrantes"
T["SSH server"]="Servidor SSH"
T["Log in from another machine"]="Entrar desde otro equipo"
T["Integrates with GNOME and KDE"]="Se integra con GNOME y KDE"
T["Simple · one command"]="Simple · un comando"
T["No battery detected: power management is for laptops."]="No se detectó batería: la gestión de energía es para portátiles."
T["Laptop power management"]="Gestión de energía del portátil"
T["Power modes in GNOME and KDE · recommended"]="Modos de energía en GNOME y KDE · recomendado"
T["More battery · no desktop integration"]="Más batería · sin integración con el escritorio"
T["32-bit libraries · Steam and Wine · official"]="Bibliotecas de 32 bits · Steam y Wine · oficial"
T["Thousands of AUR programs prebuilt · nothing to compile"]="Miles de programas del AUR ya compilados · nada que compilar"
T["Custom repositories: name=URL, space separated"]="Repositorios propios: nombre=URL, separados por espacios"
T["Enter to skip · e.g. myrepo=https://example.org/\$arch"]="Enter para omitir · p. ej. mirepo=https://ejemplo.org/\$arch"
T["Desktop environment"]="Entorno de escritorio"
T["Modern and simple · like macOS · touch friendly"]="Moderno y simple · como macOS · amigable con pantallas táctiles"
T["Like Windows · customize everything"]="Como Windows · personaliza todo"
T["Light and classic · old machines"]="Ligero y clásico · equipos viejos"
T["Windows-style · from Linux Mint"]="Estilo Windows · de Linux Mint"
T["The old GNOME 2 · traditional"]="El viejo GNOME 2 · tradicional"
T["Simple and elegant"]="Simple y elegante"
T["Very light · weak machines"]="Muy ligero · equipos flojos"
T["New desktop by System76 · in Rust"]="Escritorio nuevo de System76 · en Rust"
T["Pretty · macOS-like"]="Bonito · estilo macOS"
T["Tiling Wayland · animations · you configure it"]="Mosaico en Wayland · animaciones · lo configuras tú"
T["Tiling Wayland · minimal"]="Mosaico en Wayland · mínimo"
T["Scrolling tiling Wayland"]="Mosaico con desplazamiento en Wayland"
T["Tiling X11 classic"]="Mosaico clásico en X11"
T["None"]="Ninguno"
T["Terminal only"]="Solo terminal"
T["No desktop, no login manager."]="Sin escritorio no hay gestor de sesión."
T["Auto"]="Auto"
T["The one that fits the desktop · recommended"]="El que va con el escritorio · recomendado"
T["GNOME's"]="El de GNOME"
T["KDE's"]="El de KDE"
T["Light and classic"]="Ligero y clásico"
T["Text mode"]="Modo texto"
T["Start from a TTY"]="Arrancar desde una TTY"
T["Themes are applied automatically for XFCE only (for now)."]="Los temas se aplican solos únicamente en XFCE (por ahora)."
T["Do you want Reimu to set a theme and icons? (No leaves XFCE as it comes)"]="¿Quieres que Reimu ponga tema e iconos? (No deja XFCE tal como viene)"
T["Theme"]="Tema"
T["XFCE's classic · light or dark · AUR"]="El clásico de XFCE · claro u oscuro · AUR"
T["Flat with transparency · the popular one · AUR"]="Plano con transparencias · el popular · AUR"
T["Material Design · official repo"]="Material Design · repo oficial"
T["Rounded and modern · official repo"]="Redondeado y moderno · repo oficial"
T["Flat and colorful · AUR"]="Plano y colorido · AUR"
T["Kali Linux look · AUR"]="Aspecto de Kali Linux · AUR"
T["Dark purple · AUR"]="Morado oscuro · AUR"
T["Nord palette · AUR"]="Paleta Nord · AUR"
T["Pastel dark · AUR"]="Oscuro pastel · AUR"
T["Default"]="Por defecto"
T["Adwaita · nothing extra"]="Adwaita · nada extra"
T["Variant"]="Variante"
T["Dark"]="Oscuro"
T["Light"]="Claro"
T["Icons"]="Iconos"
T["The most popular · official repo"]="Los más populares · repo oficial"
T["Rounded and colorful · AUR"]="Redondeados y coloridos · AUR"
T["Matches the Flat Remix theme · AUR"]="A juego con el tema Flat Remix · AUR"
T["Clean · official repo"]="Limpios · repo oficial"
T["KDE's · official repo"]="Los de KDE · repo oficial"
T["Matches the Arc theme · AUR"]="A juego con el tema Arc · AUR"
T["That theme comes from the AUR: pick an AUR helper in Software, or it will be skipped."]="Ese tema viene del AUR: elige un ayudante de AUR en Software o se omitirá."
T["Detect"]="Detectar"
T["Found: %s · recommended"]="Detectado: %s · recomendado"
T["NVIDIA open modules"]="NVIDIA módulos abiertos"
T["GTX 16xx · RTX · 2018 onwards"]="GTX 16xx · RTX · desde 2018"
T["NVIDIA proprietary"]="NVIDIA propietario"
T["Older cards"]="Tarjetas antiguas"
T["Free NVIDIA driver · slow"]="Driver libre para NVIDIA · lento"
T["Virtual machine"]="Máquina virtual"
T["Guest tools"]="Herramientas de invitado"
T["Modern · recommended"]="Moderno · recomendado"
T["The classic"]="El clásico"
T["Extra packages, space separated"]="Paquetes extra, separados por espacios"
T["Enter to skip · e.g. neovim htop"]="Enter para omitir · p. ej. neovim htop"
T["Extra systemd units to enable"]="Unidades de systemd extra que activar"
T["Enter to skip · e.g. docker.service"]="Enter para omitir · p. ej. docker.service"
T["Install Sanae, the software store for the terminal?"]="¿Instalar Sanae, la tienda de software para la terminal?"
T["English (US)"]="Inglés (EE. UU.)"
T["Password for %s"]="Contraseña de %s"
T["Password for root"]="Contraseña de root"
T["Disk encryption password"]="Contraseña de cifrado del disco"

# ---- resumen, fases y despedida -------------------------------------------------
T["Summary"]="Resumen"
T["Machine"]="Equipo"
T["laptop"]="portátil"
T["WILL BE ERASED COMPLETELY"]="SE BORRARÁ POR COMPLETO"
T["WILL BE FORMATTED"]="SE FORMATEARÁ"
T["formatted"]="se formatea"
T["kept"]="se conserva"
T["Home"]="Home"
T["Root"]="Raíz"
T["Swap part."]="Part. swap"
T["System"]="Sistema"
T["User"]="Usuario"
T["enabled"]="activada"
T["Repos"]="Repos"
T["no bundles"]="sin paquetes"
T["Dry run: nothing will be written."]="Simulación: no se escribirá nada."
T["This erases the data on the partitions marked above. There is no undo."]="Esto borra los datos de las particiones marcadas arriba. No hay vuelta atrás."
T["Type YES to continue"]="Escribe YES para continuar"
T["Aborted. Nothing was changed."]="Abortado. No se cambió nada."
T["already done"]="ya hecho"
T["Done in %s min."]="Terminado en %s min."
T["Mirrors and keyring"]="Mirrors y llavero"
T["Base system"]="Sistema base"
T["System configuration"]="Configuración del sistema"
T["initramfs"]="initramfs"
T["Desktop and graphics"]="Escritorio y gráficos"
T["Finishing touches"]="Toques finales"
T["Arch Linux is installed"]="Arch Linux está instalado"
T["Take the USB out and reboot."]="Saca el USB y reinicia."
T["Your recipe is at /root/reimu.conf and the log at /var/log/reimu/install.log."]="Tu receta está en /root/reimu.conf y el log en /var/log/reimu/install.log."
T["Rerun the same install on another machine with:  reimu --config reimu.conf"]="Repite la misma instalación en otro equipo con:  reimu --config reimu.conf"
T["Reimu is made by Chidaruma. Like it? Visit github.com/Chidaruma696 and leave a star."]="Reimu está hecho por Chidaruma. ¿Te gusta? Visita github.com/Chidaruma696 y deja una estrella."
T["Sanae is installed: type sanae after logging in to browse and install software."]="Sanae está instalada: escribe sanae tras iniciar sesión para explorar e instalar software."
T["Packages that could not be installed (install them later by hand):"]="Paquetes que no se pudieron instalar (instálalos luego a mano):"
T["Reboot now?"]="¿Reiniciar ahora?"

# ---- ayudas ----------------------------------------------------------------------
help_disk_mode() {
  cat <<'EOF'
Automático borra el disco entero y crea las particiones por ti. Es lo correcto
para un equipo que solo va a tener Arch Linux.
Manual te deja conservar otros sistemas o particiones: creas las particiones
con cfdisk y le dices a Reimu cuál es cuál.
EOF
}

help_disk() {
  cat <<'EOF'
El disco donde vivirá Arch Linux. Los NVMe suelen ser el SSD rápido de los
portátiles; sda/sdb son discos SATA o memorias USB. No elijas el USB desde el
que arrancaste.
EOF
}

help_fs() {
  cat <<'EOF'
El sistema de archivos es cómo se organizan los archivos en el disco.
• btrfs puede hacer snapshots: una foto del sistema a la que volver si una
  actualización rompe algo. Además comprime los archivos, así que ganas
  espacio. Es la mejor opción para un escritorio o un portátil.
• ext4 es el clásico, simple y probado. Sin snapshots, sin compresión.
• xfs es muy rápido con archivos enormes (vídeo, bases de datos) pero no se
  puede encoger.
EOF
}

help_snapshots() {
  cat <<'EOF'
Los snapshots son puntos de restauración automáticos. Reimu hace uno antes de
cada actualización de pacman y guarda unas horas y días de historial. Si algo
se rompe, vuelves atrás en segundos. Con GRUB hasta puedes arrancar directo en
un snapshot. Casi no cuesta espacio mientras tus archivos no cambien.
EOF
}

help_encrypt() {
  local tail=""
  (( DETECT_LAPTOP )) && tail=$'\nEsto es un portátil: el cifrado es muy recomendable. Los portátiles se pierden.'
  cat <<EOF
El cifrado (LUKS) revuelve el disco entero para que nadie pueda leer tus
archivos sin tu contraseña, aunque saquen el disco. Escribirás esa contraseña
en cada arranque, antes de que empiece el sistema. Si la olvidas, los datos se
pierden para siempre. No se nota lentitud en equipos modernos.$tail
EOF
}

help_swap() {
  local gib; gib="$(help_ram_gib)"
  cat <<EOF
La swap es memoria de reserva en disco, usada cuando se acaba la RAM. Tu equipo
tiene ${gib} GiB de RAM.
• zram comprime la memoria dentro de la propia RAM: rápida, sin espacio en
  disco, ideal para casi todos. Hibernar (suspender a disco) no es posible
  solo con zram.
• Una partición de swap hace falta si quieres hibernar: hazla al menos del
  tamaño de tu RAM (${gib} GiB).
• Un archivo de swap es como una partición pero más fácil de redimensionar.
• Ninguna: bien con mucha RAM, arriesgado por debajo de 8 GiB.
EOF
}

help_bootloader() {
  local note=""
  if [[ "$DETECT_FIRMWARE" == bios ]]; then
    note=$'\nEste equipo arrancó en modo BIOS (heredado), así que systemd-boot no se puede\nofrecer. En VirtualBox activa "Enable EFI" en Sistema; en QEMU usa OVMF; en un\nPC real busca el modo UEFI en la configuración del firmware.'
  fi
  cat <<EOF
El gestor de arranque es el programita que inicia Linux cuando enciendes el
equipo.
• systemd-boot es simple y rápido, con un menú plano. Solo UEFI.
• GRUB muestra un menú completo, puede arrancar otros sistemas (Windows) y
  arrancar desde snapshots de btrfs. Funciona en UEFI y en BIOS antiguas.
• Limine es moderno y diminuto, con un menú limpio, y funciona en UEFI y en
  BIOS.${note}
EOF
}

help_kernels() {
  cat <<'EOF'
El kernel es el núcleo de Linux. "linux" es el normal. "linux-lts" es más
antiguo pero con soporte más largo: una segunda opción segura si el más nuevo
tiene problemas con tu hardware. "zen" está afinado para escritorios;
"hardened" cambia algo de velocidad por seguridad. Puedes instalar varios y
elegir uno al arrancar.
EOF
}

help_user() {
  cat <<'EOF'
Tu cuenta de todos los días. Minúsculas, dígitos, guion o guion bajo, sin
espacios. Tiene permisos de administrador a través de sudo (escribes tu
contraseña para hacer cambios en el sistema).
EOF
}

help_shell() {
  cat <<'EOF'
La shell es el programa que hay detrás de la terminal. bash es la de siempre.
zsh añade un autocompletado más listo y es la que usa macOS. fish es la más
amable: colores y sugerencias de serie, pero su sintaxis no es compatible con
bash.
EOF
}

help_sudo() {
  cat <<'EOF'
sudo es la herramienta estándar para ejecutar comandos como administrador;
todas las guías de internet la usan. doas hace lo mismo con mucho menos
código; Reimu añade un alias "sudo" para que las guías sigan sirviendo.
EOF
}

help_root() {
  cat <<'EOF'
root es la cuenta todopoderosa. Casi nadie entra como root: usa sudo desde su
propia cuenta. Bloquear root (recomendado) quita una puerta de entrada.
EOF
}

help_network() {
  cat <<'EOF'
• NetworkManager gestiona Wi-Fi, cable y VPN y pone un icono de red en todos
  los escritorios. La opción correcta para portátiles y escritorios.
• iwd es un demonio de Wi-Fi más ligero que se controla desde la terminal.
• systemd-networkd es para servidores por cable, sin herramientas Wi-Fi.
EOF
}

help_extras() {
  cat <<'EOF'
• Bluetooth: auriculares, ratones, mandos.
• Impresión: CUPS, el sistema de impresión, con impresión a PDF.
• Cortafuegos: bloquea conexiones entrantes. Inofensivo en un escritorio,
  bueno en un portátil que se conecta a Wi-Fi públicas.
• Servidor SSH: te deja entrar a este equipo desde otro.
EOF
}

help_power() {
  cat <<'EOF'
Gestión de energía del portátil. power-profiles-daemon se integra con GNOME y
KDE (el selector de modo de energía del menú). TLP exprime más batería por su
cuenta pero no habla con el escritorio. Elige uno, nunca los dos.
EOF
}

help_desktop() {
  cat <<'EOF'
El entorno de escritorio es lo que ves: paneles, menús, ventanas, ajustes.
GNOME y KDE Plasma son los dos grandes escritorios completos. XFCE, MATE y
LXQt son más ligeros y simples. Hyprland, Sway, niri e i3 son gestores "en
mosaico" para usuarios avanzados que viven en el teclado: rápidos, pero lo
configuras todo tú. Ninguno te deja solo una terminal.
EOF
}

help_dm() {
  cat <<'EOF'
El gestor de sesión es la pantalla donde escribes tu contraseña. "Auto" elige
el que va con tu escritorio. "Ninguno" significa que entras en una consola de
texto y arrancas el escritorio a mano.
EOF
}

help_gpu() {
  local found="$DETECT_GPU"
  [[ "$DETECT_VIRT" != none ]] && found="una máquina virtual ($DETECT_VIRT)"
  cat <<EOF
El driver de gráficos hace que el escritorio vaya fluido y los juegos rápidos.
Reimu detectó: ${found}. Los drivers de Intel y AMD son libres y funcionan sin
más. NVIDIA necesita el suyo: "módulos abiertos" para tarjetas desde 2018 (GTX
16xx, RTX), "propietario" para las más viejas, "nouveau" es la alternativa
libre pero lenta.
EOF
}

help_aur() {
  cat <<'EOF'
El AUR es el repositorio de la comunidad con miles de programas extra (Spotify,
Google Chrome, fuentes…). Un ayudante de AUR los instala como paquetes
normales. paru y yay son equivalentes; paru es el más moderno.
AVISO: los paquetes del AUR son recetas escritas por otros usuarios, no por
Arch. Lee el PKGBUILD antes de compilar algo que no conozcas.
EOF
}

help_bundles() {
  cat <<'EOF'
Conjuntos de programas listos, por tema. Elige los que quieras; cada uno
instala un puñado de aplicaciones conocidas. Siempre puedes añadir o quitar
programas después.
EOF
}

help_locale() {
  cat <<'EOF'
El locale es el idioma de menús, fechas y números. Los locales adicionales
permiten a los programas cambiar de idioma después sin reinstalar. La
distribución del teclado es para la consola de texto; los escritorios tienen
su propio ajuste, que Reimu también deja puesto.
EOF
}

help_mirrors() {
  cat <<'EOF'
Los mirrors son los servidores de los que se descargan los paquetes. Elegir tu
país o uno vecino hace las descargas mucho más rápidas. Reimu mantiene la lista
fresca con un temporizador semanal.
EOF
}

help_hostname() {
  cat <<'EOF'
El nombre de este equipo en la red (lo que ves en la terminal). Letras,
dígitos y guiones.
EOF
}

help_timezone() {
  cat <<'EOF'
Tu zona horaria como Región/Ciudad. Escribe parte de una ciudad para buscar.
EOF
}

help_repos() {
  cat <<'EOF'
Los repositorios son las fuentes de las que instala pacman. Los de Arch
siempre están activos.
• multilib: bibliotecas oficiales de 32 bits; Steam, Wine y muchos juegos las
  necesitan.
• Chaotic-AUR: un repositorio comunitario con miles de programas del AUR ya
  compilados (navegadores, editores, juegos, fuentes…) que se instalan en
  segundos en vez de compilarlos. Muy usado; lo mantienen miembros de la
  comunidad de Arch.
AVISO: nada fuera de los repositorios oficiales (Chaotic-AUR, repos propios, el
propio AUR) lo revisa Arch Linux. Un paquete de ahí puede romper una
actualización o contener cualquier cosa. Activa solo lo que entiendas. Más
fuentes (Liquorix, BlackArch, ALHP, Flatpak, Snap) se pueden activar luego
desde los Ajustes de Sanae, con el mismo aviso.
EOF
}

help_custom_repos() {
  cat <<'EOF'
Añade cualquier otro repositorio de pacman como nombre=URL, separados por
espacios. La URL es la línea "Server =" de las instrucciones de ese
repositorio y puede contener $arch. Reimu los añade con firmas opcionales y
confianza total, así que añade solo repositorios de los que te fíes.
EOF
}

help_theme() {
  cat <<'EOF'
Un tema cambia el aspecto de ventanas, botones y menús; los iconos cambian las
imágenes de menús y gestores de archivos. Reimu instala los paquetes y los deja
como predeterminados de tu usuario, así que XFCE ya se ve así en el primer
inicio de sesión. Los temas "AUR" necesitan el ayudante de AUR de la sección
Software (paru o yay).
Esto es opcional: di que no y XFCE queda exactamente como viene.
EOF
}

help_sanae() {
  cat <<'EOF'
En Windows instalas programas desde una tienda; en Arch tecleas comandos de
pacman y buscas nombres de paquetes. Sanae es esa tienda, para la terminal:
muestra los programas por lo que son (Internet, Juegos, Oficina,
Desarrollo…) con su nombre real y un resumen de una línea, te dice cuántos
usuarios de Arch tiene cada uno, y los instala con una tecla. Busca a la vez
en los repositorios oficiales y en el AUR (el repositorio de la comunidad con
miles de programas más), mantiene el sistema actualizado y avisa cuando Arch
publica noticias que hay que leer antes de actualizar, y puede limpiar paquetes
sobrantes.
También tiene "recetas": configuraciones de una tecla que instalan un programa
Y lo dejan funcionando, cosa que los gestores de paquetes normales nunca hacen.
Ejemplos: Docker con el servicio en marcha y tu usuario con permiso para
usarlo, máquinas virtuales QEMU listas para crear una VM, escritura en japonés,
fuentes extra, temas de XFCE.
Hecha por el mismo autor que Reimu. Es software joven. No sustituye a pacman:
ejecuta pacman por ti. Un solo archivo en /usr/local/bin/sanae; se quita con:
sudo rm /usr/local/bin/sanae
EOF
}
