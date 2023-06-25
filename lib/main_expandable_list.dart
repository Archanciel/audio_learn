import 'package:audio_learn/services/settings_data_service.dart';
import 'package:audio_learn/viewmodels/audio_download_vm.dart';
import 'package:audio_learn/viewmodels/warning_message_vm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;

import 'package:audio_learn/viewmodels/expandable_playlist_list_vm.dart';
import 'package:audio_learn/views/expandable_playlist_list_view.dart';

import 'constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    WarningMessageVM warningMessageVM = WarningMessageVM();
    AudioDownloadVM audioDownloadVM = AudioDownloadVM(
      warningMessageVM: warningMessageVM,
    );
      SettingsDataService settingsDataService = SettingsDataService();

      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      settingsDataService.loadSettingsFromFile(
          jsonPathFileName:
              "$kDownloadAppTestDirWindows${path.separator}$kSettingsFileName");

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

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ExpandablePlaylistListVM>(
          create: (context) => expandablePlaylistListVM,
        ),
      ],
        child: MaterialApp(
          title: 'MVVM Example',
          home: Scaffold(
            appBar: AppBar(
              title: const Text('MVVM Example'),
            ),
            body: ExpandablePlaylistListView(),
          ),
        ),
    );
  }
}
