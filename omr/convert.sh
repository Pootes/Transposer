#!/usr/bin/env bash
# PDF/image -> MusicXML using Audiveris (local OMR), then unpack to uncompressed
# .musicxml ready to load into the transposer. Nothing here is hosted; it all runs
# on your machine and costs nothing.
#
#   bash omr/convert.sh input.pdf [output_dir]
#
# Requirements:
#   - Java 17+ (Audiveris 5.3/5.4 needs it)
#   - Audiveris installed. Set AUDIVERIS to its launcher if 'audiveris' is not on PATH:
#       export AUDIVERIS=/path/to/Audiveris        (Linux/macOS)
#       export AUDIVERIS="C:/Program Files/Audiveris/bin/Audiveris.bat"   (Windows/Git Bash)
#     Built from source? Use:  export AUDIVERIS="./gradlew run --args="
#
# OMR is assistive, not exact. Expect to open the result in MuseScore and fix
# wrong notes before trusting it. Clean, printed, single-line melodies do best.

set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
AUDIVERIS="${AUDIVERIS:-audiveris}"

if [ $# -lt 1 ]; then
  echo "usage: convert.sh input.pdf [output_dir]" >&2
  exit 1
fi
IN="$1"
OUT="${2:-$HERE/out}"
mkdir -p "$OUT"

if ! command -v "${AUDIVERIS%% *}" >/dev/null 2>&1 && [ ! -x "${AUDIVERIS%% *}" ]; then
  echo "Audiveris launcher not found: $AUDIVERIS" >&2
  echo "Install it, or set AUDIVERIS to the correct path (see header of this script)." >&2
  exit 127
fi

echo "Running Audiveris (batch, export) on: $IN"
# -batch: no GUI. -export: write MusicXML. -output: destination. -- : end of options.
$AUDIVERIS -batch -export -output "$OUT" -- "$IN"

echo "Unpacking any .mxl to uncompressed .musicxml ..."
found=0
while IFS= read -r -d '' f; do
  python3 -I "$HERE/mxl2xml.py" "$f"
  found=1
done < <(find "$OUT" -type f -name '*.mxl' -print0)

if [ "$found" -eq 0 ]; then
  echo "No .mxl produced. Check Audiveris output in $OUT (it may have exported .xml directly, or failed on this page)." >&2
else
  echo "Done. Load the .musicxml from $OUT into index.html, then review and fix notes."
fi
