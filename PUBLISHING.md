# Publishing muxm to Homebrew via a personal tap

## Overview

Two repos work together:

- **TheBluWiz/MuxMaster** — the source project (unchanged)
- **TheBluWiz/homebrew-muxm** — the tap (a Formula that points to MuxMaster releases)

## Step 1: Create a tagged release on MuxMaster

In your local MuxMaster checkout:

```bash
git tag -a v1.0.0 -m "v1.0.0 — initial Homebrew release"
git push origin v1.0.0
```

Then go to https://github.com/TheBluWiz/MuxMaster/releases and click
**Draft a new release**:

- **Tag:** v1.0.0 (the tag you just pushed)
- **Title:** MuxMaster v1.0.0
- **Description:** whatever changelog notes you want
- **Publish release**

GitHub automatically generates a source tarball at:
`https://github.com/TheBluWiz/MuxMaster/archive/refs/tags/v1.0.0.tar.gz`

## Step 2: Get the SHA256 hash

Download the tarball and hash it:

```bash
curl -sL https://github.com/TheBluWiz/MuxMaster/archive/refs/tags/v1.0.0.tar.gz \
  | shasum -a 256
```

Copy the hash — you'll paste it into the formula.

## Step 3: Create the homebrew-muxm repo

Create a new repo on GitHub named **homebrew-muxm** under your account.
Then push the tap:

```bash
cd homebrew-muxm
git init
git add .
git commit -m "muxm 1.0.0"
git remote add origin git@github.com:TheBluWiz/homebrew-muxm.git
git push -u origin main
```

## Step 4: Update the SHA256 in the formula

Edit `Formula/muxm.rb` and replace `PLACEHOLDER_SHA256` with the real hash
from Step 2. Commit and push.

## Step 5: Test the install

```bash
# Clean test (uninstall first if you have a manual install)
brew tap TheBluWiz/muxm
brew install muxm
muxm --version
muxm --install-completions
```

## Releasing a new version

When you ship a new version of muxm:

1. Tag and release on MuxMaster:
   ```bash
   git tag -a v1.1.0 -m "v1.1.0"
   git push origin v1.1.0
   # Publish the release on GitHub
   ```

2. Get the new SHA:
   ```bash
   curl -sL https://github.com/TheBluWiz/MuxMaster/archive/refs/tags/v1.1.0.tar.gz \
     | shasum -a 256
   ```

3. Update the formula in homebrew-muxm:
   - Change `url` to point to the new tag
   - Replace the `sha256` value
   - Commit and push

4. Users update with:
   ```bash
   brew update && brew upgrade muxm
   ```

## Notes

- **bc** is pre-installed on macOS, so it's not declared as a Homebrew
  dependency. Linux users installing via Homebrew would already have it.

- **ffprobe** ships with the ffmpeg package — no separate dependency needed.

- The formula rewrites the shebang from `#!/usr/bin/env bash` to
  Homebrew's bash so muxm always runs under bash 4.3+ even if the user's
  default shell or PATH gives them macOS system bash 3.2.

- The formula does NOT declare dovi_tool, gpac, or tesseract as
  dependencies because muxm gracefully disables those features at runtime
  when they're missing. Declaring them as `depends_on` would force every
  user to install them even if they never use DV or subtitle OCR.

- The `post_install` block runs `muxm --install-man` which detects
  `brew --prefix` and writes the man page to the correct location
  automatically. Completions are left to the user (`muxm --install-completions`)
  because that command modifies shell RC files, which shouldn't happen
  silently during a brew install.
