// Mocks generated by Mockito 5.4.4 from annotations
// in audiolearn/test/viewmodels/mock_youtube.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i6;
import 'dart:collection' as _i3;

import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i5;
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as _i2;

import 'mock_youtube.dart' as _i4;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeVideoClient_0 extends _i1.SmartFake implements _i2.VideoClient {
  _FakeVideoClient_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakePlaylistClient_1 extends _i1.SmartFake
    implements _i2.PlaylistClient {
  _FakePlaylistClient_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeChannelClient_2 extends _i1.SmartFake implements _i2.ChannelClient {
  _FakeChannelClient_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeSearchClient_3 extends _i1.SmartFake implements _i2.SearchClient {
  _FakeSearchClient_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeVideoId_4 extends _i1.SmartFake implements _i2.VideoId {
  _FakeVideoId_4(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeChannelId_5 extends _i1.SmartFake implements _i2.ChannelId {
  _FakeChannelId_5(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeThumbnailSet_6 extends _i1.SmartFake implements _i2.ThumbnailSet {
  _FakeThumbnailSet_6(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeUnmodifiableListView_7<E> extends _i1.SmartFake
    implements _i3.UnmodifiableListView<E> {
  _FakeUnmodifiableListView_7(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeEngagement_8 extends _i1.SmartFake implements _i2.Engagement {
  _FakeEngagement_8(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _Fake$VideoCopyWith_9<$Res> extends _i1.SmartFake
    implements _i2.$VideoCopyWith<$Res> {
  _Fake$VideoCopyWith_9(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeStreamClient_10 extends _i1.SmartFake implements _i2.StreamClient {
  _FakeStreamClient_10(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeClosedCaptionClient_11 extends _i1.SmartFake
    implements _i2.ClosedCaptionClient {
  _FakeClosedCaptionClient_11(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeCommentsClient_12 extends _i1.SmartFake
    implements _i2.CommentsClient {
  _FakeCommentsClient_12(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeVideo_13 extends _i1.SmartFake implements _i2.Video {
  _FakeVideo_13(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [YoutubeExplode].
///
/// See the documentation for Mockito's code generation for more information.
class MockYoutubeExplode extends _i1.Mock implements _i4.YoutubeExplode {
  MockYoutubeExplode() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.VideoClient get videos => (super.noSuchMethod(
        Invocation.getter(#videos),
        returnValue: _FakeVideoClient_0(
          this,
          Invocation.getter(#videos),
        ),
      ) as _i2.VideoClient);

  @override
  set videos(_i2.VideoClient? _videos) => super.noSuchMethod(
        Invocation.setter(
          #videos,
          _videos,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i2.PlaylistClient get playlists => (super.noSuchMethod(
        Invocation.getter(#playlists),
        returnValue: _FakePlaylistClient_1(
          this,
          Invocation.getter(#playlists),
        ),
      ) as _i2.PlaylistClient);

  @override
  set playlists(_i2.PlaylistClient? _playlists) => super.noSuchMethod(
        Invocation.setter(
          #playlists,
          _playlists,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i2.ChannelClient get channels => (super.noSuchMethod(
        Invocation.getter(#channels),
        returnValue: _FakeChannelClient_2(
          this,
          Invocation.getter(#channels),
        ),
      ) as _i2.ChannelClient);

  @override
  set channels(_i2.ChannelClient? _channels) => super.noSuchMethod(
        Invocation.setter(
          #channels,
          _channels,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i2.SearchClient get search => (super.noSuchMethod(
        Invocation.getter(#search),
        returnValue: _FakeSearchClient_3(
          this,
          Invocation.getter(#search),
        ),
      ) as _i2.SearchClient);

  @override
  set search(_i2.SearchClient? _search) => super.noSuchMethod(
        Invocation.setter(
          #search,
          _search,
        ),
        returnValueForMissingStub: null,
      );

  @override
  void close() => super.noSuchMethod(
        Invocation.method(
          #close,
          [],
        ),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [YoutubeVideo].
///
/// See the documentation for Mockito's code generation for more information.
class MockYoutubeVideo extends _i1.Mock implements _i4.YoutubeVideo {
  MockYoutubeVideo() {
    _i1.throwOnMissingStub(this);
  }

  @override
  String get url => (super.noSuchMethod(
        Invocation.getter(#url),
        returnValue: _i5.dummyValue<String>(
          this,
          Invocation.getter(#url),
        ),
      ) as String);

  @override
  bool get hasWatchPage => (super.noSuchMethod(
        Invocation.getter(#hasWatchPage),
        returnValue: false,
      ) as bool);

  @override
  _i2.VideoId get id => (super.noSuchMethod(
        Invocation.getter(#id),
        returnValue: _FakeVideoId_4(
          this,
          Invocation.getter(#id),
        ),
      ) as _i2.VideoId);

  @override
  String get title => (super.noSuchMethod(
        Invocation.getter(#title),
        returnValue: _i5.dummyValue<String>(
          this,
          Invocation.getter(#title),
        ),
      ) as String);

  @override
  String get author => (super.noSuchMethod(
        Invocation.getter(#author),
        returnValue: _i5.dummyValue<String>(
          this,
          Invocation.getter(#author),
        ),
      ) as String);

  @override
  _i2.ChannelId get channelId => (super.noSuchMethod(
        Invocation.getter(#channelId),
        returnValue: _FakeChannelId_5(
          this,
          Invocation.getter(#channelId),
        ),
      ) as _i2.ChannelId);

  @override
  String get description => (super.noSuchMethod(
        Invocation.getter(#description),
        returnValue: _i5.dummyValue<String>(
          this,
          Invocation.getter(#description),
        ),
      ) as String);

  @override
  _i2.ThumbnailSet get thumbnails => (super.noSuchMethod(
        Invocation.getter(#thumbnails),
        returnValue: _FakeThumbnailSet_6(
          this,
          Invocation.getter(#thumbnails),
        ),
      ) as _i2.ThumbnailSet);

  @override
  _i3.UnmodifiableListView<String> get keywords => (super.noSuchMethod(
        Invocation.getter(#keywords),
        returnValue: _FakeUnmodifiableListView_7<String>(
          this,
          Invocation.getter(#keywords),
        ),
      ) as _i3.UnmodifiableListView<String>);

  @override
  _i2.Engagement get engagement => (super.noSuchMethod(
        Invocation.getter(#engagement),
        returnValue: _FakeEngagement_8(
          this,
          Invocation.getter(#engagement),
        ),
      ) as _i2.Engagement);

  @override
  bool get isLive => (super.noSuchMethod(
        Invocation.getter(#isLive),
        returnValue: false,
      ) as bool);

  @override
  _i2.$VideoCopyWith<_i2.Video> get copyWith => (super.noSuchMethod(
        Invocation.getter(#copyWith),
        returnValue: _Fake$VideoCopyWith_9<_i2.Video>(
          this,
          Invocation.getter(#copyWith),
        ),
      ) as _i2.$VideoCopyWith<_i2.Video>);
}

/// A class which mocks [VideoClient].
///
/// See the documentation for Mockito's code generation for more information.
class MockVideoClient extends _i1.Mock implements _i4.VideoClient {
  MockVideoClient() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.StreamClient get streamsClient => (super.noSuchMethod(
        Invocation.getter(#streamsClient),
        returnValue: _FakeStreamClient_10(
          this,
          Invocation.getter(#streamsClient),
        ),
      ) as _i2.StreamClient);

  @override
  _i2.ClosedCaptionClient get closedCaptions => (super.noSuchMethod(
        Invocation.getter(#closedCaptions),
        returnValue: _FakeClosedCaptionClient_11(
          this,
          Invocation.getter(#closedCaptions),
        ),
      ) as _i2.ClosedCaptionClient);

  @override
  _i2.CommentsClient get commentsClient => (super.noSuchMethod(
        Invocation.getter(#commentsClient),
        returnValue: _FakeCommentsClient_12(
          this,
          Invocation.getter(#commentsClient),
        ),
      ) as _i2.CommentsClient);

  @override
  _i2.StreamClient get streams => (super.noSuchMethod(
        Invocation.getter(#streams),
        returnValue: _FakeStreamClient_10(
          this,
          Invocation.getter(#streams),
        ),
      ) as _i2.StreamClient);

  @override
  _i2.CommentsClient get comments => (super.noSuchMethod(
        Invocation.getter(#comments),
        returnValue: _FakeCommentsClient_12(
          this,
          Invocation.getter(#comments),
        ),
      ) as _i2.CommentsClient);

  @override
  _i6.Future<_i2.Video> get(dynamic videoId) => (super.noSuchMethod(
        Invocation.method(
          #get,
          [videoId],
        ),
        returnValue: _i6.Future<_i2.Video>.value(_FakeVideo_13(
          this,
          Invocation.method(
            #get,
            [videoId],
          ),
        )),
      ) as _i6.Future<_i2.Video>);

  @override
  _i6.Future<_i2.RelatedVideosList?> getRelatedVideos(_i2.Video? video) =>
      (super.noSuchMethod(
        Invocation.method(
          #getRelatedVideos,
          [video],
        ),
        returnValue: _i6.Future<_i2.RelatedVideosList?>.value(),
      ) as _i6.Future<_i2.RelatedVideosList?>);
}
