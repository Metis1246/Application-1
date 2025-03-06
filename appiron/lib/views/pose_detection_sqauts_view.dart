import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../painters/pose_squats_painter.dart';
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
      home: PoseDetectorView(),
    );
  }
}

class PoseDetectorView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PoseDetectorViewState();
}

class _PoseDetectorViewState extends State<PoseDetectorView> {
  final PoseDetector _poseDetector =
      PoseDetector(options: PoseDetectorOptions());
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.front;

  final ValueNotifier<int> _squatCountNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> _squat1 = ValueNotifier<int>(0);

  int _countdown = 10;
  bool _cameraStarted = false;
  bool _isStartButtonPressed =
      false; // Variable to track if start button is pressed

  @override
  void dispose() async {
    _canProcess = false;
    _poseDetector.close();
    _squatCountNotifier.dispose();
    _squat1.dispose();
    super.dispose();
  }

  void _startCountdown() {
    Future.delayed(Duration(seconds: 1), () {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
        _startCountdown(); // Recursively call until countdown reaches 0
      } else {
        setState(() {
          _cameraStarted = true; // Start the camera when countdown finishes
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
              child: Container(
                color: Colors.white,
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
            ),
          if (_isStartButtonPressed && _countdown > 0)
            Center(
              child: Text(
                '$_countdown',
                style: TextStyle(fontSize: 48, color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    final poses = await _poseDetector.processImage(inputImage);
    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {
      final painter = PosePainter(
        poses,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        _cameraLensDirection,
        _squatCountNotifier,
        context,
      );
      _customPaint = CustomPaint(painter: painter);
    } else {
      _text = 'Poses found: ${poses.length}\n\n';
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
