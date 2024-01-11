import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../views/screen_mixin.dart';
import '../../constants.dart';
import '../../models/audio.dart';
import '../../services/settings_data_service.dart';
import '../../viewmodels/audio_player_vm.dart';
import '../../viewmodels/theme_provider_vm.dart';

/// This dialog is used in the AudioPlayerView to display the list
/// of playable audios of the selected playlist and to enable the
/// user to select another audio to listen.
class ListPlayableAudiosDialogWidget extends StatefulWidget {
  const ListPlayableAudiosDialogWidget({
    super.key,
  });

  @override
  _ListPlayableAudiosDialogWidgetState createState() =>
      _ListPlayableAudiosDialogWidgetState();
}

class _ListPlayableAudiosDialogWidgetState
    extends State<ListPlayableAudiosDialogWidget> with ScreenMixin {
  // Using FocusNode to enable clicking on Enter to close
  // the dialog
  final FocusNode _focusNode = FocusNode();

  Audio? _selectedAudio;
  bool _excludeFullyPlayedAudios = false;

  final ScrollController _scrollController = ScrollController();
  final GlobalKey myKey = GlobalKey();

  late int _currentAudioIndex;

  final double _itemHeight = 70.0;

  @override
  void initState() {
    super.initState();

    // Request focus when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _scrollToItem();
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
    ThemeProviderVM themeProviderVM = Provider.of<ThemeProviderVM>(context);
    bool isDarkTheme = themeProviderVM.currentTheme == AppTheme.dark;
    AudioPlayerVM audioGlobalPlayerVM =
        Provider.of<AudioPlayerVM>(context, listen: false);
    Audio? currentAudio = audioGlobalPlayerVM.currentAudio;

    List<Audio> playableAudioLst;

    if (_excludeFullyPlayedAudios) {
      playableAudioLst =
          audioGlobalPlayerVM.getNotFullyPlayedAudiosOrderedByDownloadDate();
    } else {
      playableAudioLst =
          audioGlobalPlayerVM.getPlayableAudiosOrderedByDownloadDate();
    }

    // avoid error when the dialog is opened and the current
    // audio is not yet set
    if (currentAudio == null) {
      _currentAudioIndex = -1;
    } else {
      _currentAudioIndex = playableAudioLst.indexOf(currentAudio);
    }

    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: (event) async {
        if (event.isKeyPressed(LogicalKeyboardKey.enter) ||
            event.isKeyPressed(LogicalKeyboardKey.numpadEnter)) {
          // executing the same code as in the 'Confirm' TextButton
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
                        child: _buildAudioTitleTextWidget(
                          audio,
                          index,
                          isDarkTheme,
                        ),
                      ),
                    );
                  },
                ),
              ),
              _buildBottomTextAndCheckbox(
                context,
                isDarkTheme,
              )
            ],
          ),
        ),
        actions: [
          TextButton(
            key: const Key('cancelButton'),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: (themeProviderVM.currentTheme == AppTheme.dark)
                  ? kTextButtonStyleDarkMode
                  : kTextButtonStyleLightMode,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomTextAndCheckbox(
    BuildContext context,
    bool isDarkTheme,
  ) {
    return Column(
      children: [
        const SizedBox(
          height: ScreenMixin.dialogCheckboxSizeBoxHeight,
        ),
        Row(
          // in this case, the audio is moved from a Youtube
          // playlist and so the keep audio entry in source
          // playlist checkbox is displayed
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.excludeFullyPlayedAudios,
                style: TextStyle(
                  color: isDarkTheme ? Colors.white : Colors.black,
                ),
              ),
            ),
            SizedBox(
              width: ScreenMixin.CHECKBOX_WIDTH_HEIGHT,
              height: ScreenMixin.CHECKBOX_WIDTH_HEIGHT,
              child: Checkbox(
                value: _excludeFullyPlayedAudios,
                onChanged: (bool? newValue) {
                  setState(() {
                    _excludeFullyPlayedAudios = newValue!;
                  });
                  // now clicking on Enter works since the
                  // Checkbox is not focused anymore
                  // _audioTitleSubStringFocusNode.requestFocus();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAudioTitleTextWidget(
    Audio audio,
    int index,
    bool isDarkTheme,
  ) {
    Color? audioTitleColor;

    if (index == _currentAudioIndex) {
      audioTitleColor = Colors.blue;
    } else if (audio.wasFullyListened()) {
      audioTitleColor = (isDarkTheme)
          ? kSliderThumbColorInDarkMode
          : kSliderThumbColorInLightMode;
    } else {
      audioTitleColor = null;
    }

    return SizedBox(
      height: _itemHeight,
      child: Text(
        audio.validVideoTitle,
        maxLines: 3,
        style: TextStyle(
          color: audioTitleColor,
        ),
      ),
    );
  }

  void _scrollToItem() {
    double multiplier = _currentAudioIndex.toDouble();

    if (_currentAudioIndex > 300) {
      multiplier *= 1.23;
    } else if (_currentAudioIndex > 120) {
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
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToItem());
    }
  }
}