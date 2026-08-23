class LlamaModel < Formula
  desc "Manage and run local GGUF models with llama-server"
  homepage "https://github.com/dennisfriedrichsen/llama-model"
  url "https://github.com/dennisfriedrichsen/llama-model/archive/refs/tags/0.3.0.tar.gz"
  sha256 "f78434eb00ac66ed5f4316772b25948677bcba06b69eec84fc681c1293a24d9d"
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