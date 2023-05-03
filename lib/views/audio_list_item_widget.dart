// dart file located in lib\views

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/audio.dart';
import '../utils/ui_util.dart';
import '../viewmodels/audio_player_vm.dart';
import '../utils/time_util.dart';

class AudioListItemWidget extends StatelessWidget {
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

  Future<void> _launchURL(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

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
                key: Key('leadingMenuOption1'),
                value: 'openYoutube',
                child: Text(AppLocalizations.of(context)!.openYoutubeVideo),
              ),
            ],
            elevation: 8,
          ).then((value) {
            if (value != null) {
              switch (value) {
                case 'openYoutube':
                  _launchURL(audio.videoUrl);
                  break;
                case 'option2':
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
