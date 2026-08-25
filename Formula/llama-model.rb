class LlamaModel < Formula
  desc "Manage and run local GGUF models with llama-server"
  homepage "https://github.com/dennisfriedrichsen/llama-model"
  url "https://github.com/dennisfriedrichsen/llama-model/archive/refs/tags/0.4.0.tar.gz"
  sha256 "fa3ee8c77a1c36cffe0a9e14b8dc11a26c472dedefa694e996b085e612f4c9fd"
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