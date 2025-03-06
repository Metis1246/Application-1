import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../painters/pose_pushup_painter.dart';
import 'detector_view.dart';

class PoseDetectorView1 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PoseDetectorViewState();
}

class _PoseDetectorViewState extends State<PoseDetectorView1> {
  final PoseDetector _poseDetector =
      PoseDetector(options: PoseDetectorOptions());
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.front;

  final ValueNotifier<int> _pushUpCountNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> _lastPush = ValueNotifier<int>(0);
  final ValueNotifier<int> _push = ValueNotifier<int>(0);

  int _countdown = 5;
  bool _cameraStarted = false;
  bool _isStartButtonPressed = false;

  @override
  void dispose() async {
    _canProcess = false;
    _poseDetector.close();
    _pushUpCountNotifier.dispose();
    _lastPush.dispose();
    _push.dispose();
    super.dispose();
  }

  void _startCountdown() {
    Future.delayed(Duration(seconds: 1), () {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
        _startCountdown(); // เรียกฟังก์ชันนี้ซ้ำจนกว่าจะนับถึง 0
      } else {
        setState(() {
          _cameraStarted = true; // เมื่อเวลาถอยหลังถึง 0 จะเริ่มต้นกล้อง
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
                    _startCountdown(); // เริ่มนับเวลาถอยหลังหลังจากกดปุ่ม Start
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // พื้นหลังสีแดง
                  ),
                  child: Text(
                    'Start',
                    style: TextStyle(fontSize: 24, color: Colors.white),
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
        _pushUpCountNotifier,
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
