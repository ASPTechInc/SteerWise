/// ------------------------------------------------------------------------
/// SteerWise - Smart Driving Practice App
/// https://github.com/ASPTechInc/SteerWise
///
/// Copyright © 2026 ASPTechnologies Incorporation. All Rights Reserved.
/// Licensed under the MIT License (see LICENSE).
/// ------------------------------------------------------------------------
library;

// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:steer_wise/src/utils/helpers.dart';

enum CameraPreviewStatus { starting, ready, denied, unavailable }

/// Returns the first camera facing [preferred], or the first camera if none
/// faces that way. [cameras] must not be empty.
CameraDescription pickCamera(
  List<CameraDescription> cameras,
  CameraLensDirection preferred,
) => cameras.firstWhere(
  (c) => c.lensDirection == preferred,
  orElse: () => cameras.first,
);

/// Returns the lens direction to switch to from [current], or null if every
/// camera faces the same way.
CameraLensDirection? otherLens(
  List<CameraDescription> cameras,
  CameraLensDirection current,
) {
  for (final camera in cameras) {
    if (camera.lensDirection != current) return camera.lensDirection;
  }
  return null;
}

/// A live camera preview, so learners can watch their hands on the wheel
/// while the phone is mounted facing them.
///
/// It uses the front camera unless the learner switches to the rear one;
/// the choice is saved on the device.
///
/// The camera runs at a low resolution with audio off, and is released
/// whenever it cannot be seen: when the app is in the background, or when
/// an ancestor [TickerMode] is disabled (the bottom navigation does this for
/// tabs that are not showing).
class CameraPreviewBox extends StatefulWidget {
  const CameraPreviewBox({super.key});

  /// Plenty for a small preview, and far lighter than full resolution.
  static const ResolutionPreset resolution = ResolutionPreset.low;

  /// Preferences key for the chosen lens ('front' or 'back').
  static const String lensKey = 'cameraLens';

  @override
  State<CameraPreviewBox> createState() => _CameraPreviewBoxState();
}

class _CameraPreviewBoxState extends State<CameraPreviewBox>
    with WidgetsBindingObserver {
  CameraController? _controller;
  CameraPreviewStatus _status = CameraPreviewStatus.starting;
  List<CameraDescription> _cameras = const [];
  CameraLensDirection? _lens;

  /// Incremented whenever the camera is stopped, so a start that finishes
  /// after the camera was meant to stop is thrown away.
  int _session = 0;

  bool _requestingPermission = false;
  bool _appResumed = true;
  bool? _visible;

  bool get _shouldRun => _appResumed && (_visible ?? false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only react when visibility changes (and on the first build), not to
    // unrelated dependency changes such as a theme switch, which would
    // otherwise ask for camera permission again.
    final visible = TickerMode.valuesOf(context).enabled;
    if (visible == _visible) return;
    _visible = visible;
    _update();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The permission dialog itself makes the app inactive, so ignore
    // lifecycle changes while it is showing.
    if (_requestingPermission) return;
    _appResumed = state == AppLifecycleState.resumed;
    _update();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _session++;
    unawaited(_controller?.dispose());
    super.dispose();
  }

  void _update() {
    if (_shouldRun && _controller == null) {
      unawaited(_start());
    } else if (!_shouldRun && _controller != null) {
      _stop();
    }
  }

  Future<void> _start() async {
    final session = ++_session;
    CameraController? controller;
    try {
      _requestingPermission = true;
      final permission = await Permission.camera.request();
      _requestingPermission = false;
      if (session != _session || !mounted) return;
      if (!permission.isGranted) {
        _setStatus(CameraPreviewStatus.denied);
        return;
      }

      final cameras = await availableCameras();
      if (session != _session || !mounted) return;
      if (cameras.isEmpty) {
        _setStatus(CameraPreviewStatus.unavailable);
        return;
      }

      _cameras = cameras;
      final lens = _lens ??= await _savedLens();
      if (session != _session || !mounted) return;
      controller = CameraController(
        pickCamera(cameras, lens),
        CameraPreviewBox.resolution,
        enableAudio: false,
      );
      _controller = controller;
      await controller.initialize();
      if (session != _session || !mounted) {
        await controller.dispose();
        return;
      }
      _setStatus(CameraPreviewStatus.ready);
    } on CameraException catch (e, stackTrace) {
      if (session != _session || !mounted) return;
      logError('Could not start the camera (${e.code})', e, stackTrace);
      await _discard(controller);
      _setStatus(
        e.code.startsWith('CameraAccess')
            ? CameraPreviewStatus.denied
            : CameraPreviewStatus.unavailable,
      );
    } catch (e, stackTrace) {
      if (session != _session || !mounted) return;
      logError('Could not start the camera', e, stackTrace);
      await _discard(controller);
      _setStatus(CameraPreviewStatus.unavailable);
    } finally {
      _requestingPermission = false;
    }
  }

  Future<CameraLensDirection> _savedLens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(CameraPreviewBox.lensKey);
      return CameraLensDirection.values.firstWhere(
        (lens) => lens.name == saved,
        orElse: () => CameraLensDirection.front,
      );
    } catch (e, stackTrace) {
      logError('Could not read the saved camera choice', e, stackTrace);
      return CameraLensDirection.front;
    }
  }

  Future<void> _switchCamera() async {
    final current = _controller?.description.lensDirection;
    final next = current == null ? null : otherLens(_cameras, current);
    if (next == null) return;
    _lens = next;
    _stop();
    unawaited(_start());
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(CameraPreviewBox.lensKey, next.name);
    } catch (e, stackTrace) {
      logError('Could not save the camera choice', e, stackTrace);
    }
  }

  Future<void> _discard(CameraController? controller) async {
    if (controller == null) return;
    if (_controller == controller) _controller = null;
    await controller.dispose();
  }

  void _stop() {
    _session++;
    final controller = _controller;
    _controller = null;
    if (_status == CameraPreviewStatus.ready) {
      _setStatus(CameraPreviewStatus.starting);
    }
    unawaited(controller?.dispose());
  }

  void _setStatus(CameraPreviewStatus status) {
    if (mounted) setState(() => _status = status);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return switch (_status) {
      CameraPreviewStatus.ready when controller != null => Stack(
        fit: StackFit.expand,
        children: [
          ClipRect(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller.value.previewSize?.height ?? 1,
                height: controller.value.previewSize?.width ?? 1,
                child: CameraPreview(controller),
              ),
            ),
          ),
          if (otherLens(_cameras, controller.description.lensDirection) != null)
            Positioned(
              top: 8,
              right: 8,
              child: IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                  foregroundColor: Colors.white,
                ),
                tooltip:
                    controller.description.lensDirection ==
                        CameraLensDirection.front
                    ? 'Switch to rear camera'
                    : 'Switch to front camera',
                icon: const Icon(Icons.cameraswitch),
                onPressed: () => unawaited(_switchCamera()),
              ),
            ),
        ],
      ),
      CameraPreviewStatus.denied => _Message(
        icon: Icons.no_photography,
        text: 'Camera access is off.',
        action: TextButton(
          onPressed: () => unawaited(openAppSettings()),
          child: const Text('Open settings'),
        ),
      ),
      CameraPreviewStatus.unavailable => const _Message(
        icon: Icons.videocam_off,
        text: 'No camera is available.',
      ),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text, this.action});

  final IconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40),
          const SizedBox(height: 8),
          Text(text),
          ?action,
        ],
      ),
    );
  }
}
