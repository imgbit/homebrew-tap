class PipelineMonitor < Formula
  desc "See a running GStreamer pipeline live in your browser"
  homepage "https://github.com/imgbit/pipeline-monitor"
  url "https://github.com/imgbit/pipeline-monitor/archive/refs/tags/v0.7.0.tar.gz"
  sha256 "12c036d8248a8912bc421be96773250a3fd9433b0624501c990007544b547755"
  license "LGPL-2.1-or-later"
  head "https://github.com/imgbit/pipeline-monitor.git", branch: "main"

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build
  depends_on "glib"
  depends_on "gstreamer"
  depends_on "json-glib"
  depends_on "libsoup"

  def install
    system "meson", "setup", "build", *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
  end

  def caveats
    <<~EOS
      Homebrew's GStreamer finds this plugin through GST_PLUGIN_PATH:
        export GST_PLUGIN_PATH="#{HOMEBREW_PREFIX}/lib/gstreamer-1.0"
      Then run a program with GST_TRACERS=pipeline-monitor and open the
      address it prints, e.g.
        GST_TRACERS=pipeline-monitor gst-launch-1.0 videotestsrc ! autovideosink
    EOS
  end

  test do
    ENV["GST_PLUGIN_PATH"] = lib/"gstreamer-1.0"
    assert_match "pipeline-monitor",
      shell_output("#{Formula["gstreamer"].opt_bin}/gst-inspect-1.0 pipeline-monitor")
  end
end
