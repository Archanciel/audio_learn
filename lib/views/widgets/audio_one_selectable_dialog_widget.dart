import 'package:audio_learn/views/screen_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/audio.dart';
import '../../services/settings_data_service.dart';
import '../../viewmodels/audio_player_vm.dart';
import '../../viewmodels/theme_provider_vm.dart';

/// This dialog is used in the AudioPlayerView to display the list
/// of playable audios of the selected playlist and to enable the
/// user to select another audio to listen.
class AudioOneSelectableDialogWidget extends StatefulWidget {
  const AudioOneSelectableDialogWidget({
    super.key,
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

  final double _itemHeight = 70.0;

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
    ThemeProviderVM themeProvider = Provider.of<ThemeProviderVM>(context);
    bool isDarkTheme = themeProvider.currentTheme == AppTheme.dark;
    AudioPlayerVM audioGlobalPlayerVM =
        Provider.of<AudioPlayerVM>(context, listen: false);
    Audio? currentAudio = audioGlobalPlayerVM.currentAudio;

    List<Audio> playableAudioLst =
        audioGlobalPlayerVM.getPlayableAudiosOrderedByDownloadDate();

    // avoid error when the dialog is opened and the current
    // audio is not yet set
    if (currentAudio == null) {
      currentAudioIndex = -1;
    } else {
      currentAudioIndex = playableAudioLst.indexOf(currentAudio);
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
                        child: _buildTextWidget(
                          audio,
                          index,
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

  Widget _buildTextWidget(Audio audio, int index) {
    return SizedBox(
      height: _itemHeight,
      child: Text(
        audio.validVideoTitle,
        maxLines: 3,
        style: TextStyle(
          color: (index == currentAudioIndex) ? Colors.blue : null,
        ),
      ),
    );
  }

  void scrollToItem() {
    double multiplier = currentAudioIndex.toDouble();

    if (currentAudioIndex > 300) {
      multiplier *= 1.23;
    } else if (currentAudioIndex > 120) {
      multiplier *= 1.2;
    }

    final double offset = multiplier * _itemHeight;

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
