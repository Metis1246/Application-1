import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../painters/pose_plank_painter.dart';
import 'detector_view.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.supportedLocales,
      debugShowCheckedModeBanner: false,
      home: PoseDetectorView2(),
    );
  }
}

class PoseDetectorView2 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PoseDetectorViewState();
}

class _PoseDetectorViewState extends State<PoseDetectorView2> {
  final PoseDetector _poseDetector =
      PoseDetector(options: PoseDetectorOptions());
  bool _canProcess = true;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.front;

  final ValueNotifier<Duration> _plankTimeNotifier =
      ValueNotifier<Duration>(Duration.zero);
  final ValueNotifier<int> _countdownNotifier = ValueNotifier<int>(20);

  int _countdown = 10;
  bool _cameraStarted = false;
  bool _isPlankActive = false; // Indicates whether the plank pose is detected
  bool _isStartButtonPressed =
      false; // Tracks if the Start button has been pressed

  @override
  void dispose() {
    _canProcess = false;
    _poseDetector.close();
    _plankTimeNotifier.dispose();
    _countdownNotifier.dispose();
    super.dispose();
  }

  void _startCountdown() {
    Future.delayed(Duration(seconds: 1), () {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
        _startCountdown(); // Recursively countdown until it reaches 0
      } else {
        setState(() {
          _cameraStarted = true; // Start the camera after countdown
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_isStartButtonPressed && _cameraStarted)
            DetectorView(
              title: 'Pose Detector',
              customPaint: _customPaint,
              text: _text,
              onImage: _processImage,
              initialCameraLensDirection: _cameraLensDirection,
              onCameraLensDirectionChanged: (value) =>
                  _cameraLensDirection = value,
            ),
          if (!_isStartButtonPressed)
            Center(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isStartButtonPressed = true;
                  });
                  _startCountdown(); // Start the countdown after pressing the Start button
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Red background
                ),
                child: Text(
                  S.of(context)!.start,
                  style: TextStyle(
                      fontSize: 24, color: Colors.white), // White text
                ),
              ),
            ),
          if (_isStartButtonPressed && !_cameraStarted)
            Center(
              child: Text(
                '$_countdown',
                style: TextStyle(fontSize: 48, color: Colors.red),
              ),
            ),
          if (_isPlankActive) // Show countdown when plank pose is active
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: ValueListenableBuilder<int>(
                  valueListenable: _countdownNotifier,
                  builder: (context, countdown, child) {
                    return Text(
                      'Time: $countdown',
                      style: TextStyle(fontSize: 24, color: Colors.red),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;

    final poses = await _poseDetector.processImage(inputImage);

    if (poses.isEmpty) {
      _text = 'No Pose Detected';
      _isPlankActive = false; // Deactivate plank countdown display
    } else {
      _text = 'Pose Detected';
      _isPlankActive = true; // Activate plank countdown display
    }

    final imageSize = Size(inputImage.metadata?.size.width.toDouble() ?? 0,
        inputImage.metadata?.size.height.toDouble() ?? 0);
    final rotation =
        inputImage.metadata?.rotation ?? InputImageRotation.rotation0deg;

    setState(() {
      _customPaint = CustomPaint(
        painter: PosePlankPainter(
          poses,
          imageSize,
          rotation,
          _cameraLensDirection,
          _plankTimeNotifier,
          _countdownNotifier,
          context,
        ),
      );
    });
  }
}
