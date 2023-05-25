import 'dart:io';

import '../constants.dart';

class DirUtil {
  static String getPlaylistDownloadHomePath({bool isTest = false}) {
    if (Platform.isWindows) {
      if (isTest) {
        return kDownloadAppTestDirWindows;
      } else {
        return kDownloadAppDirWindows;
      }
    } else {
      if (isTest) {
        return kDownloadAppTestDir;
      } else {
        return kDownloadAppDir;
      }
    }
  }

  static String removeAudioDownloadHomePathFromPathFileName(
      {required String pathFileName}) {
    String path = getPlaylistDownloadHomePath();
    String pathFileNameWithoutHomePath = pathFileName.replaceFirst(path, '');

    return pathFileNameWithoutHomePath;
  }
  
  static Future<void> createAppDirIfNotExist({
    bool isAppDirToBeDeleted = false,
  }) async {
    String path = DirUtil.getPlaylistDownloadHomePath();
    final Directory directory = Directory(path);

    // using await directory.exists did delete dir only on second
    // app restart. Uncomprehensible !
    bool directoryExists = directory.existsSync();

    if (isAppDirToBeDeleted) {
      if (directoryExists) {
        DirUtil.deleteFilesInDirAndSubDirs(path);
      }
    }

    if (!directoryExists) {
      await directory.create();
    }
  }

  static Future<void> createDirIfNotExist({
    required String pathStr,
  }) async {
    final Directory directory = Directory(pathStr);
    bool directoryExists = await directory.exists();

    if (!directoryExists) {
      await directory.create(recursive: true);
    }
  }

  static void deleteFilesInDirAndSubDirs(String transferDataJsonPath) {
    final Directory directory = Directory(transferDataJsonPath);
    final List<FileSystemEntity> contents = directory.listSync(recursive: true);

    for (FileSystemEntity file in contents) {
      if (file is File) {
        file.deleteSync();
      }
    }
  }

  static void deleteFileIfExist(String pathFileName) {
    final File file = File(pathFileName);

    if (file.existsSync()) {
      file.deleteSync();
    }
  }

  static Future<void> copyFileToDirectory({
    required String sourceFilePathName,
    required String targetDirectoryPath,
    String? targetFileName,
  }) async {
    File sourceFile = File(sourceFilePathName);
    String copiedFileName = targetFileName ?? sourceFile.uri.pathSegments.last;
    String targetPathFileName = '$targetDirectoryPath/$copiedFileName';

    await sourceFile.copy(targetPathFileName);
  }

  static List<String> listPathFileNamesInSubDirs({
    required String path,
    required String extension,
  }) {
    List<String> pathFileNameList = [];

    final dir = Directory(path);
    final pattern = RegExp(r'\.' + RegExp.escape(extension) + r'$');

    for (FileSystemEntity entity
        in dir.listSync(recursive: true, followLinks: false)) {
      if (entity is File && pattern.hasMatch(entity.path)) {
        // Check if the file is not directly in the path itself
        String relativePath = entity.path
            .replaceFirst(RegExp(RegExp.escape(path) + r'[/\\]?'), '');
        if (relativePath.contains(Platform.pathSeparator)) {
          pathFileNameList.add(entity.path);
        }
      }
    }

    return pathFileNameList;
  }
}

Future<void> main() async {
  List<String> fileNames = DirUtil.listPathFileNamesInSubDirs(
    path: 'C:\\Users\\Jean-Pierre\\Downloads\\Audio\\',
    extension: 'json',
  );

  print(fileNames);
}
