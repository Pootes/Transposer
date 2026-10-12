#!/usr/bin/env python3
# Convert a compressed MusicXML (.mxl, which is a zip) to uncompressed .musicxml.
# Audiveris exports .mxl; the browser tool reads uncompressed MusicXML, so this
# bridges the two. Run with -I for safety when handling files from outside sources.
#
#   python3 -I mxl2xml.py path/to/score.mxl [output.musicxml]
#
# With no output path, writes alongside the input with a .musicxml extension.

import sys
import os
import zipfile
import xml.etree.ElementTree as ET


def rootfile_path(zf):
    # META-INF/container.xml names the real score file inside the archive.
    try:
        with zf.open("META-INF/container.xml") as c:
            tree = ET.parse(c)
        for rf in tree.iter():
            if rf.tag.endswith("rootfile"):
                fp = rf.get("full-path")
                if fp:
                    return fp
    except KeyError:
        pass
    # Fallback: first .xml/.musicxml entry that is not in META-INF.
    for name in zf.namelist():
        low = name.lower()
        if not name.startswith("META-INF/") and (low.endswith(".xml") or low.endswith(".musicxml")):
            return name
    raise SystemExit("No MusicXML entry found inside the .mxl archive.")


def main():
    if len(sys.argv) < 2:
        raise SystemExit("usage: mxl2xml.py input.mxl [output.musicxml]")
    src = sys.argv[1]
    if not zipfile.is_zipfile(src):
        raise SystemExit(f"{src} is not a valid .mxl (zip) file.")
    with zipfile.ZipFile(src) as zf:
        inner = rootfile_path(zf)
        data = zf.read(inner)
    if len(sys.argv) >= 3:
        out = sys.argv[2]
    else:
        out = os.path.splitext(src)[0] + ".musicxml"
    with open(out, "wb") as f:
        f.write(data)
    print(f"Wrote {out} ({len(data)} bytes)")


if __name__ == "__main__":
    main()
