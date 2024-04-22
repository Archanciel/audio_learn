import 'package:flutter_test/flutter_test.dart';

import 'package:audio_learn/models/playlist.dart';
import 'package:audio_learn/services/settings_data_service.dart';
import 'package:audio_learn/models/audio.dart';

void main() {
  group('Testing Playlist add and remove methods', () {
    test('add 3 audios to playlist', () {
      Playlist playlist = Playlist(
        url: 'https://example.com/playlist2',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      addThreeDownloadedAudios(playlist);

      expect(playlist.downloadedAudioLst.length, 3);
      expect(playlist.downloadedAudioLst[0].originalVideoTitle, 'C');
      expect(playlist.downloadedAudioLst[1].originalVideoTitle, 'A');
      expect(playlist.downloadedAudioLst[2].originalVideoTitle, 'B');

      expect(playlist.playableAudioLst.length, 3);
      expect(playlist.playableAudioLst[0].originalVideoTitle, 'B');
      expect(playlist.playableAudioLst[1].originalVideoTitle, 'A');
      expect(playlist.playableAudioLst[2].originalVideoTitle, 'C');
    });

    test('remove 1 audio from downloaded and playable audio list', () {
      Playlist playlist = Playlist(
        url: 'https://example.com/playlist2',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      addThreeDownloadedAudios(playlist);

      expect(playlist.playableAudioLst.length, 3);

      playlist.removeDownloadedAudioFromDownloadAndPlayableAudioLst(
        downloadedAudio: playlist.playableAudioLst[1],
      );

      expect(playlist.downloadedAudioLst.length, 2);
      expect(playlist.downloadedAudioLst[0].originalVideoTitle, 'C');
      expect(playlist.downloadedAudioLst[1].originalVideoTitle, 'B');

      expect(playlist.playableAudioLst.length, 2);
      expect(playlist.playableAudioLst[0].originalVideoTitle, 'B');
      expect(playlist.playableAudioLst[1].originalVideoTitle, 'C');
    });

    test('remove 1 audio from playable audio list only', () {
      Playlist playlist = Playlist(
        url: 'https://example.com/playlist2',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      addThreeDownloadedAudios(playlist);

      expect(playlist.playableAudioLst.length, 3);

      playlist.removeDownloadedAudioFromPlayableAudioLstOnly(
        downloadedAudio: playlist.playableAudioLst[1],
      );

      expect(playlist.downloadedAudioLst.length, 3);
      expect(playlist.downloadedAudioLst[0].originalVideoTitle, 'C');
      expect(playlist.downloadedAudioLst[1].originalVideoTitle, 'A');
      expect(playlist.downloadedAudioLst[2].originalVideoTitle, 'B');

      expect(playlist.playableAudioLst.length, 2);
      expect(playlist.playableAudioLst[0].originalVideoTitle, 'B');
      expect(playlist.playableAudioLst[1].originalVideoTitle, 'C');
    });

    test('remove 1 audio mp3 from playalable audio list', () {
      Playlist playlist = Playlist(
        url: 'https://example.com/playlist2',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      addThreeDownloadedAudios(playlist);

      expect(playlist.playableAudioLst.length, 3);
      expect(playlist.downloadedAudioLst[0].originalVideoTitle, 'C');
      expect(playlist.downloadedAudioLst[1].originalVideoTitle, 'A');
      expect(playlist.downloadedAudioLst[2].originalVideoTitle, 'B');

      playlist.removePlayableAudio(
        playableAudio: playlist.playableAudioLst[1],
      );

      expect(playlist.downloadedAudioLst.length, 3);
      expect(playlist.playableAudioLst.length, 2);
      expect(playlist.playableAudioLst[0].originalVideoTitle, 'B');
      expect(playlist.playableAudioLst[1].originalVideoTitle, 'C');
    });
    test('add 1 audio to empty playlist', () {
      Playlist playlist = Playlist(
        url: 'https://example.com/playlist2',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      playlist.currentOrPastPlayableAudioIndex = -1;

      addOneDownloadedAudio(playlist);

      expect(playlist.downloadedAudioLst.length, 1);
      expect(playlist.downloadedAudioLst[0].originalVideoTitle, 'A');

      expect(playlist.playableAudioLst.length, 1);
      expect(playlist.playableAudioLst[0].originalVideoTitle, 'A');

      expect(playlist.currentOrPastPlayableAudioIndex, 0);
    });
    test(
        'add 1 audio to empty playlist and then remove it from downloaded and playable list',
        () {
      Playlist playlist = Playlist(
        url: 'https://example.com/playlist2',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      playlist.currentOrPastPlayableAudioIndex = -1;

      addOneDownloadedAudio(playlist);

      expect(playlist.currentOrPastPlayableAudioIndex, 0);

      playlist.removeDownloadedAudioFromDownloadAndPlayableAudioLst(
        downloadedAudio: playlist.playableAudioLst[0],
      );

      expect(playlist.downloadedAudioLst.length, 0);
      expect(playlist.playableAudioLst.length, 0);
      expect(playlist.currentOrPastPlayableAudioIndex, -1);
    });
    test(
        'add 1 audio to empty playlist and then remove it from playable list only',
        () {
      Playlist playlist = Playlist(
        url: 'https://example.com/playlist2',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      playlist.currentOrPastPlayableAudioIndex = -1;

      addOneDownloadedAudio(playlist);

      expect(playlist.currentOrPastPlayableAudioIndex, 0);

      playlist.removeDownloadedAudioFromPlayableAudioLstOnly(
        downloadedAudio: playlist.playableAudioLst[0],
      );

      expect(playlist.downloadedAudioLst.length, 1);
      expect(playlist.playableAudioLst.length, 0);
      expect(playlist.currentOrPastPlayableAudioIndex, -1);
    });
    test('add 1 audio to empty playlist and then delete the mp3', () {
      Playlist playlist = Playlist(
        url: 'https://example.com/playlist2',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      playlist.currentOrPastPlayableAudioIndex = -1;

      addOneDownloadedAudio(playlist);

      expect(playlist.currentOrPastPlayableAudioIndex, 0);

      playlist.removePlayableAudio(
        playableAudio: playlist.playableAudioLst[0],
      );

      expect(playlist.downloadedAudioLst.length, 1);
      expect(playlist.playableAudioLst.length, 0);
      expect(playlist.currentOrPastPlayableAudioIndex, -1);
    });
    test(
        'add 2 audios to empty playlist and then remove 1 audio from downloaded and playable list',
        () {
      Playlist playlist = Playlist(
        url: 'https://example.com/playlist2',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      playlist.currentOrPastPlayableAudioIndex = -1;

      addOneDownloadedAudio(playlist);

      expect(playlist.currentOrPastPlayableAudioIndex, 0);
      expect(
          playlist.playableAudioLst[playlist.currentOrPastPlayableAudioIndex]
              .originalVideoTitle,
          'A');

      addOneOtherDownloadedAudio(playlist);

      // verifying that the currentOrPastPlayableAudioIndex
      // is not changed by the addDownloadedAudio method
      expect(playlist.currentOrPastPlayableAudioIndex, 1);
      expect(
          playlist.playableAudioLst[playlist.currentOrPastPlayableAudioIndex]
              .originalVideoTitle,
          'A');

      playlist.removeDownloadedAudioFromDownloadAndPlayableAudioLst(
        downloadedAudio: playlist.playableAudioLst[0],
      );

      expect(playlist.downloadedAudioLst.length, 1);
      expect(playlist.playableAudioLst.length, 1);
      expect(playlist.currentOrPastPlayableAudioIndex, 0);
      expect(
          playlist.playableAudioLst[playlist.currentOrPastPlayableAudioIndex]
              .originalVideoTitle,
          'A');
    });
    test(
        'add 3 audios to playlist, set second as current, then delete the first downloaded',
        () {
      Playlist playlist = Playlist(
        url: 'https://example.com/playlist2',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      addThreeDownloadedAudios(playlist);

      playlist.currentOrPastPlayableAudioIndex = 1;
      expect(
          playlist.playableAudioLst[playlist.currentOrPastPlayableAudioIndex]
              .originalVideoTitle,
          'A');

      // deleting the first downloaded audio. Since the
      // currentOrPastPlayableAudioIndex is 1, i.e. the
      // second downloaded audio, the currentOrPastPlayableAudioIndex
      // is not changed
      playlist.removePlayableAudio(
        playableAudio: playlist.playableAudioLst[2],
      );

      expect(playlist.currentOrPastPlayableAudioIndex, 1);
      expect(
          playlist.playableAudioLst[playlist.currentOrPastPlayableAudioIndex]
              .originalVideoTitle,
          'A');
    });
    test(
        'add 3 audios to playlist, set second as current, then delete the audios',
        () {
      Playlist playlist = Playlist(
        url: 'https://example.com/playlist2',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      addThreeDownloadedAudios(playlist);

      playlist.currentOrPastPlayableAudioIndex = 1;
      expect(
          playlist.playableAudioLst[playlist.currentOrPastPlayableAudioIndex]
              .originalVideoTitle,
          'A');

      // deleting the last downloaded audio. Since the
      // currentOrPastPlayableAudioIndex is 1, i.e. the
      // second downloaded audio, the currentOrPastPlayableAudioIndex
      // is decremented by 1
      playlist.removePlayableAudio(
        playableAudio: playlist.playableAudioLst[0],
      );

      expect(playlist.currentOrPastPlayableAudioIndex, 0);
      expect(
          playlist.playableAudioLst[playlist.currentOrPastPlayableAudioIndex]
              .originalVideoTitle,
          'A');

      // now deleting the remaining (and current) downloaded audio

      playlist.removePlayableAudio(
        playableAudio: playlist.playableAudioLst[0],
      );

      expect(playlist.currentOrPastPlayableAudioIndex, -1);
    });
    test(
        'add 3 audios to playlist, set second as current, then remove from playable audio list the first downloaded',
        () {
      Playlist playlist = Playlist(
        url: 'https://example.com/playlist2',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      addThreeDownloadedAudios(playlist);

      playlist.currentOrPastPlayableAudioIndex = 1;
      expect(
          playlist.playableAudioLst[playlist.currentOrPastPlayableAudioIndex]
              .originalVideoTitle,
          'A');

      // removing the first downloaded audio from the playable
      // playlist only. Since the
      // currentOrPastPlayableAudioIndex is 1, i.e. the
      // second downloaded audio, the currentOrPastPlayableAudioIndex
      // is not changed
      playlist.removeDownloadedAudioFromPlayableAudioLstOnly(
        downloadedAudio: playlist.playableAudioLst[2],
      );

      expect(playlist.currentOrPastPlayableAudioIndex, 1);
      expect(
          playlist.playableAudioLst[playlist.currentOrPastPlayableAudioIndex]
              .originalVideoTitle,
          'A');
    });
    test(
        'add 3 audios to playlist, set second as current, then remove them from playable audio list',
        () {
      Playlist playlist = Playlist(
        url: 'https://example.com/playlist2',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      addThreeDownloadedAudios(playlist);

      playlist.currentOrPastPlayableAudioIndex = 1;
      expect(
          playlist.playableAudioLst[playlist.currentOrPastPlayableAudioIndex]
              .originalVideoTitle,
          'A');

      // removing the last downloaded audio. Since the
      // currentOrPastPlayableAudioIndex is 1, i.e. the
      // second downloaded audio, the currentOrPastPlayableAudioIndex
      // is decremented by 1
      playlist.removeDownloadedAudioFromPlayableAudioLstOnly(
        downloadedAudio: playlist.playableAudioLst[0],
      );

      expect(playlist.currentOrPastPlayableAudioIndex, 0);
      expect(
          playlist.playableAudioLst[playlist.currentOrPastPlayableAudioIndex]
              .originalVideoTitle,
          'A');

      // now deleting the remaining (and current) downloaded audio

      playlist.removeDownloadedAudioFromPlayableAudioLstOnly(
        downloadedAudio: playlist.playableAudioLst[0],
      );

      expect(playlist.currentOrPastPlayableAudioIndex, -1);
    });
    test(
        'copy 2 audios to empty playlist and then remove 1 audio from downloaded and playable list',
        () {
      Playlist playlist = Playlist(
        url: 'https://example.com/playlist2',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      playlist.currentOrPastPlayableAudioIndex = -1;

      copyOneDownloadedAudio(playlist);

      expect(playlist.currentOrPastPlayableAudioIndex, 0);
      expect(
          playlist.playableAudioLst[playlist.currentOrPastPlayableAudioIndex]
              .originalVideoTitle,
          'A');

      copyOneOtherDownloadedAudio(playlist);

      // verifying that the currentOrPastPlayableAudioIndex
      // is not changed by the addDownloadedAudio method
      expect(playlist.currentOrPastPlayableAudioIndex, 1);
      expect(
          playlist.playableAudioLst[playlist.currentOrPastPlayableAudioIndex]
              .originalVideoTitle,
          'A');

      playlist.removeDownloadedAudioFromDownloadAndPlayableAudioLst(
        downloadedAudio: playlist.playableAudioLst[0],
      );

      expect(playlist.downloadedAudioLst.length, 0);
      expect(playlist.playableAudioLst.length, 1);
      expect(playlist.currentOrPastPlayableAudioIndex, 0);
      expect(
          playlist.playableAudioLst[playlist.currentOrPastPlayableAudioIndex]
              .originalVideoTitle,
          'A');
    });
    test(
        'move 2 audios to empty playlist and then remove 1 audio from downloaded and playable list',
        () {
      Playlist playlist = Playlist(
        url: 'https://example.com/playlist2',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      playlist.currentOrPastPlayableAudioIndex = -1;

      moveOneDownloadedAudio(playlist);

      expect(playlist.currentOrPastPlayableAudioIndex, 0);
      expect(
          playlist.playableAudioLst[playlist.currentOrPastPlayableAudioIndex]
              .originalVideoTitle,
          'A');

      moveOneOtherDownloadedAudio(playlist);

      // verifying that the currentOrPastPlayableAudioIndex
      // is not changed by the addDownloadedAudio method
      expect(playlist.currentOrPastPlayableAudioIndex, 1);
      expect(
          playlist.playableAudioLst[playlist.currentOrPastPlayableAudioIndex]
              .originalVideoTitle,
          'A');

      playlist.removeDownloadedAudioFromDownloadAndPlayableAudioLst(
        downloadedAudio: playlist.playableAudioLst[0],
      );

      expect(playlist.downloadedAudioLst.length, 1);
      expect(playlist.playableAudioLst.length, 1);
      expect(playlist.currentOrPastPlayableAudioIndex, 0);
      expect(
          playlist.playableAudioLst[playlist.currentOrPastPlayableAudioIndex]
              .originalVideoTitle,
          'A');
    });
  });
  group('Testing Playlist sorting methods', () {
    test('sortDownloadedAudioLst on validVideoTitle ascending', () {
      Playlist playlist = Playlist(
        url: 'https://example.com/playlist1',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      addThreeDownloadedAudios(playlist);

      playlist.sortDownloadedAudioLst(
        audioSortCriteriomn: AudioSortCriterion.validVideoTitle,
        isSortAscending: true,
      );

      expect(playlist.downloadedAudioLst[0].originalVideoTitle, 'A');
      expect(playlist.downloadedAudioLst[1].originalVideoTitle, 'B');
      expect(playlist.downloadedAudioLst[2].originalVideoTitle, 'C');
    });

    test('sortDownloadedAudioLst on validVideoTitle descending', () {
      Playlist playlist = Playlist(
        url: 'https://example.com/playlist1',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      addThreeDownloadedAudios(playlist);

      playlist.sortDownloadedAudioLst(
        audioSortCriteriomn: AudioSortCriterion.validVideoTitle,
        isSortAscending: false,
      );

      expect(playlist.downloadedAudioLst[0].originalVideoTitle, 'C');
      expect(playlist.downloadedAudioLst[1].originalVideoTitle, 'B');
      expect(playlist.downloadedAudioLst[2].originalVideoTitle, 'A');
    });

    test('sortDownloadedAudioLst on audioDownloadDateTime ascending', () {
      Playlist playlist = Playlist(
        url: 'https://example.com/playlist1',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      addThreeDownloadedAudios(playlist);

      playlist.sortDownloadedAudioLst(
        audioSortCriteriomn: AudioSortCriterion.audioDownloadDateTime,
        isSortAscending: true,
      );

      expect(playlist.downloadedAudioLst[0].originalVideoTitle, 'B');
      expect(playlist.downloadedAudioLst[1].originalVideoTitle, 'C');
      expect(playlist.downloadedAudioLst[2].originalVideoTitle, 'A');
    });

    test('sortDownloadedAudioLst on audioDownloadDateTime descending', () {
      Playlist playlist = Playlist(
        url: 'https://example.com/playlist1',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      addThreeDownloadedAudios(playlist);

      playlist.sortDownloadedAudioLst(
        audioSortCriteriomn: AudioSortCriterion.audioDownloadDateTime,
        isSortAscending: false,
      );

      expect(playlist.downloadedAudioLst[0].originalVideoTitle, 'A');
      expect(playlist.downloadedAudioLst[1].originalVideoTitle, 'C');
      expect(playlist.downloadedAudioLst[2].originalVideoTitle, 'B');
    });

    test('sortPlayableAudioLst on validVideoTitle ascending', () {
      Playlist playlist = Playlist(
        url: 'https://example.com/playlist2',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      addThreeDownloadedAudios(playlist);

      playlist.sortPlayableAudioLst(
        audioSortCriteriomn: AudioSortCriterion.validVideoTitle,
        isSortAscending: true,
      );

      expect(playlist.playableAudioLst[0].originalVideoTitle, 'A');
      expect(playlist.playableAudioLst[1].originalVideoTitle, 'B');
      expect(playlist.playableAudioLst[2].originalVideoTitle, 'C');
    });

    test('sortPlayableAudioLst on validVideoTitle descending', () {
      Playlist playlist = Playlist(
        url: 'https://example.com/playlist2',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      addThreeDownloadedAudios(playlist);

      playlist.sortPlayableAudioLst(
        audioSortCriteriomn: AudioSortCriterion.validVideoTitle,
        isSortAscending: false,
      );

      expect(playlist.playableAudioLst[0].originalVideoTitle, 'C');
      expect(playlist.playableAudioLst[1].originalVideoTitle, 'B');
      expect(playlist.playableAudioLst[2].originalVideoTitle, 'A');
    });

    test('sortPlayableAudioLst on audioDownloadDateTime ascending', () {
      Playlist playlist = Playlist(
        url: 'https://example.com/playlist2',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      addThreeDownloadedAudios(playlist);

      playlist.sortPlayableAudioLst(
        audioSortCriteriomn: AudioSortCriterion.audioDownloadDateTime,
        isSortAscending: true,
      );

      expect(playlist.playableAudioLst[0].originalVideoTitle, 'B');
      expect(playlist.playableAudioLst[1].originalVideoTitle, 'C');
      expect(playlist.playableAudioLst[2].originalVideoTitle, 'A');
    });

    test('sortPlayableAudioLst on audioDownloadDateTime descending', () {
      Playlist playlist = Playlist(
        url: 'https://example.com/playlist2',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      addThreeDownloadedAudios(playlist);

      playlist.sortPlayableAudioLst(
        audioSortCriteriomn: AudioSortCriterion.audioDownloadDateTime,
        isSortAscending: false,
      );

      expect(playlist.playableAudioLst[0].originalVideoTitle, 'A');
      expect(playlist.playableAudioLst[1].originalVideoTitle, 'C');
      expect(playlist.playableAudioLst[2].originalVideoTitle, 'B');
    });
  });
}

void addThreeDownloadedAudios(Playlist playlist) {
  playlist.addDownloadedAudio(Audio(
      enclosingPlaylist: playlist,
      originalVideoTitle: 'C',
      compactVideoDescription: '',
      videoUrl: 'https://example.com/video1',
      audioDownloadDateTime: DateTime(2023, 3, 20),
      videoUploadDate: DateTime.now(),
      audioPlaySpeed: 1.5));
  playlist.addDownloadedAudio(Audio(
      enclosingPlaylist: playlist,
      originalVideoTitle: 'A',
      compactVideoDescription: '',
      videoUrl: 'https://example.com/video2',
      audioDownloadDateTime: DateTime(2023, 3, 25),
      videoUploadDate: DateTime.now(),
      audioPlaySpeed: 1.5));
  playlist.addDownloadedAudio(Audio(
      enclosingPlaylist: playlist,
      compactVideoDescription: '',
      originalVideoTitle: 'B',
      videoUrl: 'https://example.com/video3',
      audioDownloadDateTime: DateTime(2023, 3, 18),
      videoUploadDate: DateTime.now(),
      audioPlaySpeed: 1.5));
}

void addOneDownloadedAudio(Playlist playlist) {
  playlist.addDownloadedAudio(Audio(
      enclosingPlaylist: playlist,
      originalVideoTitle: 'A',
      compactVideoDescription: '',
      videoUrl: 'https://example.com/video1',
      audioDownloadDateTime: DateTime(2023, 3, 20),
      videoUploadDate: DateTime.now(),
      audioPlaySpeed: 1.5));
}

void addOneOtherDownloadedAudio(Playlist playlist) {
  playlist.addDownloadedAudio(Audio(
      enclosingPlaylist: playlist,
      originalVideoTitle: 'B',
      compactVideoDescription: '',
      videoUrl: 'https://example.com/video1',
      audioDownloadDateTime: DateTime(2023, 3, 20),
      videoUploadDate: DateTime.now(),
      audioPlaySpeed: 1.5));
}

void copyOneDownloadedAudio(Playlist playlist) {
  Audio audio = Audio(
      enclosingPlaylist: playlist,
      originalVideoTitle: 'A',
      compactVideoDescription: '',
      videoUrl: 'https://example.com/video1',
      audioDownloadDateTime: DateTime(2023, 3, 20),
      videoUploadDate: DateTime.now(),
      audioPlaySpeed: 1.5);
  audio.audioDownloadSpeed = 1000;
  playlist.addCopiedAudio(
      copiedAudio: audio, copiedFromPlaylistTitle: 'source playlist title');
}

void copyOneOtherDownloadedAudio(Playlist playlist) {
  Audio audio = Audio(
      enclosingPlaylist: playlist,
      originalVideoTitle: 'B',
      compactVideoDescription: '',
      videoUrl: 'https://example.com/video1',
      audioDownloadDateTime: DateTime(2023, 3, 20),
      videoUploadDate: DateTime.now(),
      audioPlaySpeed: 1.5);
  audio.audioDownloadSpeed = 1000;
  playlist.addCopiedAudio(
      copiedAudio: audio, copiedFromPlaylistTitle: 'source playlist title');
}

void moveOneDownloadedAudio(Playlist playlist) {
  Audio audio = Audio(
      enclosingPlaylist: playlist,
      originalVideoTitle: 'A',
      compactVideoDescription: '',
      videoUrl: 'https://example.com/video1',
      audioDownloadDateTime: DateTime(2023, 3, 20),
      videoUploadDate: DateTime.now(),
      audioPlaySpeed: 1.5);
  audio.audioDownloadSpeed = 1000;
  playlist.addMovedAudio(
      movedAudio: audio, movedFromPlaylistTitle: 'source playlist title');
}

void moveOneOtherDownloadedAudio(Playlist playlist) {
  Audio audio = Audio(
      enclosingPlaylist: playlist,
      originalVideoTitle: 'B',
      compactVideoDescription: '',
      videoUrl: 'https://example.com/video1',
      audioDownloadDateTime: DateTime(2023, 3, 20),
      videoUploadDate: DateTime.now(),
      audioPlaySpeed: 1.5);
  audio.audioDownloadSpeed = 1000;
  playlist.addMovedAudio(
      movedAudio: audio, movedFromPlaylistTitle: 'source playlist title');
}
