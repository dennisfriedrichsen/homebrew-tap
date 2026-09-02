# Homebrew formula for the netdash macOS collector.
#
# Tap:  https://github.com/dennisfriedrichsen/homebrew-tap
# Ships as: brew install dennisfriedrichsen/tap/netdash-collector
#
# Re-publishing a new version:
#   git tag 0.3.1 && git push origin 0.3.1
#   curl -sL https://github.com/dennisfriedrichsen/netdash/archive/refs/tags/0.3.1.tar.gz | shasum -a 256
#
# netdash-patchcheck is a separate formula from the same tarball: Homebrew
# allows one service per formula, and the patch check runs daily rather than
# every 60 seconds.
class NetdashCollector < Formula
  desc "Pushes CPU, memory and disk metrics to a netdash server"
  homepage "https://github.com/dennisfriedrichsen/netdash"
  url "https://github.com/dennisfriedrichsen/netdash/archive/refs/tags/0.3.1.tar.gz"
  sha256 "c122ef7d8fee3c5816c6ecd46eafbaa4df9e94b151e9e3423c3e3435974215f7"
  license "BSD-2-Clause"

  def install
    bin.install "collectors/macos/netdash-collector.sh" => "netdash-collector"
    # Installed only if absent, so `brew upgrade` never clobbers a real token.
    (etc/"netdash").install "homebrew/collector.conf.sample" => "collector.conf"
  end

  service do
    run [opt_bin/"netdash-collector"]
    run_type :interval
    interval 60
    log_path var/"log/netdash-collector.log"
    error_log_path var/"log/netdash-collector.log"
  end

  def caveats
    <<~EOS
      Set the server URL and token BEFORE starting the service:
        nano #{etc}/netdash/collector.conf      (or any editor)

      Do not rely on $EDITOR here -- if it is unset, the shell tries to execute
      the config file and reports "permission denied" without opening it.

      Check it took, before starting anything:
        netdash-collector --print     # prints the JSON it would send
        netdash-collector             # silent + exit 0 means the post worked

      Then start the launchd timer (Homebrew never auto-starts services on install):
        brew services start netdash-collector

      Verify what it will send:
        netdash-collector --print

      For the patch status badge (security updates pending), also install:
        brew install dennisfriedrichsen/tap/netdash-patchcheck
        brew services start netdash-patchcheck
      Without it the card reads "not checked" -- which is deliberate: an
      unchecked host must never be shown as up to date.

      Updates later:
        brew update && brew upgrade netdash-collector
      (brew services restarts the job automatically on upgrade.)
    EOS
  end

  test do
    output = shell_output("#{bin}/netdash-collector --print")
    assert_match "cpu_pct", output
    # Always present, null when no patch check has run -- the server reads a
    # missing or null value as "unknown" rather than as up to date.
    assert_match "patches", output
  end
end
