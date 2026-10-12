# OMR workflow (PDF/image to MusicXML, local and free)

In-browser note recognition does not exist reliably, so scanning happens here, on
your own machine, with Audiveris. The output feeds the browser transposer. No
server, no subscription.

## 1. Install Java 17+

Audiveris 5.3/5.4 needs a Java 17 or newer runtime.

- Check: `java -version`
- If missing: install Temurin/OpenJDK 17 (adoptium.net) or your OS package.

## 2. Install Audiveris

- Windows: use the installer from the Audiveris GitHub releases. The launcher
  lands at something like `C:/Program Files/Audiveris/bin/Audiveris.bat`.
- macOS / Linux: build from source (official method):

      git clone https://github.com/Audiveris/audiveris.git
      cd audiveris
      ./gradlew build
      # run with: ./gradlew run --args="..."

If `audiveris` is not on your PATH, point the script at the launcher:

    export AUDIVERIS=/path/to/Audiveris
    # or, when built from source:
    export AUDIVERIS="./gradlew run --args="

## 3. Convert

    bash omr/convert.sh path/to/sheet.pdf

This runs Audiveris headless, exports MusicXML, and unpacks the compressed `.mxl`
into uncompressed `.musicxml` (what the transposer reads). Results land in
`omr/out/` by default.

## 4. Review, then transpose

OMR is assistive. Open the `.musicxml` in MuseScore, fix misread notes, rhythms,
and accidentals, then load it into `../index.html` to get the alto part.

## What works and what does not

- Best: clean, printed, single-staff monophonic melodies and lead sheets.
- Rough: dense polyphony, handwriting, low-quality scans, photos at an angle.
- Always verify the output. Treat the transposition as correct only after you
  have checked the notes Audiveris produced.
