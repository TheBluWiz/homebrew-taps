# typed: false
  # frozen_string_literal: true

  # Formula for MuxMaster (muxm) — video encoding/muxing utility
  # https://github.com/TheBluWiz/MuxMaster
  class Muxm < Formula
    desc "Universal video encoder/muxer for DV, HDR10, HLG, and SDR with format profiles"
    homepage "https://github.com/TheBluWiz/MuxMaster"
    url "https://github.com/TheBluWiz/MuxMaster/archive/refs/tags/v1.5.0.tar.gz"
    sha256 "8dae832ef509a9406f8a7fe38db00ecc8ae9b1e081f2ac767b53e7bc2bf1da9d"
    license :cannot_represent # MuxMaster Freeware License v1.0.1

    depends_on "bash"   # macOS ships bash 3.2; muxm requires 4.3+
    depends_on "jq"
    depends_on :macos   # tested primarily on macOS; Linux users install differently
  
    # ffmpeg is required but users may want the homebrew-ffmpeg tap build
    # (--with-libass) for subtitle burn-in. We depend on core ffmpeg and
    # note the libass upgrade path in caveats.
    depends_on "ffmpeg"

    # Optional but recommended — gracefully disabled at runtime if missing.
    # Not declared as depends_on because muxm auto-disables features when
    # they're absent. Users can install as needed:
    #   brew install dovi_tool gpac tesseract

    def install
      # Rewrite shebang from /usr/bin/env bash to Homebrew's bash 4.3+.
      # inreplace raises if the exact string isn't found, so a drifted
      # first line in the source will fail loudly rather than silently.
      inreplace "muxm", "#!/usr/bin/env bash",
                        "#!#{Formula["bash"].opt_bin}/bash"

      bin.install "muxm"
      man1.install "docs/muxm.1"
      bash_completion.install "completions/muxm-completion.bash" => "muxm"
    end

    def caveats
      <<~EOS
        Optional dependencies (install as needed):

          brew install dovi_tool         # Dolby Vision RPU handling
          brew install gpac              # DV container signaling (MP4Box)
          brew install tesseract         # PGS subtitle OCR

        For subtitle burn-in (--sub-burn-forced), ffmpeg must be built with
        libass. The simplest option:
  
          brew install ffmpeg-full       # includes libass + tesseract

        Or run: muxm --install-dependencies
      EOS
    end

    test do
      assert_match "MuxMaster v#{version}", shell_output("#{bin}/muxm --version")
    end
  end
