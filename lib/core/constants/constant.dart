import 'package:eClassify/app/navigator_observer.dart';
import 'package:eClassify/core/models/system_settings.dart';
import 'package:flutter/material.dart';

final class Constant {
  /// Immutable constants that will never be mutated during runtime

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static final RouteObserver<ModalRoute> routeObserver =
      RouteObserver<ModalRoute>();

  // Must stay a stable singleton, not created inline in a widget's build()
  // — MaterialApp swaps in whatever observer instance it's handed on
  // rebuild, but Navigator doesn't replay past didPush calls to a newly
  // attached observer, so a fresh instance's routeStack silently resets to
  // empty on every rebuild (theme/language changes, etc).
  static final AppNavigatorObserver appNavigatorObserver =
      AppNavigatorObserver();

  static const double horizontalPadding = 16;
  static const double verticalPadding = 20;
  static const double bottomPadding = 20;
  static const double topPadding = 20;
  static const EdgeInsets appContentPadding = EdgeInsets.only(
    left: horizontalPadding,
    right: horizontalPadding,
    top: topPadding,
  );
  static const EdgeInsets safeAreaMinimumPadding = EdgeInsets.only(
    bottom: bottomPadding,
    left: horizontalPadding,
    right: horizontalPadding,
    top: topPadding,
  );

  // Interval for showing native ads in home screen's infinite scrolling
  // ONLY ADD EVEN NUMBERS
  static const int nativeAdsAfterItemNumber = 12;

  // Interstitial ad throttle settings
  static const int interstitialAdTimeDelaySeconds = 60;

  // Max ads shown per session. Set to -1 to disable count-based throttle.
  static const int interstitialAdMaxCountPerSession = 5;

  // This is only to show the actual google map in ad_details_screen.dart
  // It can be set to false in case there are any lags in loading the screen
  static const bool showGoogleMap = true;

  // Set to true to enforce manual terms/privacy acceptance during registration
  static const bool requireTermsConsent = true;

  // Quality requested from the server when rendering remote images.
  // Sent as the `q` query parameter, see [ImageUrlUtils.withImageParams]
  static const int displayImageQuality = 80;

  // Decides whether to use lottie for loading indicator or regular circular indicator
  static const bool useLottieProgress = true;

  // Decides whether to show SEO fields or not during ad posting
  // Disable if you do not wish end users to fill SEO manually or you do not use
  // website
  static const bool showSEOFields = true;

  static const int otpTimeOutSecond = 60;

  ///========================================================================///

  /// Mutable values that are set after the initial API call and remains Immutable
  /// throughout the App's lifecycle
  // Storage path for media downloads
  static String savePath = '';

  static bool isUpdateAvailable = false;
  static String newVersionNumber = "";

  static late SystemSettings systemSettings;
}
