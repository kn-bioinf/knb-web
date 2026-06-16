#!/usr/bin/env bash
#
# build-game.sh — kompiluje grę pygame do wersji webowej (pygbag) i wgrywa
# gotowy artefakt do tej strony (static/). Kod źródłowy gry NIE jest tu
# kopiowany — pozostaje w swoim repozytorium. Tutaj trafia tylko zbudowany,
# statyczny wynik (jak skompilowany plik).
#
# Użycie:
#   scripts/build-game.sh <katalog_z_gra> <slug> [--python <python>]
#
# Przykład:
#   scripts/build-game.sh ../science-picnic-2026 kinesinquest \
#       --python ~/miniconda3/envs/kinesinquest/bin/python
#
# Po zbudowaniu:  hugo serve   (test)  ->  commit  ->  push (deploy)
#
set -euo pipefail

GAME_DIR="${1:?podaj katalog z grą, np. ../science-picnic-2026}"
SLUG="${2:?podaj slug gry, np. kinesinquest}"
shift 2 || true

PYTHON="python3"
PYGBAG_VERSION="0.9.3"
while [ $# -gt 0 ]; do
	case "$1" in
		--python) PYTHON="$2"; shift 2 ;;
		*) echo "Nieznany argument: $1" >&2; exit 1 ;;
	esac
done

# Katalog tej strony (rodzic katalogu scripts/)
WEB_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATIC="$WEB_ROOT/static"
GAME_OUT="$STATIC/games/$SLUG"
CDN_OUT="$STATIC/cdn"
CDN_BASE="https://pygame-web.github.io/cdn"

echo ">> Buduję $SLUG z $GAME_DIR (pygbag $PYGBAG_VERSION)"
( cd "$GAME_DIR" && "$PYTHON" -m pygbag --build --ume_block 0 --title "$SLUG" main.py >/dev/null )

BUILD_WEB="$GAME_DIR/build/web"
[ -f "$BUILD_WEB/index.html" ] || { echo "Brak build/web/index.html — build nie powiódł się" >&2; exit 1; }

echo ">> Przepinam runtime na lokalny /cdn/ (self-hosting, same-origin)"
sed -i 's#https://pygame-web\.github\.io/cdn/#/cdn/#g' "$BUILD_WEB/index.html"

# Wyłączamy debugowy terminal xterm (vtx) — gra go nie potrzebuje, a jego
# inicjalizacja potrafi zawiesić ładowanie. Zostają: snd (dźwięk) + gui (canvas).
echo ">> Wyłączam debugowy terminal (vtx)"
sed -i 's/data-os="vtx,snd,gui"/data-os="snd,gui"/' "$BUILD_WEB/index.html"

# gui_divider=2 rezerwuje połowę kanwy na (wyłączony) terminal — gra była
# ściśnięta z szarym marginesem. =1 oddaje grze pełny obszar 16:9.
echo ">> Ustawiam gui_divider=1 (pełna kanwa gry)"
sed -i 's/gui_divider : 2/gui_divider : 1/' "$BUILD_WEB/index.html"

# can_close=1 wyłącza okno "Are you sure you want to navigate away?"
# (pygbag rejestruje onbeforeunload tylko gdy can_close=0). Osadzona gra
# nie powinna blokować odświeżania/wyjścia ze strony.
echo ">> Wyłączam ostrzeżenie o opuszczaniu strony (can_close=1)"
sed -i 's/can_close : 0/can_close : 1/' "$BUILD_WEB/index.html"

# Wstrzykujemy własny styl ekranu ładowania (białe tło + granatowy komunikat).
STYLE_FILE="$WEB_ROOT/scripts/loader-style.html"
if [ -f "$STYLE_FILE" ]; then
	echo ">> Wstrzykuję styl ekranu ładowania"
	"$PYTHON" - "$BUILD_WEB/index.html" "$STYLE_FILE" <<'PYEOF'
import sys
html_path, style_path = sys.argv[1], sys.argv[2]
html = open(html_path, encoding="utf-8").read()
style = open(style_path, encoding="utf-8").read()
if "KNB: styl ekranu" not in html:
    html = html.replace("</head>", style + "\n</head>", 1)
    open(html_path, "w", encoding="utf-8").write(html)
PYEOF
fi

echo ">> Kopiuję artefakt gry -> static/games/$SLUG/"
mkdir -p "$GAME_OUT"
cp "$BUILD_WEB/index.html" "$GAME_OUT/index.html"
# Runtime pobiera archiwum gry jako .tar.gz — to plik wymagany. .apk kopiujemy
# pomocniczo (do pobrania/uruchomienia offline), ale gra w przeglądarce używa .tar.gz.
cp "$BUILD_WEB"/*.tar.gz "$GAME_OUT/" 2>/dev/null || true
cp "$BUILD_WEB"/*.apk "$GAME_OUT/" 2>/dev/null || true
cp "$BUILD_WEB/favicon.png" "$GAME_OUT/" 2>/dev/null || true

# Runtime pygbag (~22 MB) jest wspólny dla wszystkich gier — pobieramy raz.
if [ ! -f "$CDN_OUT/0.9.3/pythons.js" ]; then
	echo ">> Pobieram runtime pygbag do static/cdn/ (jednorazowo)"
	mkdir -p "$CDN_OUT/0.9.3/cpython312" "$CDN_OUT/cp312" "$CDN_OUT/vt"
	dl() { curl -fsSL --max-time 180 "$CDN_BASE/$1" -o "$CDN_OUT/$2" && echo "   OK  $2" || echo "   (pominięto, opcjonalne) $2"; }
	dl "0.9.3/pythons.js"                  "0.9.3/pythons.js"
	dl "0.9.3/empty.html"                  "0.9.3/empty.html"
	dl "0.9.3/cpythonrc.py"                "0.9.3/cpythonrc.py"
	dl "0.9.3/favicon.png"                 "0.9.3/favicon.png"
	dl "0.9.3/cpython312/main.js"          "0.9.3/cpython312/main.js"
	dl "0.9.3/cpython312/main.wasm"        "0.9.3/cpython312/main.wasm"
	dl "0.9.3/cpython312/main.data"        "0.9.3/cpython312/main.data"
	dl "cp312/pygame_ce-2.5.7-cp312-cp312-wasm32_bi_emscripten.whl" "cp312/pygame_ce-2.5.7-cp312-cp312-wasm32_bi_emscripten.whl"
	dl "index-0.9.3-cp312.json"            "index-0.9.3-cp312.json"
	dl "vtx.js"                            "vtx.js"
	dl "vt/xterm.js"                       "vt/xterm.js"
	dl "vt/xterm.css"                      "vt/xterm.css"
	dl "vt/xterm-addon-image.js"           "vt/xterm-addon-image.js"
else
	echo ">> static/cdn/ już istnieje — pomijam pobieranie runtime"
fi

echo ">> Gotowe. Test:  hugo serve  ->  http://localhost:1313/projekty/$SLUG/"
