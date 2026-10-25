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
import 'package:camera/camera.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:steer_wise/src/widgets/camera_preview_box.dart';

const _permissionChannel = MethodChannel(
  'flutter.baseflow.com/permissions/methods',
);
const _cameraChannel = MethodChannel('plugins.flutter.io/camera');

// permission_handler codes: Permission.camera is 1; status 0 is denied and
// 1 is granted.
const _camera = 1;
const _denied = 0;
const _granted = 1;

void main() {
  late int permissionRequests;
  late int cameraQueries;

  void mockPlatform({required int cameraPermission}) {
    permissionRequests = 0;
    cameraQueries = 0;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(_permissionChannel, (call) async {
      if (call.method == 'requestPermissions') {
        permissionRequests++;
        return {_camera: cameraPermission};
      }
      return null;
    });
    messenger.setMockMethodCallHandler(_cameraChannel, (call) async {
      if (call.method == 'availableCameras') {
        cameraQueries++;
        return <Map<String, Object>>[];
      }
      return null;
    });
  }

  tearDown(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(_permissionChannel, null);
    messenger.setMockMethodCallHandler(_cameraChannel, null);
  });

  Widget preview({bool visible = true, ThemeData? theme}) => MaterialApp(
    theme: theme,
    home: Scaffold(
      body: TickerMode(enabled: visible, child: const CameraPreviewBox()),
    ),
  );

  testWidgets('explains when camera access is off', (tester) async {
    mockPlatform(cameraPermission: _denied);

    await tester.pumpWidget(preview());
    await tester.pumpAndSettle();

    expect(find.text('Camera access is off.'), findsOneWidget);
    expect(find.text('Open settings'), findsOneWidget);
    expect(cameraQueries, 0);
  });

  testWidgets('explains when the device has no camera', (tester) async {
    mockPlatform(cameraPermission: _granted);

    await tester.pumpWidget(preview());
    await tester.pumpAndSettle();

    expect(find.text('No camera is available.'), findsOneWidget);
    expect(cameraQueries, 1);
  });

  testWidgets('does not start the camera while hidden', (tester) async {
    mockPlatform(cameraPermission: _granted);

    await tester.pumpWidget(preview(visible: false));
    await tester.pumpAndSettle();

    expect(permissionRequests, 0);
    expect(cameraQueries, 0);
  });

  testWidgets('starts the camera when it becomes visible', (tester) async {
    mockPlatform(cameraPermission: _granted);

    await tester.pumpWidget(preview(visible: false));
    await tester.pumpAndSettle();
    await tester.pumpWidget(preview());
    await tester.pumpAndSettle();

    expect(permissionRequests, 1);
    expect(cameraQueries, 1);
  });

  testWidgets('does not ask again when the theme changes', (tester) async {
    mockPlatform(cameraPermission: _denied);

    await tester.pumpWidget(preview());
    await tester.pumpAndSettle();
    await tester.pumpWidget(preview(theme: ThemeData.dark()));
    await tester.pumpAndSettle();

    expect(permissionRequests, 1);
  });

  group('camera choice', () {
    const front = CameraDescription(
      name: 'front',
      lensDirection: CameraLensDirection.front,
      sensorOrientation: 270,
    );
    const back = CameraDescription(
      name: 'back',
      lensDirection: CameraLensDirection.back,
      sensorOrientation: 90,
    );
    const backWide = CameraDescription(
      name: 'back-wide',
      lensDirection: CameraLensDirection.back,
      sensorOrientation: 90,
    );

    test('picks the camera facing the preferred way', () {
      expect(pickCamera([back, front], CameraLensDirection.front), front);
      expect(pickCamera([front, back], CameraLensDirection.back), back);
    });

    test('falls back to the first camera if none faces that way', () {
      expect(pickCamera([front], CameraLensDirection.back), front);
    });

    test('switches between front and rear', () {
      final cameras = [back, backWide, front];
      expect(
        otherLens(cameras, CameraLensDirection.front),
        CameraLensDirection.back,
      );
      expect(
        otherLens(cameras, CameraLensDirection.back),
        CameraLensDirection.front,
      );
    });

    test('offers no switch when every camera faces the same way', () {
      expect(otherLens([back, backWide], CameraLensDirection.back), isNull);
      expect(otherLens([front], CameraLensDirection.front), isNull);
    });
  });
}
