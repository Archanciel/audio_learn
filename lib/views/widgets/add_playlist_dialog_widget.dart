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

  const AddPlaylistDialogWidget({
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
  final FocusNode _localPlaylistTitleFocusNode = FocusNode();

  bool _isChecked = false;

  @override
  void initState() {
    // Add this line to request focus on the TextField after the build
    // method has been called
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(
        _localPlaylistTitleFocusNode,
      );
    });

    super.initState();
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
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              createTitleCommentRowFunction(
                titleTextWidgetKey:
                    const Key('playlistTitleCommentConfirmDialogKey'),
                context: context,
                value: AppLocalizations.of(context)!.addPlaylistDialogComment,
              ),
              createInfoRowFunction(
                  valueTextWidgetKey: const Key('playlistUrlConfirmDialogText'),
                  context: context,
                  label: AppLocalizations.of(context)!.youtubePlaylistUrlLabel,
                  value: widget.playlistUrl),
              createEditableRowFunction(
                  valueTextFieldWidgetKey:
                      const Key('playlistLocalTitleConfirmDialogTextField'),
                  context: context,
                  label: AppLocalizations.of(context)!.localPlaylistTitleLabel,
                  value: '',
                  controller: _localPlaylistTitleTextEditingController,
                  textFieldFocusNode: _localPlaylistTitleFocusNode),
              createCheckboxRowFunction(
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
    ExpandablePlaylistListVM expandablePlaylistListVM =
        Provider.of<ExpandablePlaylistListVM>(context, listen: false);

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
