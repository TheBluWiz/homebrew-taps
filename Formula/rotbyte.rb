class Rotbyte < Formula
    desc "Guard your files against silent data corruption (bit rot)"
    homepage "https://github.com/TheBluWiz/RotByte"
    url "https://github.com/TheBluWiz/RotByte/archive/refs/tags/v1.1.2.tar.gz"
    sha256 "7b4aa537ae87c2045d23a13ee2e92a7ef63df78dae2498f41224a7cd3c33a2d7"
    license "MIT"

    depends_on "python@3.14"
  
    def install
      # Install the entry point and its sibling package
      libexec.install "rotbyte.py", "_rotbyte"
  
      # Wrapper that puts python@3.14 first on PATH so the script's
      # `#!/usr/bin/env python3` shebang resolves to the right interpreter
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
      assert_predicate testpath/"data/.data_rotbyte.db", :exist?

      # Verify --report works
      output = shell_output("#{bin}/rotbyte --report #{testpath}/data")
      assert_match "OK", output

      # Verify --json works
      json_output = shell_output("#{bin}/rotbyte --json #{testpath}/data")
      assert_match "\"status\"", json_output
    end
  end
