# Publishing projects to Homebrew via a personal tap

## Overview

This repo (`TheBluWiz/homebrew-taps`) is a single Homebrew tap that hosts formulas for multiple projects. Each project lives in `Formula/<name>.rb` and points to releases in its own source repo.

Current projects:

| Formula | Source repo | Language |
|---------|-------------|----------|
| `muxm` | [TheBluWiz/MuxMaster](https://github.com/TheBluWiz/MuxMaster) | Bash |
| `rotbyte` | [TheBluWiz/RotByte](https://github.com/TheBluWiz/RotByte) | Python |

---

## Adding a new project to this tap

### Step 1: Create a tagged release on the source repo

In your local checkout of the source project:

```bash
git tag -a v1.0.0 -m "v1.0.0"
git push origin v1.0.0
```

Then go to the GitHub releases page for that project and publish a release against that tag. GitHub automatically generates a source tarball at:

```
https://github.com/<owner>/<repo>/archive/refs/tags/v1.0.0.tar.gz
```

### Step 2: Get the SHA256 hash

```bash
curl -sL https://github.com/TheBluWiz/rotbyte/archive/refs/tags/v1.0.0.tar.gz \
  | shasum -a 256
```

Copy the hash — you'll put it in the formula.

### Step 3: Write the formula

Create `Formula/<name>.rb` in this repo. At minimum:

```ruby
class <Name> < Formula
  desc "One-line description of the tool"
  homepage "https://github.com/<owner>/<repo>"
  url "https://github.com/<owner>/<repo>/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "<hash from step 2>"
  license "<license identifier>"

  depends_on "<runtime>"   # e.g. "python@3.14", "bash", "node"

  def install
    bin.install "<script-or-binary>"
    man1.install "<name>.1"   # if a man page exists
  end

  test do
    assert_match "<name> v#{version}", shell_output("#{bin}/<name> --version")
  end
end
```

See `Formula/muxm.rb` for a Bash example (shebang rewriting, post-install hooks, caveats) and `Formula/rotbyte.rb` for a Python example (libexec wrapper, shell completions for bash/zsh/fish).

### Step 4: Test the install locally

```bash
brew tap TheBluWiz/taps
brew install TheBluWiz/taps/<name>
<name> --version
```

To test the formula file directly before pushing:

```bash
brew install --build-from-source Formula/<name>.rb
brew test Formula/<name>.rb
```

### Step 5: Commit and push

```bash
git add Formula/<name>.rb
git commit -m "<name> 1.0.0"
git push
```

---

## Releasing a new version of an existing project

Do this for both muxm and rotbyte (or any future project) whenever you cut a new release.

### Step 1: Tag and publish the release on the source repo

```bash
# In the source project's repo
git tag -a v1.1.0 -m "v1.1.0"
git push origin v1.1.0
# Publish the GitHub release
```

### Step 2: Get the new SHA256

```bash
# muxm example
curl -sL https://github.com/TheBluWiz/MuxMaster/archive/refs/tags/v1.1.0.tar.gz \
  | shasum -a 256

# rotbyte example
curl -sL https://github.com/TheBluWiz/RotByte/archive/refs/tags/v1.1.0.tar.gz \
  | shasum -a 256
```

### Step 3: Update the formula

In `Formula/<name>.rb`, change two lines:

```ruby
url "https://github.com/<owner>/<repo>/archive/refs/tags/v1.1.0.tar.gz"
sha256 "<new hash>"
```

### Step 4: Commit and push

```bash
git add Formula/<name>.rb
git commit -m "<name> 1.1.0"
git push
```

### Step 5: Verify the upgrade

```bash
brew update && brew upgrade <name>
<name> --version
```

---

## Notes

### muxm-specific

- **bc** is pre-installed on macOS — not declared as a dependency.
- **ffprobe** ships with ffmpeg — no separate dependency needed.
- The formula rewrites the shebang from `#!/usr/bin/env bash` to Homebrew's bash so muxm always runs under bash 4.3+ regardless of the user's default shell.
- `dovi_tool`, `gpac`, and `tesseract` are not declared as `depends_on` because muxm gracefully disables those features at runtime when they're absent.
- The `post_install` block runs `muxm --install-man` and `muxm --install-completions` automatically on install/upgrade.

### rotbyte-specific

- Shell completions (bash, zsh, fish) are installed directly by the formula from the `completions/` directory in the source tarball.
- The formula uses a `write_env_script` wrapper so the `rotbyte` command always resolves to the correct Python interpreter.

### General

- Homebrew taps must be hosted in a repo named `homebrew-<tapname>`. This repo is `homebrew-taps`, so users tap it as `TheBluWiz/taps`.
- A formula's class name must be the PascalCase version of its filename (e.g. `rotbyte.rb` → `class Rotbyte`).
- Always test with `brew install --build-from-source` before pushing a new formula or version bump.
