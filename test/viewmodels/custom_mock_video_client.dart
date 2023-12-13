import 'package:audio_learn/constants.dart';

import 'mock_youtube.mocks.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

/// This class extends the MockVideoClient class generated by
/// the build_runner package based on mock_youtube.dart definitions.
class CustomMockVideoClient extends MockVideoClient {
  @override
  Future<yt.Video> get(dynamic id) async {
    List<String> keywords = ['keyword 1', 'keyword 2', 'keyword 3'];

    yt.Video returnedVideo;

    switch (id.value) {
      case 'invalid_url':
        {
          // if the video url is invalid, instanciating the yt.VideoId
          // in unit test will not throw an ArgumentError, but will return
          // a yt.VideoId instance with a value of 'invalid_url'.
          //
          // So, in order to test the error handling if the video url is
          // invalid, we need to set a channel id that is invalid.
          returnedVideo = yt.Video(
            yt.VideoId('invalid_url'), // Assuming 'id' is a valid video ID
            'Invalid URL video title',
            'Invalid URL author',
            // 'invalid channel id' causes an Exception to be thrown, which
            // causes the false to be returned by
            // AudioDownloadVM.downloadSingleVideoAudio().
            yt.ChannelId('invalid channel id'),
            DateTime.now(),
            englishDateTimeFormat.format(DateTime.now()),
            DateTime.now(),
            'Invalid URL video description',
            const Duration(minutes: 50),
            yt.ThumbnailSet(id.toString()), // Thumbnails
            keywords,
            const yt.Engagement(200, 15, 3),
            false,
            // Add other required fields as necessary
          );

          break;
        }
      case 'v7PWb7f_P8M':
        {
          // if the video url is invalid, instanciating the yt.VideoId
          // in unit test will not throw an ArgumentError, but will return
          // a yt.VideoId instance with a value of 'invalid_url'.
          //
          // So, in order to test the error handling if the video url is
          // invalid, we need to set a channel id that is invalid.
          DateTime uploadAndPublishDate =
              englishDateTimeFormat.parse('2023-06-10 00:00');
          returnedVideo = yt.Video(
            yt.VideoId(id.value), // Assuming 'id' is a valid video ID
            'audio learn test short video one',
            'Jean-Pierre Schnyder',
            yt.ChannelId('UCd11FV1u3nj3RvOgH_s_ckQ'),
            uploadAndPublishDate,
            '2023-06-10 00:00',
            uploadAndPublishDate,
            'Jean-Pierre Schnyder\n\nCette vid\u00e9o me sert \u00e0 tester AudioLearn, l\'app Android que je d\u00e9veloppe et dont le code est disponible sur GitHub. ...',
            const Duration(milliseconds: 24000),
            yt.ThumbnailSet(id.toString()), // Thumbnails
            keywords,
            const yt.Engagement(100, 10, 2),
            false,
            // Add other required fields as necessary
          );

          break;
        }
      default:
        {
          returnedVideo = yt.Video(
            yt.VideoId('invalid_url'), // Assuming 'id' is a valid video ID
            'Invalid URL video title',
            'Invalid URL author',
            // 'invalid channel id' causes an Exception to be thrown, which
            // causes the false to be returned by
            // AudioDownloadVM.downloadSingleVideoAudio().
            yt.ChannelId('invalid channel id'),
            DateTime.now(),
            englishDateTimeFormat.format(DateTime.now()),
            DateTime.now(),
            'Invalid URL video description',
            const Duration(minutes: 50),
            yt.ThumbnailSet(id.toString()), // Thumbnails
            keywords,
            const yt.Engagement(200, 15, 3),
            false,
            // Add other required fields as necessary
          );

          break;
        }
    }

    return returnedVideo;
  }
}
