import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
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
import 'sort_and_filter_audio_dialog.dart';

enum PlaylistPopupMenuButton { sortFilterAudios, other }

class ExpandablePlaylistListView extends StatefulWidget {
  final MaterialStateProperty<RoundedRectangleBorder>
      appElevatedButtonRoundedShape =
      MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kRoundedButtonBorderRadius)));
  @override
  State<ExpandablePlaylistListView> createState() =>
      _ExpandablePlaylistListViewState();
}

class _ExpandablePlaylistListViewState
    extends State<ExpandablePlaylistListView> {
  final TextEditingController _playlistUrlController = TextEditingController();

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
    if (_playlistUrlController.text.isEmpty) {
      _playlistUrlController.text =
          (audioDownloadViewModel.listOfPlaylist.isNotEmpty)
              ? audioDownloadViewModel.listOfPlaylist[0].url
              : kUniquePlaylistUrl;
    }
    return Container(
      margin: const EdgeInsets.all(kDefaultMargin),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextField(
                  key: const Key('playlistUrlTextField'),
                  controller: _playlistUrlController,
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
                    shape: widget.appElevatedButtonRoundedShape,
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.symmetric(
                          horizontal: kSmallButtonInsidePadding),
                    ),
                  ),
                  onPressed: () {
                    final String playlistUrl =
                        _playlistUrlController.text.trim();
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
                    shape: widget.appElevatedButtonRoundedShape,
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.symmetric(
                          horizontal: kSmallButtonInsidePadding),
                    ),
                  ),
                  onPressed: () {
                    Flushbar(
                      flushbarPosition: FlushbarPosition.TOP,
                      message: AppLocalizations.of(context)!
                          .singleVideoAudioDownload,
                      duration: const Duration(seconds: 5),
                      backgroundColor: Colors.green,
                      margin: kFlushbarEdgeInsets,
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                    ).show(context);
                    audioDownloadViewModel.downloadSingleVideoAudio(
                      videoUrl: _playlistUrlController.text.trim(),
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
                    shape: widget.appElevatedButtonRoundedShape,
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.symmetric(
                          horizontal: kSmallButtonInsidePadding),
                    ),
                  ),
                  onPressed: audioDownloadViewModel.isDownloading &&
                          !audioDownloadViewModel.isDownloadStopping
                      ? () {
                          // Flushbar creation must be located before calling
                          // the stopDownload method, otherwise the flushbar
                          // will be located higher.
                          Flushbar(
                            flushbarPosition: FlushbarPosition.TOP,
                            message: AppLocalizations.of(context)!
                                .audioDownloadingStopping,
                            duration: const Duration(seconds: 8),
                            backgroundColor: Colors.purple.shade900,
                            messageColor: Colors.white,
                            margin: kFlushbarEdgeInsets,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8)),
                          ).show(context);
                          audioDownloadViewModel.stopDownload();
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
                  style: ButtonStyle(
                    shape: widget.appElevatedButtonRoundedShape,
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.symmetric(
                          horizontal: kSmallButtonInsidePadding),
                    ),
                  ),
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
                          .isButtonMoveUpPlaylistEnabled
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
                  key: const Key('move_down_playlist_button'),
                  onPressed: Provider.of<ExpandablePlaylistListVM>(context)
                          .isButtonDownPlaylistEnabled
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
                  style: ButtonStyle(
                    shape: widget.appElevatedButtonRoundedShape,
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.symmetric(
                          horizontal: kSmallButtonInsidePadding),
                    ),
                  ),
                  onPressed: (Provider.of<ExpandablePlaylistListVM>(context)
                              .isButtonDownloadSelPlaylistsEnabled &&
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
              Tooltip(
                message: AppLocalizations.of(context)!.audioQuality,
                child: Checkbox(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  fillColor: MaterialStateColor.resolveWith(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.disabled)) {
                        return Colors.grey.shade800;
                      }
                      return kIconColor;
                    },
                  ),
                  value: audioDownloadViewModel.isHighQuality,
                  onChanged: (Provider.of<ExpandablePlaylistListVM>(context)
                              .isButtonMoveUpPlaylistEnabled &&
                          !Provider.of<AudioDownloadVM>(context).isDownloading)
                      ? (bool? value) {
                          audioDownloadViewModel.setAudioQuality(
                              isHighQuality: value ?? false);
                        }
                      : null,
                ),
              ),
              // Text(AppLocalizations.of(context)!.audioQuality),
              PopupMenuButton<PlaylistPopupMenuButton>(
                key: const Key('audio_popup_menu_button'),
                enabled: (Provider.of<ExpandablePlaylistListVM>(context)
                        .isButtonAudioPopupMenuEnabled),
                onSelected: (PlaylistPopupMenuButton value) {
                  // Handle menu item selection
                  switch (value) {
                    case PlaylistPopupMenuButton.sortFilterAudios:
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return SortAndFilterAudioDialog(
                            selectedPlaylistAudioLst:
                                Provider.of<ExpandablePlaylistListVM>(context)
                                    .getSelectedPlaylistsPlayableAudios(),
                          );
                        },
                      ).then((result) {
                        if (result != null) {
                          List<Audio> returnedAudioList = result;
                          Provider.of<ExpandablePlaylistListVM>(context,
                                  listen: false)
                              .setSortedFilteredSelectedPlaylistsPlayableAudios(
                                  returnedAudioList);
                        }
                      });
                      break;
                    case PlaylistPopupMenuButton.other:
                      break;
                    default:
                  }
                },
                icon: const Icon(Icons.filter_list),
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem<PlaylistPopupMenuButton>(
                      key: const Key('sort_and_filter_audio_dialog_item'),
                      value: PlaylistPopupMenuButton.sortFilterAudios,
                      child:
                          Text(AppLocalizations.of(context)!.sortFilterAudios),
                    ),
                    const PopupMenuItem<PlaylistPopupMenuButton>(
                      value: PlaylistPopupMenuButton.other,
                      child: Text('Option 2'),
                    ),
                    // Add more PopupMenuItems as needed
                  ];
                },
              ),
            ],
          ),
          Consumer<ExpandablePlaylistListVM>(
            builder: (context, expandablePlaylistListVM, child) {
              if (expandablePlaylistListVM.isListExpanded) {
                List<Playlist> upToDateSelectablePlaylists =
                    expandablePlaylistListVM.getUpToDateSelectablePlaylists();
                return Expanded(
                  child: ListView.builder(
                    itemCount: upToDateSelectablePlaylists.length,
                    itemBuilder: (context, index) {
                      Playlist item = upToDateSelectablePlaylists[index];
                      return ListTile(
                        title: Text(item.title),
                        trailing: Checkbox(
                          value: item.isSelected,
                          onChanged: (value) {
                            expandablePlaylistListVM.setPlaylistSelection(
                              playlistIndex: index,
                              isPlaylistSelected: value!,
                            );
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
                        .getSelectedPlaylistsPlayableAudios()[index];
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
