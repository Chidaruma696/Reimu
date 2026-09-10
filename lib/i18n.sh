# shellcheck shell=bash
# Reimu · i18n: every user-facing string is written in English in the code and
# looked up in a table at display time. A language file fills the table and may
# redefine the help_* texts. Missing entries fall back to English.
#
#   t "English text"            -> translated text, or the English one
#   tf "Template %s" "value"    -> same, through printf
#   i18n_load es                -> source lib/lang/es.sh

declare -A T=()
REIMU_LANG="${REIMU_LANG:-en}"

# Languages Reimu ships with: code|Native name.
I18N_LANGS=("en|English" "es|Español")

t() {
  local s="$1"
  if [[ -n "${T[$s]+x}" ]]; then printf '%s' "${T[$s]}"; else printf '%s' "$s"; fi
}

tf() {
  local template="$1"; shift
  # shellcheck disable=SC2059
  printf "$(t "$template")" "$@"
}

i18n_load() {
  local code="$1" file
  REIMU_LANG="$code"
  T=()
  [[ "$code" == en ]] && return 0
  file="$REIMU_DIR/lib/lang/$code.sh"
  if [[ -r "$file" ]]; then
    # shellcheck disable=SC1090
    source "$file"
  else
    warn "No translation for '$code'; using English."
    REIMU_LANG=en
  fi
  return 0
}

# Pick the language from the environment when nothing was chosen yet.
i18n_guess() {
  case "${LANG:-}${LC_ALL:-}" in
    es*|*:es*) printf 'es' ;;
    *) printf 'en' ;;
  esac
}
