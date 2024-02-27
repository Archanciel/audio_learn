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

  bool _backToAllAudios = false;

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

    return KeyboardListener(
      focusNode: _focusNode,
        onKeyEvent: (event) async {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.numpadEnter) {
          // executing the same code as in the 'Confirm' TextButton
          // onPressed callback
          // await audioGlobalPlayerVM.setCurrentAudio(_selectedAudio!);
          Navigator.of(context).pop(_selectedAudio);
        }}
      },
      child: AlertDialog(
        title: Text(AppLocalizations.of(context)!.audioOneSelectedDialogTitle),
        actionsPadding: kDialogActionsPadding,
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
                key: const Key('excludeFullyPlayedAudiosCheckbox'),
                value: _excludeFullyPlayedAudios,
                onChanged: (bool? newValue) {
                  setState(() {
                    if (newValue != null) {
                      if (newValue) {
                        _backToAllAudios = false;
                      } else {
                        _backToAllAudios = true;
                      }
                      _excludeFullyPlayedAudios = newValue;
                      _scrollToItem();
                    }
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
    Color? audioTitleTextColor;
    Color? audioTitleBackgroundColor;

    if (index == _currentAudioIndex) {
      audioTitleTextColor = Colors.white;
      audioTitleBackgroundColor = Colors.blue;
    } else if (audio.wasFullyListened()) {
      audioTitleTextColor = (isDarkTheme)
          ? kSliderThumbColorInDarkMode
          : kSliderThumbColorInLightMode;
      audioTitleBackgroundColor = null;
    } else if (audio.isPartiallyListened()) {
      audioTitleTextColor = Colors.blue;
      audioTitleBackgroundColor = null;
    } else {
      audioTitleTextColor = null;
      audioTitleBackgroundColor = null;
    }

    return SizedBox(
      height: _itemHeight,
      child: Text(
        audio.validVideoTitle,
        maxLines: 3,
        style: TextStyle(
          color: audioTitleTextColor,
          backgroundColor: audioTitleBackgroundColor,
        ),
      ),
    );
  }

  void _scrollToItem() {
    double multiplier = _currentAudioIndex.toDouble();

    if (_currentAudioIndex > 300) {
      multiplier *= 1.23;
    } else if (_currentAudioIndex > 200) {
      multiplier *= 1.21;
    } else if (_currentAudioIndex > 120) {
      multiplier *= 1.2;
    }

    double offset = multiplier * _itemHeight;

    if (_backToAllAudios) {
      // improves the scrolling when the user goes back to
      // the list of all audios
      offset *= 1.4;
      _backToAllAudios = false;
    }

    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0.0);
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
