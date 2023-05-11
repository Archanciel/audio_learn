import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../viewmodels/warning_message_vm.dart';
import '../screen_mixin.dart';

class DisplayMessageWidget extends StatelessWidget with ScreenMixin {
  final BuildContext _context;
  final WarningMessageVM _warningMessageVM;
  final TextEditingController _playlistUrlController;

  DisplayMessageWidget({
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
                displayWarningDialog(
                    context: _context,
                    message: AppLocalizations.of(context)!
                        .downloadAudioYoutubeError(exceptionMessage),
                    warningMessageVM: _warningMessageVM);
              });
            }

            return const SizedBox.shrink();
          case ErrorType.noInternet:
            WidgetsBinding.instance.addPostFrameCallback((_) {
              displayWarningDialog(
                  context: _context,
                  message: AppLocalizations.of(context)!.noInternet,
                  warningMessageVM: _warningMessageVM);
            });

            return const SizedBox.shrink();
          case ErrorType.downloadAudioFileAlreadyOnAudioDirectory:
            String audioShortPathFileName = _warningMessageVM.errorMessage;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              displayWarningDialog(
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
            displayWarningDialog(
                context: _context,
                message: AppLocalizations.of(context)!
                    .updatedPlaylistUrlTitle(updatedPlayListTitle),
                warningMessageVM: _warningMessageVM);
          });
        }

        return const SizedBox.shrink();
      case WarningMessageType.addPlaylistTitle:
        String addedPlayListTitle = _warningMessageVM.addedPlaylistTitle;

        if (addedPlayListTitle.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            displayWarningDialog(
                context: _context,
                message: AppLocalizations.of(context)!
                    .addPlaylistTitle(addedPlayListTitle),
                warningMessageVM: _warningMessageVM);
          });
        }

        return const SizedBox.shrink();
      case WarningMessageType.invalidPlaylistUrl:
        String playlistUrl = _playlistUrlController.text;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          displayWarningDialog(
            context: _context,
            message:
                AppLocalizations.of(context)!.invalidPlaylistUrl(playlistUrl),
            warningMessageVM: _warningMessageVM,
          );
        });

        return const SizedBox.shrink();
      case WarningMessageType.playlistWithUrlAlreadyInListOfPlaylists:
        String playlistUrl = _playlistUrlController.text;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          displayWarningDialog(
            context: _context,
            message: AppLocalizations.of(context)!
                .playlistWithUrlAlreadyInListOfPlaylists(playlistUrl),
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
          displayWarningDialog(
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
          displayWarningDialog(
            context: _context,
            message: AppLocalizations.of(context)!
                .invalidSingleVideoUUrl(playlistUrl),
            warningMessageVM: _warningMessageVM,
          );
        });

        return const SizedBox.shrink();
      default:
        return const SizedBox.shrink();
    }
  }
}
