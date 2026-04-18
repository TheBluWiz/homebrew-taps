class Rotbyte < Formula
  desc "Guard your files against silent data corruption (bit rot)"
  homepage "https://github.com/TheBluWiz/RotByte"
  url "https://github.com/TheBluWiz/RotByte/archive/refs/tags/v1.1.0.tar.gz"
  sha256 "3172fec5a68891ab06c4f9de863ae77a25647de30bf66c2faad89ae78f78a712"
  license "MIT"

  depends_on "python@3.14"

  def install
    # Entry-point script + internal package must live together so Python's
    # automatic sys.path entry (the script's directory) can resolve `_rotbyte`.
    libexec.install "rotbyte.py"
    libexec.install "_rotbyte"

    (bin/"rotbyte").write_env_script(
      libexec/"rotbyte.py",
      PATH: "#{Formula["python@3.14"].opt_bin}:${PATH}"
    )

    man1.install "rotbyte.1"

    zsh_completion.install "completions/_rotbyte"
    bash_completion.install "completions/rotbyte_completions.bash" => "rotbyte"
    fish_completion.install "completions/rotbyte_completions.fish" => "rotbyte.fish"
  end

  test do
    (testpath/"data/hello.txt").write("hello world")
    system bin/"rotbyte", testpath/"data"
    assert_predicate testpath/"data/.data_rotbyte.db", :exist?

    output = shell_output("#{bin}/rotbyte --report #{testpath}/data")
    assert_match "OK", output

    json_output = shell_output("#{bin}/rotbyte --json #{testpath}/data")
    assert_match "\"status\"", json_output
  end
end