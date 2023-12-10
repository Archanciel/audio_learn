import 'package:audio_learn/constants.dart';

import 'mock_youtube.mocks.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

class CustomMockVideoClient extends MockVideoClient {
  @override
  Future<yt.Video> get(dynamic id) async {
    List<String> keywords = ['keyword 1', 'keyword 2', 'keyword 3'];

    return yt.Video(
      yt.VideoId(id.toString()), // Assuming 'id' is a valid video ID
      'CustomMockVideoClient Video Title',
      'CustomMockVideoClient Author',
      yt.ChannelId('CustomMockVideoClient_ChannelId'),
      DateTime.now(),
      frenchDateTimeFormat.format(DateTime.now()),
      DateTime.now(),
      'CustomMockVideoClient video description',
      const Duration(minutes: 50),
      yt.ThumbnailSet(id.toString()), // Thumbnails
      keywords,
      const yt.Engagement(1, 10, 2),
      false,
      // Add other required fields as necessary
    );
  }
}
