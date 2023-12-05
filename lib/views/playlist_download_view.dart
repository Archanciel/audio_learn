import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../constants.dart';
import '../models/audio.dart';
import '../models/playlist.dart';
import '../services/permission_requester_service.dart';
import '../utils/ui_util.dart';
import '../viewmodels/audio_download_vm.dart';
import '../viewmodels/playlist_list_vm.dart';
import '../viewmodels/warning_message_vm.dart';
import 'widgets/add_playlist_dialog_widget.dart';
import 'widgets/audio_learn_snackbar.dart';
import 'widgets/audio_list_item_widget.dart';
import 'screen_mixin.dart';
import 'widgets/display_message_widget.dart';
import 'widgets/playlist_list_item_widget.dart';
import 'widgets/playlist_one_selectable_dialog_widget.dart';
import 'widgets/sort_and_filter_audio_dialog_widget.dart';

enum PlaylistPopupMenuButton {
  sortFilterAudios,
  subSortFilterAudios,
  updatePlaylistJson,
  updateAppPlaylistList,
}

class PlaylistDownloadView extends StatefulWidget {
  // this instance variable stores the function defined in
  // _MyHomePageState which causes the PageView widget to drag
  // to another screen according to the passed index.
  // This function is necessary since it is passed to the
  // constructor of AudioListItemWidget.
  final Function(int) onPageChangedFunction;

  const PlaylistDownloadView({
    super.key,
    required this.onPageChangedFunction,
  });

  @override
  State<PlaylistDownloadView> createState() => _PlaylistDownloadViewState();
}

class _PlaylistDownloadViewState extends State<PlaylistDownloadView>
    with ScreenMixin {
  final TextEditingController _playlistUrlController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Audio> _selectedPlaylistsPlayableAudios = [];

  //request permission from initStateMethod
  @override
  void initState() {
    super.initState();
    PermissionRequesterService.requestMultiplePermissions();

    // enabling to download a playlist in the emulator in which
    // pasting a URL is not possible
    // if (kPastedPlaylistUrl.isNotEmpty) {
    //   _playlistUrlController.text = kPastedPlaylistUrl;
    // }
  }

  @override
  void dispose() {
    _playlistUrlController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AudioDownloadVM audioDownloadViewModel = Provider.of<AudioDownloadVM>(
      context,
      listen: false,
    );
    return Container(
      margin: const EdgeInsets.all(kDefaultMargin),
      child: Column(
        children: <Widget>[
          Consumer<WarningMessageVM>(
            builder: (context, warningMessageVM, child) {
              // displays a warning message each time the
              // warningMessageVM calls notifyListners(), which
              // happens when an other view model sets a warning
              // message on the warningMessageVM
              return DisplayMessageWidget(
                warningMessageVM: warningMessageVM,
                parentContext: context,
                playlistUrlController: _playlistUrlController,
              );
            },
          ),
          SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  // necessary to avoid Exception
                  child: Column(
                    children: [
                      Expanded(
                        flex: 6, // controls the height ratio
                        child: TextField(
                          key: const Key('playlistUrlTextField'),
                          controller: _playlistUrlController,
                          style: const TextStyle(fontSize: 15),
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!
                                .ytPlaylistLinkLabel,
                            hintText: AppLocalizations.of(context)!
                                .ytPlaylistLinkHintText,
                            border: const OutlineInputBorder(),
                            isDense: true,
                            contentPadding: const EdgeInsets.all(2),
                          ),
                          maxLines: 1,
                        ),
                      ),
                      Expanded(
                        flex: 4, // controls the height ratio
                        child: TextField(
                          key: const Key('selectedPlaylistTextField'),
                          readOnly: true,
                          controller: TextEditingController(
                            text: Provider.of<PlaylistListVM>(context)
                                    .uniqueSelectedPlaylist
                                    ?.title ??
                                '',
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.all(2),
                          ),
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: kRowWidthSeparator,
                ),
                SizedBox(
                  width: kSmallestButtonWidth,
                  child: Tooltip(
                    message:
                        AppLocalizations.of(context)!.addPlaylistButtonTooltip,
                    child: ElevatedButton(
                      key: const Key('addPlaylistButton'),
                      style: ButtonStyle(
                        shape: appElevatedButtonRoundedShape,
                        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                          const EdgeInsets.symmetric(
                              horizontal: kSmallButtonInsidePadding),
                        ),
                      ),
                      onPressed: () {
                        final String playlistUrl =
                            _playlistUrlController.text.trim();
                        // Using FocusNode to enable clicking on Enter to close
                        // the dialog
                        final FocusNode focusNode = FocusNode();
                        showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (BuildContext context) {
                            return AddPlaylistDialogWidget(
                              playlistUrl: playlistUrl,
                              focusNode: focusNode,
                            );
                          },
                        ).then((value) {
                          // not null value is boolean
                          if (value != null && value) {
                            // value is null if
                            //                             clicking on Cancel
                            //                             or if the dialog is
                            //                             dismissed by clicking
                            //                             outside the dialog.

                            // if a Youtube playlist has been added, then
                            // the playlistUrlController is cleared
                            _playlistUrlController.clear();
                          }
                        });
                        focusNode.requestFocus();
                      },
                      child: Text(AppLocalizations.of(context)!.addPlaylist),
                    ),
                  ),
                ),
                const SizedBox(
                  width: kRowWidthSeparator,
                ),
                SizedBox(
                  width: kSmallButtonWidth, // necessary to display english text
                  child: Tooltip(
                    message: AppLocalizations.of(context)!
                        .downloadSingleVideoButtonTooltip,
                    child: ElevatedButton(
                      key: const Key('downloadSingleVideoButton'),
                      style: ButtonStyle(
                        shape: appElevatedButtonRoundedShape,
                        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                          const EdgeInsets.symmetric(
                              horizontal: kSmallButtonInsidePadding),
                        ),
                      ),
                      onPressed: () {
                        PlaylistListVM expandablePlaylistListVM =
                            Provider.of<PlaylistListVM>(context, listen: false);

                        // disabling the sorted filtered playable audio list
                        // downloading audios of selected playlists so that
                        // the currently displayed audio list is not sorted
                        // or/and filtered. This way, the newly downloaded
                        // audio will be added at top of the displayed audio
                        // list.
                        expandablePlaylistListVM
                            .disableSortedFilteredPlayableAudioLst();

                        Playlist? selectedTargetPlaylist;

                        showDialog(
                          context: context,
                          builder: (context) =>
                              const PlaylistOneSelectableDialogWidget(
                            usedFor: PlaylistOneSelectableDialogUsedFor
                                .downloadSingleVideoAudio,
                          ),
                        ).then((_) {
                          PlaylistListVM expandablePlaylistVM =
                              Provider.of<PlaylistListVM>(context,
                                  listen: false);
                          selectedTargetPlaylist =
                              expandablePlaylistVM.uniqueSelectedPlaylist;

                          if (selectedTargetPlaylist == null) {
                            return;
                          }

                          // Using FocusNode to enable clicking on Enter to close
                          // the dialog
                          final FocusNode focusNode = FocusNode();

                          // confirming or not the addition of the single video
                          // audio to the selected playlist
                          showDialog(
                            context: context,
                            builder: (context) => RawKeyboardListener(
                              // Using FocusNode to enable clicking on Enter to close
                              // the dialog
                              focusNode: focusNode,
                              onKey: (event) {
                                if (event.isKeyPressed(
                                        LogicalKeyboardKey.enter) ||
                                    event.isKeyPressed(
                                        LogicalKeyboardKey.numpadEnter)) {
                                  // executing the same code as in the 'Ok'
                                  // ElevatedButton onPressed callback
                                  Navigator.of(context).pop('ok');
                                }
                              },
                              child: AlertDialog(
                                title: Text(AppLocalizations.of(context)!
                                    .confirmDialogTitle),
                                actionsPadding:
                                    // reduces the top vertical space between the buttons
                                    // and the content
                                    const EdgeInsets.fromLTRB(10, 0, 10,
                                        10), // Adjust the value as needed
                                content: Text(
                                  AppLocalizations.of(context)!
                                      .confirmSingleVideoAudioPlaylistTitle(
                                    selectedTargetPlaylist!.title,
                                  ),
                                  style: kDialogTextFieldStyle,
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text('Ok'),
                                    onPressed: () {
                                      Navigator.of(context).pop('ok');
                                    },
                                  ),
                                  TextButton(
                                    child: Text(
                                        AppLocalizations.of(context)!.cancel),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ).then((value) async {
                            if (value != null) {
                              // the case if the user clicked on Ok button
                              bool isSingleVideoAudioCorrectlyDownloaded =
                                  await audioDownloadViewModel
                                      .downloadSingleVideoAudio(
                                videoUrl: _playlistUrlController.text.trim(),
                                singleVideoTargetPlaylist:
                                    selectedTargetPlaylist!,
                              );

                              if (isSingleVideoAudioCorrectlyDownloaded) {
                                // if the single video audio has been
                                // correctly downloaded, then the playlistUrl
                                // field is cleared
                                _playlistUrlController.clear();
                              }
                            }
                          });
                          focusNode.requestFocus();
                        });
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize
                            .min, // Pour s'assurer que le Row n'occupe pas plus d'espace que nécessaire
                        children: <Widget>[
                          const Icon(
                            Icons.download_outlined,
                            size: 15,
                          ), // Icône
                          Text(
                            AppLocalizations.of(context)!
                                .downloadSingleVideoAudio,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: kRowWidthSeparator,
                ),
                SizedBox(
                  width: kSmallestButtonWidth,
                  child: Tooltip(
                    message: AppLocalizations.of(context)!
                        .stopDownloadingButtonTooltip,
                    child: ElevatedButton(
                      key: const Key('stopDownloadingButton'),
                      style: ButtonStyle(
                        shape: appElevatedButtonRoundedShape,
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
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(8)),
                              ).show(context);
                              audioDownloadViewModel.stopDownload();
                            }
                          : null,
                      child: Text(AppLocalizations.of(context)!.stopDownload),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // displaying the currently downloading audiodownload
          // informations.
          Consumer<AudioDownloadVM>(
            builder: (context, audioDownloadVM, child) {
              if (audioDownloadVM.isDownloading) {
                String downloadProgressPercent =
                    '${(audioDownloadVM.downloadProgress * 100).toStringAsFixed(1)}%';
                String downloadFileSize = UiUtil.formatLargeIntValue(
                  context: context,
                  value: audioDownloadVM.currentDownloadingAudio.audioFileSize,
                );
                String downloadSpeed = '${UiUtil.formatLargeIntValue(
                  context: context,
                  value: audioDownloadVM.lastSecondDownloadSpeed,
                )}/sec';
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        audioDownloadVM.currentDownloadingAudio.validVideoTitle,
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
                width: kNormalButtonWidth,
                child: Tooltip(
                  message:
                      AppLocalizations.of(context)!.playlistToggleButtonTooltip,
                  child: ElevatedButton(
                    key: const Key('playlist_toggle_button'),
                    style: ButtonStyle(
                      shape: appElevatedButtonRoundedShape,
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        const EdgeInsets.symmetric(
                            horizontal: kSmallButtonInsidePadding),
                      ),
                    ),
                    onPressed: () {
                      Provider.of<PlaylistListVM>(context, listen: false)
                          .toggleList();
                    },
                    child: const Text('Playlists'),
                  ),
                ),
              ),
              Expanded(
                child: IconButton(
                  key: const Key('move_up_playlist_button'),
                  onPressed: Provider.of<PlaylistListVM>(context)
                          .isButtonMoveUpPlaylistEnabled
                      ? () {
                          Provider.of<PlaylistListVM>(context, listen: false)
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
                  onPressed: Provider.of<PlaylistListVM>(context)
                          .isButtonDownPlaylistEnabled
                      ? () {
                          Provider.of<PlaylistListVM>(context, listen: false)
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
                width: kGreaterButtonWidth,
                child: Tooltip(
                  message: AppLocalizations.of(context)!
                      .downloadSelPlaylistsButtonTooltip,
                  child: ElevatedButton(
                    key: const Key('download_sel_playlists_button'),
                    style: ButtonStyle(
                      shape: appElevatedButtonRoundedShape,
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        const EdgeInsets.symmetric(
                            horizontal: kSmallButtonInsidePadding),
                      ),
                    ),
                    onPressed: (Provider.of<PlaylistListVM>(context)
                                .isButtonDownloadSelPlaylistsEnabled &&
                            !Provider.of<AudioDownloadVM>(context)
                                .isDownloading)
                        ? () async {
                            PlaylistListVM expandablePlaylistListVM =
                                Provider.of<PlaylistListVM>(context,
                                    listen: false);

                            // disable the sorted filtered playable audio list
                            // downloading audios of selected playlists so that
                            // the currently displayed audio list is not sorted
                            // or/and filtered. This way, the newly downloaded
                            // audio will be added at top of the displayed audio
                            // list.
                            expandablePlaylistListVM
                                .disableSortedFilteredPlayableAudioLst();

                            List<Playlist> selectedPlaylists =
                                expandablePlaylistListVM.getSelectedPlaylist();

                            // currently only one playlist can be selected and
                            // downloaded at a time.
                            await Provider.of<AudioDownloadVM>(context,
                                    listen: false)
                                .downloadPlaylistAudios(
                                    playlistUrl: selectedPlaylists[0].url);
                          }
                        : null,
                    child: Row(
                      mainAxisSize: MainAxisSize
                          .min, // Pour s'assurer que le Row n'occupe pas plus d'espace que nécessaire
                      children: <Widget>[
                        const Icon(
                          Icons.download_outlined,
                          size: 15,
                        ),
                        Text(AppLocalizations.of(context)!
                            .downloadSelectedPlaylist), // Texte
                      ],
                    ),
                  ),
                ),
              ),
              Tooltip(
                message: AppLocalizations.of(context)!.musicalQualityTooltip,
                child: SizedBox(
                  width: 20,
                  child: Checkbox(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    fillColor: MaterialStateColor.resolveWith(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.disabled)) {
                          return Colors.grey.shade800;
                        }
                        return kDarkAndLightIconColor;
                      },
                    ),
                    value: audioDownloadViewModel.isHighQuality,
                    onChanged: (Provider.of<PlaylistListVM>(context)
                                .isButtonMoveUpPlaylistEnabled &&
                            !Provider.of<AudioDownloadVM>(context)
                                .isDownloading)
                        ? (bool? value) {
                            bool isHighQuality = value ?? false;
                            audioDownloadViewModel.setAudioQuality(
                                isHighQuality: isHighQuality);
                            String snackBarMessage = isHighQuality
                                ? AppLocalizations.of(context)!
                                    .audioQualityHighSnackBarMessage
                                : AppLocalizations.of(context)!
                                    .audioQualityLowSnackBarMessage;
                            ScaffoldMessenger.of(context).showSnackBar(
                              AudioLearnSnackBar(
                                message: snackBarMessage,
                              ),
                            );
                          }
                        : null,
                  ),
                ),
              ),
              SizedBox(
                width: 35,
                child: PopupMenuButton<PlaylistPopupMenuButton>(
                  key: const Key('audio_popup_menu_button'),
                  enabled: (Provider.of<PlaylistListVM>(context)
                      .isButtonAudioPopupMenuEnabled),
                  onSelected: (PlaylistPopupMenuButton value) {
                    // Handle menu item selection
                    switch (value) {
                      case PlaylistPopupMenuButton.sortFilterAudios:
                        // Using FocusNode to enable clicking on Enter to close
                        // the dialog
                        final FocusNode focusNode = FocusNode();
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return SortAndFilterAudioDialogWidget(
                              selectedPlaylistAudioLst:
                                  Provider.of<PlaylistListVM>(context)
                                      .getSelectedPlaylistPlayableAudios(
                                subFilterAndSort: false,
                              ),
                              focusNode: focusNode,
                            );
                          },
                        ).then((result) {
                          if (result != null) {
                            List<Audio> returnedAudioList = result;
                            Provider.of<PlaylistListVM>(context, listen: false)
                                .setSortedFilteredSelectedPlaylistsPlayableAudios(
                                    returnedAudioList);
                          }
                        });
                        focusNode.requestFocus();
                        break;
                      case PlaylistPopupMenuButton.subSortFilterAudios:
                        // Using FocusNode to enable clicking on Enter to close
                        // the dialog
                        final FocusNode focusNode = FocusNode();
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return SortAndFilterAudioDialogWidget(
                              selectedPlaylistAudioLst:
                                  Provider.of<PlaylistListVM>(context)
                                      .getSelectedPlaylistPlayableAudios(
                                subFilterAndSort: true,
                              ),
                              focusNode: focusNode,
                            );
                          },
                        ).then((result) {
                          if (result != null) {
                            List<Audio> returnedAudioList = result;
                            Provider.of<PlaylistListVM>(context, listen: false)
                                .setSortedFilteredSelectedPlaylistsPlayableAudios(
                                    returnedAudioList);
                          }
                        });
                        focusNode.requestFocus();
                        break;
                      case PlaylistPopupMenuButton.updatePlaylistJson:
                        Provider.of<PlaylistListVM>(context, listen: false)
                            .updateSettingsAndPlaylistJsonFiles();
                        break;
                      default:
                        break;
                    }
                  },
                  icon: const Icon(Icons.filter_list),
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem<PlaylistPopupMenuButton>(
                        key: const Key('sort_and_filter_audio_dialog_item'),
                        value: PlaylistPopupMenuButton.sortFilterAudios,
                        child: Text(
                            AppLocalizations.of(context)!.sortFilterAudios),
                      ),
                      PopupMenuItem<PlaylistPopupMenuButton>(
                        key: const Key('sub_sort_and_filter_audio_dialog_item'),
                        value: PlaylistPopupMenuButton.subSortFilterAudios,
                        child: Text(
                            AppLocalizations.of(context)!.subSortFilterAudios),
                      ),
                      PopupMenuItem<PlaylistPopupMenuButton>(
                        key: const Key('update_playlist_json_dialog_item'),
                        value: PlaylistPopupMenuButton.updatePlaylistJson,
                        child: Text(AppLocalizations.of(context)!
                            .updatePlaylistJsonFiles),
                      ),
                    ];
                  },
                ),
              ),
            ],
          ),
          Consumer<PlaylistListVM>(
            builder: (context, expandablePlaylistListVM, child) {
              if (expandablePlaylistListVM.isListExpanded) {
                List<Playlist> upToDateSelectablePlaylists =
                    expandablePlaylistListVM.getUpToDateSelectablePlaylists();
                return Expanded(
                  child: ListView.builder(
                    key: const Key('expandable_playlist_list'),
                    itemCount: upToDateSelectablePlaylists.length,
                    itemBuilder: (context, index) {
                      Playlist playlist = upToDateSelectablePlaylists[index];
                      return Builder(
                        builder: (listTileContext) {
                          return PlaylistListItemWidget(
                            playlist: playlist,
                            index: index,
                          );
                        },
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
            child: Consumer<PlaylistListVM>(
              builder: (context, expandablePlaylistListVM, child) {
                _selectedPlaylistsPlayableAudios = expandablePlaylistListVM
                    .getSelectedPlaylistPlayableAudios();
                if (expandablePlaylistListVM.isAudioListFilteredAndSorted()) {
                  // Scroll the sublist to the top when the audio
                  // list is filtered and/or sorted
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  });
                }

                return ListView.builder(
                  key: const Key('audio_list'),
                  controller: _scrollController,
                  itemCount: (_selectedPlaylistsPlayableAudios.isEmpty)
                      ? 0
                      : expandablePlaylistListVM
                          .getSelectedPlaylistPlayableAudios()
                          .length,
                  itemBuilder: (BuildContext context, int index) {
                    final audio = _selectedPlaylistsPlayableAudios[index];
                    return AudioListItemWidget(
                      audio: audio,
                      onPageChangedFunction: widget.onPageChangedFunction,
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
