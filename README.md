# homebrew-taps

Homebrew tap for [TheBluWiz](https://github.com/TheBluWiz) projects.

## Tap

```bash
brew tap TheBluWiz/taps
```

---

## Formulas

### muxm

[MuxMaster](https://github.com/TheBluWiz/MuxMaster) — a video encoding/muxing utility for Dolby Vision, HDR10, HLG, and SDR with format profiles.

```bash
brew install TheBluWiz/taps/muxm
```

First-time setup:

```bash
muxm --install-completions   # tab completion for bash/zsh
```

Optional dependencies (auto-disabled at runtime if missing):

```bash
brew install dovi_tool    # Dolby Vision RPU extraction/injection
brew install gpac         # DV container signaling verification (MP4Box)
brew install tesseract    # PGS subtitle OCR engine
```

For subtitle burn-in (`--sub-burn-forced`), ffmpeg needs libass:

```bash
brew install ffmpeg-full          # includes libass + tesseract
brew link --force ffmpeg-full     # keg-only — must be linked manually
```

Or run `muxm --install-dependencies` to handle everything automatically.

Uninstall:

```bash
muxm --uninstall-completions
muxm --uninstall-man
brew uninstall muxm
```

---

### rotbyte

[RotByte](https://github.com/TheBluWiz/RotByte) — guard your files against silent data corruption (bit rot).

```bash
brew install TheBluWiz/taps/rotbyte
```

Shell completions for bash, zsh, and fish are installed automatically.

Uninstall:

```bash
brew uninstall rotbyte
```

---

## Update all

```bash
brew update
brew upgrade
```

Or upgrade a specific formula:

```bash
brew upgrade muxm
brew upgrade rotbyte
```

---

## Publishing and version bumps

See [PUBLISHING.md](PUBLISHING.md) for instructions on releasing new versions or adding new formulas to this tap.
