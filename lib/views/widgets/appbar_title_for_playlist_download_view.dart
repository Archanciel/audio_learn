import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../constants.dart';
import '../../views/screen_mixin.dart';

/// When the PlaylistView screen is displayed, the AppBarTitleForPlaylistView
/// is displayed in the AppBar title:
class AppBarTitleForPlaylistDownloadView extends StatelessWidget
    with ScreenMixin {
  const AppBarTitleForPlaylistDownloadView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // changing the build code to imitate working
    // chatgpt_main_draggable.dart does not eliminate
    // the error !
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Flexible(
          child: Text(
            AppLocalizations.of(context)!.appBarTitleDownloadAudio,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 17),
          ),
        ),
        InkWell(
          key: const Key('image_open_youtube'),
          onTap: () async {
            await openUrlInExternalApp(
              url: kYoutubeUrl,
            );
          },
          child: Image.asset('assets/images/youtube-logo-png-2069.png',
              height: 38),
        ),
      ],
    );
  }
}