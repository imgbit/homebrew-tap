class PipelineMonitor < Formula
  desc "See a running GStreamer pipeline live in your browser"
  homepage "https://github.com/imgbit/pipeline-monitor"
  url "https://github.com/imgbit/pipeline-monitor/archive/refs/tags/v0.11.0.tar.gz"
  sha256 "e8b44337ea22259d27b6ac3ade16a32de3e3c53637a5f08ce0488d25b5aecbba"
  license "LGPL-2.1-or-later"
  head "https://github.com/imgbit/pipeline-monitor.git", branch: "main"

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => [:build, :test]
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
      To open recordings without a program, run pipeline-monitor
      (or pipeline-monitor open FILE.jsonl).
    EOS
  end

  test do
    # Not gst-inspect-1.0: on macOS it starts NSApplication and hangs here.
    (testpath/"load.c").write <<~C
      #include <gst/gst.h>
      int main (int argc, char **argv) {
        GError *error = NULL;
        GstPlugin *plugin;
        gst_init (&argc, &argv);
        plugin = gst_plugin_load_file (argv[1], &error);
        if (plugin == NULL) {
          g_printerr ("%s\\n", error->message);
          return 1;
        }
        g_print ("%s %s\\n", gst_plugin_get_name (plugin),
            gst_plugin_get_version (plugin));
        return 0;
      }
    C
    flags = shell_output("pkgconf --cflags --libs gstreamer-1.0").chomp.split
    system ENV.cc, "load.c", "-o", "load", *flags
    plugin = lib/"gstreamer-1.0"/shared_library("libgstpipelinemonitor")
    assert_match "pipelinemonitor #{version}", shell_output("./load #{plugin}")
    assert_match "pipeline-monitor #{version}",
                 shell_output("#{bin}/pipeline-monitor --version")
  end
end
