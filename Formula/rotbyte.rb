class Rotbyte < Formula
  desc "Guard your files against silent data corruption (bit rot)"
  homepage "https://github.com/TheBluWiz/RotByte"
  url "https://github.com/TheBluWiz/RotByte/archive/refs/tags/v1.3.0.tar.gz"
  sha256 "7cbaec1b8d63e0e1d36d9248906bcc1fa86786c48d3d391aa3ae3ebf3b584487"
  license "MIT"

  depends_on "python@3.14"

  def install
    # Install the entry point and its sibling package
    libexec.install "rotbyte.py", "_rotbyte"

    # Wrapper that puts python@3.14 first on PATH so the script's
    # `#!/usr/bin/env python3` shebang resolves to the right interpreter
    (bin/"rotbyte").write_env_script(
      libexec/"rotbyte.py",
      PATH: "#{formula_opt_bin("python@3.14")}:${PATH}",
    )

    # Man pages: rotbyte.1 plus the section-7 conceptual guides
    man1.install "man/rotbyte.1"
    man7.install "man/rotbyte-notify.7", "man/rotbyte-permissions.7"

    # Setup guides (also readable in the terminal via `rotbyte --docs`)
    doc.install Dir["docs/*.md"]

    # Shell completions
    zsh_completion.install "completions/_rotbyte"
    bash_completion.install "completions/rotbyte_completions.bash" => "rotbyte"
    fish_completion.install "completions/rotbyte_completions.fish" => "rotbyte.fish"
  end

  def caveats
    <<~EOS
      Setup guides are available in the terminal:
        rotbyte --docs              # list topics
        rotbyte --docs notify       # email notifications
        rotbyte --docs permissions  # macOS Full Disk Access
        rotbyte --docs scheduler    # Windows Task Scheduler

      They are also installed under #{doc}, and notify/permissions as
      man pages (man rotbyte-notify, man rotbyte-permissions).
    EOS
  end

  test do
    # Create a temp directory with a test file, run rotbyte, verify it indexes
    (testpath/"data/hello.txt").write("hello world")
    system bin/"rotbyte", testpath/"data"
    assert_path_exists testpath/"data/.data_rotbyte.db"

    # Verify --report works
    output = shell_output("#{bin}/rotbyte --report #{testpath}/data")
    assert_match "OK", output

    # Verify --json works
    json_output = shell_output("#{bin}/rotbyte --json #{testpath}/data")
    assert_match "\"status\"", json_output

    # Verify the bundled --docs guides were packaged and are reachable
    assert_match "notify", shell_output("#{bin}/rotbyte --docs")
  end
end
