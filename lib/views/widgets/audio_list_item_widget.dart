// dart file located in lib\views

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../models/audio.dart';
import '../../../models/playlist.dart';
import '../../../utils/ui_util.dart';
import '../../../viewmodels/audio_download_vm.dart';
import '../../../viewmodels/audio_player_vm.dart';
import '../../../utils/time_util.dart';
import '../screen_mixin.dart';
import '../../../viewmodels/warning_message_vm.dart';

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
    String subTitleStr = buildSubTitle(context);

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
              PopupMenuItem<String>(
                key: const Key('popup_menu_open_youtube_video'),
                value: 'openYoutubeVideo',
                child: Text(AppLocalizations.of(context)!.openYoutubeVideo),
              ),
              PopupMenuItem<String>(
                key: const Key('popup_copy_youtube_video_url'),
                value: 'copyYoutubeVideoUrl',
                child: Text(AppLocalizations.of(context)!.copyYoutubeVideoUrl),
              ),
              PopupMenuItem<String>(
                key: const Key('popup_menu_delete_audio'),
                value: 'deleteAudio',
                child: Text(AppLocalizations.of(context)!.deleteAudio),
              ),
              PopupMenuItem<String>(
                key: const Key('popup_menu_delete_audio_from_playlist_aswell'),
                value: 'deleteAudioFromPlaylistAswell',
                child: Text(AppLocalizations.of(context)!
                    .deleteAudioFromPlaylistAswell),
              ),
            ],
            elevation: 8,
          ).then((value) {
            if (value != null) {
              switch (value) {
                case 'openYoutubeVideo':
                  openUrlInExternalApp(url: audio.videoUrl);
                  break;
                case 'copyYoutubeVideoUrl':
                  Clipboard.setData(ClipboardData(text: audio.videoUrl));
                  break;
                case 'deleteAudio':
                  Provider.of<AudioDownloadVM>(context, listen: false)
                      .deleteAudio(audio: audio);
                  break;
                case 'deleteAudioFromPlaylistAswell':
                  Playlist? audioEnclosingPlaylist = audio.enclosingPlaylist;
                  Provider.of<AudioDownloadVM>(context, listen: false)
                      .deleteAudioFromPlaylistAswell(audio: audio);
                  Provider.of<WarningMessageVM>(context, listen: false)
                      .setDeleteAudioFromPlaylistAswellTitle(
                          deleteAudioFromPlaylistAswellTitle:
                              audioEnclosingPlaylist!.title,
                          deleteAudioFromPlaylistAswellAudioVideoTitle:
                              audio.originalVideoTitle);
                  break;
                default:
                  break;
              }
            }
          });
        },
      ),
      title: Text(audio.validVideoTitle),
      subtitle: Text(subTitleStr),
      trailing: _buildPlayButton(),
    );
  }

  String buildSubTitle(BuildContext context) {
    String subTitle;

    Duration? audioDuration = audio.audioDuration;
    int audioFileSize = audio.audioFileSize;
    String audioFileSizeStr;

    audioFileSizeStr = UiUtil.formatLargeIntValue(audioFileSize);

    int audioDownloadSpeed = audio.audioDownloadSpeed;
    String audioDownloadSpeedStr;

    if (audioDownloadSpeed.isInfinite) {
      audioDownloadSpeedStr = 'infinite o/sec';
    } else {
      audioDownloadSpeedStr =
          '${UiUtil.formatLargeIntValue(audioDownloadSpeed)}/sec';
    }

    if (audioDuration == null) {
      subTitle = '?';
    } else {
      subTitle =
          '${audioDuration.HHmmss()}. ${AppLocalizations.of(context)!.size} $audioFileSizeStr. ${AppLocalizations.of(context)!.downloaded} ${AppLocalizations.of(context)!.atPreposition} $audioDownloadSpeedStr';
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
