import 'package:audio_learn/views/screen_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/audio.dart';
import '../../services/settings_data_service.dart';
import '../../viewmodels/audio_global_player_vm.dart';
import '../../viewmodels/theme_provider.dart';

/// This dialog is used to select a single playlist among the
/// displayed playlists.
class AudioOneSelectableDialogWidget extends StatefulWidget {
  // Displaying the audio only checkbox is useful when the dialog is used
  // in order to move an Audio file to a destination playlist.
  //
  // Setting the checkbox to true has the effect that the Audio entry in
  // the source playlist is not deleted, which has the advantage that it
  // is not necessary to remove the Audio video link from the Youtube
  // source playlist in order to avoid to redownload it the next time
  // download all is applyed to the source playlist.
  //
  // In any case, the moved Audio playlist entry is added to the
  // destination playlist.
  final bool isAudioOnlyCheckboxDisplayed;

  const AudioOneSelectableDialogWidget({
    super.key,
    this.isAudioOnlyCheckboxDisplayed = false,
  });

  @override
  _AudioOneSelectableDialogWidgetState createState() =>
      _AudioOneSelectableDialogWidgetState();
}

class _AudioOneSelectableDialogWidgetState
    extends State<AudioOneSelectableDialogWidget> {
  // Using FocusNode to enable clicking on Enter to close
  // the dialog
  final FocusNode _focusNode = FocusNode();

  Audio? _selectedAudio;
  bool _keepAudioDataInSourcePlaylist = true;

  @override
  void initState() {
    super.initState();
    // Request focus when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    // Dispose the focus node when the widget is disposed
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkTheme = themeProvider.currentTheme == AppTheme.dark;
    AudioGlobalPlayerVM audioGlobalPlayerVM =
        Provider.of<AudioGlobalPlayerVM>(context, listen: false);

    List<Audio> selectableAudios = audioGlobalPlayerVM
        .getPlayableAudiosContainedInCurrentAudioEnclosingPlaylist();

    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: (event) {
        if (event.isKeyPressed(LogicalKeyboardKey.enter) ||
            event.isKeyPressed(LogicalKeyboardKey.numpadEnter)) {
          // executing the same code as in the 'Confirm' ElevatedButton
          // onPressed callback
          audioGlobalPlayerVM.setCurrentAudio(_selectedAudio!);
          Navigator.of(context).pop(_selectedAudio);
        }
      },
      child: AlertDialog(
        title: Text(AppLocalizations.of(context)!.audioOneSelectedDialogTitle),
        actionsPadding:
            // reduces the top vertical space between the buttons
            // and the content
            const EdgeInsets.fromLTRB(
                10, 0, 10, 10), // Adjust the value as needed
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min, // Use minimum space
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: selectableAudios.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return RadioListTile<Audio>(
                      title: Text(selectableAudios[index].validVideoTitle),
                      value: selectableAudios[index],
                      groupValue: _selectedAudio,
                      onChanged: (Audio? value) {
                        setState(() {
                          _selectedAudio = value;
                        });
                      },
                    );
                  },
                ),
              ),
              Row(
                // in this case, the audio is moved from a Youtube
                // playlist and so the keep audio entry in source
                // playlist checkbox is displayed
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!
                          .keepAudioEntryInSourcePlaylist,
                      style: TextStyle(
                        color: isDarkTheme ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: ScreenMixin.CHECKBOX_WIDTH_HEIGHT,
                    height: ScreenMixin.CHECKBOX_WIDTH_HEIGHT,
                    child: Checkbox(
                      value: _keepAudioDataInSourcePlaylist,
                      onChanged: (bool? newValue) {
                        setState(() {
                          _keepAudioDataInSourcePlaylist = newValue!;
                        });
                        // now clicking on Enter works since the
                        // Checkbox is not focused anymore
                        // _audioTitleSubStringFocusNode.requestFocus();
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        actions: [
          // situation of downloading a single video
          // audio. This is tested by 'Bug fix
          // verification with partial download single
          // video audio' integration test

          ElevatedButton(
            key: const Key('confirmButton'),
            onPressed: () {
              audioGlobalPlayerVM.setCurrentAudio(_selectedAudio!);
              Navigator.of(context).pop(_selectedAudio);
            },
            child: Text(AppLocalizations.of(context)!.confirmButton),
          ),
          ElevatedButton(
            key: const Key('cancelButton'),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
        ],
      ),
    );
  }
}
