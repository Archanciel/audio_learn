import 'package:audio_learn/services/sort_filter_parameters.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:audio_learn/constants.dart';
import 'package:audio_learn/models/audio.dart';
import 'package:audio_learn/services/audio_sort_filter_service.dart';

void main() {
  group('sort audio lst by one SortingOption', () {
    late AudioSortFilterService audioSortFilterService;

    setUp(() {
      audioSortFilterService = AudioSortFilterService();
    });
    test('sort by title', () {
      final Audio zebra = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Zebra ?',
        compactVideoDescription: '',
        validVideoTitle: 'Zebra',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );
      final Audio apple = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Apple ?',
        compactVideoDescription: '',
        validVideoTitle: 'Apple',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );
      final Audio bananna = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Bananna ?',
        compactVideoDescription: '',
        validVideoTitle: 'Bananna',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );

      List<Audio> audioList = [
        zebra,
        apple,
        bananna,
      ];

      List<Audio> expectedResultForTitleAsc = [
        apple,
        bananna,
        zebra,
      ];

      List<Audio> expectedResultForTitleDesc = [
        zebra,
        bananna,
        apple,
      ];

      final List<SortingItem> selectedSortOptionsLstAsc = [
        SortingItem(
          sortingOption: SortingOption.validAudioTitle,
          isAscending: true,
        ),
      ];

      List<Audio> sortedByTitleAsc =
          audioSortFilterService.sortAudioLstBySortingOptions(
        audioLst: List<Audio>.from(audioList), // copy list
        selectedSortOptionsLst: selectedSortOptionsLstAsc,
      );

      expect(
          sortedByTitleAsc.map((audio) => audio.validVideoTitle).toList(),
          equals(expectedResultForTitleAsc
              .map((audio) => audio.validVideoTitle)
              .toList()));

      final List<SortingItem> selectedSortOptionsLstDesc = [
        SortingItem(
          sortingOption: SortingOption.validAudioTitle,
          isAscending: false,
        ),
      ];

      List<Audio> sortedByTitleDesc =
          audioSortFilterService.sortAudioLstBySortingOptions(
        audioLst: List<Audio>.from(audioList), // copy list
        selectedSortOptionsLst: selectedSortOptionsLstDesc,
      );

      expect(
          sortedByTitleDesc.map((audio) => audio.validVideoTitle).toList(),
          equals(expectedResultForTitleDesc
              .map((audio) => audio.validVideoTitle)
              .toList()));
    });

    test('sort by title starting with non language chars', () {
      Audio title = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: "'title",
        compactVideoDescription: 'compactVideoDescription',
        validVideoTitle: "'title",
        videoUrl: 'videoUrl',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(seconds: 1),
        audioDownloadSpeed: 1,
        videoUploadDate: DateTime.now(),
        audioDuration: const Duration(seconds: 1),
        isAudioMusicQuality: true,
        audioPlaySpeed: 1.0,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'audioFileName',
        audioFileSize: 1,
      );

      Audio avecPercentTitle = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: "%avec percent title",
        compactVideoDescription: 'compactVideoDescription',
        validVideoTitle: "%avec percent title",
        videoUrl: 'videoUrl',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(seconds: 1),
        audioDownloadSpeed: 1,
        videoUploadDate: DateTime.now(),
        audioDuration: const Duration(seconds: 1),
        isAudioMusicQuality: true,
        audioPlaySpeed: 1.0,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'audioFileName',
        audioFileSize: 1,
      );

      Audio percentTitle = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: "%percent title",
        compactVideoDescription: 'compactVideoDescription',
        validVideoTitle: "%percent title",
        videoUrl: 'videoUrl',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(seconds: 1),
        audioDownloadSpeed: 1,
        videoUploadDate: DateTime.now(),
        audioDuration: const Duration(seconds: 1),
        isAudioMusicQuality: true,
        audioPlaySpeed: 1.0,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'audioFileName',
        audioFileSize: 1,
      );

      Audio powerTitle = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: "power title",
        compactVideoDescription: 'compactVideoDescription',
        validVideoTitle: "power title",
        videoUrl: 'videoUrl',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(seconds: 1),
        audioDownloadSpeed: 1,
        videoUploadDate: DateTime.now(),
        audioDuration: const Duration(seconds: 1),
        isAudioMusicQuality: true,
        audioPlaySpeed: 1.0,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'audioFileName',
        audioFileSize: 1,
      );

      Audio amenTitle = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: "#'amen title",
        compactVideoDescription: 'compactVideoDescription',
        validVideoTitle: "#'amen title",
        videoUrl: 'videoUrl',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(seconds: 1),
        audioDownloadSpeed: 1,
        videoUploadDate: DateTime.now(),
        audioDuration: const Duration(seconds: 1),
        isAudioMusicQuality: true,
        audioPlaySpeed: 1.0,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'audioFileName',
        audioFileSize: 1,
      );

      Audio epicure = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: "ÉPICURE - La mort n'est rien 📏",
        compactVideoDescription: 'compactVideoDescription',
        validVideoTitle: "ÉPICURE - La mort n'est rien",
        videoUrl: 'videoUrl',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(seconds: 1),
        audioDownloadSpeed: 1,
        videoUploadDate: DateTime.now(),
        audioDuration: const Duration(seconds: 1),
        isAudioMusicQuality: true,
        audioPlaySpeed: 1.0,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'audioFileName',
        audioFileSize: 1,
      );

      Audio ninetyFiveTitle = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: "%95 title",
        compactVideoDescription: 'compactVideoDescription',
        validVideoTitle: "%95 title",
        videoUrl: 'videoUrl',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(seconds: 1),
        audioDownloadSpeed: 1,
        videoUploadDate: DateTime.now(),
        audioDuration: const Duration(seconds: 1),
        isAudioMusicQuality: true,
        audioPlaySpeed: 1.0,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'audioFileName',
        audioFileSize: 1,
      );

      Audio ninetyThreeTitle = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: "93 title",
        compactVideoDescription: 'compactVideoDescription',
        validVideoTitle: "93 title",
        videoUrl: 'videoUrl',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(seconds: 1),
        audioDownloadSpeed: 1,
        videoUploadDate: DateTime.now(),
        audioDuration: const Duration(seconds: 1),
        isAudioMusicQuality: true,
        audioPlaySpeed: 1.0,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'audioFileName',
        audioFileSize: 1,
      );

      Audio ninetyFourTitle = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: "#94 title",
        compactVideoDescription: 'compactVideoDescription',
        validVideoTitle: "#94 title",
        videoUrl: 'videoUrl',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(seconds: 1),
        audioDownloadSpeed: 1,
        videoUploadDate: DateTime.now(),
        audioDuration: const Duration(seconds: 1),
        isAudioMusicQuality: true,
        audioPlaySpeed: 1.0,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'audioFileName',
        audioFileSize: 1,
      );

      Audio echapper = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: "Échapper à l'illusion de l'esprit",
        compactVideoDescription: 'compactVideoDescription',
        validVideoTitle: "Échapper à l'illusion de l'esprit",
        videoUrl: 'videoUrl',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(seconds: 1),
        audioDownloadSpeed: 1,
        videoUploadDate: DateTime.now(),
        audioDuration: const Duration(seconds: 1),
        isAudioMusicQuality: true,
        audioPlaySpeed: 1.0,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'audioFileName',
        audioFileSize: 1,
      );

      Audio evidentTitle = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: "évident title",
        compactVideoDescription: 'compactVideoDescription',
        validVideoTitle: "évident title",
        videoUrl: 'videoUrl',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(seconds: 1),
        audioDownloadSpeed: 1,
        videoUploadDate: DateTime.now(),
        audioDuration: const Duration(seconds: 1),
        isAudioMusicQuality: true,
        audioPlaySpeed: 1.0,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'audioFileName',
        audioFileSize: 1,
      );

      Audio aLireTitle = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: "à lire title",
        compactVideoDescription: 'compactVideoDescription',
        validVideoTitle: "à lire title",
        videoUrl: 'videoUrl',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(seconds: 1),
        audioDownloadSpeed: 1,
        videoUploadDate: DateTime.now(),
        audioDuration: const Duration(seconds: 1),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'audioFileName',
        audioFileSize: 1,
      );

      Audio nineTitle = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: "9 title",
        compactVideoDescription: 'compactVideoDescription',
        validVideoTitle: "9 title",
        videoUrl: 'videoUrl',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(seconds: 1),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: true,
        isPaused: true,
        audioPausedDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioPositionSeconds: 500,
        audioDownloadSpeed: 1,
        videoUploadDate: DateTime.now(),
        audioDuration: const Duration(seconds: 10000),
        audioFileName: 'audioFileName',
        audioFileSize: 1,
      );

      Audio eightTitle = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: "8 title",
        compactVideoDescription: 'compactVideoDescription',
        validVideoTitle: "8 title",
        videoUrl: 'videoUrl',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(seconds: 1),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: true,
        isPaused: true,
        audioPausedDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioPositionSeconds: 500,
        audioDownloadSpeed: 1,
        videoUploadDate: DateTime.now(),
        audioDuration: const Duration(seconds: 10000),
        audioFileName: 'audioFileName',
        audioFileSize: 1,
      );

      Audio eventuelTitle = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: "éventuel title",
        compactVideoDescription: 'compactVideoDescription',
        validVideoTitle: "éventuel title",
        videoUrl: 'videoUrl',
        audioDownloadDateTime: DateTime.now(),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioDownloadDuration: const Duration(seconds: 1),
        audioDownloadSpeed: 1,
        videoUploadDate: DateTime.now(),
        audioDuration: const Duration(seconds: 1),
        audioFileName: 'audioFileName',
        audioFileSize: 1,
      );

      List<Audio?> audioLst = [
        title,
        avecPercentTitle,
        percentTitle,
        powerTitle,
        amenTitle,
        epicure,
        ninetyFiveTitle,
        ninetyThreeTitle,
        ninetyFourTitle,
        echapper,
        evidentTitle,
        aLireTitle,
        nineTitle,
        eightTitle,
        eventuelTitle,
      ];

      List<Audio?> expectedResultForTitleAsc = [
        amenTitle,
        ninetyFourTitle,
        ninetyFiveTitle,
        avecPercentTitle,
        percentTitle,
        title,
        eightTitle,
        nineTitle,
        ninetyThreeTitle,
        powerTitle,
        aLireTitle,
        echapper,
        epicure,
        eventuelTitle,
        evidentTitle,
      ];

      List<Audio?> expectedResultForTitleDesc = [
        evidentTitle,
        eventuelTitle,
        epicure,
        echapper,
        aLireTitle,
        powerTitle,
        ninetyThreeTitle,
        nineTitle,
        eightTitle,
        title,
        percentTitle,
        avecPercentTitle,
        ninetyFiveTitle,
        ninetyFourTitle,
        amenTitle,
      ];

      final List<SortingItem> selectedSortOptionsLstAsc = [
        SortingItem(
          sortingOption: SortingOption.validAudioTitle,
          isAscending: true,
        ),
      ];

      List<Audio> sortedByTitleAsc =
          audioSortFilterService.sortAudioLstBySortingOptions(
        audioLst: List<Audio>.from(audioLst), // copy list
        selectedSortOptionsLst: selectedSortOptionsLstAsc,
      );

      expect(
          sortedByTitleAsc.map((audio) => audio.validVideoTitle).toList(),
          equals(expectedResultForTitleAsc
              .map((audio) => audio!.validVideoTitle)
              .toList()));

      final List<SortingItem> selectedSortOptionsLstDesc = [
        SortingItem(
          sortingOption: SortingOption.validAudioTitle,
          isAscending: false,
        ),
      ];

      List<Audio> sortedByTitleDesc =
          audioSortFilterService.sortAudioLstBySortingOptions(
        audioLst: List<Audio>.from(audioLst), // copy list
        selectedSortOptionsLst: selectedSortOptionsLstDesc,
      );

      expect(
          sortedByTitleDesc.map((audio) => audio.validVideoTitle).toList(),
          equals(expectedResultForTitleDesc
              .map((audio) => audio!.validVideoTitle)
              .toList()));
    });
  });
  group("sort audio lst by multiple SortingOption's", () {
    late AudioSortFilterService audioSortFilterService;

    setUp(() {
      audioSortFilterService = AudioSortFilterService();
    });
    test('sort by duration and title', () {
      final Audio zebra = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Zebra ?',
        compactVideoDescription: '',
        validVideoTitle: 'Zebra',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );
      final Audio apple = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Apple ?',
        compactVideoDescription: '',
        validVideoTitle: 'Apple',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );
      final Audio bananna = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Bananna ?',
        compactVideoDescription: '',
        validVideoTitle: 'Bananna',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 15, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );
      final Audio banannaLonger = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Bananna ?',
        compactVideoDescription: '',
        validVideoTitle: 'Bananna Longer',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 25, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );

      List<Audio> audioList = [
        zebra,
        banannaLonger,
        apple,
        bananna,
      ];

      List<Audio> expectedResultForDurationAscAndTitleAsc = [
        apple,
        zebra,
        bananna,
        banannaLonger,
      ];

      List<Audio> expectedResultForDurationDescAndTitleDesc = [
        banannaLonger,
        bananna,
        zebra,
        apple,
      ];

      final List<SortingItem> selectedSortOptionsLstDurationAscAndTitleAsc = [
        SortingItem(
          sortingOption: SortingOption.audioDuration,
          isAscending: true,
        ),
        SortingItem(
          sortingOption: SortingOption.validAudioTitle,
          isAscending: true,
        ),
      ];

      List<Audio> sortedByTitleAsc =
          audioSortFilterService.sortAudioLstBySortingOptions(
        audioLst: List<Audio>.from(audioList), // copy list
        selectedSortOptionsLst: selectedSortOptionsLstDurationAscAndTitleAsc,
      );

      expect(
          sortedByTitleAsc.map((audio) => audio.validVideoTitle).toList(),
          equals(expectedResultForDurationAscAndTitleAsc
              .map((audio) => audio.validVideoTitle)
              .toList()));

      final List<SortingItem> selectedSortOptionsLstDurationDescAndTitleDesc = [
        SortingItem(
          sortingOption: SortingOption.audioDuration,
          isAscending: false,
        ),
        SortingItem(
          sortingOption: SortingOption.validAudioTitle,
          isAscending: false,
        ),
      ];

      List<Audio> sortedByTitleDesc =
          audioSortFilterService.sortAudioLstBySortingOptions(
        audioLst: List<Audio>.from(audioList), // copy list
        selectedSortOptionsLst: selectedSortOptionsLstDurationDescAndTitleDesc,
      );

      expect(
          sortedByTitleDesc.map((audio) => audio.validVideoTitle).toList(),
          equals(expectedResultForDurationDescAndTitleDesc
              .map((audio) => audio.validVideoTitle)
              .toList()));
    });

  });
  group('filterAndSortAudioLst by title and description', () {
    late AudioSortFilterService audioSortFilterService;

    setUp(() {
      audioSortFilterService = AudioSortFilterService();
    });

    test('with search word in title only', () {
      final Audio zebra1 = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Zebra ?',
        compactVideoDescription: '',
        validVideoTitle: 'Zebra 1',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );
      final Audio apple = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Apple ?',
        compactVideoDescription: '',
        validVideoTitle: 'Apple',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );
      final Audio zebra3 = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Zebra ?',
        compactVideoDescription: '',
        validVideoTitle: 'Zebra 3',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );
      final Audio bananna = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Bananna ?',
        compactVideoDescription: '',
        validVideoTitle: 'Bananna',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );
      final Audio zebra2 = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Zebra ?',
        compactVideoDescription: '',
        validVideoTitle: 'Zebra 2',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );

      List<Audio> audioList = [
        zebra1,
        apple,
        zebra3,
        bananna,
        zebra2,
      ];

      List<Audio> expectedResultForTitleAsc = [
        apple,
        bananna,
        zebra1,
        zebra2,
        zebra3,
      ];

      List<Audio> expectedResultForTitleDesc = [
        zebra3,
        zebra2,
        zebra1,
        bananna,
        apple,
      ];

      final List<SortingItem> selectedSortOptionsLstAsc = [
        SortingItem(
          sortingOption: SortingOption.validAudioTitle,
          isAscending: true,
        ),
      ];

      List<Audio> sortedByTitleAsc =
          audioSortFilterService.sortAudioLstBySortingOptions(
        audioLst: List<Audio>.from(audioList), // copy list
        selectedSortOptionsLst: selectedSortOptionsLstAsc,
      );

      expect(
          sortedByTitleAsc.map((audio) => audio.validVideoTitle).toList(),
          equals(expectedResultForTitleAsc
              .map((audio) => audio.validVideoTitle)
              .toList()));

      final List<SortingItem> selectedSortOptionsLstDesc = [
        SortingItem(
          sortingOption: SortingOption.validAudioTitle,
          isAscending: false,
        ),
      ];

      List<Audio> sortedByTitleDesc =
          audioSortFilterService.sortAudioLstBySortingOptions(
        audioLst: List<Audio>.from(audioList), // copy list
        selectedSortOptionsLst: selectedSortOptionsLstDesc,
      );

      expect(
          sortedByTitleDesc.map((audio) => audio.validVideoTitle).toList(),
          equals(expectedResultForTitleDesc
              .map((audio) => audio.validVideoTitle)
              .toList()));

      List<Audio> expectedResultForFilterSortTitleAsc = [
        zebra1,
        zebra2,
        zebra3,
      ];

      List<Audio> expectedResultForFilterSortTitleDesc = [
        zebra3,
        zebra2,
        zebra1,
      ];

      List<Audio> filteredAndSortedByTitleAsc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
        selectedSortOptionsLst: selectedSortOptionsLstAsc,
        searchWords: 'Zeb',
      );

      expect(
          filteredAndSortedByTitleAsc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          equals(expectedResultForFilterSortTitleAsc
              .map((audio) => audio.validVideoTitle)
              .toList()));

      List<Audio> filteredAndSortedByTitleDesc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
        selectedSortOptionsLst: selectedSortOptionsLstDesc,
        searchWords: 'Zeb',
      );

      expect(
          filteredAndSortedByTitleDesc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          equals(expectedResultForFilterSortTitleDesc
              .map((audio) => audio.validVideoTitle)
              .toList()));
    });
    test('with search word in compact description only', () {
      final Audio zebra1 = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Zebra ?',
        compactVideoDescription: 'Julien Bam',
        validVideoTitle: 'Zebra 1',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );
      final Audio apple = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Apple ?',
        compactVideoDescription: 'description',
        validVideoTitle: 'Apple',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );
      final Audio zebra3 = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Zebra ?',
        compactVideoDescription: 'Julien Bam',
        validVideoTitle: 'Zebra 3',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );
      final Audio bananna = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Bananna ?',
        compactVideoDescription: '',
        validVideoTitle: 'Bananna',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );
      final Audio zebra2 = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Zebra ?',
        compactVideoDescription: 'Julien Goal',
        validVideoTitle: 'Zebra 2',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );

      List<Audio> audioList = [
        zebra1,
        apple,
        zebra3,
        bananna,
        zebra2,
      ];

      List<Audio> expectedResultForFilterSortTitleAsc = [
        zebra1,
        zebra2,
        zebra3,
      ];

      List<Audio> expectedResultForFilterSortTitleDesc = [
        zebra3,
        zebra2,
        zebra1,
      ];

      final List<SortingItem> selectedSortOptionsLstAsc = [
        SortingItem(
          sortingOption: SortingOption.validAudioTitle,
          isAscending: true,
        ),
      ];

      List<Audio> filteredAndSortedByTitleAsc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
        selectedSortOptionsLst: selectedSortOptionsLstAsc,
        searchWords: 'Julien',
        searchInVideoCompactDescription: true,
      );

      expect(
          filteredAndSortedByTitleAsc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          equals(expectedResultForFilterSortTitleAsc
              .map((audio) => audio.validVideoTitle)
              .toList()));

      final List<SortingItem> selectedSortOptionsLstDesc = [
        SortingItem(
          sortingOption: SortingOption.validAudioTitle,
          isAscending: false,
        ),
      ];

      List<Audio> filteredAndSortedByTitleDesc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
        selectedSortOptionsLst: selectedSortOptionsLstDesc,
        searchInVideoCompactDescription: true,
        searchWords: 'Julien',
      );

      expect(
          filteredAndSortedByTitleDesc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          equals(expectedResultForFilterSortTitleDesc
              .map((audio) => audio.validVideoTitle)
              .toList()));
    });
    test('with search word in title and in compact description', () {
      final Audio zebra1 = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Zebra ?',
        compactVideoDescription: 'Julien Bam',
        validVideoTitle: 'Zebra 1',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );
      final Audio apple = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Apple ?',
        compactVideoDescription: 'description',
        validVideoTitle: 'Apple Julien',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );
      final Audio zebra3 = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Zebra ?',
        compactVideoDescription: 'Julien Bam',
        validVideoTitle: 'Zebra 3',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );
      final Audio bananna = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Bananna ?',
        compactVideoDescription: '',
        validVideoTitle: 'Bananna',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );
      final Audio zebra2 = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Zebra ?',
        compactVideoDescription: 'Julien Goal',
        validVideoTitle: 'Zebra 2',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );

      List<Audio> audioList = [
        zebra1,
        apple,
        zebra3,
        bananna,
        zebra2,
      ];

      List<Audio> expectedResultForFilterSortTitleAsc = [
        apple,
        zebra1,
        zebra2,
        zebra3,
      ];

      List<Audio> expectedResultForFilterSortTitleDesc = [
        zebra3,
        zebra2,
        zebra1,
        apple,
      ];

      final List<SortingItem> selectedSortOptionsLstAsc = [
        SortingItem(
          sortingOption: SortingOption.validAudioTitle,
          isAscending: true,
        ),
      ];

      List<Audio> filteredAndSortedByTitleAsc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
        selectedSortOptionsLst: selectedSortOptionsLstAsc,
        searchWords: 'Julien',
        searchInVideoCompactDescription: true,
      );

      expect(
          filteredAndSortedByTitleAsc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          equals(expectedResultForFilterSortTitleAsc
              .map((audio) => audio.validVideoTitle)
              .toList()));

      final List<SortingItem> selectedSortOptionsLstDesc = [
        SortingItem(
          sortingOption: SortingOption.validAudioTitle,
          isAscending: false,
        ),
      ];

      List<Audio> filteredAndSortedByTitleDesc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
        selectedSortOptionsLst: selectedSortOptionsLstDesc,
        searchWords: 'Julien',
        searchInVideoCompactDescription: true,
      );

      expect(
          filteredAndSortedByTitleDesc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          equals(expectedResultForFilterSortTitleDesc
              .map((audio) => audio.validVideoTitle)
              .toList()));
    });
  });
  group('filterAndSortAudioLst by title only', () {
    late AudioSortFilterService audioSortFilterService;

    setUp(() {
      audioSortFilterService = AudioSortFilterService();
    });

    test('with search word in title and in compact description', () {
      final Audio zebra1 = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Zebra ?',
        compactVideoDescription: 'Julien Bam',
        validVideoTitle: 'Zebra 1 Julien',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );
      final Audio apple = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Apple ?',
        compactVideoDescription: 'description',
        validVideoTitle: 'Apple Julien',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );
      final Audio zebra3 = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Zebra ?',
        compactVideoDescription: 'Julien Bam',
        validVideoTitle: 'Zebra 3',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );
      final Audio bananna = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Bananna ?',
        compactVideoDescription: '',
        validVideoTitle: 'Bananna',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );
      final Audio zebra2 = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Zebra ?',
        compactVideoDescription: 'Julien Goal',
        validVideoTitle: 'Zebra 2',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
      );

      List<Audio> audioList = [
        zebra1,
        apple,
        zebra3,
        bananna,
        zebra2,
      ];

      List<Audio> expectedResultForFilterSortTitleAsc = [
        apple,
        zebra1,
      ];

      List<Audio> expectedResultForFilterSortTitleDesc = [
        zebra1,
        apple,
      ];

      final List<SortingItem> selectedSortOptionsLstAsc = [
        SortingItem(
          sortingOption: SortingOption.validAudioTitle,
          isAscending: true,
        ),
      ];

      List<Audio> filteredAndSortedByTitleAsc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
        selectedSortOptionsLst: selectedSortOptionsLstAsc,
        searchWords: 'Julien',
      );

      expect(
          filteredAndSortedByTitleAsc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          equals(expectedResultForFilterSortTitleAsc
              .map((audio) => audio.validVideoTitle)
              .toList()));

      final List<SortingItem> selectedSortOptionsLstDesc = [
        SortingItem(
          sortingOption: SortingOption.validAudioTitle,
          isAscending: false,
        ),
      ];

      List<Audio> filteredAndSortedByTitleDesc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
        selectedSortOptionsLst: selectedSortOptionsLstDesc,
        searchWords: 'Julien',
      );

      expect(
          filteredAndSortedByTitleDesc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          equals(expectedResultForFilterSortTitleDesc
              .map((audio) => audio.validVideoTitle)
              .toList()));
    });
  });
}
