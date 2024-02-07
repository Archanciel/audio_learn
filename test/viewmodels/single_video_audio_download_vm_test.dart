import 'package:audio_learn/models/playlist.dart';
import 'package:audio_learn/viewmodels/single_video_audio_download_vm.dart';
import 'package:flutter_test/flutter_test.dart';

import 'custom_mock_youtube_explode.dart';

void main() {
  group('SingleVideoAudioDownloadVM Tests', () {
    late SingleVideoAudioDownloadVM singleVideoAudioDownloadVM;
    late CustomMockYoutubeExplode mockYoutubeExplode;

    setUp(() {
      mockYoutubeExplode = CustomMockYoutubeExplode();
      singleVideoAudioDownloadVM =
          SingleVideoAudioDownloadVM(youtubeExplode: mockYoutubeExplode);
    });

    test('Test download failure when the Youtube service returns an error',
        () async {
      Playlist singleVideoTargetPlaylist = Playlist(
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      expect(
        await singleVideoAudioDownloadVM.downloadSingleVideoAudio(
          videoUrl: 'invalid_url',
          singleVideoTargetPlaylist: singleVideoTargetPlaylist,
        ),
        false,
      );
    });

    // Autres tests...
  });
}
