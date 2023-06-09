
import 'package:audio_learn/models/audio.dart';
import 'package:audio_learn/models/playlist.dart';
import 'package:audio_learn/viewmodels/audio_download_vm.dart';
import 'package:audio_learn/viewmodels/warning_message_vm.dart';

class MockAudioDownloadVM extends AudioDownloadVM {
  final List<Playlist> _playlistLst = [];

  String _youtubePlaylistTitle = '';
  set youtubePlaylistTitle(String youtubePlaylistTitle) {
    _youtubePlaylistTitle = youtubePlaylistTitle;
  }

  MockAudioDownloadVM({
    required WarningMessageVM warningMessageVM,
    bool isTest = false,
  }) : super(
          warningMessageVM: warningMessageVM,
          isTest: isTest,
        );

  @override
  Future<void> downloadPlaylistAudios({
    required String playlistUrl,
  }) async {
    List<Audio> audioLst = [
      Audio(
          enclosingPlaylist: _playlistLst[0],
          originalVideoTitle: 'Audio 1',
          videoUrl: 'https://example.com/video2',
          audioDownloadDateTime: DateTime(2023, 3, 25),
          videoUploadDate: DateTime.now(),
          audioDuration: const Duration(minutes: 3, seconds: 42),
          compactVideoDescription: 'Video Description 1'),
      Audio(
          enclosingPlaylist: _playlistLst[0],
          originalVideoTitle: 'Audio 2',
          videoUrl: 'https://example.com/video2',
          audioDownloadDateTime: DateTime(2023, 3, 25),
          videoUploadDate: DateTime.now(),
          audioDuration: const Duration(minutes: 5, seconds: 21),
          compactVideoDescription: 'Video Description 2'),
      Audio(
          enclosingPlaylist: _playlistLst[0],
          originalVideoTitle: 'Audio 3',
          videoUrl: 'https://example.com/video2',
          audioDownloadDateTime: DateTime(2023, 3, 25),
          videoUploadDate: DateTime.now(),
          audioDuration: const Duration(minutes: 2, seconds: 15),
          compactVideoDescription: 'Video Description 3'),
    ];

    int i = 1;
    int speed = 100000;
    int size = 900000;

    for (Audio audio in audioLst) {
      audio.audioDownloadSpeed = speed * i;
      audio.audioFileSize = size * i;
      i++;
    }

    _playlistLst[0].downloadedAudioLst = audioLst;
    _playlistLst[0].playableAudioLst = audioLst;

    notifyListeners();
  }

  @override
  Future<Playlist?> addPlaylist({
    String playlistUrl = '',
    String localPlaylistTitle = '',
    required PlaylistQuality playlistQuality,
  }) async {
    // calling the AudioDownloadVM's addPlaylistCallableByMock method
    // enables the MockAudioDownloadVM to use the logic of the AudioDownloadVM
    // addPlaylist method !
    Playlist? addedPlaylist = await addPlaylistCallableByMock(
      playlistUrl: playlistUrl,
      localPlaylistTitle: localPlaylistTitle,
      playlistQuality: playlistQuality,
      mockYoutubePlaylistTitle: _youtubePlaylistTitle,
    );

    return addedPlaylist;
  }
}
