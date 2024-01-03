import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../models/playlist.dart';
import '../../constants.dart';
import '../../services/settings_data_service.dart';
import '../../viewmodels/theme_provider_vm.dart';
import '../../viewmodels/warning_message_vm.dart';

enum WarningMode {
  warning,
  confirm,
}

/// This widget is used to display warning messages to the user.
/// It is created each time a warning message is set to the
/// [WarningMessageVM] class.
///
/// The warning messages are displayed as a dialog whose content
/// depends on the type of the warning message set to the
/// WarningMessageVM.
class DisplayMessageWidget extends StatelessWidget {
  final BuildContext _context;
  final WarningMessageVM _warningMessageVM;
  final TextEditingController _playlistUrlController;

  const DisplayMessageWidget({
    required BuildContext parentContext,
    required WarningMessageVM warningMessageVM,
    required TextEditingController playlistUrlController,
    super.key,
  })  : _context = parentContext,
        _warningMessageVM = warningMessageVM,
        _playlistUrlController = playlistUrlController;

  @override
  Widget build(BuildContext context) {
    WarningMessageType warningMessageType =
        _warningMessageVM.warningMessageType;
    ThemeProviderVM themeProviderVM = Provider.of<ThemeProviderVM>(context);

    switch (warningMessageType) {
      case WarningMessageType.errorMessage:
        ErrorType errorType = _warningMessageVM.errorType;

        switch (errorType) {
          case ErrorType.downloadAudioYoutubeError:
            String exceptionMessage = _warningMessageVM.errorArgOne;

            if (exceptionMessage.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _displayWarningDialog(
                  context: _context,
                  message: AppLocalizations.of(context)!
                      .downloadAudioYoutubeError(exceptionMessage),
                  warningMessageVM: _warningMessageVM,
                  themeProviderVM: themeProviderVM,
                );
              });
            }

            return const SizedBox.shrink();
          case ErrorType.downloadAudioYoutubeErrorDueToLiveVideoInPlaylist:
            String playlistTitle = _warningMessageVM.errorArgOne;
            String liveVideoString = _warningMessageVM.errorArgTwo;

            if (liveVideoString.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _displayWarningDialog(
                  context: _context,
                  message: AppLocalizations.of(context)!
                      .downloadAudioYoutubeErrorDueToLiveVideoInPlaylist(
                          playlistTitle, liveVideoString),
                  warningMessageVM: _warningMessageVM,
                  themeProviderVM: themeProviderVM,
                );
              });
            }

            return const SizedBox.shrink();
          case ErrorType.noInternet:
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _displayWarningDialog(
                  context: _context,
                  message: AppLocalizations.of(context)!.noInternet,
                  warningMessageVM: _warningMessageVM,
                  themeProviderVM: themeProviderVM);
            });

            return const SizedBox.shrink();
          case ErrorType.downloadAudioFileAlreadyOnAudioDirectory:
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _displayWarningDialog(
                  context: _context,
                  message: AppLocalizations.of(context)!
                      .downloadAudioFileAlreadyOnAudioDirectory(
                    _warningMessageVM.errorArgOne,
                    _warningMessageVM.errorArgTwo,
                    _warningMessageVM.errorArgThree,
                  ),
                  warningMessageVM: _warningMessageVM,
                  themeProviderVM: themeProviderVM);
            });

            return const SizedBox.shrink();
          default:
            return const SizedBox.shrink();
        }
      case WarningMessageType.updatedPlaylistUrlTitle:
        String updatedPlayListTitle = _warningMessageVM.updatedPlaylistTitle;

        if (updatedPlayListTitle.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _displayWarningDialog(
                context: _context,
                message: AppLocalizations.of(context)!
                    .updatedPlaylistUrlTitle(updatedPlayListTitle),
                warningMessageVM: _warningMessageVM,
                themeProviderVM: themeProviderVM);
          });
        }

        return const SizedBox.shrink();
      case WarningMessageType.addPlaylistTitle:
        String addedPlayListTitle = _warningMessageVM.addedPlaylistTitle;
        PlaylistQuality playlistQuality =
            _warningMessageVM.addedPlaylistQuality;
        String playlistQualityStr;

        if (addedPlayListTitle.isNotEmpty) {
          if (playlistQuality == PlaylistQuality.voice) {
            playlistQualityStr =
                AppLocalizations.of(context)!.playlistQualityAudio;
          } else {
            playlistQualityStr =
                AppLocalizations.of(context)!.playlistQualityMusic;
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _displayWarningDialog(
                context: _context,
                message: AppLocalizations.of(context)!
                    .addPlaylistTitle(addedPlayListTitle, playlistQualityStr),
                warningMessageVM: _warningMessageVM,
                themeProviderVM: themeProviderVM);
          });
        }

        return const SizedBox.shrink();
      case WarningMessageType.invalidPlaylistUrl:
        String playlistUrl = _warningMessageVM.invalidPlaylistUrl;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayWarningDialog(
            context: _context,
            message:
                AppLocalizations.of(context)!.invalidPlaylistUrl(playlistUrl),
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.playlistWithUrlAlreadyInListOfPlaylists:
        String playlistUrl = _playlistUrlController.text;
        String playlistTitle = _warningMessageVM.playlistAlreadyDownloadedTitle;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayWarningDialog(
            context: _context,
            message: AppLocalizations.of(context)!
                .playlistWithUrlAlreadyInListOfPlaylists(
                    playlistUrl, playlistTitle),
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.localPlaylistWithTitleAlreadyInListOfPlaylists:
        String playlistTitle =
            _warningMessageVM.localPlaylistAlreadyCreatedTitle;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayWarningDialog(
            context: _context,
            message: AppLocalizations.of(context)!
                .localPlaylistWithTitleAlreadyInListOfPlaylists(playlistTitle),
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.deleteAudioFromPlaylistAswellWarning:
        String playlistTitle =
            _warningMessageVM.deleteAudioFromPlaylistAswellTitle;
        String audioVideoTitle =
            _warningMessageVM.deleteAudioFromPlaylistAswellAudioVideoTitle;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayWarningDialog(
            context: _context,
            message: AppLocalizations.of(context)!
                .deleteAudioFromPlaylistAswellWarning(
              audioVideoTitle,
              playlistTitle,
            ),
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.invalidSingleVideoUrl:
        String playlistUrl = _playlistUrlController.text;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayWarningDialog(
            context: _context,
            message: AppLocalizations.of(context)!
                .invalidSingleVideoUUrl(playlistUrl),
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.updatedPlayableAudioLst:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayWarningDialog(
            context: _context,
            message: AppLocalizations.of(context)!.updatedPlayableAudioLst(
              _warningMessageVM.removedPlayableAudioNumber,
              _warningMessageVM.updatedPlayableAudioLstPlaylistTitle,
            ),
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.noPlaylistSelectedForSingleVideoDownload:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayWarningDialog(
            context: _context,
            message: AppLocalizations.of(context)!
                .noPlaylistSelectedForSingleVideoDownload,
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.tooManyPlaylistSelectedForSingleVideoDownload:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayWarningDialog(
            context: _context,
            message: AppLocalizations.of(context)!
                .tooManyPlaylistSelectedForSingleVideoDownload,
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.audioNotMovedFromToPlaylist:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayWarningDialog(
            context: _context,
            message: AppLocalizations.of(context)!.audioNotMovedFromToPlaylist(
              _warningMessageVM.movedAudioValidVideoTitle,
              _warningMessageVM.movedFromPlaylistTitle,
              _warningMessageVM.movedToPlaylistTitle,
            ),
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.audioNotCopiedFromToPlaylist:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayWarningDialog(
            context: _context,
            message: AppLocalizations.of(context)!.audioNotCopiedFromToPlaylist(
              _warningMessageVM.copiedAudioValidVideoTitle,
              _warningMessageVM.copiedFromPlaylistTitle,
              _warningMessageVM.copiedToPlaylistTitle,
            ),
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.audioMovedFromToPlaylist:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          String audioMovedFromToPlaylistMessage;

          if (_warningMessageVM.movedFromPlaylistType == PlaylistType.local) {
            if (_warningMessageVM.movedToPlaylistType == PlaylistType.local) {
              audioMovedFromToPlaylistMessage = AppLocalizations.of(context)!
                  .audioMovedFromLocalPlaylistToLocalPlaylist(
                _warningMessageVM.movedAudioValidVideoTitle,
                _warningMessageVM.movedFromPlaylistTitle,
                _warningMessageVM.movedToPlaylistTitle,
              );
            } else {
              audioMovedFromToPlaylistMessage = AppLocalizations.of(context)!
                  .audioMovedFromLocalPlaylistToYoutubePlaylist(
                _warningMessageVM.movedAudioValidVideoTitle,
                _warningMessageVM.movedFromPlaylistTitle,
                _warningMessageVM.movedToPlaylistTitle,
              );
            }
          } else {
            if (!_warningMessageVM.keepAudioDataInSourcePlaylist) {
              if (_warningMessageVM.movedToPlaylistType == PlaylistType.local) {
                audioMovedFromToPlaylistMessage = AppLocalizations.of(context)!
                    .audioMovedFromYoutubePlaylistToLocalPlaylistPlaylistWarning(
                  _warningMessageVM.movedAudioValidVideoTitle,
                  _warningMessageVM.movedFromPlaylistTitle,
                  _warningMessageVM.movedToPlaylistTitle,
                );
              } else {
                audioMovedFromToPlaylistMessage = AppLocalizations.of(context)!
                    .audioMovedFromYoutubePlaylistToYoutubePlaylistPlaylistWarning(
                  _warningMessageVM.movedAudioValidVideoTitle,
                  _warningMessageVM.movedFromPlaylistTitle,
                  _warningMessageVM.movedToPlaylistTitle,
                );
              }
            } else {
              if (_warningMessageVM.movedToPlaylistType == PlaylistType.local) {
                audioMovedFromToPlaylistMessage = AppLocalizations.of(context)!
                    .audioMovedFromYoutubePlaylistToLocalPlaylist(
                  _warningMessageVM.movedAudioValidVideoTitle,
                  _warningMessageVM.movedFromPlaylistTitle,
                  _warningMessageVM.movedToPlaylistTitle,
                );
              } else {
                audioMovedFromToPlaylistMessage = AppLocalizations.of(context)!
                    .audioMovedFromYoutubePlaylistToYoutubePlaylist(
                  _warningMessageVM.movedAudioValidVideoTitle,
                  _warningMessageVM.movedFromPlaylistTitle,
                  _warningMessageVM.movedToPlaylistTitle,
                );
              }
            }
          }
          _displayWarningDialog(
            context: _context,
            message: audioMovedFromToPlaylistMessage,
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
            warningMode: WarningMode.confirm,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.audioCopiedFromToPlaylist:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          String audioCopiedFromToPlaylistMessage;

          if (_warningMessageVM.copiedFromPlaylistType == PlaylistType.local) {
            if (_warningMessageVM.copiedToPlaylistType == PlaylistType.local) {
              audioCopiedFromToPlaylistMessage = AppLocalizations.of(context)!
                  .audioCopiedFromLocalPlaylistToLocalPlaylist(
                _warningMessageVM.copiedAudioValidVideoTitle,
                _warningMessageVM.copiedFromPlaylistTitle,
                _warningMessageVM.copiedToPlaylistTitle,
              );
            } else {
              audioCopiedFromToPlaylistMessage = AppLocalizations.of(context)!
                  .audioCopiedFromLocalPlaylistToYoutubePlaylist(
                _warningMessageVM.copiedAudioValidVideoTitle,
                _warningMessageVM.copiedFromPlaylistTitle,
                _warningMessageVM.copiedToPlaylistTitle,
              );
            }
          } else {
            if (_warningMessageVM.copiedToPlaylistType == PlaylistType.local) {
              audioCopiedFromToPlaylistMessage = AppLocalizations.of(context)!
                  .audioCopiedFromYoutubePlaylistToLocalPlaylist(
                _warningMessageVM.copiedAudioValidVideoTitle,
                _warningMessageVM.copiedFromPlaylistTitle,
                _warningMessageVM.copiedToPlaylistTitle,
              );
            } else {
              audioCopiedFromToPlaylistMessage = AppLocalizations.of(context)!
                  .audioCopiedFromYoutubePlaylistToYoutubePlaylist(
                _warningMessageVM.copiedAudioValidVideoTitle,
                _warningMessageVM.copiedFromPlaylistTitle,
                _warningMessageVM.copiedToPlaylistTitle,
              );
            }
          }
          _displayWarningDialog(
            context: _context,
            message: audioCopiedFromToPlaylistMessage,
            warningMessageVM: _warningMessageVM,
            themeProviderVM: themeProviderVM,
            warningMode: WarningMode.confirm,
          );
        });

        return const SizedBox.shrink();
      default:
        return const SizedBox.shrink();
    }
  }

  void _displayWarningDialog({
    required BuildContext context,
    required String message,
    required WarningMessageVM warningMessageVM,
    required ThemeProviderVM themeProviderVM,
    WarningMode warningMode = WarningMode.warning,
  }) {
    final focusNode = FocusNode();
    String alertDialogTitle = '';

    switch (warningMode) {
      case WarningMode.warning:
        alertDialogTitle = AppLocalizations.of(context)!.warningDialogTitle;
        break;
      case WarningMode.confirm:
        alertDialogTitle = AppLocalizations.of(context)!.confirmDialogTitle;
        break;
      default:
        break;
    }

    showDialog(
      context: context,
      builder: (context) => RawKeyboardListener(
        // Using FocusNode to enable clicking on Enter to close
        // the dialog
        focusNode: focusNode,
        onKey: (event) {
          if (event.isKeyPressed(LogicalKeyboardKey.enter) ||
              event.isKeyPressed(LogicalKeyboardKey.numpadEnter)) {
            // executing the same code as in the 'Ok'
            // TextButton onPressed callback
            warningMessageVM.warningMessageType = WarningMessageType.none;
            Navigator.of(context).pop();
          }
        },
        child: AlertDialog(
          title: Text(
            key: const Key('warningDialogTitle'),
            alertDialogTitle,
          ),
          actionsPadding:
              // reduces the top vertical space between the buttons
              // and the content
              const EdgeInsets.fromLTRB(
                  10, 0, 10, 10), // Adjust the value as needed
          content: Text(
            key: const Key('warningDialogMessage'),
            message,
            style: kDialogTextFieldStyle,
          ),
          actions: [
            TextButton(
              child: Text(
                key: const Key('warningDialogOkButton'),
                'Ok',
                style: (themeProviderVM.currentTheme == AppTheme.dark)
                    ? kTextButtonStyleDarkMode
                    : kTextButtonStyleLightMode,
              ),
              onPressed: () {
                warningMessageVM.warningMessageType = WarningMessageType.none;
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );

    // To automatically focus on the dialog when it appears. If commented,
    // clicking on Enter will not close the dialog.
    focusNode.requestFocus();
  }
}
