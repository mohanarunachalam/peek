/*
Peek Copyright (c) 2017 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

namespace Peek.PostProcessing {

  /**
  * Uses ffmpeg to generate PNG images for each frame.
  */
  public class ExtractFramesPostProcessor : CliPostProcessor {
    public override async File[]? process_async (File[] files) {
      var input_file = files[0];
      string[] args = {
        "ffmpeg", "-y",
        "-i", files[0].get_path (),
        get_png_filename_pattern (input_file, "%04d")
      };

      int status = yield spawn_command_async (args);

      var png_file_pattern = get_png_filename_pattern (input_file, "*");
      var glob = Posix.Glob ();
      glob.glob (png_file_pattern);

      if (!Utils.is_exit_status_success (status)) {
        foreach (string png_file_path in glob.pathv) {
          FileUtils.remove (png_file_path);
        }

        return null;
      }

      var output = new Array<File> ();
      foreach (string png_file_path in glob.pathv) {
        var file = File.new_for_path (png_file_path);
        output.append_val (file);
      }

      return output.data;
    }

    private static string get_png_filename_pattern (File input_file, string replacement) {
      return input_file.get_path () + "." + replacement + ".png";
    }
  }
}
