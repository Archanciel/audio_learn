import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path/path.dart' as path;

import 'package:audio_learn/constants.dart';
import 'package:audio_learn/services/settings_data_service.dart';
import 'package:audio_learn/utils/dir_util.dart';
import 'package:audio_learn/viewmodels/audio_download_vm.dart';
import 'package:audio_learn/viewmodels/audio_player_vm.dart';
import 'package:audio_learn/viewmodels/expandable_playlist_list_vm.dart';
import 'package:audio_learn/viewmodels/language_provider.dart';
import 'package:audio_learn/viewmodels/theme_provider.dart';
import 'package:audio_learn/viewmodels/warning_message_vm.dart';
import 'package:audio_learn/views/expandable_playlist_list_view.dart';

class MockExpandablePlaylistListVM extends ExpandablePlaylistListVM {
  MockExpandablePlaylistListVM({
    required WarningMessageVM warningMessageVM,
    required AudioDownloadVM audioDownloadVM,
    required SettingsDataService settingsDataService,
  }) : super(
          warningMessageVM: warningMessageVM,
          audioDownloadVM: audioDownloadVM,
          settingsDataService: settingsDataService,
        );
}

void main() {
  group(
      'Testing expandable playlist list located in ExpandableListView functions',
      () {
    testWidgets(
        'should render ListViewWidget, not using MyApp but ListViewWidget',
        (WidgetTester tester) async {
      SettingsDataService settingsDataService = SettingsDataService(
        isTest: true,
      );
      WarningMessageVM warningMessageVM = WarningMessageVM();
      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        isTest: true,
      );

      await createExpandablePlaylistListViewWidget(
        tester,
        warningMessageVM,
        audioDownloadVM,
        settingsDataService,
      );

      expect(find.byType(ExpandablePlaylistListView), findsOneWidget);
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

      await createExpandablePlaylistListViewWidget(
        tester,
        warningMessageVM,
        audioDownloadVM,
        settingsDataService,
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

      await createExpandablePlaylistListViewWidget(
        tester,
        warningMessageVM,
        audioDownloadVM,
        settingsDataService,
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

      await createExpandablePlaylistListViewWidget(
        tester,
        warningMessageVM,
        audioDownloadVM,
        settingsDataService,
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

      await createExpandablePlaylistListViewWidget(
        tester,
        warningMessageVM,
        audioDownloadVM,
        settingsDataService,
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

      await createExpandablePlaylistListViewWidget(
        tester,
        warningMessageVM,
        audioDownloadVM,
        settingsDataService,
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
    // warningMessageVM: warningMessageVM,
    // isTest: true,
    //   );

    //   await createWidget(
    //     tester,
    //     warningMessageVM,
    //     audioDownloadVM,
    //     settingsDataService,
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

      await createExpandablePlaylistListViewWidget(
        tester,
        warningMessageVM,
        audioDownloadVM,
        settingsDataService,
      );

      // displaying the list
      final Finder toggleButtonFinder =
          find.byKey(const ValueKey('playlist_toggle_button'));
      await tester.tap(toggleButtonFinder);
      await tester.pump();

      Finder listViewFinder = find.byType(ExpandablePlaylistListView);

      // tester.element(listViewFinder) returns a StatefulElement
      // which is a BuildContext
      ExpandablePlaylistListVM listViewModel =
          Provider.of<ExpandablePlaylistListVM>(tester.element(listViewFinder),
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

      listViewFinder = find.byType(ExpandablePlaylistListView);

      // tester.element(listViewFinder) returns a StatefulElement
      // which is a BuildContext
      listViewModel = Provider.of<ExpandablePlaylistListVM>(
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

      await createExpandablePlaylistListViewWidget(
        tester,
        warningMessageVM,
        audioDownloadVM,
        settingsDataService,
      );

      // displaying the list
      final Finder toggleButtonFinder =
          find.byKey(const ValueKey('playlist_toggle_button'));
      await tester.tap(toggleButtonFinder);
      await tester.pump();

      Finder listViewFinder = find.byType(ExpandablePlaylistListView);

      // tester.element(listViewFinder) returns a StatefulElement
      // which is a BuildContext
      ExpandablePlaylistListVM listViewModel =
          Provider.of<ExpandablePlaylistListVM>(tester.element(listViewFinder),
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

      listViewFinder = find.byType(ExpandablePlaylistListView);

      // tester.element(listViewFinder) returns a StatefulElement
      // which is a BuildContext
      listViewModel = Provider.of<ExpandablePlaylistListVM>(
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

      await createExpandablePlaylistListViewWidget(
        tester,
        warningMessageVM,
        audioDownloadVM,
        settingsDataService,
      );

      // displaying the list
      final Finder toggleButtonFinder =
          find.byKey(const ValueKey('playlist_toggle_button'));
      await tester.tap(toggleButtonFinder);
      await tester.pump();

      Finder listViewFinder = find.byType(ExpandablePlaylistListView);

      // tester.element(listViewFinder) returns a StatefulElement
      // which is a BuildContext
      ExpandablePlaylistListVM listViewModel =
          Provider.of<ExpandablePlaylistListVM>(tester.element(listViewFinder),
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

      listViewFinder = find.byType(ExpandablePlaylistListView);

      // tester.element(listViewFinder) returns a StatefulElement
      // which is a BuildContext
      listViewModel = Provider.of<ExpandablePlaylistListVM>(
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

      await createExpandablePlaylistListViewWidget(
        tester,
        warningMessageVM,
        audioDownloadVM,
        settingsDataService,
      );

      // displaying the list
      final Finder toggleButtonFinder =
          find.byKey(const ValueKey('playlist_toggle_button'));
      await tester.tap(toggleButtonFinder);
      await tester.pumpAndSettle();

      Finder listViewFinder = find.byType(ExpandablePlaylistListView);

      // tester.element(listViewFinder) returns a StatefulElement
      // which is a BuildContext
      ExpandablePlaylistListVM listViewModel =
          Provider.of<ExpandablePlaylistListVM>(tester.element(listViewFinder),
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

      listViewFinder = find.byType(ExpandablePlaylistListView);

      // tester.element(listViewFinder) returns a StatefulElement
      // which is a BuildContext
      listViewModel = Provider.of<ExpandablePlaylistListVM>(
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

      await createExpandablePlaylistListViewWidget(
        tester,
        warningMessageVM,
        audioDownloadVM,
        settingsDataService,
      );

      // displaying the list
      final Finder toggleButtonFinder =
          find.byKey(const ValueKey('playlist_toggle_button'));
      await tester.tap(toggleButtonFinder);
      await tester.pump();

      Finder listViewFinder = find.byType(ExpandablePlaylistListView);

      // tester.element(listViewFinder) returns a StatefulElement
      // which is a BuildContext
      ExpandablePlaylistListVM listViewModel =
          Provider.of<ExpandablePlaylistListVM>(tester.element(listViewFinder),
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

      listViewFinder = find.byType(ExpandablePlaylistListView);

      // tester.element(listViewFinder) returns a StatefulElement
      // which is a BuildContext
      listViewModel = Provider.of<ExpandablePlaylistListVM>(
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

Future<void> createExpandablePlaylistListViewWidget(
    WidgetTester tester,
    WarningMessageVM warningMessageVM,
    AudioDownloadVM audioDownloadVM,
    SettingsDataService settingsDataService) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ExpandablePlaylistListVM>(
            create: (_) => MockExpandablePlaylistListVM(
                  warningMessageVM: warningMessageVM,
                  audioDownloadVM: audioDownloadVM,
                  settingsDataService: settingsDataService,
                )),
        ChangeNotifierProvider(create: (_) => audioDownloadVM),
        ChangeNotifierProvider(create: (_) => AudioPlayerVM()),
        ChangeNotifierProvider(
            create: (_) => ThemeProvider(
                  appSettings: settingsDataService,
                )),
        ChangeNotifierProvider(
            create: (_) => LanguageProvider(
                  appSettings: settingsDataService,
                )),
        ChangeNotifierProvider(create: (_) => warningMessageVM),
      ],
      child: MaterialApp(
        title: 'MVVM Example',
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          appBar: AppBar(
            title: const Text('MVVM Example'),
          ),
          body: ExpandablePlaylistListView(),
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
