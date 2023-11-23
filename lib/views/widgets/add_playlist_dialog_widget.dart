import 'package:audio_learn/views/screen_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../models/audio.dart';
import '../../models/playlist.dart';
import '../../utils/ui_util.dart';
import '../../viewmodels/playlist_list_vm.dart';

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
    return RawKeyboardListener(
      // Using FocusNode to enable clicking on Enter to close
      // the dialog
      focusNode: widget.focusNode,
      onKey: (event) {
        if (event.isKeyPressed(LogicalKeyboardKey.enter) ||
            event.isKeyPressed(LogicalKeyboardKey.numpadEnter)) {
          // executing the same code as in the 'Add'
          // ElevatedButton onPressed callback
          _addPlaylist(context);
          Navigator.of(context).pop();
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
          ElevatedButton(
            key: const Key('addPlaylistConfirmDialogAddButton'),
            onPressed: () {
              _addPlaylist(context);
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.add),
          ),
          ElevatedButton(
            key: const Key('addPlaylistConfirmDialogCancelButton'),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
        ],
      ),
    );
  }

  void _addPlaylist(BuildContext context) {
    String localPlaylistTitle = _localPlaylistTitleTextEditingController.text;
    PlaylistListVM expandablePlaylistListVM =
        Provider.of<PlaylistListVM>(context, listen: false);

    if (localPlaylistTitle.isNotEmpty) {
      // if the local playlist title is not empty, then add the local
      // playlist
      expandablePlaylistListVM.addPlaylist(
        localPlaylistTitle: localPlaylistTitle,
        playlistQuality:
            _isChecked ? PlaylistQuality.music : PlaylistQuality.voice,
      );
    } else {
      // if the local playlist title is empty, then add the Youtube
      // playlist if the Youtube playlist URL is not empty
      if (widget.playlistUrl.isNotEmpty) {
        expandablePlaylistListVM.addPlaylist(
          playlistUrl: widget.playlistUrl,
          playlistQuality:
              _isChecked ? PlaylistQuality.music : PlaylistQuality.voice,
        );
      }
    }
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
