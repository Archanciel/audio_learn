import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../constants.dart';
import '../my_home_page.dart';

/// When the AudioPlayerView screen is displayed, the AppBarTitleForAudioPlayerView
/// is displayed in the AppBar title:
class AppBarTitleForAudioPlayerView extends StatelessWidget {
  const AppBarTitleForAudioPlayerView({
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
            AppLocalizations.of(context)!.appBarTitleAudioPlayer,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 17),
          ),
        ),
      ],
    );
  }
}
