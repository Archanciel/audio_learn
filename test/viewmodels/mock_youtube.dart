import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

class YoutubeExplode extends Mock implements yt.YoutubeExplode {}
class YoutubeVideo extends Mock implements yt.Video {}

// Executing dart run build_runner build generates the mock
// classes in the test/viewmodels/mock_youtube.mocks.dart
// file
@GenerateMocks([YoutubeExplode, YoutubeVideo, yt.VideoClient])
void main() {}
