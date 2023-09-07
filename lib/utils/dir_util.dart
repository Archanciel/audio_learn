import 'dart:io';
import 'package:path/path.dart' as path;

import '../constants.dart';

class DirUtil {
  static String getPlaylistDownloadHomePath({
    bool isTest = false,
  }) {
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
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: path,
        );
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

  /// Delete all the files in the {rootPath} directory and its
  /// subdirectories. If {deleteSubDirectoriesAsWell} is true,
  /// the subdirectories and sub subdirectories of {rootPath} are
  /// deleted as well.
  static void deleteFilesInDirAndSubDirs({
    required String rootPath,
    bool deleteSubDirectoriesAsWell = false,
  }) {
    final Directory directory = Directory(rootPath);

    // List the contents of the directory and its subdirectories
    final List<FileSystemEntity> contents = directory.listSync(recursive: true);

    // First, delete all the files
    for (FileSystemEntity entity in contents) {
      if (entity is File) {
        entity.deleteSync();
      }
    }

    // Then, delete the directories starting from the innermost ones
    if (deleteSubDirectoriesAsWell) {
      contents.reversed
          .whereType<Directory>()
          .forEach((dir) => dir.deleteSync());
    }
  }

  static void deleteFileIfExist(String pathFileName) {
    final File file = File(pathFileName);

    if (file.existsSync()) {
      file.deleteSync();
    }
  }

  /// This function copies all files and directories from a given
  /// source directory and its sub-directories to a target directory.
  ///
  /// It first checks if the source and target directories exist,
  /// and creates the target directory if it does not exist. It then
  /// iterates through all the contents of the source directory and
  /// its sub-directories, creating any directories that do not exist
  /// in the target directory and copying any files to the
  /// corresponding paths in the target directory.
  static void copyFilesFromDirAndSubDirsToDirectory({
    required String sourceRootPath,
    required String destinationRootPath,
  }) {
    final Directory sourceDirectory = Directory(sourceRootPath);
    final Directory targetDirectory = Directory(destinationRootPath);

    if (!sourceDirectory.existsSync()) {
      print(
          'Source directory does not exist. Please check the source directory path.');
      return;
    }

    if (!targetDirectory.existsSync()) {
      print('Target directory does not exist. Creating...');
      targetDirectory.createSync(recursive: true);
    }

    final List<FileSystemEntity> contents =
        sourceDirectory.listSync(recursive: true);

    for (FileSystemEntity entity in contents) {
      String relativePath = path.relative(entity.path, from: sourceRootPath);
      String newPath = path.join(destinationRootPath, relativePath);

      if (entity is Directory) {
        Directory(newPath).createSync(recursive: true);
      } else if (entity is File) {
        entity.copySync(newPath);
      }
    }
  }

  static Future<void> copyFileToDirectory({
    required String sourceFilePathName,
    required String targetDirectoryPath,
    String? targetFileName,
  }) async {
    File sourceFile = File(sourceFilePathName);
    String copiedFileName = targetFileName ?? sourceFile.uri.pathSegments.last;
    String targetPathFileName =
        '$targetDirectoryPath${path.separator}$copiedFileName';

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

  static listFileNamesInDir({
    required String path,
    required String extension,
  }) {
    List<String> fileNameList = [];

    final dir = Directory(path);
    final pattern = RegExp(r'\.' + RegExp.escape(extension) + r'$');

    for (FileSystemEntity entity
        in dir.listSync(recursive: false, followLinks: false)) {
      if (entity is File && pattern.hasMatch(entity.path)) {
        fileNameList.add(entity.path.split(Platform.pathSeparator).last);
      }
    }

    return fileNameList;
  }

  /// If [targetFileName] is not provided, the moved file will
  /// have the same name than the source file name.
  ///
  /// Returns true if the file has been moved, false
  /// otherwise which happens if the moved file already exist in
  /// the target dir.
  static bool moveFileToDirectoryIfNotExistSync({
    required String sourceFilePathName,
    required String targetDirectoryPath,
    String? targetFileName,
  }) {
    File sourceFile = File(sourceFilePathName);
    String copiedFileName = targetFileName ?? sourceFile.uri.pathSegments.last;
    String targetPathFileName =
        '$targetDirectoryPath${path.separator}$copiedFileName';

    if (File(targetPathFileName).existsSync()) {
      return false;
    }

    sourceFile.renameSync(targetPathFileName);

    return true;
  }

  /// If [targetFileName] is not provided, the moved file will
  /// have the same name than the source file name.
  ///
  /// Returns true if the file has been copied, false
  /// otherwise in case the copied file already exist in
  /// the target dir and {overwriteFileIfExist} is false.
  static bool copyFileToDirectorySync({
    required String sourceFilePathName,
    required String targetDirectoryPath,
    String? targetFileName,
    bool overwriteFileIfExist = false,
  }) {
    File sourceFile = File(sourceFilePathName);
    String copiedFileName = targetFileName ?? sourceFile.uri.pathSegments.last;
    String targetPathFileName =
        '$targetDirectoryPath${path.separator}$copiedFileName';

    if (!overwriteFileIfExist && File(targetPathFileName).existsSync()) {
      return false;
    }

    sourceFile.copySync(targetPathFileName);

    return true;
  }

  /// Return false in case a file named as newFileName already
  /// exist. In this case, the file is not renamed.
  static bool renameFile({
    required String fileToRenameFilePathName,
    required String newFileName,
  }) {
    File sourceFile = File(fileToRenameFilePathName);

    // Get the directory of the source file
    String dirPath = path.dirname(fileToRenameFilePathName);

    // Create the new file path with the new file name
    String newFilePathName = path.join(dirPath, newFileName);

    // Check if a file with the new name already exists
    if (File(newFilePathName).existsSync()) {
      print('A file with the new name already exists.');
      return false;
    }

    // Rename the file
    sourceFile.renameSync(newFilePathName);

    return true;
  }
}

Future<void> main() async {
  List<String> fileNames = DirUtil.listPathFileNamesInSubDirs(
    path: 'C:\\Users\\Jean-Pierre\\Downloads\\Audio\\',
    extension: 'json',
  );

  print(fileNames);

  List<String> fileNames2 = DirUtil.listFileNamesInDir(
    path: 'C:\\Users\\Jean-Pierre\\Downloads\\Audio\\new\\',
    extension: 'mp3',
  );

  print(fileNames2);
  try {
    String firstMatch =
        fileNames2.firstWhere((fileName) => fileName.contains('Peter Deunov'));
    print(firstMatch);
  } catch (e) {
    print('No file found containing the word');
  }
}
