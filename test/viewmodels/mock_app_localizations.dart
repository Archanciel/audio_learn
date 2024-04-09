import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// This mock class is necessary in order to define two getters
/// which return an empty string. This is necessary to avoid the
/// following error when running the playlist_download_view_test
/// tests:
///
/// ══╡ EXCEPTION CAUGHT BY RENDERING LIBRARY
/// ╞═════════════════════════════════════════════════════════
/// The following assertion was thrown during layout:
/// A RenderFlex overflowed by 44 pixels on the right.
///
/// The relevant error-causing widget was:
/// Row
/// Row:file:///C:/Users/Jean-Pierre/Development/Flutter/
/// audio_learn/lib/views/playlist_download_view.dart:510:28 ...
class MockAppLocalizations extends AppLocalizations {
  MockAppLocalizations() : super('en');

  // Getters changed in mock version. All other methods are the same
  // as the original class AppLocalizationsEn located in
  // audio_learn\.dart_tool\flutter_gen\gen_l10n from which the mock
  // code was copied.

  @override
  // Getter mock version replacing 'One' by ''
  String get downloadSingleVideoAudio => '';

  @override
  // Getter mock version replacing 'Playlist' by ''
  String get downloadSelectedPlaylist => '';

  @override
  String get appBarTitleDownloadAudio => 'Download Audio';

  @override
  String get appBarTitleAudioPlayer => 'Audio Player';

  @override
  String get toggleList => 'Toggle List';

  @override
  String get delete => 'Delete';

  @override
  String get moveItemUp => 'Move item up';

  @override
  String get moveItemDown => 'Move item down';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get french => 'French';

  @override
  String get downloadAudio => 'Download Audio Youtube';

  @override
  String translate(Object language) {
    return 'Select $language';
  }

  @override
  String get musicalQualityTooltip => 'If set, downloads at musical quality';

  @override
  String get ofPreposition => 'of';

  @override
  String get atPreposition => 'at';

  @override
  String get ytPlaylistLinkLabel => 'Youtube Playlist Link';

  @override
  String get ytPlaylistLinkHintText => 'Enter a Youtube playlist link';

  @override
  String get addPlaylist => 'Add';

  @override
  String get renameAudioFileButton => 'Rename';

  @override
  String get stopDownload => 'Stop';

  @override
  String get audioDownloadingStopping => 'Stopping download ...';

  @override
  String audioDownloadError(Object error) {
    return 'Error downloading audio: $error';
  }

  @override
  String get singleVideoAudioDownload =>
      'Downloading single video audio in Various dir';

  @override
  String get about => 'About ...';

  @override
  String get defineSortFilterAudiosSettings => 'Sort/filter audios';

  @override
  String get saveSortFilterAudiosSettingsToPlaylist => 'Sub sort/filter audios';

  @override
  String get sortFilterDialogTitle => 'Sort and Filter Options';

  @override
  String get sortBy => 'Sort by:';

  @override
  String get audioDownloadDate => 'Audio download date';

  @override
  String get videoUploadDate => 'Video upload date';

  @override
  String get audioEnclosingPlaylistTitle => 'Audio playlist title';

  @override
  String get audioDuration => 'Audio duration';

  @override
  String get audioFileSize => 'Audio file size';

  @override
  String get audioMusicQuality => 'Audio music quality';

  @override
  String get audioDownloadSpeed => 'Audio download speed';

  @override
  String get audioDownloadDuration => 'Audio download duration';

  @override
  String get sortAscending => 'Asc';

  @override
  String get sortDescending => 'Desc';

  @override
  String get filterOptions => 'Filter options:';

  @override
  String get videoTitleOrDescription => 'Video title (and description)';

  @override
  String get startDownloadDate => 'Start downl date';

  @override
  String get endDownloadDate => 'End downl date';

  @override
  String get startUploadDate => 'Start upl date';

  @override
  String get endUploadDate => 'End upl date';

  @override
  String get fileSizeRange => 'File Size Range (bytes)';

  @override
  String get start => 'Start';

  @override
  String get end => 'End';

  @override
  String get audioDurationRange => 'Audio duration range (hh:mm)';

  @override
  String get openYoutubeVideo => 'Open Youtube video';

  @override
  String get openYoutubePlaylist => 'Open Youtube playlist';

  @override
  String get apply => 'Apply';

  @override
  String get cancel => 'Cancel';

  @override
  String get deleteAudio => 'Delete audio';

  @override
  String get deleteAudioFromPlaylistAswell =>
      'Delete audio from playlist as well';

  @override
  String deleteAudioFromPlaylistAswellWarning(
      Object audioTitle, Object playlistTitle) {
    return 'If the deleted audio video "$audioTitle" remains in the "$playlistTitle" Youtube playlist, it will be downloaded again the next time you download the playlist !';
  }

  @override
  String get warningDialogTitle => 'WARNING';

  @override
  String updatedPlaylistUrlTitle(Object title) {
    return 'Playlist "$title" URL was updated. The playlist can be downloaded with its new URL.';
  }

  @override
  String addPlaylistTitle(Object title, Object quality) {
    return 'Playlist "$title" of $quality quality added at end of list of playlists.';
  }

  @override
  String invalidPlaylistUrl(Object url) {
    return 'Playlist with invalid URL "$url" neither added nor modified.';
  }

  @override
  String playlistWithUrlAlreadyInListOfPlaylists(Object url, Object title) {
    return 'Playlist "$title" with this URL "$url" is already in the list of playlists and so won\'t be recreated.';
  }

  @override
  String localPlaylistWithTitleAlreadyInListOfPlaylists(Object title) {
    return 'Local playlist "$title" already exists in the list of playlists and so won\'t be recreated.';
  }

  @override
  String downloadAudioYoutubeError(Object exceptionMessage) {
    return 'Error downloading audio from Youtube: "$exceptionMessage"';
  }

  @override
  String downloadAudioYoutubeErrorDueToLiveVideoInPlaylist(
      Object playlistTitle, Object liveVideoString) {
    return 'Error downloading audio from Youtube. The playlist "$playlistTitle" contains a live video which causes the playlist audio downloading failure. To solve the problem, after having downloaded the audio of the live video as explained below, remove the live video from the playlist, then restart the application and retry.\n\nThe live video URL contains the following string: "$liveVideoString". In order to add the live video audio to the playlist "$playlistTitle", download it separately as single video download adding it to the playlist "$playlistTitle".';
  }

  @override
  String downloadAudioFileAlreadyOnAudioDirectory(
      Object audioValidVideoTitle, Object fileName, Object playlistTitle) {
    return 'Audio "$audioValidVideoTitle" is contained in file "$fileName" present in the "$playlistTitle" playlist directory and so won\'t be redownloaded.';
  }

  @override
  String get noInternet => 'No Internet. Please connect your device and retry.';

  @override
  String invalidSingleVideoUUrl(Object url) {
    return 'Single video with invalid URL "$url" could not be downloaded.';
  }

  @override
  String get copyYoutubeVideoUrl => 'Copy Youtube video URL';

  @override
  String get displayAudioInfo => 'Display audio data';

  @override
  String get renameAudioFile => 'Rename audio file';

  @override
  String get moveAudioToPlaylist => 'Move audio to playlist ...';

  @override
  String get copyAudioToPlaylist => 'Copy audio in playlist ...';

  @override
  String get audioInfoDialogTitle => 'Audio Info';

  @override
  String get originalVideoTitleLabel => 'Original video title';

  @override
  String get validVideoTitleLabel => 'Valid video title';

  @override
  String get videoUrlLabel => 'Video URL';

  @override
  String get audioDownloadDateTimeLabel => 'Audio downl date time';

  @override
  String get audioDownloadDurationLabel => 'Audio downl duration';

  @override
  String get audioDownloadSpeedLabel => 'Audio downl speed';

  @override
  String get videoUploadDateLabel => 'Video upload date';

  @override
  String get audioDurationLabel => 'Audio duration';

  @override
  String get audioFileNameLabel => 'Audio file name';

  @override
  String get audioFileSizeLabel => 'Audio file size';

  @override
  String get isMusicQualityLabel => 'Is music quality';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get octetShort => 'B';

  @override
  String get infiniteBytesPerSecond => 'infinite B/sec';

  @override
  String get updatePlaylistJsonFiles => 'Update playlist JSON files';

  @override
  String get compactVideoDescription => 'Compact video description';

  @override
  String get ignoreCase => 'Ignore case';

  @override
  String get searchInVideoCompactDescription => 'Include description';

  @override
  String get on => 'on';

  @override
  String get copyYoutubePlaylistUrl => 'Copy Youtube playlist URL';

  @override
  String get displayPlaylistInfo => 'Display playlist data';

  @override
  String get playlistInfoDialogTitle => 'Playlist Info';

  @override
  String get playlistTitleLabel => 'Playlist title';

  @override
  String get playlistIdLabel => 'Playlist ID';

  @override
  String get playlistUrlLabel => 'Playlist URL';

  @override
  String get playlistDownloadPathLabel => 'Playlist download path';

  @override
  String get playlistLastDownloadDateTimeLabel =>
      'Playlist last downl date time';

  @override
  String get playlistIsSelectedLabel => 'Playlist is selected';

  @override
  String get playlistTotalAudioNumberLabel => 'Playlist total audio number';

  @override
  String get playlistPlayableAudioNumberLabel => 'Playable audio number';

  @override
  String get playlistPlayableAudioTotalDurationLabel =>
      'Playable audio total duration';

  @override
  String get playlistPlayableAudioTotalSizeLabel => 'Playable audio total size';

  @override
  String get updatePlaylistPlayableAudioList => 'Update playable audio list';

  @override
  String updatedPlayableAudioLst(Object number, Object title) {
    return 'Playable audio list for playlist "$title" was updated. $number audio(s) were removed.';
  }

  @override
  String get addYoutubePlaylistDialogTitle => 'Add Playlist';

  @override
  String get addLocalPlaylistDialogTitle => 'Add Playlist';

  @override
  String get renameAudioFileDialogTitle => 'Rename Audio File';

  @override
  String get renameAudioFileDialogComment =>
      'Renaming audio file in order to improve their playing order.';

  @override
  String get youtubePlaylistUrlLabel => 'Youtube playlist URL';

  @override
  String get localPlaylistTitleLabel => 'Local playlist title';

  @override
  String get renameAudioFileLabel => 'Audio file name';

  @override
  String get playlistTypeLabel => 'Playlist type';

  @override
  String get playlistTypeYoutube => 'Youtube';

  @override
  String get playlistTypeLocal => 'Local';

  @override
  String get playlistQualityLabel => 'Playlist quality';

  @override
  String get playlistQualityMusic => 'music';

  @override
  String get playlistQualityAudio => 'audio';

  @override
  String get audioQualityHighSnackBarMessage => 'Download at music quality';

  @override
  String get audioQualityLowSnackBarMessage => 'Download at audio quality';

  @override
  String get add => 'Add';

  @override
  String get noPlaylistSelectedForSingleVideoDownload =>
      'No playlist selected for single video download. Select one playlist and retry ...';

  @override
  String get tooManyPlaylistSelectedForSingleVideoDownload =>
      'More than one playlist selected for single video download. Select only one playlist and retry ...';

  @override
  String get confirmDialogTitle => 'CONFIRMATION';

  @override
  String confirmSingleVideoAudioPlaylistTitle(Object title) {
    return 'Confirm playlist "$title" for downloading single video audio.';
  }

  @override
  String get playlistJsonFileSizeLabel => 'JSON file size';

  @override
  String get playlistOneSelectedDialogTitle => 'Select a playlist';

  @override
  String get confirmButton => 'Confirm';

  @override
  String get enclosingPlaylistLabel => 'Enclosing playlist';

  @override
  String audioNotMovedFromToPlaylist(
      Object audioTitle, Object fromPlaylistTitle, Object toPlaylistTitle) {
    return 'Audio "$audioTitle" NOT moved from playlist "$fromPlaylistTitle" to playlist "$toPlaylistTitle" since it is already present in the destination playlist.';
  }

  @override
  String audioNotCopiedFromToPlaylist(
      Object audioTitle, Object fromPlaylistTitle, Object toPlaylistTitle) {
    return 'Audio "$audioTitle" NOT copied from playlist "$fromPlaylistTitle" to playlist "$toPlaylistTitle" since it is already present in the destination playlist.';
  }

  @override
  String audioMovedFromLocalPlaylistToLocalPlaylist(
      Object audioTitle, Object fromPlaylistTitle, Object toPlaylistTitle) {
    return 'Audio "$audioTitle" moved from local playlist "$fromPlaylistTitle" to local playlist "$toPlaylistTitle".';
  }

  @override
  String audioMovedFromLocalPlaylistToYoutubePlaylist(
      Object audioTitle, Object fromPlaylistTitle, Object toPlaylistTitle) {
    return 'Audio "$audioTitle" moved from local playlist "$fromPlaylistTitle" to Youtube playlist "$toPlaylistTitle".';
  }

  @override
  String audioMovedFromYoutubePlaylistToLocalPlaylistPlaylistWarning(
      Object audioTitle, Object fromPlaylistTitle, Object toPlaylistTitle) {
    return 'Audio "$audioTitle" moved from Youtube playlist "$fromPlaylistTitle" to local playlist "$toPlaylistTitle".\n\nIF THE DELETED AUDIO VIDEO "$audioTitle" REMAINS IN THE "$fromPlaylistTitle" YOUTUBE PLAYLIST, IT WILL BE DOWNLOADED AGAIN THE NEXT TIME YOU DOWNLOAD THE PLAYLIST !';
  }

  @override
  String audioMovedFromYoutubePlaylistToYoutubePlaylistPlaylistWarning(
      Object audioTitle, Object fromPlaylistTitle, Object toPlaylistTitle) {
    return 'Audio "$audioTitle" moved from Youtube playlist "$fromPlaylistTitle" to Youtube playlist "$toPlaylistTitle".\n\nIF THE DELETED AUDIO VIDEO "$audioTitle" REMAINS IN THE "$fromPlaylistTitle" YOUTUBE PLAYLIST, IT WILL BE DOWNLOADED AGAIN THE NEXT TIME YOU DOWNLOAD THE PLAYLIST !';
  }

  @override
  String audioMovedFromYoutubePlaylistToLocalPlaylist(
      Object audioTitle, Object fromPlaylistTitle, Object toPlaylistTitle) {
    return 'Audio "$audioTitle" moved from Youtube playlist "$fromPlaylistTitle" to local playlist "$toPlaylistTitle".';
  }

  @override
  String audioMovedFromYoutubePlaylistToYoutubePlaylist(
      Object audioTitle, Object fromPlaylistTitle, Object toPlaylistTitle) {
    return 'Audio "$audioTitle" moved from Youtube playlist "$fromPlaylistTitle" to Youtube playlist "$toPlaylistTitle".';
  }

  @override
  String audioCopiedFromToPlaylist(
      Object audioTitle, Object fromPlaylistTitle, Object toPlaylistTitle) {
    return 'Audio "$audioTitle" copied from playlist "$fromPlaylistTitle" to playlist "$toPlaylistTitle".';
  }

  @override
  String get author => 'Author:';

  @override
  String get authorName => 'Jean-Pierre Schnyder / Switzerland';

  @override
  String get aboutAppDescription =>
      'This application allows you to download audio from Youtube playlists or from single video links.\n\nThe future version will enable you to listen the audios, to add comments to them and to extract significative portions of the audio and share them or combine them in a new summary audio.';

  @override
  String get keepAudioEntryInSourcePlaylist =>
      'Keep audio entry in source playlist';

  @override
  String get movedFromPlaylistLabel => 'Moved from playlist';

  @override
  String get movedToPlaylistLabel => 'Moved to playlist';

  @override
  String get downloadSingleVideoButtonTooltip => 'Download single video audio';

  @override
  String get addPlaylistButtonTooltip => 'Add Youtube or local playlist';

  @override
  String get stopDownloadingButtonTooltip => 'Stop downloading';

  @override
  String get playlistToggleButtonTooltip => 'Show/hide playlists';

  @override
  String get downloadSelPlaylistsButtonTooltip =>
      'Download audios of selected playlist';

  @override
  String get option1 => 'Option one';

  @override
  String get option2 => 'Option two';

  @override
  String get audioOneSelectedDialogTitle => 'Select an audio';

  @override
  String get audioPositionLabel => 'Audio position';

  @override
  String get audioStateLabel => 'Audio state';

  @override
  String get audioStatePaused => 'Paused';

  @override
  String get audioStatePlaying => 'Playing';

  @override
  String get audioStateStopped => 'Stopped';

  @override
  String get audioStateNotStarted => 'Not started';

  @override
  String get audioPausedDateTimeLabel => 'Date/time paused';

  @override
  String get audioPlaySpeedLabel => 'Play speed';

  @override
  String get audioPlayVolumeLabel => 'Play volume';

  @override
  String audioCopiedFromLocalPlaylistToLocalPlaylist(
      Object audioTitle, Object fromPlaylistTitle, Object toPlaylistTitle) {
    return 'Audio "$audioTitle" copied from local playlist "$fromPlaylistTitle" to local playlist "$toPlaylistTitle".';
  }

  @override
  String audioCopiedFromLocalPlaylistToYoutubePlaylist(
      Object audioTitle, Object fromPlaylistTitle, Object toPlaylistTitle) {
    return 'Audio "$audioTitle" copied from local playlist "$fromPlaylistTitle" to Youtube playlist "$toPlaylistTitle".';
  }

  @override
  String audioCopiedFromYoutubePlaylistToLocalPlaylistPlaylistWarning(
      Object audioTitle, Object fromPlaylistTitle, Object toPlaylistTitle) {
    return 'Audio "$audioTitle" copied from Youtube playlist "$fromPlaylistTitle" to local playlist "$toPlaylistTitle".\n\nIF THE DELETED AUDIO VIDEO "$audioTitle" REMAINS IN THE "$fromPlaylistTitle" YOUTUBE PLAYLIST, IT WILL BE DOWNLOADED AGAIN THE NEXT TIME YOU DOWNLOAD THE PLAYLIST !';
  }

  @override
  String audioCopiedFromYoutubePlaylistToYoutubePlaylistPlaylistWarning(
      Object audioTitle, Object fromPlaylistTitle, Object toPlaylistTitle) {
    return 'Audio "$audioTitle" copied from Youtube playlist "$fromPlaylistTitle" to Youtube playlist "$toPlaylistTitle".\n\nIF THE DELETED AUDIO VIDEO "$audioTitle" REMAINS IN THE "$fromPlaylistTitle" YOUTUBE PLAYLIST, IT WILL BE DOWNLOADED AGAIN THE NEXT TIME YOU DOWNLOAD THE PLAYLIST !';
  }

  @override
  String audioCopiedFromYoutubePlaylistToLocalPlaylist(
      Object audioTitle, Object fromPlaylistTitle, Object toPlaylistTitle) {
    return 'Audio "$audioTitle" copied from Youtube playlist "$fromPlaylistTitle" to local playlist "$toPlaylistTitle".';
  }

  @override
  String audioCopiedFromYoutubePlaylistToYoutubePlaylist(
      Object audioTitle, Object fromPlaylistTitle, Object toPlaylistTitle) {
    return 'Audio "$audioTitle" copied from Youtube playlist "$fromPlaylistTitle" to Youtube playlist "$toPlaylistTitle".';
  }

  @override
  String get copiedFromPlaylistLabel => 'Copied from playlist';

  @override
  String get copiedToPlaylistLabel => 'Copied to playlist';

  @override
  String get audioPlayerViewNoCurrentAudio => 'No audio selected';

  @override
  String get deletePlaylist => 'Delete playlist ...';

  @override
  String deleteYoutubePlaylistDialogTitle(Object title) {
    return 'Delete Youtube Playlist "$title"';
  }

  @override
  String deleteLocalPlaylistDialogTitle(Object title) {
    return 'Delete Local Playlist "$title"';
  }

  @override
  String get deletePlaylistDialogComment =>
      'Deleting the playlist and all its audios as well as its JSON file and its directory.';

  @override
  String get appBarTitleAudioExtractor => 'Audio Extractor';

  @override
  String get setAudioPlaySpeedDialogTitle => 'Playback speed';

  @override
  String get setAudioPlaySpeedTooltip => 'Set audio play speed';

  @override
  String get excludeFullyPlayedAudios => 'Exclude fully played audios';

  @override
  String get increaseAudioVolumeIconButton => 'Increase audio volume';

  @override
  String get decreaseAudioVolumeIconButton => 'Increase audio volume';

  @override
  String get resetSortFilterOptionsTooltip => 'Reset sort and filter options';

  @override
  String get clickToSetAscendingOrDescendingTooltip =>
      'Click to set ascending or descending';

  @override
  String get and => 'And';

  @override
  String get or => 'Or';

  @override
  String get audioTitleSearchSentenceTextFieldTooltip =>
      "Contains a word or a sentence searched on video title and on video description if checkbox 'Include description' is set";

  @override
  String get andSentencesTooltip =>
      "If set, only audio containing all the listed words or sentences are selected";

  @override
  String get orSentencesTooltip =>
      "If set, audio containing one of the listed words or sentences are selected";

  @override
  String get searchInVideoCompactDescriptionTooltip =>
      "If set, search words or sentences are searched on video description as well";

  @override
  String get exclude => "Exclude ";

  @override
  String get fullyPlayed => "fully played ";

  @override
  String get audios => "audios";

  @override
  String get fullyListened => "Fully listened";

  @override
  String get partiallyListened => "Partially listened";

  @override
  String get notListened => "Not listened";

  @override
  String get saveSortFilterOptionsToPlaylistDialogTitle =>
      "Save Sort/Filter Options";

  @override
  String saveSortFilterOptionsToPlaylist(Object title) => "To playlist $title";

  @override
  String saveSortFilterOptionsForView(Object title) => "For $title view";

  @override
  String get saveSortFilterOptionsAutomaticApplication =>
      "Sort/filter options automatic application";

  @override
  String get saveSortFilterOptionsAutomaticApplicationTooltip =>
      "If the automatic application is selected; the sort/filter options stored in the playlist are automatically applied when the playlist is selected.";

  @override
  String get saveSortFilterOptionsAutomaticApplicationAudioPlayerViewTooltip =>
      "If the automatic application is selected; the sort/filter options stored in the playlist are automatically applied when the playlist is selected.";

  @override
  String get saveButton => "Save";

  @override
  String errorInPlaylistJsonFile(Object filePathName) =>
      "File $filePathName contains an invalid data definition. Try finding the problem in order to correct it before executing again the operation.";

  @override
  String youtubePlaylistWithTitleAlreadyInListOfPlaylists(Object title) =>
      "Youtube playlist \"{title}\" already exists in the list of playlists and so a local playlist with this title won't be created.";

  @override
  String get updatePlaylistJsonFilesTooltip =>
      "If one or several playlist directories containing or not audios were manually added to the application data root directory or if audios were manually deleted from one or several playlist directories, this functionality updates the playlist JSON files as well as the application settings JSON file in order to reflect the changes in the application screens.";

  @override
  String get updatePlaylistPlayableAudioListTooltip =>
      "If audios were manually deleted from one or several playlist directories, this functionality updates the playlist JSON files to reflect the changes in the application screens.";

  @override
  String get audioPlayedInThisOrderTooltip =>
      "Les audios sont joués dans cet ordre.";

  @override
  String get playableAudioDialogSortDescriptionTooltipBottomDownloadBefore =>
      "Les audios au bas de l'écran ont été téléchargés avant les audios en haut de l'écran.";

  @override
  String get playableAudioDialogSortDescriptionTooltipBottomDownloadAfter =>
      "Les audios au bas de l'écran ont été téléchargés après les audios en haut de l'écran.";

  @override
  String get playableAudioDialogSortDescriptionTooltipBottomUploadBefore =>
      "Les audios au bas de l'écran ont été téléchargés avant les audios en haut de l'écran.";

  @override
  String get playableAudioDialogSortDescriptionTooltipBottomUploadAfter =>
      "Les audios au bas de l'écran ont été téléchargés après les audios en haut de l'écran.";

  @override
  String get playableAudioDialogSortDescriptionTooltipTopDurationBigger =>
      "Les audios au bas de l'écran ont été téléchargés avant les audios en haut de l'écran.";

  @override
  String get playableAudioDialogSortDescriptionTooltipTopDurationSmaller =>
      "Les audios au bas de l'écran ont été téléchargés après les audios en haut de l'écran.";

  @override
  String get saveAs => "Save as:";

  @override
  String get sortFilterSaveAsTextFieldTooltip =>
      "Saving with the same \"Save as\" name updates the existing sort/filter settings to the modified parameters.";

  @override
  String get applySortFilterToView => "Apply sort/filter to view";

  @override
  String get saveSortFilterOptionsTooltip =>
      "If the name already exists, the existing sort/filter options are updated with the modified parameters.";

  @override
  String get deleteSortFilterOptionsTooltip =>
      "If those sort/filter options are applied in a view, the Default sort/filter options will be applied instead.";

  @override
  String get deleteShort => "Delete";

  @override
  String get applySortFilterToViewTooltip =>
      "Selecting sort/filter application to one or two audio views. This will be applied to the playlists to which this sort/filter is associated.";

  @override
  String get sortFilterParametersDefaultName => "default";

  @override
  String get sortFilterParametersDownloadButtonHint => "Select sort/filter";
}
