import 'package:audio_learn/models/playlist.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../constants.dart';
import '../../viewmodels/warning_message_vm.dart';

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

    switch (warningMessageType) {
      case WarningMessageType.errorMessage:
        ErrorType errorType = _warningMessageVM.errorType;

        switch (errorType) {
          case ErrorType.downloadAudioYoutubeError:
            String exceptionMessage = _warningMessageVM.errorMessage;

            if (exceptionMessage.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _displayWarningDialog(
                    context: _context,
                    message: AppLocalizations.of(context)!
                        .downloadAudioYoutubeError(exceptionMessage),
                    warningMessageVM: _warningMessageVM);
              });
            }

            return const SizedBox.shrink();
          case ErrorType.noInternet:
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _displayWarningDialog(
                  context: _context,
                  message: AppLocalizations.of(context)!.noInternet,
                  warningMessageVM: _warningMessageVM);
            });

            return const SizedBox.shrink();
          case ErrorType.downloadAudioFileAlreadyOnAudioDirectory:
            String audioShortPathFileName = _warningMessageVM.errorMessage;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              _displayWarningDialog(
                  context: _context,
                  message: AppLocalizations.of(context)!
                      .downloadAudioFileAlreadyOnAudioDirectory(
                          audioShortPathFileName),
                  warningMessageVM: _warningMessageVM);
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
                warningMessageVM: _warningMessageVM);
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
                warningMessageVM: _warningMessageVM);
          });
        }

        return const SizedBox.shrink();
      case WarningMessageType.invalidPlaylistUrl:
        String playlistUrl = _playlistUrlController.text;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayWarningDialog(
            context: _context,
            message:
                AppLocalizations.of(context)!.invalidPlaylistUrl(playlistUrl),
            warningMessageVM: _warningMessageVM,
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
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.localPlaylistWithTitleAlreadyInListOfPlaylists:
        String playlistTitle = _warningMessageVM.localPlaylistAlreadyCreatedTitle;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayWarningDialog(
            context: _context,
            message: AppLocalizations.of(context)!
                .localPlaylistWithTitleAlreadyInListOfPlaylists(
                    playlistTitle),
            warningMessageVM: _warningMessageVM,
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
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.invalidSingleVideoUUrl:
        String playlistUrl = _playlistUrlController.text;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayWarningDialog(
            context: _context,
            message: AppLocalizations.of(context)!
                .invalidSingleVideoUUrl(playlistUrl),
            warningMessageVM: _warningMessageVM,
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
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.noPlaylistSelectedForSingleVideoDownload:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayWarningDialog(
            context: _context,
            message: AppLocalizations.of(context)!.noPlaylistSelectedForSingleVideoDownload,
            warningMessageVM: _warningMessageVM,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.tooManyPlaylistSelectedForSingleVideoDownload:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayWarningDialog(
            context: _context,
            message: AppLocalizations.of(context)!.tooManyPlaylistSelectedForSingleVideoDownload,
            warningMessageVM: _warningMessageVM,
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
  }) {
    final focusNode = FocusNode();

    showDialog(
      context: context,
      builder: (context) => RawKeyboardListener(
        // Using FocusNode to enable clicking on Enter to close
        // the dialog
        focusNode: focusNode,
        onKey: (event) {
          if (event.isKeyPressed(LogicalKeyboardKey.enter) ||
              event.isKeyPressed(LogicalKeyboardKey.numpadEnter)) {
            warningMessageVM.warningMessageType = WarningMessageType.none;
            Navigator.of(context).pop();
          }
        },
        child: AlertDialog(
          title: Text(AppLocalizations.of(context)!.warning),
          content: Text(
            message,
            style: kDialogTextFieldStyle,
          ),
          actions: [
            TextButton(
              child: const Text('Ok'),
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

  void _displayConfirmDialog({
    required BuildContext context,
    required String message,
    required WarningMessageVM warningMessageVM,
  }) {
    final focusNode = FocusNode();

    showDialog(
      context: context,
      builder: (context) => RawKeyboardListener(
        // Using FocusNode to enable clicking on Enter to close
        // the dialog
        focusNode: focusNode,
        onKey: (event) {
          if (event.isKeyPressed(LogicalKeyboardKey.enter) ||
              event.isKeyPressed(LogicalKeyboardKey.numpadEnter)) {
            warningMessageVM.warningMessageType = WarningMessageType.none;
            Navigator.of(context).pop();
          }
        },
        child: AlertDialog(
          title: Text(AppLocalizations.of(context)!.warning),
          content: Text(
            message,
            style: kDialogTextFieldStyle,
          ),
          actions: [
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                warningMessageVM.warningMessageType = WarningMessageType.ok;
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
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
