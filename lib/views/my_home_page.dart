import 'package:audio_learn/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/audio_player_vm.dart';
import '../viewmodels/theme_provider_vm.dart';
import '../services/settings_data_service.dart';
import '../views/widgets/appbar_leading_popup_menu_widget.dart';
import '../views/widgets/appbar_application_right_popup_menu_widget.dart';
import '../views/screen_mixin.dart';
import '../views/playlist_download_view.dart';
import '../views/audio_player_view.dart';
import 'audio_extractor_view.dart';
import '../views/widgets/appbar_title_for_playlist_download_view.dart';
import 'widgets/appbar_title_for_audio_extractor_view.dart';
import 'widgets/appbar_title_for_audio_player_view.dart';

/// Before enclosing Scaffold in MyHomePage, this exception was
/// thrown:
///
/// Exception has occurred.
/// _CastError (Null check operator used on a null value)
///
/// if the AppBar title is obtained that way:
///
///            home: Scaffold(
///              appBar: AppBar(
///                title: Text(AppLocalizations.of(context)!.title),
///
/// The issue occurs because the context provided to the
/// AppLocalizations.of(context) is not yet aware of the
/// localization configuration, as it's being accessed within
/// the same MaterialApp widget where you define the localization
/// delegates and the locale.
///
/// To fix this issue, you can wrap your Scaffold in a new widget,
/// like MyHomePage, which will have access to the correct context.

const Duration pageTransitionDuration = Duration(milliseconds: 20);
const Curve pageTransitionCurve = Curves.ease;

class MyHomePage extends StatefulWidget with ScreenMixin {
  MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  // _pageController is the PageView controller
  final PageController _pageController = PageController();

  final List<IconData> _screenNavigationIconLst = [
    Icons.download,
    Icons.audiotrack,
    Icons.edit,
  ];

  final List<Key> _screenNavigationIconButtonKeyLst = [
    const Key('playlistDownloadViewIconButton'),
    const Key('audioPlayerViewIconButton'),
    const Key('audioExtractorIconButton'),
  ];

  // contains a list of widgets which build the AppBar title. Each
  // widget is specific to the screen currently displayed. This list
  // is filled in the initState() method.
  final List<Widget> _appBarTitleWidgetLst = [];

  // contains the list of screens displayable on the application home
  // page. This list is filled in the initState() method.
  final List<StatefulWidget> _screenWidgetLst = [];

  @override
  void initState() {
    super.initState();

    _appBarTitleWidgetLst.add(
      AppBarTitleForPlaylistDownloadView(),
    );

    _appBarTitleWidgetLst.add(
      const AppBarTitleForAudioPlayerView(),
    );

    _appBarTitleWidgetLst.add(
      AppBarTitleForAudioExtractorView(),
    );

    _screenWidgetLst
        .add(PlaylistDownloadView(onPageChangedFunction: changePage));
    _screenWidgetLst.add(const AudioPlayerView());
    _screenWidgetLst.add(AudioExtractorView());
  }

  @override
  Widget build(BuildContext context) {
    ThemeProviderVM themeProvider = Provider.of<ThemeProviderVM>(
      context,
      listen: false,
    );
    AudioPlayerVM audioGlobalPlayerVM = Provider.of<AudioPlayerVM>(
      context,
      listen: false,
    );

    // This list is used to display the application action icons
    // located in in the AppBar after the AppBar title. The
    // content of the list is the same for all displayable screens
    // since it enables to select the light or dark theme and to
    // select the app language.
    List<Widget> appBarApplicationActionLst = [
      IconButton(
        onPressed: () {
          themeProvider.toggleTheme();
        },
        icon: Icon(themeProvider.currentTheme == AppTheme.dark
            ? Icons.light_mode
            : Icons.dark_mode),
      ),
      AppBarApplicationRightPopupMenuWidget(themeProvider: themeProvider),
    ];

    return Scaffold(
      appBar: AppBar(
        title: _appBarTitleWidgetLst[_currentIndex],
        leading: AppBarLeadingPopupMenuWidget(themeProvider: themeProvider),
        actions: appBarApplicationActionLst,
      ),
      body: Column(
        children: [
          _buildPageView(_screenWidgetLst[_currentIndex]),
          _buildScreenIconButtonRow(audioGlobalPlayerVM),
        ],
      ),
    );
  }

  Expanded _buildPageView(StatefulWidget screenWidget) {
    return Expanded(
      // PageView enables changing screen by dragging
      child: PageView.builder(
        itemCount:
            _screenNavigationIconLst.length, // specifies the number of pages
        //                           that can be swiped by dragging left or right
        controller: _pageController,
        onPageChanged: onPageChangedFunction,
        itemBuilder: (context, index) {
          return screenWidget;
        },
      ),
    );
  }

  Row _buildScreenIconButtonRow(AudioPlayerVM audioGlobalPlayerVM) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _screenNavigationIconLst.asMap().entries.map((entry) {
        return IconButton(
          key: _screenNavigationIconButtonKeyLst[entry.key],
          icon: Icon(entry.value),
          onPressed: () async {
            changePage(entry.key);
          },
          color: _currentIndex == entry.key ? kScreenButtonColor : Colors.grey,
          iconSize:
              27, // Set this if you want to control the icon's visual size
          padding: EdgeInsets
              .zero, // This is crucial to avoid default IconButton padding
        );
      }).toList(),
    );
  }

  /// This function causes PageView to drag to the screen
  /// associated to the passed index.
  void changePage(int index) {
    onPageChangedFunction(index);

    // _pageController is the PageView controller
    _pageController.animateToPage(
      index,
      duration: pageTransitionDuration, // Use constant
      curve: pageTransitionCurve, // Use constant
    );
  }

  /// This function is passed as the onPageChanged: parameter
  /// of the PageView builder. The function is called each time
  /// the PageView drag to another screen.
  void onPageChangedFunction(int index) async {
    if (index == ScreenMixin.AUDIO_PLAYER_VIEW_DRAGGABLE_INDEX) {
      // dragging to the AudioPlayerView screen requires to set
      // the current audio defined on the currently selected playlist.
      await globalAudioGlobalPlayerVM.setCurrentAudioFromSelectedPlaylist();
    }

    setState(() {
      _currentIndex = index;
    });
  }
}
