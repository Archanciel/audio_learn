import 'package:audio_learn/views/screen_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../models/audio.dart';
import '../../models/playlist.dart';
import '../../utils/ui_util.dart';
import '../../viewmodels/expandable_playlist_list_vm.dart';

class AddPlaylistDialogWidget extends StatefulWidget {
  final String playlistUrl;
  final FocusNode focusNode;

  AddPlaylistDialogWidget({
    required this.playlistUrl,
    required this.focusNode,
    Key? key,
  }) : super(key: key);

  @override
  State<AddPlaylistDialogWidget> createState() =>
      _AddPlaylistDialogWidgetState();
}

class _AddPlaylistDialogWidgetState extends State<AddPlaylistDialogWidget>
    with ScreenMixin {
  final TextEditingController _localPlaylistTitleTextEditingController =
      TextEditingController();
  bool _isChecked = false;

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
          Navigator.of(context).pop();
        }
      },
      child: AlertDialog(
        title: Text(AppLocalizations.of(context)!.addPlaylistDialogTitle),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              createTitleCommentRowFunction(
                context: context,
                value: AppLocalizations.of(context)!.addPlaylistDialogComment,
              ),
              createInfoRowFunction(
                  context: context,
                  label: AppLocalizations.of(context)!.youtubePlaylistUrlLabel,
                  value: widget.playlistUrl),
              createEditableRowFunction(
                  context: context,
                  label: AppLocalizations.of(context)!.localPlaylistTitleLabel,
                  value: '',
                  controller: _localPlaylistTitleTextEditingController),
              createCheckboxRowFunction(
                context: context,
                label: AppLocalizations.of(context)!.isMusicQualityLabel,
                value: _isChecked,
                onChanged: (bool? value) {
                  setState(() {
                    _isChecked = value ?? false;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              String localPlaylistTitle =
                  _localPlaylistTitleTextEditingController.text;
              ExpandablePlaylistListVM expandablePlaylistListVM =
                  Provider.of<ExpandablePlaylistListVM>(context, listen: false);

              if (localPlaylistTitle.isNotEmpty) {
                expandablePlaylistListVM.addPlaylist(
                  localPlaylistTitle: localPlaylistTitle,
                  playlistQuality: _isChecked
                      ? PlaylistQuality.music
                      : PlaylistQuality.voice,
                );
              } else if (widget.playlistUrl.isNotEmpty) {
                expandablePlaylistListVM.addPlaylist(
                  playlistUrl: widget.playlistUrl,
                  playlistQuality: _isChecked
                      ? PlaylistQuality.music
                      : PlaylistQuality.voice,
                );
              }
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.apply),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
        ],
      ),
    );
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
