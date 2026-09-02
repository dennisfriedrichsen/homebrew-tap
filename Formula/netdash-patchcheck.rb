# Homebrew formula for the netdash macOS patch check.
#
# Tap:  https://github.com/dennisfriedrichsen/homebrew-tap
# Ships as: brew install dennisfriedrichsen/tap/netdash-patchcheck
#
# Separate from netdash-collector, from the same tarball, because a formula may
# define only one service and these two run on very different clocks: the
# collector every 60 seconds, this once a day.
#
# Re-publishing a new version:
#   git tag 0.3.2 && git push origin 0.3.2
#   curl -sL https://github.com/dennisfriedrichsen/netdash/archive/refs/tags/0.3.2.tar.gz | shasum -a 256
class NetdashPatchcheck < Formula
  desc "Reports pending macOS security updates to a netdash server"
  homepage "https://github.com/dennisfriedrichsen/netdash"
  url "https://github.com/dennisfriedrichsen/netdash/archive/refs/tags/0.3.2.tar.gz"
  sha256 "c8848cdb7d739ba660d209eaa50e814e4e52cfebe7f18654630e2037df625dcd"
  license "BSD-2-Clause"

  # For the shared $(brew --prefix)/etc/netdash/collector.conf, and because a
  # patch check with no collector to report it has nothing to talk to.
  depends_on "dennisfriedrichsen/tap/netdash-collector"

  def install
    bin.install "collectors/macos/netdash-patchcheck.sh" => "netdash-patchcheck"
  end

  # Daily, not on an interval: this reads the software-update scan macOS already
  # performs every six hours, and `softwareupdate -l` costs tens of seconds on
  # the rare occasions it has to force one. The collector picks the result up
  # from disk on its next 60-second run.
  service do
    run [opt_bin/"netdash-patchcheck"]
    run_type :cron
    cron "17 3 * * *"
    log_path var/"log/netdash-patchcheck.log"
    error_log_path var/"log/netdash-patchcheck.log"
  end

  def caveats
    <<~EOS
      Homebrew never auto-starts a service, so schedule it once:
        brew services start netdash-patchcheck

      Check what it will report:
        netdash-patchcheck --print    # prints the JSON, writes nothing
        netdash-patchcheck            # writes #{var}/netdash/patches.json

      The collector inlines that file on its next run. Until the check has run
      the card reads "not checked", and a result older than the server's
      patch_stale_hours reads "unknown" -- never "up to date". An unverified
      host is not a patched host.
    EOS
  end

  test do
    # A Mac that has never completed a software update scan has no
    # LastSuccessfulDate, and the check exits non-zero saying so rather than
    # inventing a timestamp. Both outcomes are correct here; a crash is not.
    output = shell_output("NETDASH_PATCH_REFRESH=no #{bin}/netdash-patchcheck --print 2>&1", nil)
    assert_match(/"source":"softwareupdate"|has this Mac ever checked/, output)
  end
end
