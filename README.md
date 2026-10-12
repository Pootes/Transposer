# Alto Sax Transposer

Convert a concert-pitch (or Bb/F/Eb) melody into the written alto saxophone part,
in the browser, for free. Transposition and engraving are client-side; nothing is
hosted beyond a static page. For personal practice use.

## Contents

    index.html         Primary tool. Verovio (WASM) engraving + transpose.
    index-osmd.html    Fallback tool. OpenSheetMusicDisplay (pure JS). Use if
                       Verovio does not load in your environment.
    vendor/setup.sh    Download the engines into vendor/ for fully offline use.
    omr/               PDF/image -> MusicXML (Audiveris, local). See omr/README.md.

## Run it

- Local: open `index.html` by double-clicking. Press "Load sample" to confirm the
  engine loads and the alto transposition renders.
- Hosted ($0): put these files in a GitHub repo, then Settings > Pages > Branch
  main, folder /root. Live at https://<user>.github.io/<repo>/ shortly after.

## Input

Load uncompressed MusicXML (`.musicxml` / `.xml`), exported from MuseScore, Finale,
Sibelius, or produced by the OMR workflow in `omr/`. Verovio also reads MEI.

## Offline / no-CDN

    bash vendor/setup.sh

Then change the `<script src>` line in `index.html` to `vendor/verovio-toolkit-wasm.js`
(and in `index-osmd.html` to `vendor/opensheetmusicdisplay.min.js`). The Verovio
`.wasm` is resolved next to its JS, so keep both in `vendor/`.

## Getting music in by name or link

Two ways to load without exporting a file yourself:

- **Fetch link** downloads a MusicXML / MEI / `.mxl` from a URL and runs it through the
  normal pipeline. It only works when the host sends CORS headers; raw GitHub file links
  (`raw.githubusercontent.com/...`) are the reliable case.
- **Search folk tunes** queries [thesession.org](https://thesession.org), an open library
  of traditional / folk tunes (CC-licensed ABC). A result is fetched as ABC, rendered and
  transposed natively by Verovio, and played back from Verovio's MIDI export.
- **Find on MuseScore** / **Find on web** open a name search in a new tab. Use these for
  Vietnamese and other songs: find a score there, download its MusicXML / `.mxl`, then load
  it with **Fetch link** or the file picker. The tool never fetches copyrighted content
  itself — it only helps you locate a file to download.

There is **no** free, legal way to auto-fetch arbitrary copyrighted songs by name —
Vietnamese or otherwise; no open API serves their MusicXML, and scraping score sites breaks
their terms. The **Vietnamese folk tune** button loads a traditional, public-domain melody
(*Kìa Con Bướm Vàng*, sung to the Frère Jacques tune) with Vietnamese lyrics as a built-in
example.

Verovio is pinned to a fixed version (`4.3.1`) rather than `latest`, because the rolling
`latest` build changed its startup API and left the engine stuck on "loading".

## Source detection

On load, the tool inspects the file's first part and sets the source dropdown
automatically. It reads the instrument name and General MIDI program for a readable
label (Piano, Guitar, Voice, Trumpet, ...), and the MusicXML `<transpose>` element
to decide whether the part is concert, Bb, F, or Eb written pitch. It also notes when
a file is a multi-staff (grand-staff) piano arrangement, where "Melody only" applies.
This is a best guess from metadata; a manual change to the dropdown is kept.

## The transposition

Alto saxophone is an Eb instrument: a written note sounds a major sixth lower than
concert pitch. Concert -> written alto is up a major sixth (M6, +9 semitones), which
adds 3 sharps to the key. The per-source, per-octave intervals are listed in the
`INTERVALS` table in `index.html` and shown live in the readout chip, so you can
check them against the staff rather than trust them.

## Melody extraction

Most downloadable scores are piano arrangements: two staves (treble melody over
bass accompaniment), with the melody line and the left-hand harmony on one part.
A saxophone plays a single line, so the default "Melody only" mode reduces the
score to one monophonic treble staff: it keeps the top staff, drops the bass staff
and its clef, reduces chords to their top note, keeps the lyrics, and renames the part
Alto Sax. "Full score" renders the source untouched.

This extraction is a heuristic, not musical intelligence. "Top staff, top note" is
usually the melody, but on a busy piano arrangement the top note can be a
right-hand harmony or ornament note rather than the tune, so the extracted line can
contain stray high notes. The reliable input is still a single-line lead sheet.
Review the result; correct it in MuseScore if the arrangement fooled the heuristic.

## Playback

The Play button plays the melody with **recorded alto-sax samples** (the MusyngKite
soundfont, via `soundfont-player`), streamed the first time you press Play, so it
sounds like a real horn. With no connection it falls back to a Web Audio synth tone
(sawtooth through a lowpass) for checking notes and rhythm. "Concert" plays the
pitches a real alto actually produces reading this part (the song's true sound);
"Written" sounds the noteheads at face value (a major sixth higher) to verify the page.

## Known limits, stated plainly

- Pitch is exact; enharmonic spelling of the written key is the renderer's call and
  is worth a glance on first load. A concert part in A major becomes F# major (6
  sharps) for alto, which is correct but accidental-heavy.
- Melody extraction is a heuristic (see above); verify the extracted line.
- Playback uses recorded sax samples when online; offline it falls back to a synth tone.
- No in-browser OMR. Scanning a PDF is a separate local Audiveris step (`omr/`), and
  its output must be reviewed before you trust it.
- `.mxl` (compressed MusicXML) is unpacked in the browser; `.mxl` from the OMR
  workflow is also handled by the Python script.
- Alto written range is roughly Bb3 to F6; use the octave control for lines that run
  off the staff.

## Verifying Verovio in your environment

I was not able to test the Verovio build from where this was written. If the staff
does not render in `index.html`, open the browser console. A failed script or `.wasm`
fetch points to the CDN/version or the self-host path. `index-osmd.html` is the
guaranteed-pure-JS fallback while you sort it out.
