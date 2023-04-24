import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../constants.dart';
import '../models/audio.dart';
import '../models/playlist.dart';
import '../utils/ui_util.dart';
import '../viewmodels/audio_download_vm.dart';
import '../viewmodels/audio_player_vm.dart';
import '../viewmodels/expandable_playlist_list_vm.dart';
import 'audio_list_item_widget.dart';

class ExpandablePlaylistListView extends StatefulWidget {
  @override
  State<ExpandablePlaylistListView> createState() =>
      _ExpandablePlaylistListViewState();
}

class _ExpandablePlaylistListViewState
    extends State<ExpandablePlaylistListView> {
  final TextEditingController _textEditingController = TextEditingController();

  final AudioPlayerVM _audioPlayerViwModel = AudioPlayerVM();

  //define on audio plugin
  final OnAudioQuery _audioQuery = OnAudioQuery();

  //request permission from initStateMethod
  @override
  void initState() {
    super.initState();
    requestStoragePermission();
  }

  /// Requires adding the lines below to the main and debug AndroidManifest.xml
  /// files in order to work on S20 - Android 13 !
  ///     <uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
  ///     <uses-permission android:name="android.permission.READ_MEDIA_VIDEO"/>
  ///     <uses-permission android:name="android.permission.READ_MEDIA_AUDIO"/>
  void requestStoragePermission() async {
    //only if the platform is not web, coz web have no permissions
    if (!kIsWeb && !Platform.isWindows) {
      bool permissionStatus = await _audioQuery.permissionsStatus();
      if (!permissionStatus) {
        await _audioQuery.permissionsRequest();
      }

      //ensure build method is called
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final AudioDownloadVM audioDownloadViewModel =
        Provider.of<AudioDownloadVM>(context);
    if (_textEditingController.text.isEmpty) {
      _textEditingController.text =
          (audioDownloadViewModel.listOfPlaylist.isNotEmpty)
              ? audioDownloadViewModel.listOfPlaylist[0].url
              : '';
    }
    return Container(
      margin: EdgeInsets.all(kDefaultMargin),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextField(
                  key: const Key('playlistUrlTextField'),
                  controller: _textEditingController,
                  decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context)!.ytPlaylistLinkLabel,
                    hintText:
                        AppLocalizations.of(context)!.ytPlaylistLinkHintText,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(
                width: kRowWidthSeparator,
              ),
              SizedBox(
                width: kSmallButtonWidth,
                child: ElevatedButton(
                  key: const Key('addPlaylistButton'),
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.symmetric(
                          horizontal: kSmallButtonInsidePadding),
                    ),
                  ),
                  onPressed: () {
                    final String playlistUrl =
                        _textEditingController.text.trim();
                    if (playlistUrl.isNotEmpty) {
                      Provider.of<ExpandablePlaylistListVM>(context,
                              listen: false)
                          .addPlaylist(playlistUrl: playlistUrl);
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.addPlaylist),
                ),
              ),
              const SizedBox(
                width: kRowWidthSeparator,
              ),
              SizedBox(
                width: kSmallButtonWidth,
                child: ElevatedButton(
                  key: const Key('downloadSingleVideoButton'),
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.symmetric(
                          horizontal: kSmallButtonInsidePadding),
                    ),
                  ),
                  onPressed: () {
                    audioDownloadViewModel.downloadSingleVideoAudio(
                      videoUrl: _textEditingController.text.trim(),
                    );
                  },
                  child: Text(
                      AppLocalizations.of(context)!.downloadSingleVideoAudio),
                ),
              ),
              const SizedBox(
                width: kRowWidthSeparator,
              ),
              SizedBox(
                width: kSmallestButtonWidth,
                child: ElevatedButton(
                  key: const Key('stopDownloadingButton'),
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.symmetric(
                          horizontal: kSmallButtonInsidePadding),
                    ),
                  ),
                  onPressed: audioDownloadViewModel.isDownloading &&
                          !audioDownloadViewModel.isDownloadStopping
                      ? () {
                          audioDownloadViewModel.stopDownload();
                          Flushbar(
                            flushbarPosition: FlushbarPosition.TOP,
                            message: AppLocalizations.of(context)!
                                .audioDownloadingStopping,
                            duration: const Duration(seconds: 3),
                            backgroundColor: Colors.blue,
                            margin: const EdgeInsets.all(15),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8)),
                          ).show(context);
                        }
                      : null,
                  child: Text(AppLocalizations.of(context)!.stopDownload),
                ),
              ),
            ],
          ),
          // displaying the currently downloading audiodownload
          // informations.
          Consumer<AudioDownloadVM>(
            builder: (context, audioDownloadVM, child) {
              if (audioDownloadVM.isDownloading) {
                String downloadProgressPercent =
                    '${(audioDownloadVM.downloadProgress * 100).toStringAsFixed(1)}%';
                String downloadFileSize =
                    '${UiUtil.formatLargeIntValue(audioDownloadVM.currentDownloadingAudio.audioFileSize)}';
                String downloadSpeed =
                    '${UiUtil.formatLargeIntValue(audioDownloadVM.lastSecondDownloadSpeed)}/sec';
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        audioDownloadVM
                            .currentDownloadingAudio.originalVideoTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10.0),
                      LinearProgressIndicator(
                          value: audioDownloadVM.downloadProgress),
                      const SizedBox(height: 10.0),
                      Text(
                        '$downloadProgressPercent ${AppLocalizations.of(context)!.ofPreposition} $downloadFileSize ${AppLocalizations.of(context)!.atPreposition} $downloadSpeed',
                      ),
                    ],
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(
                width: 87,
                child: ElevatedButton(
                  key: const Key('toggle_button'),
                  onPressed: () {
                    Provider.of<ExpandablePlaylistListVM>(context,
                            listen: false)
                        .toggleList();
                  },
                  child: const Text('Playlists'),
                ),
              ),
              Expanded(
                child: IconButton(
                  key: const Key('move_up_button'),
                  onPressed: Provider.of<ExpandablePlaylistListVM>(context)
                          .isButton2Enabled
                      ? () {
                          Provider.of<ExpandablePlaylistListVM>(context,
                                  listen: false)
                              .moveSelectedItemUp();
                        }
                      : null,
                  padding: const EdgeInsets.all(0),
                  icon: const Icon(
                    Icons.arrow_drop_up,
                    size: 50,
                  ),
                ),
              ),
              Expanded(
                child: IconButton(
                  key: const Key('move_down_button'),
                  onPressed: Provider.of<ExpandablePlaylistListVM>(context)
                          .isButton3Enabled
                      ? () {
                          Provider.of<ExpandablePlaylistListVM>(context,
                                  listen: false)
                              .moveSelectedItemDown();
                        }
                      : null,
                  padding: const EdgeInsets.all(0),
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    size: 50,
                  ),
                ),
              ),
              SizedBox(
                width: 90,
                child: ElevatedButton(
                  key: const Key('download_sel_playlists_button'),
                  onPressed: (Provider.of<ExpandablePlaylistListVM>(context)
                              .isButton1Enabled &&
                          !Provider.of<AudioDownloadVM>(context).isDownloading)
                      ? () {
                          List<Playlist> selectedPlaylists =
                              Provider.of<ExpandablePlaylistListVM>(context,
                                      listen: false)
                                  .getSelectedPlaylists();

                          // currently only one playlist can be selected and
                          // downloaded at a time.
                          Provider.of<AudioDownloadVM>(context, listen: false)
                              .downloadPlaylistAudios(
                                  playlistUrl: selectedPlaylists[0].url);
                        }
                      : null,
                  child: Text(
                      AppLocalizations.of(context)!.downloadSelectedPlaylists),
                ),
              ),
            ],
          ),
          Consumer<ExpandablePlaylistListVM>(
            builder: (context, expandablePlaylistListViewModel, child) {
              if (expandablePlaylistListViewModel.isListExpanded) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: expandablePlaylistListViewModel
                        .getUpToDateSelectablePlaylists()
                        .length,
                    itemBuilder: (context, index) {
                      Playlist item = expandablePlaylistListViewModel
                          .getUpToDateSelectablePlaylists()[index];
                      return ListTile(
                        title: Text(item.title),
                        trailing: Checkbox(
                          value: item.isSelected,
                          onChanged: (value) {
                            expandablePlaylistListViewModel.selectItem(
                                context, index);
                          },
                        ),
                      );
                    },
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
          Expanded(
            child: Consumer<ExpandablePlaylistListVM>(
              builder: (context, expandablePlaylistListVM, child) {
                return ListView.builder(
                  itemCount:
                      (expandablePlaylistListVM.getSelectedPlaylists().isEmpty)
                          ? 0
                          : expandablePlaylistListVM
                              .getSelectedPlaylists()[0]
                              .playableAudioLst
                              .length,
                  itemBuilder: (BuildContext context, int index) {
                    final audio = expandablePlaylistListVM
                        .getSelectedPlaylists()[0]
                        .playableAudioLst[index];
                    return AudioListItemWidget(
                      audio: audio,
                      onPlayPressedFunction: (Audio audio) {
                        _audioPlayerViwModel.play(audio);
                      },
                      onStopPressedFunction: (Audio audio) {
                        _audioPlayerViwModel.stop(audio);
                      },
                      onPausePressedFunction: (Audio audio) {
                        _audioPlayerViwModel.pause(audio);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
