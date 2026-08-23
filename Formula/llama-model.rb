class LlamaModel < Formula
  desc "Manage and run local GGUF models with llama-server"
  homepage "https://github.com/dennisfriedrichsen/llama-model"
  url "https://github.com/dennisfriedrichsen/llama-model/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "d5558cd419c8d46bdc958064cb97f963d1ea793866414c025906ec15033512ed"
  license "BSD-2-Clause"

  depends_on "llama.cpp"

  def install
    inreplace "llama-model", /^VERSION=dev$/, "VERSION=#{version}"

    bin.install "llama-model"
    man1.install "llama-model.1"

    doc.install "README.md"

    (pkgshare/"examples").install \
      "llama-models.conf.example",
      "server.args.example"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/llama-model --version")
  end
end