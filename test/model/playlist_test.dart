import 'package:flutter_test/flutter_test.dart';

import 'package:audio_learn/models/playlist.dart';
import 'package:audio_learn/services/settings_data_service.dart';
import 'package:audio_learn/models/audio.dart';

void main() {
  group('Testing Playlist add and remove methods', () {
    test('add audio to playlist', () {
      Playlist playlist = Playlist(
        url: 'https://example.com/playlist2',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      addDownloadedAudios(playlist);

      expect(playlist.downloadedAudioLst.length, 3);
      expect(playlist.downloadedAudioLst[0].originalVideoTitle, 'C');
      expect(playlist.downloadedAudioLst[1].originalVideoTitle, 'A');
      expect(playlist.downloadedAudioLst[2].originalVideoTitle, 'B');

      expect(playlist.playableAudioLst.length, 3);
      expect(playlist.playableAudioLst[0].originalVideoTitle, 'B');
      expect(playlist.playableAudioLst[1].originalVideoTitle, 'A');
      expect(playlist.playableAudioLst[2].originalVideoTitle, 'C');
    });

    test('remove audio from downloaded audio list', () {
      Playlist playlist = Playlist(
        url: 'https://example.com/playlist2',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      addDownloadedAudios(playlist);

      expect(playlist.playableAudioLst.length, 3);

      playlist.removeDownloadedAudio(playlist.playableAudioLst[1]);

      expect(playlist.downloadedAudioLst.length, 2);
      expect(playlist.downloadedAudioLst[0].originalVideoTitle, 'C');
      expect(playlist.downloadedAudioLst[1].originalVideoTitle, 'B');

      expect(playlist.playableAudioLst.length, 2);
      expect(playlist.playableAudioLst[0].originalVideoTitle, 'B');
      expect(playlist.playableAudioLst[1].originalVideoTitle, 'C');
    });

    test('remove audio from playalable audio list', () {
      Playlist playlist = Playlist(
        url: 'https://example.com/playlist2',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      addDownloadedAudios(playlist);

      expect(playlist.playableAudioLst.length, 3);
      expect(playlist.downloadedAudioLst[0].originalVideoTitle, 'C');
      expect(playlist.downloadedAudioLst[1].originalVideoTitle, 'A');
      expect(playlist.downloadedAudioLst[2].originalVideoTitle, 'B');

      playlist.removePlayableAudio(playlist.playableAudioLst[1]);

      expect(playlist.downloadedAudioLst.length, 3);
      expect(playlist.playableAudioLst.length, 2);
      expect(playlist.playableAudioLst[0].originalVideoTitle, 'B');
      expect(playlist.playableAudioLst[1].originalVideoTitle, 'C');
    });
  });
  group('Testing Playlist sorting methods', () {
    test('sortDownloadedAudioLst on validVideoTitle ascending', () {
      Playlist playlist = Playlist(
        url: 'https://example.com/playlist1',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      addDownloadedAudios(playlist);

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

      addDownloadedAudios(playlist);

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

      addDownloadedAudios(playlist);

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

      addDownloadedAudios(playlist);

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

      addDownloadedAudios(playlist);

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

      addDownloadedAudios(playlist);

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

      addDownloadedAudios(playlist);

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

      addDownloadedAudios(playlist);

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

void addDownloadedAudios(Playlist playlist) {
  playlist.addDownloadedAudio(Audio(
      enclosingPlaylist: playlist,
      originalVideoTitle: 'C',
      compactVideoDescription: '',
      videoUrl: 'https://example.com/video1',
      audioDownloadDateTime: DateTime(2023, 3, 20),
      videoUploadDate: DateTime.now()));
  playlist.addDownloadedAudio(Audio(
      enclosingPlaylist: playlist,
      originalVideoTitle: 'A',
      compactVideoDescription: '',
      videoUrl: 'https://example.com/video2',
      audioDownloadDateTime: DateTime(2023, 3, 25),
      videoUploadDate: DateTime.now()));
  playlist.addDownloadedAudio(Audio(
      enclosingPlaylist: playlist,
      compactVideoDescription: '',
      originalVideoTitle: 'B',
      videoUrl: 'https://example.com/video3',
      audioDownloadDateTime: DateTime(2023, 3, 18),
      videoUploadDate: DateTime.now()));
}
