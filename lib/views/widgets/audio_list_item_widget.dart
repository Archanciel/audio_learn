// dart file located in lib\views

import 'package:audio_learn/viewmodels/expandable_playlist_list_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../models/audio.dart';
import '../../../utils/ui_util.dart';
import '../../../viewmodels/audio_player_vm.dart';
import '../../../utils/time_util.dart';
import '../../constants.dart';
import '../screen_mixin.dart';
import 'audio_info_dialog_widget.dart';

enum AudioPopupMenuAction {
  openYoutubeVideo,
  copyYoutubeVideoUrl,
  displayAudioInfo,
  deleteAudio,
  deleteAudioFromPlaylistAswell,
}

class AudioListItemWidget extends StatelessWidget with ScreenMixin {
  final Audio audio;
  final void Function(Audio audio) onPlayPressedFunction;
  final void Function(Audio audio) onStopPressedFunction;
  final void Function(Audio audio) onPausePressedFunction;

  const AudioListItemWidget({
    super.key,
    required this.audio,
    required this.onPlayPressedFunction,
    required this.onStopPressedFunction,
    required this.onPausePressedFunction,
  });

  @override
  Widget build(BuildContext context) {

    return ListTile(
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {
          final RenderBox listTileBox = context.findRenderObject() as RenderBox;
          final Offset listTilePosition =
              listTileBox.localToGlobal(Offset.zero);

          showMenu(
            context: context,
            position: RelativeRect.fromLTRB(
              listTilePosition.dx - listTileBox.size.width,
              listTilePosition.dy,
              0,
              0,
            ),
            items: [
              PopupMenuItem<AudioPopupMenuAction>(
                key: const Key('popup_menu_open_youtube_video'),
                value: AudioPopupMenuAction.openYoutubeVideo,
                child: Text(AppLocalizations.of(context)!.openYoutubeVideo),
              ),
              PopupMenuItem<AudioPopupMenuAction>(
                key: const Key('popup_copy_youtube_video_url'),
                value: AudioPopupMenuAction.copyYoutubeVideoUrl,
                child: Text(AppLocalizations.of(context)!.copyYoutubeVideoUrl),
              ),
              PopupMenuItem<AudioPopupMenuAction>(
                key: const Key('popup_menu_display_audio_info'),
                value: AudioPopupMenuAction.displayAudioInfo,
                child: Text(AppLocalizations.of(context)!.displayAudioInfo),
              ),
              PopupMenuItem<AudioPopupMenuAction>(
                key: const Key('popup_menu_delete_audio'),
                value: AudioPopupMenuAction.deleteAudio,
                child: Text(AppLocalizations.of(context)!.deleteAudio),
              ),
              PopupMenuItem<AudioPopupMenuAction>(
                key: const Key('popup_menu_delete_audio_from_playlist_aswell'),
                value: AudioPopupMenuAction.deleteAudioFromPlaylistAswell,
                child: Text(AppLocalizations.of(context)!
                    .deleteAudioFromPlaylistAswell),
              ),
            ],
            elevation: 8,
          ).then((value) {
            if (value != null) {
              switch (value) {
                case AudioPopupMenuAction.openYoutubeVideo:
                  openUrlInExternalApp(url: audio.videoUrl);
                  break;
                case AudioPopupMenuAction.copyYoutubeVideoUrl:
                  Clipboard.setData(ClipboardData(text: audio.videoUrl));
                  break;
                case AudioPopupMenuAction.displayAudioInfo:
                  // Using FocusNode to enable clicking on Enter to close
                  // the dialog
                  final FocusNode focusNode = FocusNode();
                  showDialog<void>(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) {
                      return AudioInfoDialogWidget(
                        audio: audio,
                        focusNode: focusNode,
                      );
                    },
                  );
                  focusNode.requestFocus();
                  break;
                case AudioPopupMenuAction.deleteAudio:
                  Provider.of<ExpandablePlaylistListVM>(context, listen: false)
                      .deleteAudio(audio: audio);
                  break;
                case AudioPopupMenuAction.deleteAudioFromPlaylistAswell:
                  Provider.of<ExpandablePlaylistListVM>(context, listen: false)
                      .deleteAudioFromPlaylistAswell(audio: audio);
                  break;
                default:
                  break;
              }
            }
          });
        },
      ),
      title: Text(audio.validVideoTitle),
      subtitle: Text(_buildSubTitle(context)),
      trailing: _buildPlayButton(),
    );
  }

  String _buildSubTitle(BuildContext context) {
    String subTitle;

    Duration? audioDuration = audio.audioDuration;
    int audioFileSize = audio.audioFileSize;
    String audioFileSizeStr;

    audioFileSizeStr = UiUtil.formatLargeIntValue(
      context: context,
      value: audioFileSize,
    );

    int audioDownloadSpeed = audio.audioDownloadSpeed;
    String audioDownloadSpeedStr;

    if (audioDownloadSpeed.isInfinite) {
      audioDownloadSpeedStr = 'infinite o/sec';
    } else {
      audioDownloadSpeedStr = '${UiUtil.formatLargeIntValue(
        context: context,
        value: audioDownloadSpeed,
      )}/sec';
    }

    if (audioDuration == null) {
      subTitle = '?';
    } else {
      subTitle =
          '${audioDuration.HHmmss()}. $audioFileSizeStr ${AppLocalizations.of(context)!.atPreposition} $audioDownloadSpeedStr ${AppLocalizations.of(context)!.on} ${frenchDateTimeFormat.format(audio.audioDownloadDateTime)}';
    }
    return subTitle;
  }

  Widget _buildPlayButton() {
    return Consumer<AudioPlayerVM>(
      builder: (context, audioPlayerViewModel, child) {
        if (audio.isPlaying) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              (audio.isPaused)
                  ? IconButton(
                      icon: const Icon(Icons.play_arrow),
                      onPressed: () {
                        audioPlayerViewModel.pause(audio);
                      },
                    )
                  : IconButton(
                      icon: const Icon(Icons.pause),
                      onPressed: () {
                        audioPlayerViewModel.pause(audio);
                      },
                    ),
              IconButton(
                icon: const Icon(Icons.stop),
                onPressed: () {
                  audioPlayerViewModel.stop(audio);
                },
              ),
            ],
          );
        } else {
          return IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () {
              audioPlayerViewModel.play(audio);
            },
          );
        }
      },
    );
  }
}
