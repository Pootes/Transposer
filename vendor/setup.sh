#!/usr/bin/env bash
# Download the engraving engines into vendor/ so the tool runs fully offline,
# with no CDN dependency. Run this on your own machine (it needs internet once).
#
#   bash vendor/setup.sh
#
# After it finishes, edit the <script src> lines:
#   index.html       -> vendor/verovio-toolkit-wasm.js  and  vendor/fflate.min.js
#   index-osmd.html  -> vendor/opensheetmusicdisplay.min.js  and  vendor/fflate.min.js
#
# Pin the versions below to whatever you verified works, rather than tracking latest.

set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"

VEROVIO_JS="https://www.verovio.org/javascript/latest/verovio-toolkit-wasm.js"
VEROVIO_WASM="https://www.verovio.org/javascript/latest/verovio.wasm"
OSMD_VER="1.8.7"
OSMD_JS="https://cdnjs.cloudflare.com/ajax/libs/opensheetmusicdisplay/${OSMD_VER}/opensheetmusicdisplay.min.js"
FFLATE_VER="0.8.2"
FFLATE_JS="https://cdnjs.cloudflare.com/ajax/libs/fflate/${FFLATE_VER}/umd/index.min.js"

echo "Fetching Verovio (JS + WASM) ..."
curl -fL "$VEROVIO_JS"   -o "$DIR/verovio-toolkit-wasm.js"
curl -fL "$VEROVIO_WASM" -o "$DIR/verovio.wasm"

echo "Fetching OpenSheetMusicDisplay ${OSMD_VER} ..."
curl -fL "$OSMD_JS" -o "$DIR/opensheetmusicdisplay.min.js"

echo "Fetching fflate ${FFLATE_VER} (.mxl unpacking) ..."
curl -fL "$FFLATE_JS" -o "$DIR/fflate.min.js"

echo "Done. Files in $DIR:"
ls -lh "$DIR" | awk 'NR>1 {print "  " $9 "  " $5}'
echo
echo "The Verovio .wasm is resolved next to its JS, so keep both files together in vendor/."
