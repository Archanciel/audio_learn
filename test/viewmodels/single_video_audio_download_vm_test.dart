import 'package:audio_learn/models/playlist.dart';
import 'package:audio_learn/viewmodels/single_video_audio_download_vm.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

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

    test('Échec du téléchargement lorsque le service renvoie une erreur',
        () async {
      Playlist singleVideoTargetPlaylist = Playlist(
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      // Simulate an error response
      // when(mockYoutubeExplode.videos.get(any))
      //     .thenAnswer((_) => Future.error(Exception("Error fetching video")));

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
