import 'package:audio_learn/views/screen_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/audio.dart';
import '../../services/settings_data_service.dart';
import '../../viewmodels/audio_player_vm.dart';
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
    extends State<AudioOneSelectableDialogWidget> with ScreenMixin {
  // Using FocusNode to enable clicking on Enter to close
  // the dialog
  final FocusNode _focusNode = FocusNode();

  Audio? _selectedAudio;
  bool _keepAudioDataInSourcePlaylist = true;

  final ScrollController _scrollController = ScrollController();
  final GlobalKey myKey = GlobalKey();

  late int currentAudioIndex;

  double itemHeight = 65.0;

  @override
  void initState() {
    super.initState();

    // Request focus when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      scrollToItem();
    });
  }

  @override
  void dispose() {
    // Dispose the focus node when the widget is disposed
    _focusNode.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkTheme = themeProvider.currentTheme == AppTheme.dark;
    AudioPlayerVM audioGlobalPlayerVM =
        Provider.of<AudioPlayerVM>(context, listen: false);
    Audio? currentAudio = audioGlobalPlayerVM.currentAudio;

    List<Audio> playableAudioLst =
        audioGlobalPlayerVM.getPlayableAudiosOrderedByDownloadTime();

    // avoid error when the dialog is opened and the current
    // audio is not yet set
    if (currentAudio == null) {
      currentAudioIndex = -1;
    } else {
      currentAudioIndex = playableAudioLst.indexOf(currentAudio);
    }

    // defining the item height depending on the number of audios
    // in the playlist so that browsing the playlist is easier
    // in order to display the current audio in the visible audio
    // list area is more efficient
    if (currentAudioIndex > 400) {
      itemHeight = 105;
    } else if (currentAudioIndex > 300) {
      itemHeight = 67.0;
    } else {
      itemHeight = 65.0;
    }

    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: (event) async {
        if (event.isKeyPressed(LogicalKeyboardKey.enter) ||
            event.isKeyPressed(LogicalKeyboardKey.numpadEnter)) {
          // executing the same code as in the 'Confirm' ElevatedButton
          // onPressed callback
          await audioGlobalPlayerVM.setCurrentAudio(_selectedAudio!);
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
                  controller: _scrollController,
                  itemCount: playableAudioLst.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    Audio audio = playableAudioLst[index];
                    return ListTile(
                      title: GestureDetector(
                        onTap: () async {
                          await audioGlobalPlayerVM.setCurrentAudio(audio);
                          Navigator.of(context).pop(audio);
                        },
                        child: Text(
                          audio.validVideoTitle,
                          style: TextStyle(
                            color: (index == currentAudioIndex)
                                ? Colors.blue
                                : null,
                          ),
                        ),
                      ),
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

  void scrollToItem() {
    final double offset = currentAudioIndex * itemHeight;

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        offset,
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
    } else {
      // The scroll controller isn't attached to any scroll views.
      // Schedule a callback to try again after the next frame.
      WidgetsBinding.instance.addPostFrameCallback((_) => scrollToItem());
    }
  }
}
