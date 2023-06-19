import 'package:audio_learn/viewmodels/audio_download_vm.dart';
import 'package:audio_learn/viewmodels/audio_player_vm.dart';
import 'package:audio_learn/viewmodels/expandable_playlist_list_vm.dart';
import 'package:audio_learn/viewmodels/language_provider.dart';
import 'package:audio_learn/viewmodels/theme_provider.dart';
import 'package:audio_learn/viewmodels/warning_message_vm.dart';
import 'package:audio_learn/views/expandable_playlist_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'package:audio_learn/constants.dart';
import 'package:audio_learn/main.dart';
import 'package:audio_learn/services/settings_data_service.dart';
import 'package:audio_learn/utils/dir_util.dart';
import 'package:audio_learn/views/widgets/playlist_list_item_widget.dart';

void main() {
  const String testPlaylistDir =
      '$kDownloadAppTestDir\\audio_learn_new_youtube_playlist_test';

  // Necessary to avoid FatalFailureException (FatalFailureException: Failed
  // to perform an HTTP request to YouTube due to a fatal failure. In most
  // cases, this error indicates that YouTube most likely changed something,
  // which broke the library.
  // If this issue persists, please report it on the project's GitHub page.
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Expandable Playlist View test', () {
    testWidgets('Add Youtube playlist', (tester) async {
      // Delete the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(rootPath: kDownloadAppTestDirWindows);

      SettingsDataService settingsDataService = SettingsDataService();
      WarningMessageVM warningMessageVM = WarningMessageVM();
      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        isTest: true
      );
      ExpandablePlaylistListVM expandablePlaylistListVM =
          ExpandablePlaylistListVM(
        warningMessageVM: warningMessageVM,
        audioDownloadVM: audioDownloadVM,
        settingsDataService: settingsDataService,
      );

      // calling getUpToDateSelectablePlaylists() loads all the
      // playlist json files from the app dir and so enables
      // expandablePlaylistListVM to know which playlists are
      // selected and which are not
      expandablePlaylistListVM.getUpToDateSelectablePlaylists();

      const String youtubePlaylistUrl =
          'https://youtube.com/playlist?list=PLzwWSJNcZTMTSAE8iabVB6BCAfFGHHfah';
      const String youtubePlaylistTitle =
          'audio_learn_new_youtube_playlist_test';

      await tester.pumpWidget(
        MultiProvider(
          providers: [
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
            ChangeNotifierProvider(create: (_) => expandablePlaylistListVM),
            ChangeNotifierProvider(create: (_) => warningMessageVM),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: Scaffold(body: ExpandablePlaylistListView()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Ensure the list is initially hidden
      expect(find.byType(ListView), findsNothing);

      // Tap the 'Toggle List' button to show the list
      await tester.tap(find.byKey(const Key('toggle_button')));
      await tester.pumpAndSettle();

      // The list should be visible now but empty
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(ListTile), findsNothing);

      // Add a new playlist
      await tester.enterText(
          find.byKey(const Key('playlistUrlTextField')), youtubePlaylistUrl);

      TextField urlTextField =
          tester.widget(find.byKey(const Key('playlistUrlTextField')));
      expect(urlTextField.controller!.text, youtubePlaylistUrl);

      await tester.tap(find.byKey(const Key('addPlaylistButton')));
      await tester.pumpAndSettle();

      // Ensure the dialog is shown
      expect(find.byType(AlertDialog), findsOneWidget);

      // Check the value of the AlertDialog TextField
      TextField confirmUrlTextField = tester
          .widget(find.byKey(const Key('playlistUrlConfirmationTextField')));
      expect(confirmUrlTextField.controller!.text, youtubePlaylistUrl);

      // Confirm the addition by tapping the confirmation button in the AlertDialog
      await tester
          .tap(find.byKey(const Key('addPlaylistConfirmDialogAddButton')));
      await tester.pumpAndSettle();

      // The list should have one item now
      expect(find.byType(ListTile), findsOneWidget);

      // Check if the added item is displayed correctly
      final playlistTile = find.byType(ListTile).first;
      expect(
          find.descendant(
              of: playlistTile, matching: find.text(youtubePlaylistTitle)),
          findsOneWidget);
    });
  });
}
