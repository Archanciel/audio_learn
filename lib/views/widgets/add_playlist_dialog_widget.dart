import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../views/screen_mixin.dart';
import '../../models/audio.dart';
import '../../models/playlist.dart';
import '../../services/settings_data_service.dart';
import '../../utils/ui_util.dart';
import '../../viewmodels/playlist_list_vm.dart';
import '../../viewmodels/theme_provider_vm.dart';

class AddPlaylistDialogWidget extends StatefulWidget {
  final String playlistUrl;
  final FocusNode focusNode;

  const AddPlaylistDialogWidget({
    required this.playlistUrl,
    required this.focusNode,
    super.key,
  });

  @override
  State<AddPlaylistDialogWidget> createState() =>
      _AddPlaylistDialogWidgetState();
}

class _AddPlaylistDialogWidgetState extends State<AddPlaylistDialogWidget>
    with ScreenMixin {
  final TextEditingController _localPlaylistTitleTextEditingController =
      TextEditingController();
  final FocusNode _localPlaylistTitleFocusNode = FocusNode();

  bool _isChecked = false;

  @override
  void initState() {
    super.initState();

    // Add this line to request focus on the TextField after the build
    // method has been called
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(
        _localPlaylistTitleFocusNode,
      );
    });
  }

  @override
  void dispose() {
    _localPlaylistTitleTextEditingController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeProviderVM themeProviderVM = Provider.of<ThemeProviderVM>(context);

    return RawKeyboardListener(
      // Using FocusNode to enable clicking on Enter to close
      // the dialog
      focusNode: widget.focusNode,
      onKey: (event) async {
        if (event.isKeyPressed(LogicalKeyboardKey.enter) ||
            event.isKeyPressed(LogicalKeyboardKey.numpadEnter)) {
          // executing the same code as in the 'Add'
          // TextButton onPressed callback
          bool isYoutubePlaylistAdded = await _addPlaylist(context);
          Navigator.of(context).pop(isYoutubePlaylistAdded);
        }
      },
      child: AlertDialog(
        title: Text(
          key: const Key('playlistConfirmDialogTitleKey'),
          AppLocalizations.of(context)!.addPlaylistDialogTitle,
        ),
        actionsPadding:
            // reduces the top vertical space between the buttons
            // and the content
            const EdgeInsets.fromLTRB(
                10, 0, 10, 10), // Adjust the value as needed
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              createTitleCommentRowFunction(
                titleTextWidgetKey:
                    const Key('playlistTitleCommentConfirmDialogKey'),
                context: context,
                commentStr:
                    AppLocalizations.of(context)!.addPlaylistDialogComment,
              ),
              createCheckboxRowFunction(
                // displaying music quality checkbox
                checkBoxWidgetKey:
                    const Key('playlistQualityConfirmDialogCheckBox'),
                context: context,
                label: AppLocalizations.of(context)!.isMusicQualityLabel,
                value: _isChecked,
                onChanged: (bool? value) {
                  setState(() {
                    _isChecked = value ?? false;
                  });
                },
              ),
              (widget.playlistUrl.isNotEmpty)
                  ? createInfoRowFunction(
                      // displaying the playlist URL
                      valueTextWidgetKey:
                          const Key('playlistUrlConfirmDialogText'),
                      context: context,
                      label:
                          AppLocalizations.of(context)!.youtubePlaylistUrlLabel,
                      value: widget.playlistUrl)
                  : Container(),
              createEditableRowFunction(
                  // displaying the local playlist title TextField
                  valueTextFieldWidgetKey:
                      const Key('playlistLocalTitleConfirmDialogTextField'),
                  context: context,
                  label: AppLocalizations.of(context)!.localPlaylistTitleLabel,
                  controller: _localPlaylistTitleTextEditingController,
                  textFieldFocusNode: _localPlaylistTitleFocusNode),
            ],
          ),
        ),
        actions: [
          TextButton(
            key: const Key('addPlaylistConfirmDialogAddButton'),
            onPressed: () async {
              bool isYoutubePlaylistAdded = await _addPlaylist(context);
              Navigator.of(context).pop(isYoutubePlaylistAdded);
            },
            child: Text(
              AppLocalizations.of(context)!.add,
              style: (themeProviderVM.currentTheme == AppTheme.dark)
                  ? kTextButtonStyleDarkMode
                  : kTextButtonStyleLightMode,
            ),
          ),
          TextButton(
            key: const Key('addPlaylistConfirmDialogCancelButton'),
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

  /// Calls the [PlaylistListVM.addPlaylist] method to add the
  /// Youtube or local playlist.
  ///
  /// Returns true if the Youtube playlist was added, false
  /// otherwise. This will be used to empty the playlist URL
  /// TextField if a Youtube playlist was added.
  Future<bool> _addPlaylist(BuildContext context) async {
    String localPlaylistTitle = _localPlaylistTitleTextEditingController.text;
    PlaylistListVM expandablePlaylistListVM =
        Provider.of<PlaylistListVM>(context, listen: false);

    if (localPlaylistTitle.isNotEmpty) {
      // if the local playlist title is not empty, then add the local
      // playlist
      await expandablePlaylistListVM.addPlaylist(
        localPlaylistTitle: localPlaylistTitle,
        playlistQuality:
            _isChecked ? PlaylistQuality.music : PlaylistQuality.voice,
      );

      return false; // the playlist URL TextField will not be cleared
    } else {
      // if the local playlist title is empty, then add the Youtube
      // playlist if the Youtube playlist URL is not empty
      if (widget.playlistUrl.isNotEmpty) {
        bool isYoutubePlaylistAdded =
            await expandablePlaylistListVM.addPlaylist(
          playlistUrl: widget.playlistUrl,
          playlistQuality:
              _isChecked ? PlaylistQuality.music : PlaylistQuality.voice,
        );

        if (isYoutubePlaylistAdded) {
          return true; // this will clear the playlist URL TextField
        } else {
          return false; // the playlist URL TextField will not be cleared
        }
      }
    }

    return false; // the playlist URL TextField will not be cleared
  }

  String formatDownloadSpeed({
    required BuildContext context,
    required Audio audio,
  }) {
    int audioDownloadSpeed = audio.audioDownloadSpeed;
    String audioDownloadSpeedStr;

    if (audioDownloadSpeed.isInfinite) {
      audioDownloadSpeedStr =
          AppLocalizations.of(context)!.infiniteBytesPerSecond;
    } else {
      audioDownloadSpeedStr =
          '${UiUtil.formatLargeIntValue(context: context, value: audioDownloadSpeed)}/sec';
    }

    return audioDownloadSpeedStr;
  }
}
