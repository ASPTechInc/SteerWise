/// ------------------------------------------------------------------------
/// SteerWise - Smart Driving Practice App
/// https://github.com/ASPTechInc/SteerWise
///
/// Copyright © 2026 ASPTechnologies Incorporation. All Rights Reserved.
/// Licensed under the MIT License (see LICENSE).
/// ------------------------------------------------------------------------
library;

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

// Project imports:
import 'package:steer_wise/src/config/routes.dart';
import 'package:steer_wise/src/providers/theme_provider.dart';
import 'package:steer_wise/src/services/tts_service.dart';
import 'package:steer_wise/src/widgets/speech_unavailable.dart';

const _permissionChannel = MethodChannel(
  'flutter.baseflow.com/permissions/methods',
);
const _cameraChannel = MethodChannel('plugins.flutter.io/camera');
const _ttsChannel = MethodChannel('flutter_tts');

/// Records the URLs the app opens instead of opening them.
class FakeUrlLauncher extends Fake
    with MockPlatformInterfaceMixin
    implements UrlLauncherPlatform {
  final List<String> launched = [];

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> canLaunch(String url) async => true;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launched.add(url);
    return true;
  }
}

/// Fake device: camera access is refused (so no real camera starts), a
/// speech engine is installed and links are recorded rather than opened.
class FakePlatform {
  FakePlatform._();

  /// Text passed to the speech engine, in order.
  final List<String> spoken = [];

  final FakeUrlLauncher urls = FakeUrlLauncher();

  static FakePlatform install() {
    final platform = FakePlatform._();
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    // permission_handler: Permission.camera (1) is denied (0).
    messenger.setMockMethodCallHandler(_permissionChannel, (call) async {
      if (call.method == 'requestPermissions') return {1: 0};
      if (call.method == 'checkPermissionStatus') return 0;
      return null;
    });
    messenger.setMockMethodCallHandler(_cameraChannel, (call) async {
      if (call.method == 'availableCameras') return <Map<String, Object>>[];
      return null;
    });
    messenger.setMockMethodCallHandler(_ttsChannel, (call) async {
      switch (call.method) {
        case 'getEngines':
          return ['org.nobody.multitts'];
        case 'speak':
          platform.spoken.add(call.arguments as String);
          return 1;
        default:
          return 1;
      }
    });
    UrlLauncherPlatform.instance = platform.urls;
    resetSpeechUnavailableNotice();
    addTearDown(() {
      messenger.setMockMethodCallHandler(_permissionChannel, null);
      messenger.setMockMethodCallHandler(_cameraChannel, null);
      messenger.setMockMethodCallHandler(_ttsChannel, null);
    });
    return platform;
  }
}

/// Pumps [home] inside the providers and MaterialApp the screens expect,
/// with the app's named routes.
Future<ThemeProvider> pumpWithProviders(
  WidgetTester tester,
  Widget home, {
  Map<String, Object> savedPrefs = const {},
}) async {
  SharedPreferences.setMockInitialValues(savedPrefs);
  final themeProvider = ThemeProvider(await SharedPreferences.getInstance());
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        Provider(create: (_) => TtsService()),
      ],
      child: MaterialApp(home: home, onGenerateRoute: AppRoutes.generateRoute),
    ),
  );
  return themeProvider;
}

/// Lets real asset loading (such as the question bank or a bundled
/// document) finish; it runs outside the test's fake clock.
Future<void> waitForAssets(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 200)),
  );
  await tester.pump();
}
