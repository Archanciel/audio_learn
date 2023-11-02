import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../constants.dart';
import '../my_home_page.dart';

/// When the PlaylistView screen is displayed, the AppBarTitlePlaylistView
/// is displayed in the AppBar title:
class AppBarTitleForPlaylistDownloadView extends StatelessWidget {
  const AppBarTitleForPlaylistDownloadView({
    super.key,
    required this.playlistViewHomePage,
  });

  final MyHomePage playlistViewHomePage;

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
            AppLocalizations.of(context)!.title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 17),
          ),
        ),
        InkWell(
          key: const Key('image_open_youtube'),
          onTap: () async {
            await playlistViewHomePage.openUrlInExternalApp(
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
