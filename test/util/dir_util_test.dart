import 'dart:io';

import 'package:audio_learn/constants.dart';
import 'package:audio_learn/utils/dir_util.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

import 'package:audio_learn/utils/duration_expansion.dart';

void main() {
  group('DirUtil replacePlaylistRootPathInSettingsJsonFiles test)', () {
    test(
      'replacing "/storage/emulated/0/Download/audiolear" by "C:\\Users\\Jean-Pierre\\Development\\Flutter\\audio_learn\\test\\data\\audio"',
      () {
        // Purge the test playlist directory if it exists so that the
        // playlist list is empty
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kDownloadAppTestDirWindows,
          deleteSubDirectoriesAsWell: true,
        );

        // Copy the test initial audio data to the app dir
        DirUtil.copyFilesFromDirAndSubDirsToDirectory(
          sourceRootPath:
              "$kDownloadAppTestSavedDataDir${path.separator}dir_util_test",
          destinationRootPath: kDownloadAppTestDirWindows,
        );

        DirUtil.replacePlaylistRootPathInSettingsJsonFiles(
            "C:\\Users\\Jean-Pierre\\Development\\Flutter\\audio_learn\\test\\data\\audio",
            '/storage/emulated/0/Download/audiolear',
            "C:\\Users\\Jean-Pierre\\Development\\Flutter\\audio_learn\\test\\data\\audio");

        File expectedFile = File(
            "$kDownloadAppTestDirWindows${path.separator}test_result.json");
        File actualFile =
            File("$kDownloadAppTestDirWindows${path.separator}settings.json");
        String actual = actualFile.readAsStringSync();
        expect(actual, expectedFile.readAsStringSync());

        // Cleanup the test data directory
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kDownloadAppTestDirWindows,
          deleteSubDirectoriesAsWell: true,
        );
      },
    );
  });
}
