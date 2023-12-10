import 'mock_youtube.mocks.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

/// This class extends the MockYoutubeExplode class generated by
/// the build_runner package.
class CustomYoutubeExplode extends MockYoutubeExplode {
  @override
  yt.VideoClient get videos {
    return MockVideoClient();
  }
}