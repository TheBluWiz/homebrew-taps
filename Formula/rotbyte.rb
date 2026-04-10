class Rotbyte < Formula
  desc "Guard your files against silent data corruption (bit rot)"
  homepage "https://github.com/TheBluWiz/RotByte"
  url "https://github.com/TheBluWiz/RotByte/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "ee78920aedfa42527200691ed39d12febcd3d8c0607a62382f1647d2be0ae2a1"
  license "MIT"

  depends_on "python@3.14"

  def install
    # Install the main script
    libexec.install "rotbyte.py"

    # Create a wrapper that invokes Python
    (bin/"rotbyte").write_env_script(
      libexec/"rotbyte.py",
      PATH: "#{Formula["python@3.14"].opt_bin}:${PATH}"
    )

    # Man page
    man1.install "rotbyte.1"

    # Shell completions
    zsh_completion.install "completions/_rotbyte"
    bash_completion.install "completions/rotbyte_completions.bash" => "rotbyte"
    fish_completion.install "completions/rotbyte_completions.fish" => "rotbyte.fish"
  end

  test do
    # Create a temp directory with a test file, run rotbyte, verify it indexes
    (testpath/"data/hello.txt").write("hello world")
    system bin/"rotbyte", testpath/"data"
    assert_predicate testpath/"data/.data_checksums.db", :exist?

    # Verify --report works
    output = shell_output("#{bin}/rotbyte --report #{testpath}/data")
    assert_match "OK", output

    # Verify --json works
    json_output = shell_output("#{bin}/rotbyte --json #{testpath}/data")
    assert_match "\"status\"", json_output
  end
end