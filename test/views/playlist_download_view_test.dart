import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path/path.dart' as path;

import 'package:audio_learn/constants.dart';
import 'package:audio_learn/services/settings_data_service.dart';
import 'package:audio_learn/utils/dir_util.dart';
import 'package:audio_learn/viewmodels/audio_download_vm.dart';
import 'package:audio_learn/viewmodels/playlist_list_vm.dart';
import 'package:audio_learn/viewmodels/language_provider_vm.dart';
import 'package:audio_learn/viewmodels/theme_provider_vm.dart';
import 'package:audio_learn/viewmodels/warning_message_vm.dart';
import 'package:audio_learn/views/playlist_download_view.dart';

class MockPlaylistListVM extends PlaylistListVM {
  MockPlaylistListVM({
    required super.warningMessageVM,
    required super.audioDownloadVM,
    required super.settingsDataService,
  });
}

class MockAppLocalizations extends AppLocalizations {
  MockAppLocalizations() : super('en');

  @override
  String get appBarTitleDownloadAudio => 'Download Audio';

  @override
  String get appBarTitleAudioPlayer => 'Audio Player';

  @override
  String get toggleList => 'Toggle List';

  @override
  String get delete => 'Delete';

  @override
  String get moveItemUp => 'Move item up';

  @override
  String get moveItemDown => 'Move item down';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get french => 'French';

  @override
  String get downloadAudio => 'Download Audio Youtube';

  @override
  String translate(Object language) {
    return 'Select $language';
  }

  @override
  String get musicalQualityTooltip => 'If set, downloads at musical quality';

  @override
  String get ofPreposition => 'of';

  @override
  String get atPreposition => 'at';

  @override
  String get ytPlaylistLinkLabel => 'Youtube Playlist Link';

  @override
  String get ytPlaylistLinkHintText => 'Enter a Youtube playlist link';

  @override
  String get addPlaylist => 'Add';

  @override
  String get renameAudioFileButton => 'Rename';

  @override
  // Changed mock version
  String get downloadSingleVideoAudio => '';

  @override
  // Changed mock version
  String get downloadSelectedPlaylist => '';

  @override
  String get stopDownload => 'Stop';

  @override
  String get audioDownloadingStopping => 'Stopping download ...';

  @override
  String audioDownloadError(Object error) {
    return 'Error downloading audio: $error';
  }

  @override
  String get singleVideoAudioDownload => 'Downloading single video audio in Various dir';

  @override
  String get about => 'About ...';

  @override
  String get sortFilterAudios => 'Sort/filter audios';

  @override
  String get subSortFilterAudios => 'Sub sort/filter audios';

  @override
  String get sortFilterDialogTitle => 'Sort and Filter Options';

  @override
  String get sortBy => 'Sort by:';

  @override
  String get audioDownloadDateTime => 'Audio download date time';

  @override
  String get videoUploadDate => 'Video upload date';

  @override
  String get audioEnclosingPlaylistTitle => 'Audio playlist title';

  @override
  String get audioDuration => 'Audio duration';

  @override
  String get audioFileSize => 'Audio file size';

  @override
  String get audioMusicQuality => 'Audio music quality';

  @override
  String get audioDownloadSpeed => 'Audio download speed';

  @override
  String get audioDownloadDuration => 'Audio download duration';

  @override
  String get sortAscending => 'Asc';

  @override
  String get sortDescending => 'Desc';

  @override
  String get filterOptions => 'Filter options:';

  @override
  String get videoTitleOrDescription => 'Video title (and description)';

  @override
  String get startDownloadDate => 'Start downl date';

  @override
  String get endDownloadDate => 'End downl date';

  @override
  String get startUploadDate => 'Start upl date';

  @override
  String get endUploadDate => 'End upl date';

  @override
  String get fileSizeRange => 'File Size Range (bytes)';

  @override
  String get start => 'Start';

  @override
  String get end => 'End';

  @override
  String get audioDurationRange => 'Audio duration range (hh:mm)';

  @override
  String get openYoutubeVideo => 'Open Youtube video';

  @override
  String get openYoutubePlaylist => 'Open Youtube playlist';

  @override
  String get apply => 'Apply';

  @override
  String get cancel => 'Cancel';

  @override
  String get deleteAudio => 'Delete audio';

  @override
  String get deleteAudioFromPlaylistAswell => 'Delete audio from playlist as well';

  @override
  String deleteAudioFromPlaylistAswellWarning(Object audioTitle, Object playlistTitle) {
    return 'If the deleted audio video \"$audioTitle\" remains in the \"$playlistTitle\" Youtube playlist, it will be downloaded again the next time you download the playlist !';
  }

  @override
  String get warningDialogTitle => 'WARNING';

  @override
  String updatedPlaylistUrlTitle(Object title) {
    return 'Playlist \"$title\" URL was updated. The playlist can be downloaded with its new URL.';
  }

  @override
  String addPlaylistTitle(Object title, Object quality) {
    return 'Playlist \"$title\" of $quality quality added at end of list of playlists.';
  }

  @override
  String invalidPlaylistUrl(Object url) {
    return 'Playlist with invalid URL \"$url\" neither added nor modified.';
  }

  @override
  String playlistWithUrlAlreadyInListOfPlaylists(Object url, Object title) {
    return 'Playlist \"$title\" with this URL \"$url\" is already in the list of playlists and so won\'t be recreated.';
  }

  @override
  String localPlaylistWithTitleAlreadyInListOfPlaylists(Object title) {
    return 'Local playlist \"$title\" already exists in the list of playlists and so won\'t be recreated.';
  }

  @override
  String downloadAudioYoutubeError(Object exceptionMessage) {
    return 'Error downloading audio from Youtube: \"$exceptionMessage\"';
  }

  @override
  String downloadAudioFileAlreadyOnAudioDirectory(Object audioValidVideoTitle, Object fileName, Object playlistTitle) {
    return 'Audio \"$audioValidVideoTitle\" is contained in file \"$fileName\" present in the \"$playlistTitle\" playlist directory and so won\'t be redownloaded.';
  }

  @override
  String get noInternet => 'No Internet. Please connect your device and retry.';

  @override
  String invalidSingleVideoUUrl(Object url) {
    return 'Single video with invalid URL \"$url\" could not be downloaded.';
  }

  @override
  String get copyYoutubeVideoUrl => 'Copy Youtube video URL';

  @override
  String get displayAudioInfo => 'Display audio data';

  @override
  String get renameAudioFile => 'Rename audio file';

  @override
  String get moveAudioToPlaylist => 'Move audio to playlist ...';

  @override
  String get copyAudioToPlaylist => 'Copy audio in playlist ...';

  @override
  String get audioInfoDialogTitle => 'Audio Info';

  @override
  String get originalVideoTitleLabel => 'Original video title';

  @override
  String get validVideoTitleLabel => 'Valid video title';

  @override
  String get videoUrlLabel => 'Video URL';

  @override
  String get audioDownloadDateTimeLabel => 'Audio downl date time';

  @override
  String get audioDownloadDurationLabel => 'Audio downl duration';

  @override
  String get audioDownloadSpeedLabel => 'Audio downl speed';

  @override
  String get videoUploadDateLabel => 'Video upload date';

  @override
  String get audioDurationLabel => 'Audio duration';

  @override
  String get audioFileNameLabel => 'Audio file name';

  @override
  String get audioFileSizeLabel => 'Audio file size';

  @override
  String get isMusicQualityLabel => 'Is music quality';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get octetShort => 'B';

  @override
  String get infiniteBytesPerSecond => 'infinite B/sec';

  @override
  String get updatePlaylistJsonFiles => 'Update playlist JSON files';

  @override
  String get compactVideoDescription => 'Compact video description';

  @override
  String get ignoreCase => 'Ignore case';

  @override
  String get searchInVideoCompactDescription => 'Include description';

  @override
  String get on => 'on';

  @override
  String get copyYoutubePlaylistUrl => 'Copy Youtube playlist URL';

  @override
  String get displayPlaylistInfo => 'Display playlist data';

  @override
  String get playlistInfoDialogTitle => 'Playlist Info';

  @override
  String get playlistTitleLabel => 'Playlist title';

  @override
  String get playlistIdLabel => 'Playlist ID';

  @override
  String get playlistUrlLabel => 'Playlist URL';

  @override
  String get playlistDownloadPathLabel => 'Playlist download path';

  @override
  String get playlistLastDownloadDateTimeLabel => 'Playlist last downl date time';

  @override
  String get playlistIsSelectedLabel => 'Playlist is selected';

  @override
  String get playlistTotalAudioNumberLabel => 'Playlist total audio number';

  @override
  String get playlistPlayableAudioNumberLabel => 'Playable audio number';

  @override
  String get playlistPlayableAudioTotalDurationLabel => 'Playable audio total duration';

  @override
  String get playlistPlayableAudioTotalSizeLabel => 'Playable audio total size';

  @override
  String get updatePlaylistPlayableAudioList => 'Update playable audio list';

  @override
  String updatedPlayableAudioLst(Object number, Object title) {
    return 'Playable audio list for playlist \"$title\" was updated. $number audio(s) were removed.';
  }

  @override
  String get addPlaylistDialogTitle => 'Add Playlist';

  @override
  String get addPlaylistDialogComment => 'Adding Youtube playlist referenced by the URL or adding a local playlist whose title must be defined.';

  @override
  String get renameAudioFileDialogTitle => 'Rename Audio File';

  @override
  String get renameAudioFileDialogComment => 'Renaming audio file in order to improve their playing order.';

  @override
  String get youtubePlaylistUrlLabel => 'Youtube playlist URL';

  @override
  String get localPlaylistTitleLabel => 'Local playlist title';

  @override
  String get renameAudioFileLabel => 'Audio file name';

  @override
  String get playlistTypeLabel => 'Playlist type';

  @override
  String get playlistTypeYoutube => 'Youtube';

  @override
  String get playlistTypeLocal => 'Local';

  @override
  String get playlistQualityLabel => 'Playlist quality';

  @override
  String get playlistQualityMusic => 'music';

  @override
  String get playlistQualityAudio => 'audio';

  @override
  String get audioQualityHighSnackBarMessage => 'Download at music quality';

  @override
  String get audioQualityLowSnackBarMessage => 'Download at audio quality';

  @override
  String get add => 'Add';

  @override
  String get noPlaylistSelectedForSingleVideoDownload => 'No playlist selected for single video download. Select one playlist and retry ...';

  @override
  String get tooManyPlaylistSelectedForSingleVideoDownload => 'More than one playlist selected for single video download. Select only one playlist and retry ...';

  @override
  String get confirmDialogTitle => 'CONFIRMATION';

  @override
  String confirmSingleVideoAudioPlaylistTitle(Object title) {
    return 'Confirm playlist \"$title\" for downloading single video audio.';
  }

  @override
  String get playlistJsonFileSizeLabel => 'JSON file size';

  @override
  String get playlistOneSelectedDialogTitle => 'Select a playlist';

  @override
  String get confirmButton => 'Confirm';

  @override
  String get enclosingPlaylistLabel => 'Enclosing playlist';

  @override
  String audioNotMovedFromToPlaylist(Object audioTitle, Object fromPlaylistTitle, Object toPlaylistTitle) {
    return 'Audio \"$audioTitle\" NOT moved from playlist \"$fromPlaylistTitle\" to playlist \"$toPlaylistTitle\" since it is already present in the destination playlist.';
  }

  @override
  String audioNotCopiedFromToPlaylist(Object audioTitle, Object fromPlaylistTitle, Object toPlaylistTitle) {
    return 'Audio \"$audioTitle\" NOT copied from playlist \"$fromPlaylistTitle\" to playlist \"$toPlaylistTitle\" since it is already present in the destination playlist.';
  }

  @override
  String audioMovedFromLocalPlaylistToLocalPlaylist(Object audioTitle, Object fromPlaylistTitle, Object toPlaylistTitle) {
    return 'Audio \"$audioTitle\" moved from local playlist \"$fromPlaylistTitle\" to local playlist \"$toPlaylistTitle\".';
  }

  @override
  String audioMovedFromLocalPlaylistToYoutubePlaylist(Object audioTitle, Object fromPlaylistTitle, Object toPlaylistTitle) {
    return 'Audio \"$audioTitle\" moved from local playlist \"$fromPlaylistTitle\" to Youtube playlist \"$toPlaylistTitle\".';
  }

  @override
  String audioMovedFromYoutubePlaylistToLocalPlaylistPlaylistWarning(Object audioTitle, Object fromPlaylistTitle, Object toPlaylistTitle) {
    return 'Audio \"$audioTitle\" moved from Youtube playlist \"$fromPlaylistTitle\" to local playlist \"$toPlaylistTitle\".\n\nIF THE DELETED AUDIO VIDEO \"$audioTitle\" REMAINS IN THE \"$fromPlaylistTitle\" YOUTUBE PLAYLIST, IT WILL BE DOWNLOADED AGAIN THE NEXT TIME YOU DOWNLOAD THE PLAYLIST !';
  }

  @override
  String audioMovedFromYoutubePlaylistToYoutubePlaylistPlaylistWarning(Object audioTitle, Object fromPlaylistTitle, Object toPlaylistTitle) {
    return 'Audio \"$audioTitle\" moved from Youtube playlist \"$fromPlaylistTitle\" to Youtube playlist \"$toPlaylistTitle\".\n\nIF THE DELETED AUDIO VIDEO \"$audioTitle\" REMAINS IN THE \"$fromPlaylistTitle\" YOUTUBE PLAYLIST, IT WILL BE DOWNLOADED AGAIN THE NEXT TIME YOU DOWNLOAD THE PLAYLIST !';
  }

  @override
  String audioMovedFromYoutubePlaylistToLocalPlaylist(Object audioTitle, Object fromPlaylistTitle, Object toPlaylistTitle) {
    return 'Audio \"$audioTitle\" moved from Youtube playlist \"$fromPlaylistTitle\" to local playlist \"$toPlaylistTitle\".';
  }

  @override
  String audioMovedFromYoutubePlaylistToYoutubePlaylist(Object audioTitle, Object fromPlaylistTitle, Object toPlaylistTitle) {
    return 'Audio \"$audioTitle\" moved from Youtube playlist \"$fromPlaylistTitle\" to Youtube playlist \"$toPlaylistTitle\".';
  }

  @override
  String audioCopiedFromToPlaylist(Object audioTitle, Object fromPlaylistTitle, Object toPlaylistTitle) {
    return 'Audio \"$audioTitle\" copied from playlist \"$fromPlaylistTitle\" to playlist \"$toPlaylistTitle\".';
  }

  @override
  String get author => 'Author:';

  @override
  String get authorName => 'Jean-Pierre Schnyder / Switzerland';

  @override
  String get aboutAppDescription => 'This application allows you to download audio from Youtube playlists or from single video links.\n\nThe future version will enable you to listen the audios, to add comments to them and to extract significative portions of the audio and share them or combine them in a new summary audio.';

  @override
  String get keepAudioEntryInSourcePlaylist => 'Keep audio entry in source playlist';

  @override
  String get movedFromPlaylistLabel => 'Moved from playlist';

  @override
  String get movedToPlaylistLabel => 'Moved to playlist';

  @override
  String get downloadSingleVideoButtonTooltip => 'Download single video audio';

  @override
  String get addPlaylistButtonTooltip => 'Add Youtube or local playlist';

  @override
  String get stopDownloadingButtonTooltip => 'Stop downloading';

  @override
  String get playlistToggleButtonTooltip => 'Show/hide playlists';

  @override
  String get downloadSelPlaylistsButtonTooltip => 'Download audios of selected playlist';

  @override
  String get option1 => 'Option one';

  @override
  String get option2 => 'Option two';

  @override
  String get audioOneSelectedDialogTitle => 'Select an audio';

  @override
  String get audioPositionLabel => 'Audio position';

  @override
  String get audioStateLabel => 'Audio state';

  @override
  String get audioStatePaused => 'Paused';

  @override
  String get audioStatePlaying => 'Playing';

  @override
  String get audioStateStopped => 'Stopped';

  @override
  String get audioStateNotStarted => 'Not started';

  @override
  String get audioPausedDateTimeLabel => 'Date/time paused';

  @override
  String get audioPlaySpeedLabel => 'Play speed';

  @override
  String audioCopiedFromLocalPlaylistToLocalPlaylist(Object audioTitle, Object fromPlaylistTitle, Object toPlaylistTitle) {
    return 'Audio \"$audioTitle\" copied from local playlist \"$fromPlaylistTitle\" to local playlist \"$toPlaylistTitle\".';
  }

  @override
  String audioCopiedFromLocalPlaylistToYoutubePlaylist(Object audioTitle, Object fromPlaylistTitle, Object toPlaylistTitle) {
    return 'Audio \"$audioTitle\" copied from local playlist \"$fromPlaylistTitle\" to Youtube playlist \"$toPlaylistTitle\".';
  }

  @override
  String audioCopiedFromYoutubePlaylistToLocalPlaylistPlaylistWarning(Object audioTitle, Object fromPlaylistTitle, Object toPlaylistTitle) {
    return 'Audio \"$audioTitle\" copied from Youtube playlist \"$fromPlaylistTitle\" to local playlist \"$toPlaylistTitle\".\n\nIF THE DELETED AUDIO VIDEO \"$audioTitle\" REMAINS IN THE \"$fromPlaylistTitle\" YOUTUBE PLAYLIST, IT WILL BE DOWNLOADED AGAIN THE NEXT TIME YOU DOWNLOAD THE PLAYLIST !';
  }

  @override
  String audioCopiedFromYoutubePlaylistToYoutubePlaylistPlaylistWarning(Object audioTitle, Object fromPlaylistTitle, Object toPlaylistTitle) {
    return 'Audio \"$audioTitle\" copied from Youtube playlist \"$fromPlaylistTitle\" to Youtube playlist \"$toPlaylistTitle\".\n\nIF THE DELETED AUDIO VIDEO \"$audioTitle\" REMAINS IN THE \"$fromPlaylistTitle\" YOUTUBE PLAYLIST, IT WILL BE DOWNLOADED AGAIN THE NEXT TIME YOU DOWNLOAD THE PLAYLIST !';
  }

  @override
  String audioCopiedFromYoutubePlaylistToLocalPlaylist(Object audioTitle, Object fromPlaylistTitle, Object toPlaylistTitle) {
    return 'Audio \"$audioTitle\" copied from Youtube playlist \"$fromPlaylistTitle\" to local playlist \"$toPlaylistTitle\".';
  }

  @override
  String audioCopiedFromYoutubePlaylistToYoutubePlaylist(Object audioTitle, Object fromPlaylistTitle, Object toPlaylistTitle) {
    return 'Audio \"$audioTitle\" copied from Youtube playlist \"$fromPlaylistTitle\" to Youtube playlist \"$toPlaylistTitle\".';
  }

  @override
  String get copiedFromPlaylistLabel => 'Copied from playlist';

  @override
  String get copiedToPlaylistLabel => 'Copied to playlist';

  @override
  String get audioPlayerViewNoCurrentAudio => 'No audio selected';

  @override
  String get deletePlaylist => 'Delete playlist ...';

  @override
  String deleteYoutubePlaylistDialogTitle(Object title) {
    return 'Delete Youtube Playlist \"$title\"';
  }

  @override
  String deleteLocalPlaylistDialogTitle(Object title) {
    return 'Delete local Playlist \"$title\"';
  }

  @override
  String get deletePlaylistDialogComment => 'Deleting the playlist and all its audios as well as its JSON file and its directory.';
}

class MockAppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return MockAppLocalizations();
  }

  @override
  bool shouldReload(MockAppLocalizationsDelegate old) => false;
}

void main() async {
  group(
      'Testing expandable playlist list located in PlaylistDownloadView functions',
      () {
    testWidgets(
        'should render ListView widget, not using MyApp but ListView widget',
        (WidgetTester tester) async {
      SettingsDataService settingsDataService = SettingsDataService(
        isTest: true,
      );
      WarningMessageVM warningMessageVM = WarningMessageVM();
      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        isTest: true,
      );

      await _createPlaylistDownloadView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        warningMessageVM: warningMessageVM,
      );

      expect(find.byType(PlaylistDownloadView), findsOneWidget);
    });

    testWidgets('should toggle list on press', (WidgetTester tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_learn_expandable_4_playlists_test",
        destinationRootPath: kDownloadAppTestDirWindows,
      );

      SettingsDataService settingsDataService = SettingsDataService(
        isTest: true,
      );

      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      settingsDataService.loadSettingsFromFile(
          jsonPathFileName:
              "$kDownloadAppTestDirWindows${path.separator}$kSettingsFileName");

      WarningMessageVM warningMessageVM = WarningMessageVM();
      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        isTest: true,
      );

      await _createPlaylistDownloadView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        warningMessageVM: warningMessageVM,
      );

      // displaying the list
      final Finder toggleButtonFinder =
          find.byKey(const ValueKey('playlist_toggle_button'));
      await tester.tap(toggleButtonFinder);
      await tester.pump();

      final Finder listTileFinder = find.byType(ListTile);
      expect(listTileFinder, findsWidgets);

      final List<Widget> listTileLst =
          tester.widgetList(listTileFinder).toList();
      expect(listTileLst.length, 4);

      // hidding the list
      await tester.tap(toggleButtonFinder);
      await tester.pump();

      expect(listTileFinder, findsNothing);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });

    testWidgets('check buttons enabled after item selected',
        (WidgetTester tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_learn_expandable_7_playlists_test",
        destinationRootPath: kDownloadAppTestDirWindows,
      );

      SettingsDataService settingsDataService = SettingsDataService(
        isTest: true,
      );

      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      settingsDataService.loadSettingsFromFile(
          jsonPathFileName:
              "$kDownloadAppTestDirWindows${path.separator}$kSettingsFileName");

      WarningMessageVM warningMessageVM = WarningMessageVM();
      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        isTest: true,
      );

      await _createPlaylistDownloadView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        warningMessageVM: warningMessageVM,
      );

      // displaying the list
      final Finder toggleButtonFinder =
          find.byKey(const ValueKey('playlist_toggle_button'));
      await tester.tap(toggleButtonFinder);
      await tester.pump();

      final Finder listItemFinder = find.byType(ListTile).first;
      await tester.tap(listItemFinder);
      await tester.pump();

      // The Delete button does not exist on the
      // ExpandableListView.
      // testing that the Delete button is disabled
      // Finder deleteButtonFinder = find.byKey(const ValueKey('delete_button'));
      // expect(deleteButtonFinder, findsOneWidget);
      // expect(
      //     tester.widget<ElevatedButton>(deleteButtonFinder).enabled, isFalse);

      // testing that the up and down buttons are disabled
      IconButton upButton = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.arrow_drop_up));
      expect(upButton.onPressed, isNull);

      IconButton downButton = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.arrow_drop_down));
      expect(downButton.onPressed, isNull);

      // Verify that the first ListTile checkbox is not
      // selected
      Checkbox firstListItemCheckbox = tester.widget<Checkbox>(find.descendant(
        of: find.byType(ListTile).first,
        matching: find.byWidgetPredicate((widget) => widget is Checkbox),
      ));
      expect(firstListItemCheckbox.value, isFalse);

      // Tap the first ListTile checkbox to select it
      await tester.tap(find.descendant(
        of: find.byType(ListTile).first,
        matching: find.byWidgetPredicate((widget) => widget is Checkbox),
      ));
      await tester.pumpAndSettle();

      // Verify that the first ListTile checkbox is now
      // selected. The check box must be obtained again
      // since the widget has been recreated !
      firstListItemCheckbox = tester.widget<Checkbox>(find.descendant(
        of: find.byType(ListTile).first,
        matching: find.byWidgetPredicate((widget) => widget is Checkbox),
      ));
      expect(firstListItemCheckbox.value, isTrue);

      // The Delete button does not exist on the
      // ExpandableListView.
      // Verify that the Delete button is now enabled.
      // The Delete button must be obtained again
      // since the widget has been recreated !
      // expect(
      //   tester.widget<ElevatedButton>(
      //       find.widgetWithText(ElevatedButton, 'Delete')),
      //   isA<ElevatedButton>().having((b) => b.enabled, 'enabled', true),
      // );

      // Verify that the up and down buttons are now enabled.
      // The Up and Down buttons must be obtained again
      // since the widget has been recreated !
      upButton = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.arrow_drop_up));
      expect(upButton.onPressed, isNotNull);

      downButton = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.arrow_drop_down));
      expect(downButton.onPressed, isNotNull);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });

    testWidgets(
        'check checkbox remains selected after toggling list up and down',
        (WidgetTester tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_learn_expandable_7_playlists_test",
        destinationRootPath: kDownloadAppTestDirWindows,
      );

      SettingsDataService settingsDataService = SettingsDataService(
        isTest: true,
      );

      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      settingsDataService.loadSettingsFromFile(
          jsonPathFileName:
              "$kDownloadAppTestDirWindows${path.separator}$kSettingsFileName");

      WarningMessageVM warningMessageVM = WarningMessageVM();
      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        isTest: true,
      );

      await _createPlaylistDownloadView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        warningMessageVM: warningMessageVM,
      );

      // displaying the list
      final Finder toggleButtonFinder =
          find.byKey(const ValueKey('playlist_toggle_button'));
      await tester.tap(toggleButtonFinder);
      await tester.pump();

      final Finder listItemFinder = find.byType(ListTile).first;
      await tester.tap(listItemFinder);
      await tester.pump();

      // Tap the first ListTile checkbox to select it
      await tester.tap(find.descendant(
        of: find.byType(ListTile).first,
        matching: find.byWidgetPredicate((widget) => widget is Checkbox),
      ));
      await tester.pump();

      // Verify that the first ListTile checkbox is now
      // selected. The check box must be obtained again
      // since the widget has been recreated !
      Checkbox firstListItemCheckbox = tester.widget<Checkbox>(find.descendant(
        of: find.byType(ListTile).first,
        matching: find.byWidgetPredicate((widget) => widget is Checkbox),
      ));
      expect(firstListItemCheckbox.value, isTrue);

      // hidding the list
      await tester.tap(toggleButtonFinder);
      await tester.pump();

      // The Delete button does not exist on the
      // ExpandableListView.
      // testing that the Delete button is disabled
      // Finder deleteButtonFinder = find.byKey(const ValueKey('Delete'));
      // expect(deleteButtonFinder, findsOneWidget);
      // expect(
      //     tester.widget<ElevatedButton>(deleteButtonFinder).enabled, isFalse);

      // testing that the up and down buttons are disabled
      IconButton upButton = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.arrow_drop_up));
      expect(upButton.onPressed, isNull);

      IconButton downButton = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.arrow_drop_down));
      expect(downButton.onPressed, isNull);

      // redisplaying the list
      await tester.tap(toggleButtonFinder);
      await tester.pump();

      // The Delete button does not exist on the
      // ExpandableListView.
      // Verify that the Delete button is now enabled.
      // The Delete button must be obtained again
      // since the widget has been recreated !
      // expect(
      //   tester.widget<ElevatedButton>(
      //       find.widgetWithText(ElevatedButton, 'Delete')),
      //   isA<ElevatedButton>().having((b) => b.enabled, 'enabled', true),
      // );

      // Verify that the up and down buttons are now enabled.
      // The Up and Down buttons must be obtained again
      // since the widget has been recreated !
      upButton = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.arrow_drop_up));
      expect(upButton.onPressed, isNotNull);

      downButton = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.arrow_drop_down));
      expect(downButton.onPressed, isNotNull);

      // Verify that the first ListTile checkbox is always
      // selected. The check box must be obtained again
      // since the widget has been recreated !
      firstListItemCheckbox = tester.widget<Checkbox>(find.descendant(
        of: find.byType(ListTile).first,
        matching: find.byWidgetPredicate((widget) => widget is Checkbox),
      ));
      expect(firstListItemCheckbox.value, isTrue);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });

    testWidgets('check buttons disabled after item unselected',
        (WidgetTester tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_learn_expandable_7_playlists_test",
        destinationRootPath: kDownloadAppTestDirWindows,
      );

      SettingsDataService settingsDataService = SettingsDataService(
        isTest: true,
      );

      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      settingsDataService.loadSettingsFromFile(
          jsonPathFileName:
              "$kDownloadAppTestDirWindows${path.separator}$kSettingsFileName");

      WarningMessageVM warningMessageVM = WarningMessageVM();
      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        isTest: true,
      );

      await _createPlaylistDownloadView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        warningMessageVM: warningMessageVM,
      );

      // displaying the list
      final Finder toggleButtonFinder =
          find.byKey(const ValueKey('playlist_toggle_button'));
      await tester.tap(toggleButtonFinder);
      await tester.pump();

      final Finder listItemFinder = find.byType(ListTile).first;
      await tester.tap(listItemFinder);
      await tester.pump();

      // Verify that the first ListTile checkbox is not
      // selected
      Checkbox firstListItemCheckbox = tester.widget<Checkbox>(find.descendant(
        of: find.byType(ListTile).first,
        matching: find.byWidgetPredicate((widget) => widget is Checkbox),
      ));
      expect(firstListItemCheckbox.value, isFalse);

      // Tap the first ListTile checkbox to select it
      await tester.tap(find.descendant(
        of: find.byType(ListTile).first,
        matching: find.byWidgetPredicate((widget) => widget is Checkbox),
      ));
      await tester.pump();

      // Verify that the first ListTile checkbox is now
      // selected. The check box must be obtained again
      // since the widget has been recreated !
      firstListItemCheckbox = tester.widget<Checkbox>(find.descendant(
        of: find.byType(ListTile).first,
        matching: find.byWidgetPredicate((widget) => widget is Checkbox),
      ));
      expect(firstListItemCheckbox.value, isTrue);

      // The Delete button does not exist on the
      // ExpandableListView.
      // Verify that the Delete button is now enabled.
      // The Delete button must be obtained again
      // since the widget has been recreated !
      // expect(
      //   tester.widget<ElevatedButton>(
      //       find.widgetWithText(ElevatedButton, 'Delete')),
      //   isA<ElevatedButton>().having((b) => b.enabled, 'enabled', true),
      // );

      // Verify that the up and down buttons are now enabled.
      // The Up and Down buttons must be obtained again
      // since the widget has been recreated !
      IconButton upButton = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.arrow_drop_up));
      expect(upButton.onPressed, isNotNull);

      IconButton downButton = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.arrow_drop_down));
      expect(downButton.onPressed, isNotNull);

      // Retap the first ListTile checkbox to unselect it
      await tester.tap(find.descendant(
        of: find.byType(ListTile).first,
        matching: find.byWidgetPredicate((widget) => widget is Checkbox),
      ));
      await tester.pump();

      // Verify that the first ListTile checkbox is now
      // unselected. The check box must be obtained again
      // since the widget has been recreated !
      firstListItemCheckbox = tester.widget<Checkbox>(find.descendant(
        of: find.byType(ListTile).first,
        matching: find.byWidgetPredicate((widget) => widget is Checkbox),
      ));
      expect(firstListItemCheckbox.value, isFalse);

      // The Delete button does not exist on the
      // ExpandableListView.
      // testing that the Delete button is now disabled
      // Finder deleteButtonFinder = find.byKey(const ValueKey('Delete'));
      // expect(deleteButtonFinder, findsOneWidget);
      // expect(
      //     tester.widget<ElevatedButton>(deleteButtonFinder).enabled, isFalse);

      // testing that the up and down buttons are now disabled
      upButton = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.arrow_drop_up));
      expect(upButton.onPressed, isNull);

      downButton = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.arrow_drop_down));
      expect(downButton.onPressed, isNull);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });

    testWidgets('ensure only one checkbox is selectable',
        (WidgetTester tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_learn_expandable_7_playlists_test",
        destinationRootPath: kDownloadAppTestDirWindows,
      );

      SettingsDataService settingsDataService = SettingsDataService(
        isTest: true,
      );

      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      settingsDataService.loadSettingsFromFile(
          jsonPathFileName:
              "$kDownloadAppTestDirWindows${path.separator}$kSettingsFileName");

      WarningMessageVM warningMessageVM = WarningMessageVM();
      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        isTest: true,
      );

      await _createPlaylistDownloadView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        warningMessageVM: warningMessageVM,
      );

      // displaying the list
      final Finder toggleButtonFinder =
          find.byKey(const ValueKey('playlist_toggle_button'));
      await tester.tap(toggleButtonFinder);
      await tester.pump();

      // final Finder listItem = find.byType(ListTile).first;
      // await tester.tap(listItem);
      // await tester.pump();

      // Verify that the first ListTile checkbox is not
      // selected
      Checkbox firstListItemCheckbox = tester.widget<Checkbox>(find.descendant(
        of: find.byType(ListTile).first,
        matching: find.byWidgetPredicate((widget) => widget is Checkbox),
      ));
      expect(firstListItemCheckbox.value, isFalse);

      // Tap the first ListTile checkbox to select it
      await tester.tap(find.descendant(
        of: find.byType(ListTile).first,
        matching: find.byWidgetPredicate((widget) => widget is Checkbox),
      ));
      await tester.pump();

      // Verify that the first ListTile checkbox is now
      // selected. The check box must be obtained again
      // since the widget has been recreated !
      firstListItemCheckbox = tester.widget<Checkbox>(find.descendant(
        of: find.byType(ListTile).first,
        matching: find.byWidgetPredicate((widget) => widget is Checkbox),
      ));
      expect(firstListItemCheckbox.value, isTrue);

      // Find and select the ListTile with text 'local_audio_playlist_4'
      String itemTextStr = 'local_audio_playlist_4';
      await findThenSelectAndTestListTileCheckbox(
        tester: tester,
        itemTextStr: itemTextStr,
      );

      // Verify that the first ListTile checkbox is no longer
      // selected. The check box must be obtained again
      // since the widget has been recreated !
      firstListItemCheckbox = tester.widget<Checkbox>(find.descendant(
        of: find.byType(ListTile).first,
        matching: find.byWidgetPredicate((widget) => widget is Checkbox),
      ));
      expect(firstListItemCheckbox.value, isFalse);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });

    // The Delete button does not exist on the
    // ExpandableListView.
    // testWidgets('select and delete item', (WidgetTester tester) async {
    // SettingsDataService settingsDataService = SettingsDataService(
    //   isTest: true,
    // );

    //   // Load the settings from the json file. This is necessary
    //   // otherwise the ordered playlist titles will remain empty
    //   // and the playlist list will not be filled with the
    //   // playlists available in the download app test dir
    //   settingsDataService.loadSettingsFromFile(
    //       jsonPathFileName:
    //           "$kDownloadAppTestDirWindows${path.separator}$kSettingsFileName");

    //   WarningMessageVM warningMessageVM = WarningMessageVM();
    //   AudioDownloadVM audioDownloadVM = AudioDownloadVM(
    // warningMessageVM:  warningMessageVM,
    // isTest: true,
    //   );

    //   await createWidget(
    //     tester: tester,
    //     warningMessageVM: warningMessageVM,
    //     audioDownloadVM: audioDownloadVM,
    //     settingsDataService: settingsDataService,
    //   );

    //   // displaying the list
    //   final Finder toggleButtonFinder =
    //       find.byKey(const ValueKey('playlist_toggle_button'));
    //   await tester.tap(toggleButtonFinder);
    //   await tester.pump();

    //   Finder listViewFinder = find.byType(ExpandablePlaylistListView);

    //   // tester.element(listViewFinder) returns a StatefulElement
    //   // which is a BuildContext
    //   ExpandablePlaylistListVM listViewModel =
    //       Provider.of<ExpandablePlaylistListVM>(tester.element(listViewFinder),
    //           listen: false);
    //   expect(listViewModel.getUpToDateSelectablePlaylists().length, 7);

    //   // Verify that the Delete button is disabled
    //   expect(find.text('Delete'), findsOneWidget);
    //   expect(find.widgetWithText(ElevatedButton, 'Delete'), findsOneWidget);
    //   expect(
    //     tester.widget<ElevatedButton>(
    //         find.widgetWithText(ElevatedButton, 'Delete')),
    //     isA<ElevatedButton>().having((b) => b.enabled, 'enabled', false),
    //   );

    //   // Find and select the ListTile item to delete
    //   const String itemToDeleteTextStr = 'local_audio_playlist_3';

    //   await findSelectAndTestListTileCheckbox(
    //     tester: tester,
    //     itemTextStr: itemToDeleteTextStr,
    //   );

    //   // Verify that the Delete button is now enabled
    //   expect(
    //     tester.widget<ElevatedButton>(
    //         find.widgetWithText(ElevatedButton, 'Delete')),
    //     isA<ElevatedButton>().having((b) => b.enabled, 'enabled', true),
    //   );

    //   // Tap the Delete button
    //   await tester.tap(find.widgetWithText(ElevatedButton, 'Delete'));
    //   await tester.pump();

    //   // Verify that the item was deleted by checking that
    //   // the ListViewModel.items getter return a list whose
    //   // length is 10 minus 1 and secondly verify that
    //   // the deleted ListTile is no longer displayed.

    //   listViewFinder = find.byType(ExpandablePlaylistListView);

    //   // tester.element(listViewFinder) returns a StatefulElement
    //   // which is a BuildContext
    //   listViewModel = Provider.of<ExpandablePlaylistListVM>(
    //       tester.element(listViewFinder),
    //       listen: false);
    //   expect(listViewModel.getUpToDateSelectablePlaylists().length, 6);

    //   expect(find.widgetWithText(ListTile, itemToDeleteTextStr), findsNothing);
    // });

    testWidgets('select and move down item', (WidgetTester tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_learn_expandable_7_playlists_test",
        destinationRootPath: kDownloadAppTestDirWindows,
      );

      SettingsDataService settingsDataService = SettingsDataService(
        isTest: true,
      );

      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      settingsDataService.loadSettingsFromFile(
          jsonPathFileName:
              "$kDownloadAppTestDirWindows${path.separator}$kSettingsFileName");

      WarningMessageVM warningMessageVM = WarningMessageVM();
      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        isTest: true,
      );

      await _createPlaylistDownloadView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        warningMessageVM: warningMessageVM,
      );

      // displaying the list
      final Finder toggleButtonFinder =
          find.byKey(const ValueKey('playlist_toggle_button'));
      await tester.tap(toggleButtonFinder);
      await tester.pump();

      Finder listViewFinder = find.byType(PlaylistDownloadView);

      // tester.element(listViewFinder) returns a StatefulElement
      // which is a BuildContext
      PlaylistListVM listViewModel = Provider.of<PlaylistListVM>(
          tester.element(listViewFinder),
          listen: false);
      expect(listViewModel.getUpToDateSelectablePlaylists().length, 7);

      // Find and select the ListTile to move'
      const String playlistToSelectTitle = 'local_audio_playlist_2';

      await findThenSelectAndTestListTileCheckbox(
        tester: tester,
        itemTextStr: playlistToSelectTitle,
      );

      // Verify that the move buttons are enabled
      IconButton upButton = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.arrow_drop_up));
      expect(upButton.onPressed, isNotNull);

      Finder downIconButtonFinder =
          find.widgetWithIcon(IconButton, Icons.arrow_drop_down);
      IconButton downButton = tester.widget<IconButton>(downIconButtonFinder);
      expect(downButton.onPressed, isNotNull);

      // Tap the move down button
      await tester.tap(downIconButtonFinder);
      await tester.pump();

      listViewFinder = find.byType(PlaylistDownloadView);

      // tester.element(listViewFinder) returns a StatefulElement
      // which is a BuildContext
      listViewModel = Provider.of<PlaylistListVM>(
          tester.element(listViewFinder),
          listen: false);
      expect(listViewModel.getUpToDateSelectablePlaylists()[1].title,
          'local_audio_playlist_3');
      expect(listViewModel.getUpToDateSelectablePlaylists()[2].title,
          'local_audio_playlist_2');

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });

    testWidgets('select and move down twice before last item',
        (WidgetTester tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_learn_expandable_4_playlists_test",
        destinationRootPath: kDownloadAppTestDirWindows,
      );

      SettingsDataService settingsDataService = SettingsDataService(
        isTest: true,
      );

      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      settingsDataService.loadSettingsFromFile(
          jsonPathFileName:
              "$kDownloadAppTestDirWindows${path.separator}$kSettingsFileName");

      WarningMessageVM warningMessageVM = WarningMessageVM();
      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        isTest: true,
      );

      await _createPlaylistDownloadView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        warningMessageVM: warningMessageVM,
      );

      // displaying the list
      final Finder toggleButtonFinder =
          find.byKey(const ValueKey('playlist_toggle_button'));
      await tester.tap(toggleButtonFinder);
      await tester.pump();

      Finder listViewFinder = find.byType(PlaylistDownloadView);

      // tester.element(listViewFinder) returns a StatefulElement
      // which is a BuildContext
      PlaylistListVM listViewModel = Provider.of<PlaylistListVM>(
          tester.element(listViewFinder),
          listen: false);
      expect(listViewModel.getUpToDateSelectablePlaylists().length, 4);

      // Find and select the ListTile to move'
      const String itemToMoveTitle = 'local_audio_playlist_2';

      await findThenSelectAndTestListTileCheckbox(
        tester: tester,
        itemTextStr: itemToMoveTitle,
      );

      // Verify that the move buttons are enabled
      IconButton upButton = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.arrow_drop_up));
      expect(upButton.onPressed, isNotNull);

      Finder dowButtonFinder =
          find.widgetWithIcon(IconButton, Icons.arrow_drop_down);
      IconButton downButton = tester.widget<IconButton>(dowButtonFinder);
      expect(downButton.onPressed, isNotNull);

      // Tap the move down button twice
      await tester.tap(dowButtonFinder);
      await tester.pump();
      await tester.tap(dowButtonFinder);
      await tester.pump();

      listViewFinder = find.byType(PlaylistDownloadView);

      // tester.element(listViewFinder) returns a StatefulElement
      // which is a BuildContext
      listViewModel = Provider.of<PlaylistListVM>(
          tester.element(listViewFinder),
          listen: false);
      expect(listViewModel.getUpToDateSelectablePlaylists()[0].title,
          'local_audio_playlist_1');
      expect(listViewModel.getUpToDateSelectablePlaylists()[3].title,
          'local_audio_playlist_2');

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
    testWidgets('select and move down twice over last item',
        (WidgetTester tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_learn_expandable_4_playlists_test",
        destinationRootPath: kDownloadAppTestDirWindows,
      );

      SettingsDataService settingsDataService = SettingsDataService(
        isTest: true,
      );

      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      settingsDataService.loadSettingsFromFile(
          jsonPathFileName:
              "$kDownloadAppTestDirWindows${path.separator}$kSettingsFileName");

      WarningMessageVM warningMessageVM = WarningMessageVM();
      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        isTest: true,
      );

      await _createPlaylistDownloadView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        warningMessageVM: warningMessageVM,
      );

      // displaying the list
      final Finder toggleButtonFinder =
          find.byKey(const ValueKey('playlist_toggle_button'));
      await tester.tap(toggleButtonFinder);
      await tester.pump();

      Finder listViewFinder = find.byType(PlaylistDownloadView);

      // tester.element(listViewFinder) returns a StatefulElement
      // which is a BuildContext
      PlaylistListVM listViewModel = Provider.of<PlaylistListVM>(
          tester.element(listViewFinder),
          listen: false);
      expect(listViewModel.getUpToDateSelectablePlaylists().length, 4);

      // Find and select the ListTile to move'
      const String itemToMoveTitle = 'local_audio_playlist_3';

      await findThenSelectAndTestListTileCheckbox(
        tester: tester,
        itemTextStr: itemToMoveTitle,
      );

      // Verify that the move buttons are enabled
      IconButton upButton = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.arrow_drop_up));
      expect(upButton.onPressed, isNotNull);

      Finder dowButtonFinder =
          find.widgetWithIcon(IconButton, Icons.arrow_drop_down);
      IconButton downButton = tester.widget<IconButton>(dowButtonFinder);
      expect(downButton.onPressed, isNotNull);

      // Tap the move down button twice
      await tester.tap(dowButtonFinder);
      await tester.pump();
      await tester.tap(dowButtonFinder);
      await tester.pump();

      listViewFinder = find.byType(PlaylistDownloadView);

      // tester.element(listViewFinder) returns a StatefulElement
      // which is a BuildContext
      listViewModel = Provider.of<PlaylistListVM>(
          tester.element(listViewFinder),
          listen: false);
      expect(listViewModel.getUpToDateSelectablePlaylists()[0].title,
          'local_audio_playlist_3');
      expect(listViewModel.getUpToDateSelectablePlaylists()[3].title,
          'local_audio_playlist_4');

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });

    testWidgets('select and move up item', (WidgetTester tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_learn_expandable_7_playlists_test",
        destinationRootPath: kDownloadAppTestDirWindows,
      );

      SettingsDataService settingsDataService = SettingsDataService(
        isTest: true,
      );

      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      settingsDataService.loadSettingsFromFile(
          jsonPathFileName:
              "$kDownloadAppTestDirWindows${path.separator}$kSettingsFileName");

      WarningMessageVM warningMessageVM = WarningMessageVM();
      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        isTest: true,
      );

      await _createPlaylistDownloadView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        warningMessageVM: warningMessageVM,
      );

      // displaying the list
      final Finder toggleButtonFinder =
          find.byKey(const ValueKey('playlist_toggle_button'));
      await tester.tap(toggleButtonFinder);
      await tester.pumpAndSettle();

      Finder listViewFinder = find.byType(PlaylistDownloadView);

      // tester.element(listViewFinder) returns a StatefulElement
      // which is a BuildContext
      PlaylistListVM listViewModel = Provider.of<PlaylistListVM>(
          tester.element(listViewFinder),
          listen: false);
      expect(listViewModel.getUpToDateSelectablePlaylists().length, 7);

      // Find and select the ListTile to move'
      const String itemToMoveTextStr = 'local_audio_playlist_4';

      await findThenSelectAndTestListTileCheckbox(
        tester: tester,
        itemTextStr: itemToMoveTextStr,
      );

      // Verify that the move buttons are enabled
      Finder upButtonFinder =
          find.widgetWithIcon(IconButton, Icons.arrow_drop_up);
      IconButton upButton = tester.widget<IconButton>(upButtonFinder);
      expect(upButton.onPressed, isNotNull);

      IconButton downButton = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.arrow_drop_down));
      expect(downButton.onPressed, isNotNull);

      // Tap the move up button
      await tester.tap(upButtonFinder);
      await tester.pump();

      listViewFinder = find.byType(PlaylistDownloadView);

      // tester.element(listViewFinder) returns a StatefulElement
      // which is a BuildContext
      listViewModel = Provider.of<PlaylistListVM>(
          tester.element(listViewFinder),
          listen: false);
      expect(listViewModel.getUpToDateSelectablePlaylists()[2].title,
          'local_audio_playlist_4');
      expect(listViewModel.getUpToDateSelectablePlaylists()[3].title,
          'local_audio_playlist_3');

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });

    testWidgets('select and move up twice first item',
        (WidgetTester tester) async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kDownloadAppTestDirWindows,
        deleteSubDirectoriesAsWell: true,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_learn_expandable_7_playlists_test",
        destinationRootPath: kDownloadAppTestDirWindows,
      );

      SettingsDataService settingsDataService = SettingsDataService(
        isTest: true,
      );

      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      settingsDataService.loadSettingsFromFile(
          jsonPathFileName:
              "$kDownloadAppTestDirWindows${path.separator}$kSettingsFileName");

      WarningMessageVM warningMessageVM = WarningMessageVM();
      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        isTest: true,
      );

      await _createPlaylistDownloadView(
        tester: tester,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
        warningMessageVM: warningMessageVM,
      );

      // displaying the list
      final Finder toggleButtonFinder =
          find.byKey(const ValueKey('playlist_toggle_button'));
      await tester.tap(toggleButtonFinder);
      await tester.pump();

      Finder listViewFinder = find.byType(PlaylistDownloadView);

      // tester.element(listViewFinder) returns a StatefulElement
      // which is a BuildContext
      PlaylistListVM listViewModel = Provider.of<PlaylistListVM>(
          tester.element(listViewFinder),
          listen: false);
      expect(listViewModel.getUpToDateSelectablePlaylists().length, 7);

      // Find and select the ListTile to move'
      const String itemToMoveTitle = 'local_audio_playlist_1';

      await findThenSelectAndTestListTileCheckbox(
        tester: tester,
        itemTextStr: itemToMoveTitle,
      );

      // Verify that the move buttons are enabled
      Finder upButtonFinder =
          find.widgetWithIcon(IconButton, Icons.arrow_drop_up);
      IconButton upButton = tester.widget<IconButton>(upButtonFinder);
      expect(upButton.onPressed, isNotNull);

      IconButton downButton = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.arrow_drop_down));
      expect(downButton.onPressed, isNotNull);

      // Tap twice the move up button
      await tester.tap(upButtonFinder);
      await tester.pump();
      await tester.tap(upButtonFinder);
      await tester.pump();

      listViewFinder = find.byType(PlaylistDownloadView);

      // tester.element(listViewFinder) returns a StatefulElement
      // which is a BuildContext
      listViewModel = Provider.of<PlaylistListVM>(
          tester.element(listViewFinder),
          listen: false);
      expect(listViewModel.getUpToDateSelectablePlaylists()[0].title,
          'local_audio_playlist_2');
      expect(listViewModel.getUpToDateSelectablePlaylists()[5].title,
          'local_audio_playlist_1');

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);
    });
  });
}

/// This constructor instanciates the [PlaylistDownloadView]
/// with the [MockPlaylistListVM]
Future<void> _createPlaylistDownloadView({
  required WidgetTester tester,
  required AudioDownloadVM audioDownloadVM,
  required SettingsDataService settingsDataService,
  required WarningMessageVM warningMessageVM,
}) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<PlaylistListVM>(
          create: (_) => MockPlaylistListVM(
            warningMessageVM: warningMessageVM,
            audioDownloadVM: audioDownloadVM,
            settingsDataService: settingsDataService,
          ),
        ),
        ChangeNotifierProvider(create: (_) => audioDownloadVM),
        ChangeNotifierProvider(
          create: (_) => ThemeProviderVM(
            appSettings: settingsDataService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => LanguageProviderVM(
            appSettings: settingsDataService,
          ),
        ),
        ChangeNotifierProvider(create: (_) => warningMessageVM),
      ],
      child: MaterialApp(
        localizationsDelegates: [
          MockAppLocalizationsDelegate(),
        ],
        home: Scaffold(
          body: PlaylistDownloadView(
            onPageChangedFunction: changePage,
          ),
        ),
      ),
    ),
  );
}

Future<void> findThenSelectAndTestListTileCheckbox({
  required WidgetTester tester,
  required String itemTextStr,
}) async {
  Finder listItemTileFinder = find.widgetWithText(ListTile, itemTextStr);

  // Find the Checkbox widget inside the ListTile
  Finder checkboxFinder = find.descendant(
    of: listItemTileFinder,
    matching: find.byType(Checkbox),
  );

  // Assert that the checkbox is not selected
  expect(tester.widget<Checkbox>(checkboxFinder).value, false);

  // now tap the item checkbox
  await tester.tap(find.descendant(
    of: listItemTileFinder,
    matching: find.byWidgetPredicate((widget) => widget is Checkbox),
  ));
  await tester.pump();

  // Find the Checkbox widget inside the ListTile

  listItemTileFinder = find.widgetWithText(ListTile, itemTextStr);

  checkboxFinder = find.descendant(
    of: listItemTileFinder,
    matching: find.byType(Checkbox),
  );

  expect(tester.widget<Checkbox>(checkboxFinder).value, true);
}

void changePage(int index) {
  onPageChanged(index);
  // _pageController.animateToPage(
  //   index,
  //   duration: pageTransitionDuration, // Use constant
  //   curve: pageTransitionCurve, // Use constant
  // );
}

void onPageChanged(int index) {
  // setState(() {
  //   _currentIndex = index;
  // });
}
