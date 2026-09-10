# shellcheck shell=bash
# Reimu · Русский. Translation table (English → Русский) and help texts.
# Keys are the English strings as they appear in the code.

T["Esc goes back"]="Esc — назад"
T["Enter picks"]="Enter — выбрать"
T["type to search"]="введите текст для поиска"
T["Repeat it"]="Повторите"
T["Empty passwords are not allowed."]="Пустой пароль не допускается."
T["They do not match, try again."]="Пароли не совпадают, попробуйте ещё раз."
T["A value is required."]="Нужно ввести значение."
T["Enter to skip"]="Enter — пропустить"
T["yes"]="да"
T["no"]="нет"
T["marks [x] each one you want"]="отмечает [x] нужные пункты"
T["ENTER when done"]="ENTER, когда закончите"
T["NOTHING WAS MARKED. Move to an option and press %s: it turns into [x]. Then ENTER. Mark [none] to pick nothing"]="НИЧЕГО НЕ ОТМЕЧЕНО. Перейдите к пункту и нажмите %s: он станет [x]. Затем ENTER. Отметьте [ничего], чтобы ничего не выбирать"
T["[none] pick nothing"]="[ничего] ничего не выбирать"
T["Pick a number between 1 and %s."]="Введите число от 1 до %s."
T["type numbers to mark or unmark, e.g. 1 3 · all · none · Enter alone when done"]="вводите номера, чтобы отметить или снять отметку, напр. 1 3 · all · none · просто Enter, когда закончите"
T["default"]="по умолчанию"
T["Press Enter to continue…"]="Нажмите Enter, чтобы продолжить…"
T["That step failed. What now?"]="Этот шаг не удался. Что дальше?"
T["Retry"]="Повторить"
T["Run the same command again (after a network cut, for example)"]="Выполнить ту же команду ещё раз (например, после обрыва сети)"
T["Skip"]="Пропустить"
T["Continue without it · the rest of the installation goes on"]="Продолжить без этого шага · остальная установка продолжится"
T["Shell"]="Оболочка"
T["Open a shell to look around · type exit to come back here"]="Открыть оболочку, чтобы осмотреться · введите exit, чтобы вернуться сюда"
T["Abort"]="Прервать"
T["Stop the installation (it can be resumed later with --resume)"]="Остановить установку (её можно продолжить позже с --resume)"
T["Type exit to return to Reimu."]="Введите exit, чтобы вернуться в Reimu."
T["The interface tool failed; switching to plain prompts."]="Инструмент интерфейса перестал работать; переключаюсь на простые запросы."
T["Still failing. Pick again."]="Снова ошибка. Выберите ещё раз."
T["Skipped: %s"]="Пропущено: %s"
T["Waiting for the network…"]="Ожидание сети…"
T["No internet connection. Waiting for it to come back… (Ctrl+C aborts)"]="Нет подключения к интернету. Ожидание восстановления… (Ctrl+C — прервать)"
T["Network is back."]="Сеть восстановлена."
T["Attempt %s of 5 failed; retrying in 10 s…"]="Попытка %s из 5 не удалась; повтор через 10 с…"
T["Language"]="Язык"
T["Disk"]="Диск"
T["Boot"]="Загрузка"
T["Users"]="Пользователи"
T["Network"]="Сеть"
T["Repositories"]="Репозитории"
T["Desktop"]="Рабочий стол"
T["Software"]="Программы"
T["Interface language"]="Язык интерфейса"
T["Keyboard layout"]="Раскладка клавиатуры"
T["Extra languages"]="Дополнительные языки"
T["Time zone"]="Часовой пояс"
T["Host name"]="Имя компьютера"
T["Mirror countries"]="Страны зеркал"
T["Partitions"]="Разделы"
T["Filesystem"]="Файловая система"
T["Snapshots"]="Снимки"
T["Encryption"]="Шифрование"
T["Swap"]="Подкачка"
T["Bootloader"]="Загрузчик"
T["Kernels"]="Ядра"
T["User name"]="Имя пользователя"
T["Administrator tool"]="Инструмент администратора"
T["Root account"]="Учётная запись root"
T["Network manager"]="Управление сетью"
T["Services"]="Службы"
T["Laptop power"]="Питание ноутбука"
T["Extra repositories"]="Дополнительные репозитории"
T["Custom repositories"]="Свои репозитории"
T["Login manager"]="Экран входа"
T["Theme and icons"]="Тема и значки"
T["Graphics driver"]="Видеодрайвер"
T["AUR helper"]="AUR-помощник"
T["Software bundles"]="Наборы программ"
T["Extra packages"]="Дополнительные пакеты"
T["Extra services"]="Дополнительные службы"
T["Sanae software store"]="Магазин программ Sanae"
T["Your choices"]="Ваш выбор"
T["Your choices will appear here."]="Здесь появится ваш выбор."
T["Esc in a question goes back one."]="Esc в вопросе возвращает на шаг назад."
T["Back to: %s"]="Назад к: %s"
T["Everything Reimu will do · pick a line to change it"]="Всё, что сделает Reimu · выберите строку, чтобы изменить"
T["💾 Save configuration to a file"]="💾 Сохранить конфигурацию в файл"
T["🚀 Start the installation"]="🚀 Начать установку"
T["✖ Quit"]="✖ Выход"
T["File"]="Файл"
T["Fix the problems above before installing."]="Исправьте проблемы выше перед установкой."
T["Welcome"]="Добро пожаловать"
T["Reimu asks a few questions, explains each one, and then installs Arch Linux from start to finish: base system, desktop, drivers, the lot.
Your answers pile up on the left as you go. Esc in any question goes back to the previous one; the menu at the end lets you change any single answer.
Nothing is written to the disk until you see the summary and type YES.

Made by Chidaruma · github.com/Chidaruma696"]="Reimu задаёт несколько вопросов, объясняет каждый и затем устанавливает Arch Linux от начала до конца: базовую систему, рабочий стол, драйверы — всё.
Ваши ответы накапливаются слева. Esc в любом вопросе возвращает к предыдущему; меню в конце позволяет изменить любой ответ.
На диск ничего не записывается, пока вы не увидите сводку и не введёте YES.

Автор: Chidaruma · github.com/Chidaruma696"
T["worldwide"]="весь мир"
T["none"]="нет"
T["automatic"]="автоматически"
T["own password"]="свой пароль"
T["locked"]="заблокирована"
T["not a laptop"]="не ноутбук"
T["xfce only"]="только XFCE"
T["as it comes"]="как есть"
T["auto · %s"]="авто · %s"
T["manual · root %s"]="вручную · корень %s"
T["boot %s · root %s"]="загрузка %s · корень %s"
T["Console keyboard layout"]="Раскладка клавиатуры в консоли"
T["System language (locale)"]="Язык системы (локаль)"
T["Extra languages to generate"]="Дополнительные языки для генерации"
T["Mirror countries (none = worldwide)"]="Страны зеркал (нет = весь мир)"
T["Mirror country codes, comma separated (Enter = worldwide)"]="Коды стран зеркал через запятую (Enter = весь мир)"
T["How do you want to partition?"]="Как разбить диск?"
T["Automatic"]="Автоматически"
T["Erase one whole disk and lay it out for me"]="Стереть весь диск и разметить его за меня"
T["Manual"]="Вручную"
T["I create the partitions with cfdisk and point Reimu at them"]="Я создам разделы в cfdisk и укажу их Reimu"
T["Target disk"]="Целевой диск"
T["live media · do not use"]="загрузочный носитель · не использовать"
T["Open cfdisk on %s now to create the partitions?"]="Открыть cfdisk на %s сейчас, чтобы создать разделы?"
T["Automatic mode: partitions are created for you."]="Автоматический режим: разделы создаются за вас."
T["EFI system partition (FAT32, 512 MiB or more)"]="Системный раздел EFI (FAT32, 512 МиБ или больше)"
T["Boot partition (will be FAT32; BIOS on GPT also needs a 1 MiB 'BIOS boot' partition)"]="Загрузочный раздел (будет FAT32; BIOS на GPT также требует раздел «BIOS boot» размером 1 МиБ)"
T["Root partition (will be formatted)"]="Корневой раздел (будет отформатирован)"
T["Separate /home partition"]="Отдельный раздел /home"
T["Home lives inside root"]="Home внутри корня"
T["Format %s? (No keeps the existing files)"]="Форматировать %s? (Нет — сохранить существующие файлы)"
T["Swap partition"]="Раздел подкачки"
T["Root filesystem"]="Файловая система корня"
T["Snapshots and compression · best for desktops and laptops"]="Снимки и сжатие · лучший выбор для ПК и ноутбуков"
T["The classic · simple and proven · no snapshots"]="Классика · просто и проверено · без снимков"
T["Fast with huge files · cannot shrink"]="Быстрая с огромными файлами · нельзя уменьшить"
T["Snapshots need btrfs."]="Для снимков нужна btrfs."
T["Enable snapshots (snapper + snap-pac)?"]="Включить снимки (snapper + snap-pac)?"
T["Encrypt the disk with LUKS2?"]="Зашифровать диск с помощью LUKS2?"
T["Compressed swap in RAM · no disk space · recommended"]="Сжатая подкачка в ОЗУ · не занимает диск · рекомендуется"
T["On disk · needed for hibernation"]="На диске · нужна для гибернации"
T["Swap file"]="Файл подкачки"
T["On disk · easy to resize"]="На диске · легко изменить размер"
T["No swap"]="Без подкачки"
T["Only with plenty of RAM"]="Только при большом объёме ОЗУ"
T["zram size"]="Размер zram"
T["%s MiB"]="%s МиБ"
T["Half of your RAM · recommended"]="Половина вашего ОЗУ · рекомендуется"
T["2 GiB"]="2 ГиБ"
T["4 GiB"]="4 ГиБ"
T["8 GiB"]="8 ГиБ"
T["16 GiB"]="16 ГиБ"
T["Custom"]="Свой"
T["Type a size in MiB"]="Введите размер в МиБ"
T["Type a size in GiB"]="Введите размер в ГиБ"
T["zram size in MiB"]="Размер zram в МиБ"
T["Swap size"]="Размер подкачки"
T["%s GiB"]="%s ГиБ"
T["Recommended for your %s GiB of RAM"]="Рекомендуется для ваших %s ГиБ ОЗУ"
T["RAM plus 2 · safe for hibernation"]="ОЗУ плюс 2 · безопасно для гибернации"
T["Swap size in GiB"]="Размер подкачки в ГиБ"
T["Simple and fast · UEFI only · recommended"]="Простой и быстрый · только UEFI · рекомендуется"
T["Full menu · other systems · boots into snapshots"]="Полное меню · другие системы · загрузка снимков"
T["Modern and small · UEFI and BIOS"]="Современный и маленький · UEFI и BIOS"
T["This machine booted in BIOS (legacy) mode."]="Этот компьютер загрузился в режиме BIOS (legacy)."
T["The normal one · recommended"]="Обычное · рекомендуется"
T["Long term support · safe fallback"]="Долгосрочная поддержка · надёжный запасной вариант"
T["Tuned for desktops"]="Настроено для ПК"
T["Security over speed"]="Безопасность важнее скорости"
T["lowercase, no spaces"]="строчные буквы, без пробелов"
T["The default everywhere"]="Стандарт везде"
T["Smarter completion · what macOS uses"]="Умное автодополнение · используется в macOS"
T["Friendliest · colors and suggestions"]="Самая дружелюбная · цвета и подсказки"
T["The standard · every guide uses it"]="Стандарт · используется во всех руководствах"
T["Tiny · with a sudo alias"]="Крошечный · с псевдонимом sudo"
T["Give root its own password? (No locks the root account)"]="Задать root отдельный пароль? (Нет — заблокировать учётную запись root)"
T["Wi-Fi · VPN · desktop icon · recommended"]="Wi-Fi · VPN · значок на рабочем столе · рекомендуется"
T["Light Wi-Fi from the terminal"]="Лёгкий Wi-Fi из терминала"
T["Wired only · servers"]="Только провод · серверы"
T["Headphones · mice · controllers"]="Наушники · мыши · геймпады"
T["Printing"]="Печать"
T["CUPS with PDF printing"]="CUPS с печатью в PDF"
T["Firewall"]="Брандмауэр"
T["Block incoming connections"]="Блокировать входящие соединения"
T["SSH server"]="Сервер SSH"
T["Log in from another machine"]="Вход с другого компьютера"
T["Integrates with GNOME and KDE"]="Интегрируется с GNOME и KDE"
T["Simple · one command"]="Просто · одна команда"
T["No battery detected: power management is for laptops."]="Батарея не обнаружена: управление питанием предназначено для ноутбуков."
T["Laptop power management"]="Управление питанием ноутбука"
T["Power modes in GNOME and KDE · recommended"]="Режимы питания в GNOME и KDE · рекомендуется"
T["More battery · no desktop integration"]="Больше автономности · без интеграции с рабочим столом"
T["32-bit libraries · Steam and Wine · official"]="32-битные библиотеки · Steam и Wine · официальный"
T["Thousands of AUR programs prebuilt · nothing to compile"]="Тысячи программ из AUR уже собраны · ничего компилировать не нужно"
T["Custom repositories: name=URL, space separated"]="Свои репозитории: имя=URL, через пробел"
T["Enter to skip · e.g. myrepo=https://example.org/\$arch"]="Enter — пропустить · напр. myrepo=https://example.org/\$arch"
T["Desktop environment"]="Окружение рабочего стола"
T["Modern and simple · like macOS · touch friendly"]="Современный и простой · как macOS · удобен для сенсорных экранов"
T["Like Windows · customize everything"]="Как Windows · настраивается всё"
T["Light and classic · old machines"]="Лёгкий и классический · старые компьютеры"
T["Windows-style · from Linux Mint"]="В стиле Windows · из Linux Mint"
T["The old GNOME 2 · traditional"]="Старый GNOME 2 · традиционный"
T["Simple and elegant"]="Простой и элегантный"
T["Very light · weak machines"]="Очень лёгкий · слабые компьютеры"
T["New desktop by System76 · in Rust"]="Новый рабочий стол от System76 · на Rust"
T["Pretty · macOS-like"]="Красивый · похож на macOS"
T["Tiling Wayland · animations · you configure it"]="Тайловый Wayland · анимации · настраиваете сами"
T["Tiling Wayland · minimal"]="Тайловый Wayland · минимальный"
T["Scrolling tiling Wayland"]="Прокручиваемый тайловый Wayland"
T["Tiling X11 classic"]="Классический тайловый X11"
T["None"]="Нет"
T["Terminal only"]="Только терминал"
T["No desktop, no login manager."]="Без рабочего стола и экрана входа."
T["Auto"]="Авто"
T["The one that fits the desktop · recommended"]="Подходящий для рабочего стола · рекомендуется"
T["GNOME's"]="Из GNOME"
T["KDE's"]="Из KDE"
T["Light and classic"]="Лёгкий и классический"
T["Text mode"]="Текстовый режим"
T["Start from a TTY"]="Запуск из TTY"
T["Themes are applied automatically for XFCE only (for now)."]="Темы применяются автоматически только для XFCE (пока)."
T["Do you want Reimu to set a theme and icons? (No leaves XFCE as it comes)"]="Хотите, чтобы Reimu настроил тему и значки? (Нет — оставить XFCE как есть)"
T["Theme"]="Тема"
T["XFCE's classic · light or dark · AUR"]="Классика XFCE · светлая или тёмная · AUR"
T["Flat with transparency · the popular one · AUR"]="Плоская с прозрачностью · популярная · AUR"
T["Material Design · official repo"]="Material Design · официальный репозиторий"
T["Rounded and modern · official repo"]="Скруглённая и современная · официальный репозиторий"
T["Flat and colorful · AUR"]="Плоская и яркая · AUR"
T["Kali Linux look · AUR"]="В стиле Kali Linux · AUR"
T["Dark purple · AUR"]="Тёмно-фиолетовая · AUR"
T["Nord palette · AUR"]="Палитра Nord · AUR"
T["Pastel dark · AUR"]="Пастельная тёмная · AUR"
T["Default"]="По умолчанию"
T["Adwaita · nothing extra"]="Adwaita · ничего лишнего"
T["Variant"]="Вариант"
T["Dark"]="Тёмный"
T["Light"]="Светлый"
T["Icons"]="Значки"
T["The most popular · official repo"]="Самые популярные · официальный репозиторий"
T["Rounded and colorful · AUR"]="Скруглённые и яркие · AUR"
T["Matches the Flat Remix theme · AUR"]="Под тему Flat Remix · AUR"
T["Clean · official repo"]="Чистые · официальный репозиторий"
T["KDE's · official repo"]="Из KDE · официальный репозиторий"
T["Matches the Arc theme · AUR"]="Под тему Arc · AUR"
T["That theme comes from the AUR: pick an AUR helper in Software, or it will be skipped."]="Эта тема из AUR: выберите AUR-помощник в разделе «Программы», иначе она будет пропущена."
T["Detect"]="Определить"
T["Found: %s · recommended"]="Найдено: %s · рекомендуется"
T["NVIDIA open modules"]="Открытые модули NVIDIA"
T["GTX 16xx · RTX · 2018 onwards"]="GTX 16xx · RTX · с 2018 года"
T["NVIDIA proprietary"]="Проприетарный NVIDIA"
T["Older cards"]="Старые карты"
T["Free NVIDIA driver · slow"]="Свободный драйвер NVIDIA · медленный"
T["Virtual machine"]="Виртуальная машина"
T["Guest tools"]="Гостевые инструменты"
T["Modern · recommended"]="Современный · рекомендуется"
T["The classic"]="Классика"
T["Extra packages, space separated"]="Дополнительные пакеты через пробел"
T["Enter to skip · e.g. neovim htop"]="Enter — пропустить · напр. neovim htop"
T["Extra systemd units to enable"]="Дополнительные юниты systemd для включения"
T["Enter to skip · e.g. docker.service"]="Enter — пропустить · напр. docker.service"
T["Install Sanae, the software store for the terminal?"]="Установить Sanae, магазин программ для терминала?"
T["English (US)"]="Английский (США)"
T["Password for %s"]="Пароль для %s"
T["Password for root"]="Пароль для root"
T["Disk encryption password"]="Пароль шифрования диска"
T["Summary"]="Сводка"
T["Machine"]="Компьютер"
T["laptop"]="ноутбук"
T["WILL BE ERASED COMPLETELY"]="БУДЕТ ПОЛНОСТЬЮ СТЁРТ"
T["WILL BE FORMATTED"]="БУДЕТ ОТФОРМАТИРОВАН"
T["formatted"]="форматируется"
T["kept"]="сохраняется"
T["Home"]="Home"
T["Root"]="Корень"
T["Swap part."]="Раздел подкачки"
T["System"]="Система"
T["User"]="Пользователь"
T["enabled"]="включено"
T["Repos"]="Репозитории"
T["no bundles"]="без наборов"
T["Dry run: nothing will be written."]="Пробный запуск: ничего не будет записано."
T["This erases the data on the partitions marked above. There is no undo."]="Это сотрёт данные на отмеченных выше разделах. Отменить будет невозможно."
T["Type YES to continue"]="Введите YES, чтобы продолжить"
T["Aborted. Nothing was changed."]="Прервано. Ничего не изменено."
T["already done"]="уже выполнено"
T["Done in %s min."]="Готово за %s мин."
T["Mirrors and keyring"]="Зеркала и ключи"
T["Base system"]="Базовая система"
T["System configuration"]="Настройка системы"
T["initramfs"]="initramfs"
T["Desktop and graphics"]="Рабочий стол и графика"
T["Finishing touches"]="Завершающие штрихи"
T["Arch Linux is installed"]="Arch Linux установлен"
T["Take the USB out and reboot."]="Извлеките USB-накопитель и перезагрузитесь."
T["Your recipe is at /root/reimu.conf and the log at /var/log/reimu/install.log."]="Ваш рецепт находится в /root/reimu.conf, а журнал — в /var/log/reimu/install.log."
T["Rerun the same install on another machine with:  reimu --config reimu.conf"]="Повторите ту же установку на другом компьютере:  reimu --config reimu.conf"
T["Reimu is made by Chidaruma. Like it? Visit github.com/Chidaruma696 and leave a star."]="Reimu создан Chidaruma. Понравилось? Загляните на github.com/Chidaruma696 и поставьте звезду."
T["Sanae is installed: type sanae after logging in to browse and install software."]="Sanae установлен: после входа введите sanae, чтобы искать и устанавливать программы."
T["Packages that could not be installed (install them later by hand):"]="Пакеты, которые не удалось установить (установите их позже вручную):"
T["Reboot now?"]="Перезагрузиться сейчас?"

help_disk_mode() {
  cat <<'EOF'
«Автоматически» стирает весь диск и создаёт разделы за вас. Это правильный
выбор для компьютера, на котором будет только Arch Linux.
«Вручную» позволяет сохранить другие системы или разделы: вы создаёте разделы
в cfdisk, а затем указываете Reimu, какой из них для чего.
EOF
}

help_disk() {
  cat <<'EOF'
Диск, на который будет установлен Arch Linux. NVMe — обычно быстрый SSD в
ноутбуках; sda/sdb — диски SATA или USB-накопители. Не выбирайте USB-накопитель,
с которого вы загрузились.
EOF
}

help_fs() {
  cat <<'EOF'
Файловая система определяет, как файлы организованы на диске.
• btrfs умеет делать снимки: копию состояния системы, к которой можно
  вернуться, если обновление что-то сломает. Она также сжимает файлы, экономя
  место. Лучший выбор для ПК и ноутбука.
• ext4 — классика, простая и проверенная. Без снимков и сжатия.
• xfs очень быстра с огромными файлами (видео, базы данных), но её нельзя
  уменьшить.
EOF
}

help_snapshots() {
  cat <<'EOF'
Снимки — это автоматические точки восстановления. Reimu делает снимок перед
каждым обновлением pacman и хранит историю за несколько часов и дней. Если
что-то сломается, вы вернётесь назад за секунды. С GRUB можно даже загрузиться
прямо из снимка. Пока ваши файлы не меняются, это почти ничего не стоит.
EOF
}

help_kernels() {
  cat <<'EOF'
Ядро — это сердце Linux. «linux» — обычное. «linux-lts» старше, но
поддерживается дольше: надёжный запасной вариант, если новейшее ядро плохо
работает с вашим оборудованием. «zen» настроено на отзывчивость рабочего стола;
«hardened» жертвует скоростью ради безопасности. Можно установить несколько и
выбирать при загрузке.
EOF
}

help_user() {
  cat <<'EOF'
Ваша повседневная учётная запись. Строчные буквы, цифры, дефис или
подчёркивание, без пробелов. Она получает права администратора через sudo (вы
вводите свой пароль, чтобы изменить систему).
EOF
}

help_shell() {
  cat <<'EOF'
Оболочка — это программа за терминалом. bash — стандарт везде. zsh умнее
дополняет команды, её использует macOS. fish самая дружелюбная: цвета и
подсказки из коробки, но её синтаксис несовместим с bash.
EOF
}

help_sudo() {
  cat <<'EOF'
sudo — стандартный инструмент для выполнения команд от имени администратора;
его используют все руководства в интернете. doas делает то же самое с гораздо
меньшим количеством кода; Reimu добавляет псевдоним «sudo», чтобы руководства
по-прежнему работали.
EOF
}

help_root() {
  cat <<'EOF'
root — всемогущая учётная запись. Большинство людей никогда не входят как root:
они используют sudo из своей учётной записи. Блокировка root (рекомендуется)
закрывает одну из дверей.
EOF
}

help_network() {
  cat <<'EOF'
• NetworkManager управляет Wi-Fi, проводной сетью, VPN и показывает значок
  сети в любом рабочем столе. Правильный выбор для ноутбуков и ПК.
• iwd — более лёгкая служба Wi-Fi, управляемая из терминала.
• systemd-networkd — для проводных серверов, без инструментов Wi-Fi.
EOF
}

help_extras() {
  cat <<'EOF'
• Bluetooth: наушники, мыши, геймпады.
• Печать: CUPS, система печати, с печатью в PDF.
• Брандмауэр: блокирует входящие соединения. Безвреден на ПК, полезен на
  ноутбуке в публичных сетях Wi-Fi.
• Сервер SSH: позволяет входить на этот компьютер с другого.
EOF
}

help_power() {
  cat <<'EOF'
Управление питанием ноутбука. power-profiles-daemon интегрируется с GNOME и
KDE (переключатель режима питания в меню). TLP сам по себе даёт больше
автономности, но не взаимодействует с рабочим столом. Выберите один, никогда
оба.
EOF
}

help_desktop() {
  cat <<'EOF'
Окружение рабочего стола — это то, что вы видите: панели, меню, окна,
настройки. GNOME и KDE Plasma — два больших полноценных рабочих стола. XFCE,
MATE и LXQt легче и проще. Hyprland, Sway, niri и i3 — «тайловые» менеджеры для
опытных пользователей, работающих с клавиатуры: быстрые, но настраивать всё
придётся самому. «Нет» оставляет только терминал.
EOF
}

help_dm() {
  cat <<'EOF'
Экран входа — это экран, где вы вводите пароль. «Авто» выбирает подходящий
для вашего рабочего стола. «Нет» означает, что вы входите в текстовой консоли и
запускаете рабочий стол вручную.
EOF
}

help_aur() {
  cat <<'EOF'
AUR — это репозиторий сообщества с тысячами дополнительных программ (Spotify,
Google Chrome, шрифты…). AUR-помощник устанавливает их как обычные пакеты.
paru и yay равноценны; paru более современный.
ВНИМАНИЕ: пакеты AUR — это рецепты, написанные другими пользователями, а не
Arch. Читайте PKGBUILD перед сборкой чего-либо незнакомого.
EOF
}

help_bundles() {
  cat <<'EOF'
Готовые наборы программ по темам. Выберите любые; каждый устанавливает
несколько известных приложений. Программы всегда можно добавить или удалить
позже.
EOF
}

help_locale() {
  cat <<'EOF'
Локаль — это язык меню, дат и чисел. Дополнительные локали позволяют
программам менять язык позже без переустановки. Раскладка клавиатуры
относится к текстовой консоли; у рабочих столов своя настройка, которую Reimu
тоже задаёт.
EOF
}

help_mirrors() {
  cat <<'EOF'
Зеркала — это серверы, с которых скачиваются пакеты. Выбор своей или соседней
страны делает загрузку намного быстрее. Reimu обновляет список еженедельным
таймером.
EOF
}

help_hostname() {
  cat <<'EOF'
Имя этого компьютера в сети (то, что вы видите в приглашении терминала).
Буквы, цифры и дефисы.
EOF
}

help_timezone() {
  cat <<'EOF'
Ваш часовой пояс в виде Регион/Город. Введите часть названия города для поиска.
EOF
}

help_repos() {
  cat <<'EOF'
Репозитории — это источники, из которых pacman устанавливает пакеты.
Репозитории Arch включены всегда.
• multilib: официальные 32-битные библиотеки; нужны Steam, Wine и многим
  играм.
• Chaotic-AUR: репозиторий сообщества с тысячами уже собранных программ из AUR
  (браузеры, редакторы, игры, шрифты…), которые устанавливаются за секунды
  вместо сборки. Широко используется; поддерживается членами сообщества Arch.
ВНИМАНИЕ: всё за пределами официальных репозиториев (Chaotic-AUR, свои
репозитории, сам AUR) не проверяется Arch Linux. Пакет оттуда может сломать
обновление или содержать что угодно. Включайте только то, что понимаете.
Другие источники (Liquorix, BlackArch, ALHP, Flatpak, Snap) можно включить
позже в настройках Sanae, с тем же предупреждением.
EOF
}

help_custom_repos() {
  cat <<'EOF'
Добавьте любой другой репозиторий pacman в виде имя=URL, через пробел. URL —
это строка «Server =» из инструкции к репозиторию, она может содержать $arch.
Reimu добавляет их с необязательными подписями и полным доверием, поэтому
добавляйте только репозитории, которым доверяете.
EOF
}

help_theme() {
  cat <<'EOF'
Тема меняет вид окон, кнопок и меню; значки меняют картинки в меню и
файловых менеджерах. Reimu устанавливает пакеты и задаёт их по умолчанию для
вашего пользователя, так что XFCE будет выглядеть так с первого входа. Темы
«AUR» требуют AUR-помощника из раздела «Программы» (paru или yay).
Это необязательно: ответьте «Нет», и XFCE останется ровно таким, как есть.
EOF
}

help_sanae() {
  cat <<'EOF'
В Windows программы устанавливают из магазина; в Arch вы вводите команды
pacman и ищете имена пакетов. Sanae — это такой магазин для терминала: он
показывает программы по назначению (Интернет, Игры, Офис, Разработка…) с
настоящим названием и строкой описания, сообщает, у скольких пользователей
Arch есть каждая, и устанавливает их одной клавишей. Он ищет одновременно в
официальных репозиториях и в AUR (репозитории сообщества с тысячами
дополнительных программ), поддерживает систему в актуальном состоянии,
предупреждая, когда Arch публикует новость, которую нужно прочитать перед
обновлением, и умеет очищать оставшиеся пакеты.
Есть и «рецепты»: настройки одной клавишей, которые устанавливают программу И
оставляют её работающей, чего обычные менеджеры пакетов не делают никогда.
Примеры: Docker с запущенной службой и доступом для вашего пользователя,
виртуальные машины QEMU, готовые к созданию ВМ, японский ввод, дополнительные
шрифты, темы XFCE.
От того же автора, что и Reimu. Это молодая программа. Она не заменяет pacman:
она запускает pacman за вас. Один файл в /usr/local/bin/sanae; удалить:
sudo rm /usr/local/bin/sanae
EOF
}

help_encrypt() {
  local tail=""
  (( DETECT_LAPTOP )) && tail=$'\nЭто ноутбук: шифрование настоятельно рекомендуется. Ноутбуки теряются.'
  cat <<EOF
Шифрование (LUKS) делает весь диск нечитаемым без вашего пароля, даже если
извлечь накопитель. Этот пароль вы будете вводить при каждой загрузке, до
запуска системы. Если забудете его, данные будут потеряны навсегда. На
современных компьютерах заметного замедления нет.$tail
EOF
}

help_swap() {
  local gib; gib="$(help_ram_gib)"
  cat <<EOF
Подкачка — это резервная память на диске, используемая, когда ОЗУ
заканчивается. В вашем компьютере ${gib} ГиБ ОЗУ.
• zram сжимает память прямо в ОЗУ: быстро, без места на диске, идеально для
  большинства. Гибернация (сон на диск) с одним только zram невозможна.
• Раздел подкачки нужен, если хотите гибернацию: не меньше объёма ОЗУ
  (${gib} ГиБ).
• Файл подкачки — как раздел, но его проще увеличить потом.
• Без подкачки: нормально при большом объёме ОЗУ, рискованно при менее 8 ГиБ.
EOF
}

help_bootloader() {
  local note=""
  if [[ "$DETECT_FIRMWARE" == bios ]]; then
    note=$'\nЭтот компьютер загрузился в режиме BIOS (legacy), поэтому systemd-boot недоступен.\nВ VirtualBox включите «Enable EFI» в разделе «Система»; в QEMU используйте OVMF;\nна реальном ПК найдите режим UEFI в настройках прошивки.'
  fi
  cat <<EOF
Загрузчик — это крошечная программа, которая запускает Linux при включении
компьютера.
• systemd-boot простой и быстрый, с минимальным меню. Только UEFI.
• GRUB показывает полное меню, может загружать другие системы (Windows) и
  снимки btrfs. Работает на UEFI и старых компьютерах с BIOS.
• Limine современный и крошечный, с аккуратным меню, работает на UEFI и
  BIOS.${note}
EOF
}

help_gpu() {
  local found="$DETECT_GPU"
  [[ "$DETECT_VIRT" != none ]] && found="виртуальная машина ($DETECT_VIRT)"
  cat <<EOF
Видеодрайвер делает рабочий стол плавным, а игры быстрыми. Reimu обнаружил:
${found}. Драйверы Intel и AMD открытые и просто работают. NVIDIA нужен свой:
«открытые модули» для карт с 2018 года (GTX 16xx, RTX), «проприетарный» для
более старых, «nouveau» — свободная, но медленная альтернатива.
EOF
}
